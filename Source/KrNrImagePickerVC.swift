//
//  KrNrImagePickerVC.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/23.
//

import UIKit
import Photos
class KrNrImagePickerVC: UIViewController {

    private var krnrSlideView:KrNrSlideView?
    private var imageManager:KrNrImageManager!
    private var assets:[String: [PHAsset]]?
    private var nullCell:KrNrCollectionViewCell?
    private var gotAssets = true
    var cacheThumbnail:[UIImage] = []
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        imageManager = KrNrImageManager.shared()
        imageManager.delegate = self
        //setUpUI()
        self.title = "KrNrImagePicker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonClick))
        // Do any additional setup after loading the view.
        
        setupCollectionView()

        permissionCheck()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let cells = myCollectionView.visibleCells
        print("visibleCells count=\(cells.count)")
    }
    
    private func permissionCheck()
    {
        //permission
        //get permission
        let status = PHPhotoLibrary.authorizationStatus()
        print("check PHOTO permission status=\(status.rawValue)")
        if status == .notDetermined  {
            
            PHPhotoLibrary.requestAuthorization({status in
                print("status=\(status.rawValue)")
                if(status == .authorized)
                {
                    self.imageManager.fetchAllPhassets()
                }
                else{
                    //not allow permission
                    print("user not allow PHOTO permission")
                }
                
            })
        }
        else if status != .authorized
        {
            let alertController = UIAlertController (title: "EasyBackup想訪問您的照片", message: "需樣訪問您的照片並且上傳", preferredStyle: .alert)
                        
                        
            let settingsAction = UIAlertAction(title: "允許訪問所有照片", style: .default) { (_) -> Void in
                            
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                                
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        print("below ios 10.0, nothing can do.....")
                    }
                }
                        
            }
                        
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        else{
            print("Permission authorized Before")
            self.imageManager.fetchAllPhassets()
        }
    }
    
    let myCollectionView: UICollectionView = {

        //setup collection layout
        let fullScreenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // 設置每一行的間距
        layout.minimumLineSpacing = 2 // 每一行之間的間距
        layout.minimumInteritemSpacing = 1 //每一個cell之間的最小間距，至少是1
        // 設置每個 cell 的尺寸
        let width = CGFloat(fullScreenSize.width - 6) / 3
        layout.itemSize = CGSize( width: width,height: width)
        print("fullScreenSize=\(fullScreenSize), item size=\(layout.itemSize)")
        // 設置 header 及 footer 的尺寸，也可以用UICollectionViewDelegateFlowLayout設定
        layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        //layout.footerReferenceSize = CGSize(
        //  width: fullScreenSize.width, height: 40)
        
        
        
        //register reuse view, cell, header, footer
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.backgroundColor = .white
        collectionview.register(KrNrCollectionViewCell.self,forCellWithReuseIdentifier: "Cell")
        collectionview.register(UICollectionReusableView.self,forSupplementaryViewOfKind:
            UICollectionElementKindSectionHeader,
          withReuseIdentifier: "Header")
        
        collectionview.register(
          UICollectionReusableView.self,
          forSupplementaryViewOfKind:
            UICollectionElementKindSectionFooter,
          withReuseIdentifier: "Footer")

        return collectionview
    }()
    
    private func setupCollectionView()
    {
        // 設置委任對象
        myCollectionView.delegate = self
        myCollectionView.dataSource = self

        // 加入畫面中
        self.view.addSubview(myCollectionView)
        
        //auto-layout(直接用autolayout設置就好，這樣就無需再考慮navigation bar的高度)
        myCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: myCollectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: myCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: myCollectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: myCollectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        
    }
    
   
    @objc private func closeButtonClick(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    open override func viewWillLayoutSubviews() {
        if let sliderview = krnrSlideView
        {
            if view.bounds.size != sliderview.currentBounds
            {
                print("Screen rotate, update sliderView frame to \(view.bounds)")
                sliderview.updateFrame(bounds: view.bounds, tappedIndex: -1)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension KrNrImagePickerVC : KrNrImageManagerDelegate
{
    func assetsPrepareCompleted(_ assets: [String : [PHAsset]]) {
        
       
        self.assets = assets
        //Notes:
        //if permission got before, process go through here first
        //if lunch app first time, permission not yet got , process go through collectionview delegate first.
        
        if(gotAssets == false)
        {
            print("collectionview check gotAssets EQUAL false, reload data again")
            //FOR first permission got, collectionView delegate callback alreadu passed
            //reloadData again
            DispatchQueue.main.async {
                //got phasset, reload view again
                self.myCollectionView.reloadData()
            }
        }
        
    }
    
}

extension KrNrImagePickerVC : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        guard let _assets = assets else
        {
            print("collectionDelegate-numberOfSections, assets is nil")
            gotAssets = false
            return 0
        }
        gotAssets = true
        return _assets.keys.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = imageManager.sortedDate[section]
        let count = assets?[key]?.count ?? 0
        return count
    }
    
    func getAssetThumbnail(asset: PHAsset, size: CGSize, cell:KrNrCollectionViewCell) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.version = .original
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        //option.isSynchronous = true
        //var thumbnail = UIImage()
        //option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .default, options: option, resultHandler: {(result, info)->Void in

            //DispatchQueue.main.async {
                cell.imageView.image = result
            //}
        })
        //return thumbnail
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 依據前面註冊設置的識別名稱 "Cell" 取得目前使用的 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KrNrCollectionViewCell

        let section = indexPath.section
        let row = indexPath.row
        
        let keyString = imageManager.sortedDate[section]
        //print("(\(section),\(row), key=\(keyString)")
        
        let asset = imageManager.dateGroupAssets[keyString]![row]
        
        // 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
        cell.index = imageManager.serialAssets.index(of: asset)!
        cell.titleLabel.text = "\(cell.index)"
        cell.asset = asset
        cell.imageManager = imageManager
        cell.reloadContents()
        
        
        print("index=\(cell.index), assetID=\(asset.localIdentifier), GET CELL")
        
        
       
        //self.getAssetThumbnail(asset: asset, size: CGSize(width: 150.0, height: 150.0), cell: cell)
        
        

        
        return cell
    }
    
    // 設置 reuse 的 section 的 header 或 footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        
        // 建立 UICollectionReusableView
        var reusableView = UICollectionReusableView()

        // 顯示文字
        let label = UILabel(frame: CGRect(
        x: 0, y: 0,
        width: collectionView.contentSize.width, height: 40))
        label.textAlignment = .center
        label.backgroundColor = .yellow

        
        // header
        if kind == UICollectionElementKindSectionHeader {
            let headerText = imageManager.sortedDate[indexPath.section]
            
            //print("HEADER---\(headerText)")
            // 依據前面註冊設置的識別名稱 "Header" 取得目前使用的 header
            reusableView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "Header",
                    for: indexPath)
            // 設置 header 的內容
            reusableView.backgroundColor = .red
            label.text = headerText;
            label.textColor = .blue
            reusableView.addSubview(label)
        } else if kind == UICollectionElementKindSectionFooter {
            //print("Footer")
            // 依據前面註冊設置的識別名稱 "Footer" 取得目前使用的 footer
            reusableView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionFooter,
                    withReuseIdentifier: "Footer",
                    for: indexPath)
            // 設置 footer 的內容
            reusableView.backgroundColor = .brown
            reusableView.frame.size = CGSize(width: 0.0, height: 0.0)
            //label.text = "Footer";
            //label.textColor = .darkText
           

        }

        
        return reusableView
    }
    
   
}

extension KrNrImagePickerVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let count = myCollectionView.visibleCells.count
        print("scroll...visibleCells(\(count))")
    }
    
    func cellPositionOnScreen(at indexPath:IndexPath, in collectionView: UICollectionView) -> (CGRect?, KrNrCollectionViewCell?)
    {
        guard let targetCell = collectionView.cellForItem(at: indexPath) as? KrNrCollectionViewCell else
        {
            print("error...indexPath=\(indexPath) get cell fail")
            return(nil, nil)
        }
        
        let myRect = targetCell.frame
        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        //算出在螢幕上面的位置，並不是在collection view上的位置
        let cellFrame = CGRect(x: cellPosition.x, y: cellPosition.y, width: myRect.size.width, height: myRect.size.height)
        
        return (cellFrame, targetCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame = collectionView.frame
        print("Selected (section,row)=\(indexPath.section),\(indexPath.row), frame=\(frame)")
        
        let section = indexPath.section
        let row = indexPath.row
        
//        guard let targetCell = collectionView.cellForItem(at: indexPath) as? KrNrCollectionViewCell else
//        {
//            print("error...indexPath=\(indexPath) get cell fail")
//            return
//        }
//
//
//        let myRect = targetCell.frame
//        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
//
        
        let (cellframe, targetcell) = cellPositionOnScreen(at: indexPath, in: collectionView)
        guard let cellFrame = cellframe, let targetCell = targetcell else
        {
            print("error...indexPath=\(indexPath) get cell fail")
            return
        }
        
        //print("selected cell frame=\(cell.frame), cellPosition=\(cellPosition)")
        //print("collectionView frame=\(self.myCollectionView.frame)")
        
        let groupAssets = imageManager.dateGroupAssets
        let keyText = imageManager.sortedDate[section]
        
        let asset = groupAssets[keyText]![row]
        //print("id=\(asset.localIdentifier)")
        
        
        let i = imageManager.serialAssets.firstIndex(of: asset)
        print("total assets count=\(imageManager.serialAssets.count)")
        //print("serial-0 id=\(imageManager.serialAssets[0].localIdentifier)")
        guard let index = i else
        {
            print("error, not found \(asset.localIdentifier)")
            return
        }
        
//        let cellFrame = CGRect(x: cellPosition.x, y: cellPosition.y, width: myRect.size.width, height: myRect.size.height)
        
        
//        let label = UILabel(frame: cellFrame)
//        label.backgroundColor = .orange
//        view.addSubview(label)
//
        
//        let slideVC = KrNrSlideViewController(selected: index, selected: cellFrame)
//        //present it
//        slideVC.view.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.3)
//        let navigationController = UINavigationController(rootViewController: slideVC)
//        self.present(navigationController, animated: false, completion: nil)

//======
        
//        //navigation it
//        self.navigationController?.pushViewController(slideVC, animated: false)
//
        
//======
        print("first selected cell frame=\(cellFrame)")
        krnrSlideView = KrNrSlideView(selected: cellFrame)
        krnrSlideView?.slideDelegate = self
        krnrSlideView!.startCachingBigImage(serialAssets: imageManager.serialAssets, selected: index, window: 100, options: nil)
        
        krnrSlideView!.loadImageToView()
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(krnrSlideView!)
        
        
        //print("view.bounds=\(view.bounds)")
        krnrSlideView!.updateFrame(bounds: view.bounds, tappedIndex: i!)
        
        //讓選中的cell反白，跟照片app一樣
        nullCell = targetCell
        nullCell?.imageView.isHidden = true
        
        let cells = collectionView.visibleCells
        var idx=[Int]()
        for cell in cells
        {
            idx.append((cell as! KrNrCollectionViewCell).index)
        }
        
        print("idx sort=\(idx.sort())")
    
        
        //如果此cell是在可見cells中的第一張or最後一張，就把該cell滾動到螢幕中間。避免使用者馬上滑動下一張或上一張時，
        //在slideTo function中，下一張或上一張會因為找不到cell位置而出錯。
        if(idx.first! == i || idx.last == i)
        {
            print("selcted cell index=\(i), the cell is last or first, scroll it to center.")
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            
            let(cellframe, targetcell) = cellPositionOnScreen(at: indexPath, in: collectionView)
            guard let cellFrame = cellframe, let targetCell = targetcell else
            {
                print("error, get cell fail")
                return
            }
            
            print("new selected cell frame=\(cellFrame)")
            krnrSlideView?.currentCellFrame = cellFrame
        }
        
    }
    
    
}

extension KrNrImagePickerVC:KrNrSlideViewDelegate
{
    
    func slideTo(left: Bool, currentPage:Int) {
        
        print(left ? "<<<===---===(\(currentPage))" : "===---===>>>(\(currentPage)")
        let cells = myCollectionView.visibleCells
        var index=[Int]()
        var targetCell:KrNrCollectionViewCell!
        for cell in cells
        {
            index.append((cell as! KrNrCollectionViewCell).index)
        }
        print("visibleCells ID=\(index.sorted())")
        
        //找出大圖目前在collectionview上面的cell
        targetCell = cells.first(where: { ($0 as! KrNrCollectionViewCell).index ==  currentPage}) as! KrNrCollectionViewCell
        
        //print("targetCell frame=\(targetCell.frame), index=\(targetCell.index)")
        
        //找到cell後，找出他的section AND row
        let indexpath = myCollectionView.indexPath(for: targetCell)
        guard let indexPath = indexpath else
        {
            print("error...Callback slide page, can not find cell indexPath on collectionview")
            return
        }
        //let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KrNrCollectionViewCell
        
        if let nullcell = self.nullCell
        {
            nullcell.imageView.isHidden = false
        }
        
        nullCell = targetCell
        targetCell.imageView.isHidden = true
        //print("path=\(path)")
        
        //var myRect = targetCell.frame
        //var cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        //print("cellPosition=\(cellPosition), scroll it")
        
        
        //透過section AND row, scroll item to top
        myCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        
        //scroll後，算出目前cell的位置
        let myRect = targetCell.frame
        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        
        //通知sliderView，目前的位置，這樣等等大圖動畫消失才可以回到collection view上的感覺。
        krnrSlideView?.currentCellFrame.origin = cellPosition
        
    }
    
    
    
    func imageDisappearComplete() {
        print("callback imageDisappearComplete ")
        if let nullcell = self.nullCell
        {
            nullcell.imageView.isHidden = false
        }
    }
}


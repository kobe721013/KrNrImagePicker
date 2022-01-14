//
//  KrNrImagePickerVC.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/23.
//

import UIKit
import Photos

protocol KrNrAssetSelectedDelegate {
    func check(page:Int, selected:Bool)
}

class KrNrImagePickerVC: UIViewController {

    private var krnrSlideView:KrNrSlideView?
    private var imageManager:KrNrImageManager!
    private var assets:[String: [PHAsset]]?
    private var nullCell:KrNrCollectionViewCell?
    private var gotAssets = true
    private var currentPage = 0
    private var rotateTriggerUpdateFrame = false
    private var selectedAssets = [Int]()
    
    let myCollectionView: UICollectionView = {

        //setup collection layout
        let fullScreenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // line spaceing
        layout.minimumLineSpacing = 2 // each line spacing
        layout.minimumInteritemSpacing = 1 //spacing between cells
        // cell size
        let width = CGFloat(fullScreenSize.width - 6) / 3
        layout.itemSize = CGSize( width: width,height: width)
        KrNrLog.track("Device FullScreenSize=\(fullScreenSize), CollectionView cell size=\(layout.itemSize)")
        // header size
        layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        
        
        
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "KrrN"
        imageManager = KrNrImageManager.shared()
        imageManager.delegate = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonClick))
        // Do any additional setup after loading the view.
        
        setupCollectionView()
        permissionCheck()
        
    }
    
    @objc private func closeButtonClick(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupCollectionView()
    {
        // setup delegate
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
    
    private func permissionCheck()
    {
        //get permission
        let status = PHPhotoLibrary.authorizationStatus()
        
        KrNrLog.track("check PHOTO permission status=\(status)")
        if status == .notDetermined
        {
            //maybe first time to ask permission
            PHPhotoLibrary.requestAuthorization({status in
                KrNrLog.track("requestAuthorization. status=\(status.rawValue)")
                if(status == .authorized)
                {
                    self.imageManager.fetchAllPhassets()
                }
                else
                {
                    //not allow permission
                    KrNrLog.track("user NOT allow PHOTO permission")
                }
                
            })
        }
        else if status != .authorized
        {
            let alertController = UIAlertController (title: "Access your photos?", message: "Need to access your media", preferredStyle: .alert)
                        
                        
            let settingsAction = UIAlertAction(title: "Allow to access all photos?", style: .default) { (_) -> Void in
                            
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                                
                    if #available(iOS 10.0, *)
                    {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            KrNrLog.track("Settings opened: \(success)") // KrNrLog.tracks true
                        })
                    } else {
                        KrNrLog.track("below ios 10.0, nothing can do.....")
                    }
                }
                        
            }
                        
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            KrNrLog.track("Permission authorized BEFORE")
            self.imageManager.fetchAllPhassets()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        if let sliderview = krnrSlideView
        {
            if view.bounds.size != sliderview.currentBounds
            {
                KrNrLog.track("Screen ROTATE, update sliderView frame to \(view.bounds)")
                sliderview.updateFrame(bounds: view.bounds, tappedIndex: -1)
                rotateTriggerUpdateFrame = true
                KrNrLog.track("sliderView updateFrames done. collectionView frame= \(myCollectionView.frame)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if(rotateTriggerUpdateFrame)
        {
            rotateTriggerUpdateFrame = false//turn off flag
            guard let page = krnrSlideView?.currentPage else {
                KrNrLog.track("!!! ERROR !!!, get sliderview page is nil")
                return
            }
            KrNrLog.track("viewDidLayoutSubviews detect Rotate event...currentpage=\(currentPage)")
            
//            DispatchQueue.global().async {
//                sleep(UInt32(1.0))
//                //如果立馬執行，在找cell position，還會停留在上一個狀態(假設原本直轉橫向)，找到的cell position還會是在直向的位置.所以sleep一會兒。
//                DispatchQueue.main.async {
                    self.scrollTo(currentPage: page, completed: self.findCellPosition(for:))
//                }
//            }
        }
    }
    
    func showvisibleCellIds()
    {
        let cells = myCollectionView.visibleCells
        var index=[Int]()
        for cell in cells
        {
            index.append((cell as! KrNrCollectionViewCell).index)
        }
        index = index.sorted()
        KrNrLog.track("frame=\(myCollectionView.frame)... visibleCells ID=\(index)")
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
        //gotAssets的目的是希望collectionView那邊再layout時，發現assets是nil，表示
        //數據還沒拿到，所以collectionView呈現出來是空白的。
        //所以當，assetsPrepareCompleted這一步完成後，表示數據確定拿到了
        //那就重新reload collectionView一次，這樣collectionView就會出現照片
        if(gotAssets == false)
        {
            //reloadData again
            DispatchQueue.main.async {
                KrNrLog.track("got assets NOW, reload collectionView AGAIN")
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
            KrNrLog.track("assets is nil, collectionView's numberOfSections return 0")
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // reuse 'cell'
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! KrNrCollectionViewCell

        let section = indexPath.section
        let row = indexPath.row
        
        let keyString = imageManager.sortedDate[section]
        
        let asset = imageManager.dateGroupAssets[keyString]![row]
        
        
        cell.index = imageManager.serialAssets.index(of: asset)!
        cell.IsSelected = selectedAssets.contains(cell.index)
        cell.delegate = self
        cell.titleLabel.isHidden = (asset.mediaType == .image)
        //cell.titleLabel.text = "\(cell.index)"
        if(asset.mediaType == .video)
        {
            //show video duration
            cell.titleLabel.text = asset.duration.toHumanFormat()
        }
        cell.asset = asset
        cell.imageManager = imageManager
        cell.reloadContents()
        
        
        //KrNrLog.track("index=\(cell.index), assetID=\(asset.localIdentifier), GET CELL")
        return cell
    }
    
    // 設置 reuse 的 section 的 header 或 footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        
        // 建立 UICollectionReusableView
        var reusableView = UICollectionReusableView()

        // show section text. (date string)
        let label = UILabel(frame: CGRect(
        x: 0, y: 0,
        width: collectionView.contentSize.width, height: 40))
        label.textAlignment = .left
        //label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 115.0/255.0, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17.0)

        
        // header
        if kind == UICollectionElementKindSectionHeader {
            let headerText = imageManager.sortedDate[indexPath.section]
            
            //KrNrLog.track("HEADER---\(headerText)")
            // 依據前面註冊設置的識別名稱 "Header" 取得目前使用的 header
            reusableView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "Header",
                    for: indexPath)
            
            if let lbl = reusableView.subviews.first as? UILabel
            {
                // 設置 header 的內容
                lbl.text = headerText;
                lbl.textColor = .purple
            }
            else
            {
                label.text = headerText;
                label.textColor = .purple
                reusableView.addSubview(label)
            }
            
        } else if kind == UICollectionElementKindSectionFooter {
            //KrNrLog.track("Footer")
            // 依據前面註冊設置的識別名稱 "Footer" 取得目前使用的 footer
            reusableView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionFooter,
                    withReuseIdentifier: "Footer",
                    for: indexPath)
            // 設置 footer 的內容
            reusableView.backgroundColor = .brown
            //size is ZERO, hidden it
            reusableView.frame.size = CGSize(width: 0.0, height: 0.0)
        }

        return reusableView
    }
}

extension KrNrImagePickerVC : KrNrAssetSelectedDelegate
{
    public func check(page:Int, selected:Bool)
    {
        guard let targetCell = getCellInstance(by: page) else { return }
        
        targetCell.IsSelected = selected
        if(selected)
        {
            selectedAssets.append(page)
        }
        else
        {
            if let i = selectedAssets.index(of: page)
            {
                selectedAssets.remove(at: i)
            }
            else
            {
                KrNrLog.track("page=\(page) Can not find in selectedAssets ")
            }
        }
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
    
    func cellPositionOnScreen(at indexPath:IndexPath, in collectionView: UICollectionView) -> (CGRect?, KrNrCollectionViewCell?)
    {
        guard let targetCell = collectionView.cellForItem(at: indexPath) as? KrNrCollectionViewCell else
        {
            KrNrLog.track("!!! ERROR !!!...get CELL FAIL by indexPath=\(indexPath) ")
            return(nil, nil)
        }
        
        let myRect = targetCell.frame
        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        //算出在螢幕上面的位置，並不是在collection view上的位置
        let cellFrame = CGRect(x: cellPosition.x, y: cellPosition.y, width: myRect.size.width, height: myRect.size.height)
        
        return (cellFrame, targetCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        KrNrLog.track("Selected Cell at (section,row)=(\(indexPath.section),\(indexPath.row))")
        
        let section = indexPath.section
        let row = indexPath.row
        
        //找出選中的cell，和cell frame，為了要把這個位置傳給sliderview，目的是希望大圖縮小後
        //回到該cell的位置，很像圖片鑲進去一樣的感覺
        let (cellframe, targetcell) = cellPositionOnScreen(at: indexPath, in: collectionView)
        guard let cellFrame = cellframe, let targetCell = targetcell else
        {
            KrNrLog.track("!!! ERROR !!!...Record selected cell frame. BUT get CELL FAIL by indexPath=\(indexPath) ")
            return
        }
        
       
        let groupAssets = imageManager.dateGroupAssets
        let keyText = imageManager.sortedDate[section]
        
        let asset = groupAssets[keyText]![row]
        let i = imageManager.serialAssets.firstIndex(of: asset)
        guard let index = i else
        {
            KrNrLog.track("!!! ERROR !!!...can NOT find index for asset ID= \(asset.localIdentifier)")
            return
        }
        KrNrLog.track("selected CELL asset, index=\(index)")
        
        KrNrLog.track("FIRST selected cell frame=\(cellFrame)")
        krnrSlideView = KrNrSlideView(selected: cellFrame)
        krnrSlideView?.selectedDelegate = self
        krnrSlideView?.selectedAssets = selectedAssets
        guard let krnrsliderview = krnrSlideView else {
            KrNrLog.track("!!!ERROR!!!...krnrSlideView is Nil")
            return
        }
        krnrsliderview.slideDelegate = self
        krnrsliderview.startCachingBigImage(serialAssets: imageManager.serialAssets, selected: index, window: 20, options: nil)
        
        //krnrsliderview.loadImageToView()
        //要把這一個view加在navigationController.view裡面，才會是滿版的sliderview，
        //否則，view依舊會在navigationBar底下，導致krnrsliderview客制的navigationBarView會看不到，被遮住了。
        self.navigationController?.view.addSubview(krnrsliderview)
        //let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        //currentWindow?.addSubview(krnrSlideView!)
        
        
        //KrNrLog.track("view.bounds=\(view.bounds)")
        krnrsliderview.updateFrame(bounds: view.bounds, tappedIndex: i!)
        
        //讓選中的cell反白，跟照片app一樣
        nullCell = targetCell
        nullCell!.imageView.isHidden = true
        
    }
    
    
}

extension KrNrImagePickerVC:KrNrSlideViewDelegate
{
    /*
     * function: findCellPosition.
     * purpose:  find cell position ON screen. when BIG image drag down, the big image will change to small size and the animation will look like the big image embeded into collectionView'cell.
     */
    func findCellPosition1(for currentPage:Int)
    {
        KrNrLog.track("myCollectionView.frame=\(myCollectionView.frame),currentPage=\(currentPage)")
        
        let cells = myCollectionView.visibleCells
        var index=[Int]()
        var targetcell:KrNrCollectionViewCell?
        for cell in cells
        {
            index.append((cell as! KrNrCollectionViewCell).index)
        }
        index = index.sorted()
        KrNrLog.track("visibleCells ID=\(index)")
        
        //找出大圖目前在collectionview上面的cell
        targetcell = cells.first(where: { ($0 as! KrNrCollectionViewCell).index ==  currentPage}) as? KrNrCollectionViewCell
        
        guard let targetCell = targetcell else {
            KrNrLog.track("cant FIND targetCell")
            if let max = index.max()
            {
                let p = myCollectionView.contentOffset
                var rect = CGRect(x: p.x, y: p.y, width: myCollectionView.frame.width, height: myCollectionView.frame.height)
                
                KrNrLog.track("currentPage=\(currentPage), max=\(max)....contentOffset=\(p)")
                if currentPage > max
                {
                    rect.origin.y += myCollectionView.frame.height
                }
                else
                {
                    rect.origin.y -= myCollectionView.frame.height
                }
                KrNrLog.track("scroll to rect=\(rect)")
                
                myCollectionView.scrollRectToVisible(rect, animated: false)
                DispatchQueue.global().async {
                    sleep(UInt32(0.5))
                    DispatchQueue.main.async {
                        self.findCellPosition(for: currentPage)
                    }
                }
            }
            return
        }
        
        //把之前imageview隱藏的cell重新顯示
        if let nullcell = self.nullCell
        {
            nullcell.imageView.isHidden = false
        }
        
        //把目前的target cell的imagevie隱藏起來，做出一個跟photo APP一樣的效果
        //好像collectionview 上被挖一個洞一樣
        nullCell = targetCell
        targetCell.imageView.isHidden = true
        
        //scroll後，算出目前cell的位置
        let myRect = targetCell.frame
        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        
        //通知sliderView，目前的位置，這樣等等大圖動畫消失才可以回到collection view上的感覺。
        krnrSlideView?.currentCellFrame.origin = cellPosition
        KrNrLog.track("cellPosition=\(cellPosition)")
        //showvisibleCellIds()
    }
    
    func getIndexPath(by currentPage:Int) -> IndexPath?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let asset = imageManager.serialAssets[currentPage]
        let key = dateFormatter.string(from: asset.creationDate!)
        
        
        let s = imageManager.sortedDate.index(of: key)
        let r = assets![key]?.index(of: asset)
        guard let section = s, let row = r else
        {
            KrNrLog.track("getIndexPath() ERROR,currentPage=\(currentPage), can not find its indexpath ")
            return nil
        }
        
        let indexpath = IndexPath(row: row, section: section)
        
        return indexpath
    }
    
    func slideTo(currentPage:Int, duplicatedCheck:Bool)
    {
        
        if(self.currentPage == currentPage && duplicatedCheck == true)
        {
            //KrNrLog.track("duplicate CALLED, return")
            return
        }
        
        if(currentPage > (imageManager.serialAssets.count - 1))
        {
            KrNrLog.track("ERROR...slideTo currentPage=\(currentPage), BUT index out of range")
            return
        }
        
        scrollTo(currentPage: currentPage, completed: findCellPosition(for:))
    }
    
    func scrollTo(currentPage:Int, completed: ((Int) -> Void)?)
    {
        KrNrLog.track("scrollTo currentPage=\(currentPage)")
        
        //update current page
        self.currentPage = currentPage
        
        if let indexpath = getIndexPath(by: currentPage)
        {
            KrNrLog.track("myCollectionView frame=\(myCollectionView.frame), Scroll to TOP by indexpath=\(indexpath), ")
            //scroll to top
            myCollectionView.scrollToItem(at: indexpath, at: .top, animated: false)
        
            //scrollToItem() function needs time to scroll. Theorefore, create a thread to wait some seconds and find cell position. otherwise, if scrollToItem() done and find cell immediately
            DispatchQueue.global().async {
                sleep(UInt32(0.2))
                KrNrLog.track("sleep ..... done")
                //and call completed event function to find cell position.
                DispatchQueue.main.async {
                    completed?(currentPage)
                }

            }
            
        }
    }
    
    func getCellInstance(by currentPage:Int) -> KrNrCollectionViewCell?
    {
        guard let indexpath = getIndexPath(by: currentPage) else { return nil }
        guard let targetCell = myCollectionView.cellForItem(at: indexpath) as? KrNrCollectionViewCell else {
            
            KrNrLog.track("ERRIR... find target cell instance fail.")
            return nil
            
        }
        return targetCell
    }
    
    
    func findCellPosition(for currentPage:Int)
    {
        KrNrLog.track("myCollectionView.frame=\(myCollectionView.frame),currentPage=\(currentPage)")
        
       
        guard let targetCell = getCellInstance(by: currentPage) else { return }
        
//        let cells = myCollectionView.visibleCells
//        var index=[Int]()
//        //var targetcell:KrNrCollectionViewCell?
//        for cell in cells
//        {
//            index.append((cell as! KrNrCollectionViewCell).index)
//        }
//        index = index.sorted()
//        KrNrLog.track("visibleCells ID=\(index)")
//
//        //找出大圖目前在collectionview上面的cell
//        targetcell = cells.first(where: { ($0 as! KrNrCollectionViewCell).index ==  currentPage}) as? KrNrCollectionViewCell
//
//        guard let targetCell = targetcell else {
//            KrNrLog.track("cant FIND targetCell")
//            if let max = index.max()
//            {
//                let p = myCollectionView.contentOffset
//                var rect = CGRect(x: p.x, y: p.y, width: myCollectionView.frame.width, height: myCollectionView.frame.height)
//
//                //KrNrLog.track("currentPage=\(currentPage), max=\(max)....contentOffset=\(p)")
//                if currentPage > max
//                {
//                    rect.origin.y += myCollectionView.frame.height
//                    KrNrLog.track("Scroll DONW to search ID=\(currentPage)")
//                }
//                else
//                {
//                    rect.origin.y -= myCollectionView.frame.height
//                    KrNrLog.track("Scroll UP to search ID=\(currentPage)")
//                }
//                //KrNrLog.track("scroll to rect=\(rect)")
//
//                myCollectionView.scrollRectToVisible(rect, animated: false)
//                DispatchQueue.global().async {
//                    sleep(UInt32(0.5))
//                    DispatchQueue.main.async {
//                        //find cell again.
//                        self.findCellPosition(for: currentPage)
//                    }
//                }
//            }
//            return
//        }
        
        //把之前imageview隱藏的cell重新顯示
        if let nullcell = self.nullCell
        {
            nullcell.imageView.isHidden = false
        }
        
        //把目前的target cell的imagevie隱藏起來，做出一個跟photo APP一樣的效果
        //好像collectionview 上被挖一個洞一樣
        nullCell = targetCell
        targetCell.imageView.isHidden = true
        
        //scroll後，算出目前cell的位置
        let myRect = targetCell.frame
        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
        
        //通知sliderView，目前的位置，這樣等等大圖動畫消失才可以回到collection view上的感覺。
        krnrSlideView?.currentCellFrame.origin = cellPosition
        KrNrLog.track("targetcell cellPosition=\(cellPosition)")
        //showvisibleCellIds()
    }
    
    /*
     * function: findCellPosition.
     * purpose:  find cell position ON screen. when BIG image drag down, the big image will change to small size and the animation will look like the big image embeded into collectionView'cell.
     */
//    func findCellPosition(for currentPage:Int)
//    {
//        KrNrLog.track("myCollectionView.frame=\(myCollectionView.frame),currentPage=\(currentPage)")
//
//        let cells = myCollectionView.visibleCells
//        var index=[Int]()
//        var targetcell:KrNrCollectionViewCell?
//        for cell in cells
//        {
//            index.append((cell as! KrNrCollectionViewCell).index)
//        }
//        index = index.sorted()
//        KrNrLog.track("visibleCells ID=\(index)")
//
//        //找出大圖目前在collectionview上面的cell
//        targetcell = cells.first(where: { ($0 as! KrNrCollectionViewCell).index ==  currentPage}) as? KrNrCollectionViewCell
//
//        guard let targetCell = targetcell else {
//            KrNrLog.track("cant FIND targetCell")
//            if let max = index.max()
//            {
//                let p = myCollectionView.contentOffset
//                var rect = CGRect(x: p.x, y: p.y, width: myCollectionView.frame.width, height: myCollectionView.frame.height)
//
//                //KrNrLog.track("currentPage=\(currentPage), max=\(max)....contentOffset=\(p)")
//                if currentPage > max
//                {
//                    rect.origin.y += myCollectionView.frame.height
//                    KrNrLog.track("Scroll DONW to search ID=\(currentPage)")
//                }
//                else
//                {
//                    rect.origin.y -= myCollectionView.frame.height
//                    KrNrLog.track("Scroll UP to search ID=\(currentPage)")
//                }
//                //KrNrLog.track("scroll to rect=\(rect)")
//
//                myCollectionView.scrollRectToVisible(rect, animated: false)
//                DispatchQueue.global().async {
//                    sleep(UInt32(0.5))
//                    DispatchQueue.main.async {
//                        //find cell again.
//                        self.findCellPosition(for: currentPage)
//                    }
//                }
//            }
//            return
//        }
//
//        //把之前imageview隱藏的cell重新顯示
//        if let nullcell = self.nullCell
//        {
//            nullcell.imageView.isHidden = false
//        }
//
//        //把目前的target cell的imagevie隱藏起來，做出一個跟photo APP一樣的效果
//        //好像collectionview 上被挖一個洞一樣
//        nullCell = targetCell
//        targetCell.imageView.isHidden = true
//
//        //scroll後，算出目前cell的位置
//        let myRect = targetCell.frame
//        let cellPosition = self.myCollectionView.convert(myRect.origin, to: self.view)
//
//        //通知sliderView，目前的位置，這樣等等大圖動畫消失才可以回到collection view上的感覺。
//        krnrSlideView?.currentCellFrame.origin = cellPosition
//        KrNrLog.track("cellPosition=\(cellPosition)")
//        //showvisibleCellIds()
//    }
    
    
    func imageDisappearComplete() {
        KrNrLog.track("callback imageDisappearComplete ")
        if let nullcell = self.nullCell
        {
            nullcell.imageView.isHidden = false
        }
        krnrSlideView = nil
    }
}


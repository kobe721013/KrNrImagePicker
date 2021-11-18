//
//  KrNrSlideView.swift
//  KrNrSlideView
//
//  Created by kobe on 17.05.2021.
//  Copyright © 2021 kobe. All rights reserved.
//

import UIKit
import Photos

public protocol KrNrSlideViewDelegate
{
    func slideTo(left: Bool, currentPage:Int)
    func imageDisappearComplete()
    
}

public class KrNrSlideView: UIView {

    private let scrollView:UIScrollView = {
        let sc = UIScrollView(frame: .zero)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.isPagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        return sc
    }()
    
    public var delegate:KrNrSlideViewDelegate?
    public var slideDelegate:KrNrSlideViewDelegate?
    
    private var portritConstraints:[NSLayoutConstraint]!
    private var landscapeConstraints:[NSLayoutConstraint]!
    
    private let navigationBar:UINavigationBar = {
        
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "999")
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(1.0)]
        bar.titleTextAttributes = textAttributes
       
        bar.tintColor = UIColor.red.withAlphaComponent(1.0)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonClick))
        
        navItem.rightBarButtonItem = doneButton
        bar.setItems([navItem], animated: false)
        
        bar.isTranslucent = true
        bar.setBackgroundImage(UIImage(), for: .default)
        //bar.shadowImage = UIImage()
        //bar.backgroundColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        return bar
    }()
    
    private let navigationBarView:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        return view
        
    }()
    
    private func addNavigationBarConstraints()
    {
        navigationBarView.addSubview(navigationBar)// add(navigationBar)
        
        //portitt
        //NSLayoutConstraint(item: bar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        let p1 = NSLayoutConstraint(item: navigationBar, attribute: .leading, relatedBy: .equal, toItem: navigationBarView, attribute: .leading, multiplier: 1.0, constant: 0.0)//.isActive = true
        let p2 = NSLayoutConstraint(item: navigationBar, attribute: .trailing, relatedBy: .equal, toItem: navigationBarView, attribute: .trailing, multiplier: 1.0, constant: 0.0)//.isActive = true
        let p3 = NSLayoutConstraint(item: navigationBar, attribute: .bottom, relatedBy: .equal, toItem: navigationBarView, attribute: .bottom, multiplier: 1.0, constant: 0.0)//.isActive = true
        
        let p4 =  navigationBar.heightAnchor.constraint(equalToConstant: 44)
        
       
        
        self.addSubview(navigationBarView)
        
        let p5 = NSLayoutConstraint(item: navigationBarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
    
        let p6 = NSLayoutConstraint(item: navigationBarView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 1.0)
        let p7 = NSLayoutConstraint(item: navigationBarView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 1.0)
        
        let p8 = navigationBarView.heightAnchor.constraint(equalToConstant: 64)
        
        let contraints = [p1,p2,p3,p4,p5,p6,p7,p8]
        portritConstraints = [p4,p8]
        
        NSLayoutConstraint.activate(contraints)
        
        
        //Lanscape
        let l1 =  navigationBar.heightAnchor.constraint(equalToConstant: 32)
        let l2 = navigationBarView.heightAnchor.constraint(equalToConstant: 32)
        
        landscapeConstraints = [l1, l2]
    }
    
    
//
//    private let navigationBarView:UIView = {
//
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        let bar = UINavigationBar()
//        bar.translatesAutoresizingMaskIntoConstraints = false
//        //bar.backgroundColor = .yellow
//
//
//        let navItem = UINavigationItem(title: "1111")
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonClick))
//
//        navItem.rightBarButtonItem = doneButton
//        bar.setItems([navItem], animated: false)
//        //bar.frame.origin.x = 0
//        //bar.frame.origin.y = 20
//
//
//        view.addSubview(bar)
//        view.backgroundColor = .white
//
////        先做到這邊，決定要自己在collection view上增一個slider view
////        然後，自己搞一個navigation bar，但目前直立的navigation bar(44)會再多加上一個status bar(20)
////        轉成橫的，會變成只有只有navigation bar(高度32)，status bar不見了。要想一下怎麼做這一個邏輯
//        //NSLayoutConstraint(item: bar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
//        NSLayoutConstraint(item: bar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
//        NSLayoutConstraint(item: bar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
//        NSLayoutConstraint(item: bar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
//
//
//
//
//
//        return view
//
//    }()
    
    @objc func doneButtonClick()
    {
        print("iamdone, who call me...")
        //for debug used
        for view in scrollView.subviews
        {
            print("index=\(view.tag), frame=\(view.frame)")
        }
        print("=====")
    }
    
    private var assetsCount:Int = 0
    private var cachImageManager:PHCachingImageManager!
    private var assets:[PHAsset]!
    private var alreadyAnimation = false
    private var currentWindowLastIndex = 150//41
    private var windowSize = 30
    private let sideSpace:CGFloat = 10.0
    private var draggingStart = false
    public var currentCellFrame:CGRect = .zero
    private var beginDraggingOffset:CGFloat = 0.0
    public var currentBounds:CGSize!
    
    
    //scroll window parameter
    var centerIndex = 37//31
    var initWindowFirstIndex:Int
    {
        get
        {
            var from = centerIndex - windowSize / 2
            if from < 0
            {
                from = 0
            }
            
            let maxIndex = assetsCount - 1
            let maxFrom = maxIndex - windowSize
            
            if(from > maxFrom)
            {
                print("orig from value=\(from), changeTo maxFrom=\(maxFrom)")
                from = maxFrom
            }
            return from
        }
    }
    
    var initWindowLastIndex:Int
    {
        get
        {
            var to = centerIndex + windowSize / 2
            if to >= assetsCount
            {
                to = assetsCount - 1
            }
            
            if to < windowSize
            {
                print("initWindowLastIndex < windowSize(\(windowSize), setup value to \(windowSize) ")
                to = windowSize
            }
            return to
        }
    }
    
    private var currentPage:Int
    {
        get
        {
            let page = scrollView.contentOffset.x / scrollView.frame.width
            return Int(page)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(selected cellFrame:CGRect) {
        //give a zero frame, real frame size will update after viewWillLayoytSubviews(call update frame method)
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white.withAlphaComponent(1.0)//UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.0)
        currentCellFrame = cellFrame
        //print("selectedCellFrame=\(selectedCellFrame)")
        cachImageManager = PHCachingImageManager()
        setupScrollView()
        //setupNavigationBar()
        addNavigationBarConstraints()
    }
   
    func setupScrollView() {
        scrollView.backgroundColor = .clear
        
        //scrollview start at x=-10 position
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: frame.size.width + 2 * sideSpace, height: frame.height)
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        //pan
        
         let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        //panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func setupNavigationBar()
    {
        self.addSubview(navigationBarView)
        
        NSLayoutConstraint(item: navigationBarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
    
        NSLayoutConstraint(item: navigationBarView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 1.0).isActive = true
        NSLayoutConstraint(item: navigationBarView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 1.0).isActive = true
        
        navigationBarView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    private func pageToFrameX(page:Int) -> CGFloat
    {
        let x = (bounds.size.width + 2.0 * sideSpace) * CGFloat(page)
        print("pageToFrameX, page=\(page), x=\(x)")
        return x
    }
    
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
   
    var newAlpha:CGFloat = 1.0
    var origXRatio:CGFloat = 0.0
    var origYRatio:CGFloat = 0.0
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        
        let page = currentPage
        print("currentPage=\(page)")
        
        if let sliderView = scrollView.subviews.filter{ $0.tag == page }.first
        {
           // sliderView.backgroundColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 0.3)
            let subView = ((sliderView) as! KrNrZoomScrollView).imageView!
            //print("panGestureAction")
            //print("subView.tag = \(subView.tag)")
            
            
            let translation = panGesture.translation(in: subView)
            print("translation=\(translation), current bounds=\(currentBounds)")
            
            if panGesture.state == .began {
                originalPosition = subView.center
                currentPositionTouched = panGesture.location(in: subView)
                
                origXRatio = self.currentPositionTouched!.x / currentBounds.width
                origYRatio = self.currentPositionTouched!.y / currentBounds.height
                print("begin - originalPosition(subView.center)=\(originalPosition), currentPositionTouched=\(currentPositionTouched), origXRatio=\(origXRatio), origYRatio=\(origYRatio)")
            } else if panGesture.state == .changed {
                
                let newHeight = currentBounds.height - translation.y
                let newWidth = newHeight * xyRatio
                print("newHeight=\(newHeight), newWidth=\(newWidth)")
                subView.frame.size = CGSize(width: newWidth, height: newHeight)
                
                let fingerPositionX = self.currentPositionTouched!.x + translation.x
                let fingerPositionY = self.currentPositionTouched!.y + translation.y
                print("fingerPosition=(\(fingerPositionX), \(fingerPositionY)")
                
                let x = (CGFloat(page) * self.scrollView.frame.width + translation.x)
                
                subView.frame.origin.x = fingerPositionX - (newWidth * origXRatio)
                subView.frame.origin.y = fingerPositionY - (newHeight * origYRatio)
                print("changeed...frame=\(subView.frame)...alpha=\(newAlpha)")
//                subView.frame.origin = CGPoint(
//                    x: translation.x,//subView.frame.origin.x,//x,
//                    y: translation.y
//                )
                
                
                
                
                
                //opacity
                newAlpha = ((newAlpha - 0.05) <= 0.0) ? 0.0 : (newAlpha - 0.05)
                self.backgroundColor = UIColor.white.withAlphaComponent(newAlpha)
                navigationBarView.backgroundColor = UIColor.white.withAlphaComponent(newAlpha)
                let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(newAlpha)]
                navigationBar.titleTextAttributes = textAttributes
                navigationBar.tintColor = UIColor.red.withAlphaComponent(newAlpha)
                
                
                
            } else if panGesture.state == .ended {
              let velocity = panGesture.velocity(in: subView)

              if velocity.y >= 1500 {
                
                
                UIView.animate(withDuration: 0.5
                  , animations: {
                    
                    //opacity
                    self.backgroundColor = UIColor.white.withAlphaComponent(0.0)
                    self.navigationBarView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
                    let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(0.0)]
                    self.navigationBar.titleTextAttributes = textAttributes
                    self.navigationBar.tintColor = UIColor.red.withAlphaComponent(0.0)
                    
                    let x = self.pageToFrameX(page: self.currentPage)
                    subView.frame = self.currentCellFrame
                    subView.contentMode = .scaleAspectFill
                    subView.clipsToBounds = true
                
                    print("subView frame change to=\(subView.frame)")
                    

                  }, completion: { (isCompleted) in
                    if isCompleted {

                        //ready to dismiss view controller
                        print("dismiss it...")
                        self.slideDelegate?.imageDisappearComplete()
                        self.removeFromSuperview()
                      //self.dismiss(animated: false, completion: nil)
                    }
                })
              } else {
                print("rollback to originalPosition=\(originalPosition!)")
                self.newAlpha = 1.0
                UIView.animate(withDuration: 0.2, animations: {
                    subView.frame.size = self.currentBounds
                    subView.center = self.originalPosition!
                    subView.contentMode = .scaleAspectFit
                    
                    self.backgroundColor = UIColor.white.withAlphaComponent(1.0)
                    self.navigationBarView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
                    let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(1.0)]
                    self.navigationBar.titleTextAttributes = textAttributes
                    self.navigationBar.tintColor = UIColor.red.withAlphaComponent(1.0)
                })
              }
            }
            
            
        
        }
        
        
      }
    
    
    func startCachingBigImage(serialAssets:[PHAsset], selected centerIndex: Int, window bufferSize: Int, options: PHImageRequestOptions?)
    {
        self.assetsCount = serialAssets.count
        self.windowSize = bufferSize
        self.centerIndex = centerIndex
        self.assets = serialAssets
        
        print("startCachingBigImage，centerIndex=\(centerIndex), bufferSize=\(bufferSize), assetsCount=\(assetsCount)")
        
       
        let to = initWindowLastIndex
        currentWindowLastIndex = to
        self.currentWindowLastIndex = to
        
        let from = initWindowFirstIndex
        
        print("startCachingBigImage, from(\(from)) ~ to(\(to))")
        var waitAssets = [PHAsset]()
        waitAssets.append(serialAssets[centerIndex])

        
        var myoptions = options
        if myoptions == nil
        {
            myoptions = PHImageRequestOptions()
            myoptions!.resizeMode = .fast
            myoptions!.deliveryMode = .highQualityFormat
        }

        let targetSize = CGSize(width: UIScreen.main.bounds.width*3, height: UIScreen.main.bounds.height*3)//PHImageManagerMaximumSize
       cachImageManager.startCachingImages(for: waitAssets, targetSize: targetSize, contentMode: .default, options: myoptions)
    }
    
    
    public func loadImageToView()
    {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        

        
        var range = Array(initWindowFirstIndex...initWindowLastIndex)
        let targetSize = CGSize(width: UIScreen.main.bounds.width*3, height: UIScreen.main.bounds.height*3)//PHImageManagerMaximumSize

        print("loadImageToView, index from (\(range.first!)) ~ (\(range.last!))")
        
        //move centerIndex to first position
        range = range.filter { $0 != centerIndex}
        range.insert(centerIndex, at: 0)
        print("request image, range order=\(range), centerIndex=\(centerIndex)")
        print("request targetSize=\(targetSize)")
        
        //===
        
        
        //===
        let diff = (centerIndex - initWindowFirstIndex)
        for index in range
        {
            //hope insert order is asc(0,1,2,3...10)
            let asset = assets[index]
            let view = KrNrZoomScrollView(frame: frame)
            view.tag = index
            
            //scroll item insert into scrollview, index order must be ASC(ex: 0,1,2,3,4,5,6,7,8,9)
            let x = centerIndex - index
            let p = diff - x
            
            //print("index=\(index), insert to position=\(p)")
            
            self.insertScrollItem(item: view, at: p, index: index)
            
            
            autoreleasepool(invoking: {
                cachImageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in

                   
                    view.image = image
                    print("windos size=\(self.windowSize), requestImage callback to update index=\(index)...size=\(String(describing: image?.size)), id=\(asset.localIdentifier), tempImage size=\(MemoryLayout.size(ofValue: image))")

                })
            
            })
            
           
        }
        
        //update scrollview 'contentSIze' & 'contentOffset'
        let unitItemSize = bounds.size.width + sideSpace * 2.0
        scrollView.contentSize = CGSize(width: CGFloat(assetsCount)*unitItemSize, height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(centerIndex)*unitItemSize, y: self.scrollView.contentOffset.y)
        
        print("scrollView each item, unitItemSize=\(unitItemSize), contentSize=\(scrollView.contentSize), contentOffset=\(scrollView.contentOffset)")
    }
    
   
    
    private func addViewToIndex(view:UIView, index:Int) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        scrollView.addSubview(view)
        
        view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        
//        print("==== now scrollView has views =====")
//        for item in scrollView.subviews
//        {
//            print("index=\(item.tag), frame=\(item.frame)")
//        }
//        print("==== now scrollView has views ===== END")
    }
    
    private func insertScrollItem(item view:UIView, at position: Int, index:Int)
    {
        scrollView.insertSubview(view, at: position)
        view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        
//        print("==== now scrollView has views =====")
//        for item in scrollView.subviews
//        {
//            print("index=\(item.tag), frame=\(item.frame)")
//        }
//        print("==== now scrollView has views ===== END")
    }
    
    //viewEnd
    var imageIndex = 0
    
    
   
    //scroll window move to left side
    func windowGoLeft()
    {
       // let waitRemoveIndex = self.currentWindowLastIndex
        
        self.currentWindowLastIndex = self.currentWindowLastIndex - 1
        print("window go LEFT currentWindowLastIndex=\(currentWindowLastIndex), subview count=\(self.scrollView.subviews.count)")
        
        var lastItem = self.scrollView.subviews.last! //as! ZoomScrollView
        //self.scrollView.subviews.filter { $0.tag == waitRemoveIndex}.first! as! KrNrZoomScrollView //
        
        
        if (lastItem is KrNrZoomScrollView) == false
        {
            print("2 got unKNOWN view(\(String(describing: type(of: lastItem))), remove it")
            lastItem.removeFromSuperview()
            lastItem = self.scrollView.subviews.last! as! KrNrZoomScrollView
            
        }
        lastItem.removeFromSuperview()
        print("remove tagID=\(lastItem.tag)")
      
//        for item in scrollView.subviews
//        {
//            print("item type=\(type(of: item))")
//        }
        
        var firstItem = self.scrollView.subviews.first!
        if(firstItem is KrNrZoomScrollView) == false
        {
            print("got unKNOWN view(\(String(describing: type(of: firstItem))), remove it")
            firstItem.removeFromSuperview()
            firstItem = self.scrollView.subviews.first! as! KrNrZoomScrollView
        }
        //get current first item ipreload index from index
       
        print("firstItem tag=\(firstItem.tag)")
        lastItem.tag = firstItem.tag - 1
        print("ok now insert index =\(lastItem.tag) to first")
        
        //real phone photo
        updateRealImage(for: lastItem.tag, on: lastItem as! KrNrZoomScrollView)
        
        //insert to first
        
        scrollView.insertSubview(lastItem, at: 0)
        //update frame size and position
        lastItem.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(lastItem.tag) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        //print("insert item index=\(lastItem.tag) to first, number=\(imageIndex+1)")
        ///end
        
//        //for debug used
//        for view in scrollView.subviews
//        {
//            print("index=\(view.tag)")
//        }
//        print("=====")
    }
    
    
    //scroll window move to right side
    func windowGoRight()
    {
        self.currentWindowLastIndex = self.currentWindowLastIndex + 1
        print("window go RIGHT, currentWindowLastIndex=\(currentWindowLastIndex)")
        /////
        var firstItem = self.scrollView.subviews[0]// as! ZoomScrollView
        //if firstItem.frame.size.width < scrollView.frame.size.width
        
        if (firstItem is KrNrZoomScrollView) == false
        {
            print("2 got unKNOWN view, remove it")
            firstItem.removeFromSuperview()
            firstItem = self.scrollView.subviews[0] as! KrNrZoomScrollView
        }
        
        firstItem.removeFromSuperview()
        print("remove tagID=\(firstItem.tag)...subview count=\(self.scrollView.subviews.count)")
        
        //first item move to last item and update new index
        firstItem.tag = self.currentWindowLastIndex
        
        //test imgae
        //updateTestImage(for: nextIndex, on: firstItem as! ZoomScrollView)
        //real phone photo
        updateRealImage(for: currentWindowLastIndex, on: firstItem as! KrNrZoomScrollView)
        
        self.addViewToIndex(view: firstItem, index: self.currentWindowLastIndex)
//        print("append item currentWindowLastIndex=\(self.currentWindowLastIndex) to Last, Number=\(imageIndex+1)")
//
//        //for debug used
//        for view in scrollView.subviews
//        {
//            print("index=\(view.tag), frame=\(view.frame)")
//        }
//        print("=====")
    }
    
//    func updateTestImage(for index:Int, on view:KrNrZoomScrollView)
//    {
//        //test picture
//        let imageIndex = index % 5
//        let image = UIImage(named: fileNames[imageIndex])
//        view.image = image
//    }
    
    func updateRealImage(for index:Int, on imageView:KrNrZoomScrollView)
    {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
            
        let targetSize = CGSize(width: UIScreen.main.bounds.width*3, height: UIScreen.main.bounds.height*3)//PHImageManagerMaximumSize
        
        //let imageManager = KrNrImageManager.shared()
        
        autoreleasepool{
            cachImageManager.requestImage(for: assets[index], targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in

                let asset = self.assets[index]
                //print("update index=\(index) image request done. size=\(image!.size), id=\(asset.localIdentifier)")
                imageView.image = image
                
            })
        }
    }
    
    
    
    
    
    private var xyRatio:CGFloat = 0.0
    //ViewWillLayoutSubviews會呼叫這一個function
    public func updateFrame(bounds:CGRect, tappedIndex: Int)
    {
        print("update frame to bounds=\(bounds)")
        
        xyRatio = bounds.size.width / bounds.size.height
        currentBounds = bounds.size
        if(bounds.width > bounds.height)
        {
            print("Landscape")
            NSLayoutConstraint.deactivate(portritConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
        else
        {
            print("Portrit")
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portritConstraints)
            
        }
        
        
        let currentPage:Int = Int (scrollView.contentOffset.x / scrollView.frame.size.width)
        
        print("currentPage=\(currentPage)")
        
        //print("currentPage=\(currentPage), offset=\(scrollView.contentOffset.x), width=\(scrollView.frame.size.width)")
        
        self.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //self.backgroundColor = .red
        
        let scrollViewWidth = self.frame.size.width + (sideSpace * 2)
        //scrollview的frame放在-10位置，bounds width＝320，再多出10的空白，所以其實一個view的長度等於10+320+10=340
        //所以contentSize就是340的倍數。
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: scrollViewWidth, height: self.frame.size.height)
        
        
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(assetsCount), height: bounds.size.height)
        scrollView.contentOffset = CGPoint(x: scrollViewWidth * CGFloat(currentPage), y: 0)
        
        
        //update each KrNrZoomScrollView in scrollView
        for view in scrollView.subviews
        {
            if view is KrNrZoomScrollView
            {
                let index = view.tag
                //這是一個重點，把每一個subview的frame放在以340(5s為例：320螢幕寬+10+10空白)為倍數的數值，再加上一個10的空白處
                view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.width, height: bounds.height)
                
                //print("index=\(index), tappedIndex = \(tappedIndex)")
                //一併把每一個ZoomScrollView裡面的imageView也一併update frame
                (view as! KrNrZoomScrollView).updateFrame(newFrame: view.frame, animated: (index == tappedIndex), selected: currentCellFrame)
            }
        }
        
    }
}

extension KrNrSlideView : UIScrollViewDelegate
{
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("BeginDragging scrollView.contentOffset.x=\(scrollView.contentOffset.x)")

        draggingStart = true
        beginDraggingOffset = scrollView.contentOffset.x

        return
    }

    //scrolling
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {

        if draggingStart
        {
            draggingStart = false
            //lastContentOffset是在Begin開始拖拉時存下的
           if (self.beginDraggingOffset > scrollView.contentOffset.x)
           {
                //通知window往左，照片角度來看就是往回上一張
                slideDelegate?.slideTo(left: true, currentPage: self.currentPage)
                print("slideTo left, page=\(self.currentPage)")
                
            
                //prePhoto
                if currentWindowLastIndex == windowSize
                {
                    //目的是希望window一但遇到左邊的index = 0邊界時，就不要繼續移動window，此時window 裡面的photo都已經預載完成
                    print("limit to Left Side, nothing to DO")
                    return
                }
                else
                {
                    //繼續往左邊滑動
                    let currentOffset = scrollView.contentOffset.x//ex: 20page, 5windowsize, centerIndex=17, currentOffset=5440(frameSize=320*17)
                    let f = Float(currentOffset / scrollView.frame.width)//5400/320=16.875, index17 => index16
                    let i = Int(f)//16
                    print("currentOffset=\(currentOffset), width=\(scrollView.frame.width), f=\(f), i=\(i)")

                    let centerIndex = (windowSize / 2) + 1//算出當nextIndex到達最後一張時，centerIndex是自哪一個位置(20page, 5windowsize, centerIndex=17)
                    
                    
                    if i < (self.assetsCount - centerIndex)
                    {
                        //已經過了中心點，window開始往左邊移動
                        windowGoLeft()
                    }
                    else
                    {
                        //過中心點才繼續移動window，還沒過中心點，錨不動
                        print("boat ANCHOR no need to move...")
                    }
                }
           }
           else if (self.beginDraggingOffset < scrollView.contentOffset.x)
           {
                //通知window往右，照片角度來看就是往下一張
                let currentOffset = scrollView.contentOffset.x
                let f = Float(currentOffset / scrollView.frame.width)
                let i = ceil(f)//無條件進位
                slideDelegate?.slideTo(left: false, currentPage: Int(i))
                print("slideTo right, page=\(i)")
                //nextPhoto
                if currentWindowLastIndex == self.assetsCount - 1
                {
                    print("limit to Right Side, nothing to DO")
                    return
                }
                else
                {
//                    let currentOffset = scrollView.contentOffset.x
//                    let f = Float(currentOffset / scrollView.frame.width)
//                    let i = ceil(f)//無條件進位
                    print("currentOffset=\(currentOffset), width=\(scrollView.frame.width), f=\(f), i=\(i)")

                    
                    
                    let centerIndex = windowSize / 2
                    if Int(i) > centerIndex
                    {
                        
                        windowGoRight()
                    }
                    else
                    {
                        //過中心點才繼續移動window，還沒過中心點，錨不動
                        print("boat ANCHOR no need to move...")
                    }
                }

           }
           else
           {
                //
           }
        }
        else
        {
            //print("scrolling...offset=\(scrollView.contentOffset.x)")
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        //print("scrollViewDidEndDecelerating...contentOffset=\(scrollView.contentOffset)")

        let currentPage:Int = Int (scrollView.contentOffset.x / scrollView.frame.size.width)

        //currentIndex = currentPage
        print("scrollview Decelerating. current Page=\(currentPage)")
//        print("=====")
//        for item in scrollView.subviews
//        {
//            print("index=\(item.tag), frame=\(item.frame)")
//        }
    }

}


extension KrNrSlideView : UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        print("shouldRecognizeSimultaneouslyWith return true")
        return true
    }
}

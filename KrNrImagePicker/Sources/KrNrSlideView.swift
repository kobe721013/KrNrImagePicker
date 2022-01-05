//
//  KrNrSlideView.swift
//  KrNrSlideView
//
//  Created by kobe on 17.05.2021.
//  Copyright © 2021 kobe. All rights reserved.
//

import UIKit
import Photos

internal protocol KrNrSlideViewDelegate
{
    func slideTo(currentPage:Int, duplicatedCheck: Bool)
    func imageDisappearComplete()
    
}

internal class KrNrSlideView: UIView {

    /*private variable*/
    private var assetsCount:Int = 0
    private var cachImageManager:PHCachingImageManager!
    private var assets:[PHAsset]!
    private var alreadyAnimation = false
    private let zoomRate:CGFloat = 3.0
    
    private var windowSize = 30
    private let sideSpace:CGFloat = 10.0
    private var draggingStart = false
    
    private var beginDraggingOffset:CGFloat = -1.0
    private var originalPosition: CGPoint?
    private var currentPositionTouched: CGPoint?
    private var newAlpha:CGFloat = 1.0
    private var origXRatio:CGFloat = 0.0
    private var origYRatio:CGFloat = 0.0
    private var portritConstraints:[NSLayoutConstraint]!
    private var landscapeConstraints:[NSLayoutConstraint]!
    private var centerIndex = 37//31
    private var slideCount = 0
    private var xyRatio:CGFloat = 0.0
    /*public variable*/
    public var currentBounds:CGSize!
    public var delegate:KrNrSlideViewDelegate?
    public var slideDelegate:KrNrSlideViewDelegate?
    public var currentCellFrame:CGRect = .zero
    //scroll window parameter
    
    
    private let scrollView:UIScrollView = {
        let sc = UIScrollView(frame: .zero)
        sc.isPagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        return sc
    }()
    
    
    /*
     * 自己製作NavigationBar，目的是為了能控制當大圖向下拖曳時，NavigationBar也能慢慢隱形
     * 效果就跟photoApp類似，所以才客製化自己的NavigationBar
     */
    private let navigationBar:UINavigationBar = {
        
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "KrNr")
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(1.0)]
        bar.titleTextAttributes = textAttributes
       
        bar.tintColor = UIColor.red.withAlphaComponent(1.0)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonClick))
        
        navItem.rightBarButtonItem = doneButton
        bar.setItems([navItem], animated: false)
        
        bar.isTranslucent = true
        bar.setBackgroundImage(UIImage(), for: .default)
        
        return bar
    }()
    
    /*
     * 自己製作NavigationBar，目的是為了能控制當大圖向下拖曳時，NavigationBar也能慢慢隱形
     * 效果就跟photoApp類似。navigationBarView是一個Container。
     */
    private let navigationBarView:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        return view
        
    }()
    
    
    @objc func doneButtonClick()
    {
        KrNrLog.track("iamdone, who call me...")
        //for debug used
        for view in scrollView.subviews
        {
            KrNrLog.track("index=\(view.tag), frame=\(view.frame)")
        }
        KrNrLog.track("=====")
    }
    
    
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
                KrNrLog.track("orig from value=\(from), changeTo maxFrom=\(maxFrom)")
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
                KrNrLog.track("initWindowLastIndex < windowSize(\(windowSize), setup value to \(windowSize) ")
                to = windowSize
            }
            return to
        }
    }
    
    /*
     * currentPage指的是畫面靜止狀態下，直接用contentOffset.x / width的結果
     */
    var currentPage:Int
    {
        get
        {
            let page = scrollView.contentOffset.x / scrollView.frame.width
            KrNrLog.track("scrollView.contentOffset.x=\(scrollView.contentOffset.x), scrollView.frame.width=\(scrollView.frame.width)")
            return Int(page)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(selected cellFrame:CGRect) {
        //give a zero frame, real frame size will update after viewWillLayoytSubviews(call update frame method)
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        cachImageManager = KrNrImageManager.shared()//PHCachingImageManager()
        currentCellFrame = cellFrame
        setupScrollView()
        addNavigationBarConstraints()
    }
   
    func setupScrollView() {
        scrollView.backgroundColor = .clear
        
        //scrollview start at x=-10 position
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: frame.size.width + 2 * sideSpace, height: frame.height)
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        // add PanGesture
         let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addNavigationBarConstraints()
    {
        navigationBarView.addSubview(navigationBar)// add(navigationBar)
        
        //portitt Constraints
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
        
        //不管Portrit or Lanscape p1,2,3,5,6,7都一樣，所以p4,p8遇到畫面是Lanscape時，P4,P8就會disable.
        portritConstraints = [p4,p8]
        
        NSLayoutConstraint.activate(contraints)
        
        
        //Lanscape constraints
        let l1 =  navigationBar.heightAnchor.constraint(equalToConstant: 32)
        let l2 = navigationBarView.heightAnchor.constraint(equalToConstant: 32)
        
        landscapeConstraints = [l1, l2]
    }
    
    
//    func setupNavigationBar()
//    {
//        self.addSubview(navigationBarView)
//
//        NSLayoutConstraint(item: navigationBarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
//
//        NSLayoutConstraint(item: navigationBarView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 1.0).isActive = true
//        NSLayoutConstraint(item: navigationBarView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 1.0).isActive = true
//
//        navigationBarView.heightAnchor.constraint(equalToConstant: 64).isActive = true
//    }
//
    /*
     * 算出目前的page是在scrollView裡面的哪一個位置，回傳X軸位置
     */
    private func pageToFrameX(page:Int) -> CGFloat
    {
        let x = (bounds.size.width + 2.0 * sideSpace) * CGFloat(page)
        //KrNrLog.track("pageToFrameX, page=\(page), x=\(x)")
        return x
    }
    
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        
        let page = currentPage
        
        if let sliderView = scrollView.subviews.filter({ $0.tag == page }).first as? KrNrZoomScrollView
        {
           // sliderView.backgroundColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 0.3)
            let subView = sliderView.imageView!
            
            
            let translation = panGesture.translation(in: subView)
            //KrNrLog.track("translation=\(translation), current bounds=\(currentBounds)")
            
            if panGesture.state == .began {
                originalPosition = CGPoint(x: currentBounds.width / 2, y: currentBounds.height / 2)//...subView.center
                currentPositionTouched = panGesture.location(in: subView)
                
                origXRatio = self.currentPositionTouched!.x / currentBounds.width
                origYRatio = self.currentPositionTouched!.y / currentBounds.height
                
                sliderView.playButton.isHidden = true
                //KrNrLog.track("begin - originalPosition(subView.center)=\(originalPosition), currentPositionTouched=\(currentPositionTouched), origXRatio=\(origXRatio), origYRatio=\(origYRatio)")
            } else if panGesture.state == .changed {
                
                let newHeight = currentBounds.height - translation.y
                let newWidth = newHeight * xyRatio
                KrNrLog.track("newHeight=\(newHeight), newWidth=\(newWidth)")
                subView.frame.size = CGSize(width: newWidth, height: newHeight)
                
                let fingerPositionX = self.currentPositionTouched!.x + translation.x
                let fingerPositionY = self.currentPositionTouched!.y + translation.y
                KrNrLog.track("fingerPosition=(\(fingerPositionX), \(fingerPositionY)")
                
            
                subView.frame.origin.x = fingerPositionX - (newWidth * origXRatio)
                subView.frame.origin.y = fingerPositionY - (newHeight * origYRatio)
                KrNrLog.track("changeed...frame=\(subView.frame)...alpha=\(newAlpha)")

                
                //opacity
                newAlpha = ((newAlpha - 0.025) <= 0.0) ? 0.0 : (newAlpha - 0.025)
                opacityChangedTo(alpha: newAlpha, playButton: sliderView.playButton)
                
                
                
            } else if panGesture.state == .ended {
              let velocity = panGesture.velocity(in: subView)

              if velocity.y >= 1500 {
                
                //大圖消失，回到collectionView
                UIView.animate(withDuration: 0.5
                  , animations: {
                    
                    //opacity
                    self.opacityChangedTo(alpha: 0.0, playButton: sliderView.playButton)
                    
                    //讓imageview回到collectionView對應的位置上，營造出感覺像是縮回去collectionView
                    subView.frame = self.currentCellFrame
                    subView.contentMode = .scaleAspectFill
                    subView.clipsToBounds = true
                
                    //KrNrLog.track("subView frame change to=\(subView.frame)")
                    

                  }, completion: { (isCompleted) in
                    if isCompleted {

                        //ready to dismiss view controller
                        KrNrLog.track("dismiss it...")
                        self.slideDelegate?.imageDisappearComplete()
                        self.removeFromSuperview()
                      
                    }
                })
              } else {
                KrNrLog.track("rollback to originalPosition=\(originalPosition!)")
                self.newAlpha = 1.0
                UIView.animate(withDuration: 0.2, animations: {
                    subView.frame.size = self.currentBounds
                    subView.center = self.originalPosition!
                    subView.contentMode = .scaleAspectFit
                    
                    self.opacityChangedTo(alpha: self.newAlpha, playButton: sliderView.playButton)
                }) { (status) in
                    sliderView.checkPlayButtonHidden()
                    
                }
              }
            }
        }
    }
    
    private func opacityChangedTo(alpha: CGFloat, playButton:UIButton)
    {
        backgroundColor = UIColor.white.withAlphaComponent(alpha)
        navigationBarView.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.red.withAlphaComponent(alpha)]
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.tintColor = UIColor.red.withAlphaComponent(alpha)
        
    }
    
    //user pass assets array, and center index, and a window size, the function will use CachImageManager to request image and load image into ZoomScrollView
    func startCachingBigImage(serialAssets:[PHAsset], selected centerIndex: Int, window bufferSize: Int, options: PHImageRequestOptions?)
    {
        assetsCount = serialAssets.count
        windowSize = bufferSize
        self.centerIndex = centerIndex
        assets = serialAssets
        
        KrNrLog.track("[\(#function)] => centerIndex=\(centerIndex), bufferSize=\(bufferSize), assetsCount=\(assetsCount)")
        
       
        let to = initWindowLastIndex
        let from = initWindowFirstIndex
        
        KrNrLog.track("startCachingBigImage, from(\(from)) ~ to(\(to))")
        var waitAssets = [PHAsset]()
        waitAssets.append(serialAssets[centerIndex])

        
        var myoptions = options
        if myoptions == nil
        {
            myoptions = PHImageRequestOptions()
            myoptions!.resizeMode = .fast
            myoptions!.deliveryMode = .highQualityFormat
        }

        let targetSize = CGSize(width: UIScreen.main.bounds.width*zoomRate, height: UIScreen.main.bounds.height*zoomRate)//PHImageManagerMaximumSize
        cachImageManager.startCachingImages(for: waitAssets, targetSize: targetSize, contentMode: .default, options: myoptions)
        
        //START to load to each ZoomScrollView
        let range = Array(from...to)
        KrNrLog.track("[\(#function)] => index from (\(range.first!)) ~ (\(range.last!))")
        
        //add view to scrollview
        let centerview = KrNrZoomScrollView(frame: frame)
        centerview.asset = assets[centerIndex]
        centerview.reloadContents()
    
        for index in range
        {
            let view:KrNrZoomScrollView
            if index == centerIndex
            {
                view = centerview
            }
            else
            {
                let asset = assets[index]
                view = KrNrZoomScrollView(frame: frame)
                view.asset = asset
                view.reloadContents()
            }
            self.addScrollItemView(item: view, index: index, insertToFirstPosition: false)
        }
                
        //update scrollview 'contentSIze' & 'contentOffset'
        let unitItemSize = bounds.size.width + sideSpace * 2.0
        scrollView.contentSize = CGSize(width: CGFloat(assetsCount)*unitItemSize, height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(centerIndex)*unitItemSize, y: self.scrollView.contentOffset.y)
        
    }
    
    //add zoomscrollview to scrollview
    private func addScrollItemView(item view:UIView, index:Int, insertToFirstPosition:Bool)
    {
        view.tag = index
        view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        
        if(insertToFirstPosition)
        {
            scrollView.insertSubview(view, at: 0)
        }
        else
        {
            scrollView.addSubview(view)
        }
    }
  
//    func updateRealImage(for index:Int, on imageView:KrNrZoomScrollView)
//    {
//        let options = PHImageRequestOptions()
//        options.resizeMode = .fast
//        options.deliveryMode = .highQualityFormat
//
//        let targetSize = CGSize(width: UIScreen.main.bounds.width*3, height: UIScreen.main.bounds.height*3)//PHImageManagerMaximumSize
//
//        //let imageManager = KrNrImageManager.shared()
//
//        autoreleasepool{
//            cachImageManager.requestImage(for: assets[index], targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in
//
//                //let asset = self.assets[index]
//                //KrNrLog.track("update index=\(index) image request done. size=\(image!.size), id=\(asset.localIdentifier)")
//                imageView.image = image
//
//            })
//        }
//    }
    
    
    //the ViewWillLayoutSubviews of parent'viewcontroller will call the function
    public func updateFrame(bounds:CGRect, tappedIndex: Int)
    {
        KrNrLog.track("update frame to bounds=\(bounds)")
        
        xyRatio = bounds.size.width / bounds.size.height
        currentBounds = bounds.size
        if(bounds.width > bounds.height)
        {
            KrNrLog.track("updateFrame to Landscape")
            NSLayoutConstraint.deactivate(portritConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
        else
        {
            KrNrLog.track("updateFrame to Portrit")
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portritConstraints)
            
        }
        //每當要選轉時，原本預期第五頁的圖片，他的offset 應該會是 (ScreenWidth+20)*5
        //在iphoneX ios14.5.1發現，他會先往左shift 44，所以算出來的page會是浮點數，因此用round改取最接近的整數
        let currentPage:Int = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        KrNrLog.track("updateFrame, currentPage=\(currentPage)")
        
       
        
        self.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        let scrollViewWidth = self.frame.size.width + (sideSpace * 2)
        //scrollview的frame放在-10位置，bounds width＝320，再多出10的空白，所以其實一個view的長度等於10+320+10=340
        //所以contentSize就是340的倍數。
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: scrollViewWidth, height: self.frame.size.height)
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(assetsCount), height: bounds.size.height)
        scrollView.contentOffset = CGPoint(x: scrollViewWidth * CGFloat(currentPage), y: 0)
        
        
        //update EACH KrNrZoomScrollView in scrollView
        for view in scrollView.subviews
        {
            if view is KrNrZoomScrollView
            {
                let index = view.tag
                //這是一個重點，把每一個subview的frame放在以340(5s為例：320螢幕寬+10+10空白)為倍數的數值，再加上一個10的空白處
                view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.width, height: bounds.height)
                
                //一併把每一個ZoomScrollView裡面的imageView也一併update frame
                (view as! KrNrZoomScrollView).updateFrame(newFrame: view.frame, animated: (index == tappedIndex), selected: currentCellFrame)
            }
        }
        
    }
}

extension KrNrSlideView : UIScrollViewDelegate
{
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        KrNrLog.track("BeginDragging scrollView.contentOffset.x=\(scrollView.contentOffset.x), slideCount=\(slideCount)")
        draggingStart = true
        slideCount = slideCount + 1
        beginDraggingOffset = scrollView.contentOffset.x

        return
    }

    //when user scroll it, the function will check current page must be at center of window, and finally, the function will return current page index.
    func balanceWindow() -> Int
    {
        if(self.scrollView.contentOffset.x > self.beginDraggingOffset)
        {
            let offset = self.scrollView.contentOffset.x
            
            let f = Float(offset / self.scrollView.frame.width)
            let i = Int(ceil(f))//無條件進位
            //算出目前的page，搭配windowSize，可以得到這一個windowSize的min,max index
            let maxIndex = assets.count - 1
            let min = i - Int(self.windowSize / 2)
            let max = i + Int(self.windowSize / 2)
            if(min < 0 || max > maxIndex)
            {
                KrNrLog.track("currentPage=\(i), LIMIT to bothSIDE, return...")
                return i
            }
            KrNrLog.track("NOWpage=\(i), offset = \(offset), width=\(self.scrollView.frame.width), min=\(min), max=\(max)")
            //window to RIGHT
            var views = self.scrollView.subviews
            let trashView = views.filter{ ($0 is KrNrZoomScrollView) == false}
            //remove unknown view in scrollview first.
            for view in trashView
            {
                view.removeFromSuperview()
            }
            
            //把不是在min~max這一個範圍的view抓出來，即將重複利用他們
            views = self.scrollView.subviews
            let reuseViews = views.filter{ ($0.tag < min) || ($0.tag > max) }
            var lastViewTag = self.scrollView.subviews.last!.tag
            //KrNrLog.track("===")
            for view in reuseViews
            {
                //KrNrLog.track("reuse tag=\(view.tag)")
                if((view is KrNrZoomScrollView) == false)
                {
                    view.removeFromSuperview()
                    continue
                }
                lastViewTag = lastViewTag + 1
                
                let zoomscrollview = view as! KrNrZoomScrollView
                self.addScrollItemView(item: zoomscrollview, index: lastViewTag, insertToFirstPosition: false)
                
                zoomscrollview.imageManager = self.cachImageManager
                zoomscrollview.asset = assets[lastViewTag]
                zoomscrollview.prepareForReuse()
                zoomscrollview.reloadContents()
            }
            //KrNrLog.track("===END")
            
            return i
            
        }
        else
        {
            let offset = self.scrollView.contentOffset.x
            
            let f = Float(offset / self.scrollView.frame.width)
            let i = Int(f)//無條件捨去
            let maxIndex = assets.count - 1
            var min = i - Int(self.windowSize / 2)
            var max = i + Int(self.windowSize / 2)
            
            if(min < 0 || max > maxIndex)
            {
                KrNrLog.track("currentPage=\(i), LIMIT to bothSIDE, return...")
                return i
            }
            min = min < 0 ? 0 : min
            max = max > assets.count ? assets.count : max
            //KrNrLog.track("NOWpage=\(i), offset = \(offset), width=\(self.scrollView.frame.width), min=\(min), max=\(max)")
            //window to LEFT
            var views = self.scrollView.subviews
            let trashView = views.filter{ ($0 is KrNrZoomScrollView) == false}
            for view in trashView
            {
                view.removeFromSuperview()
            }
            views = self.scrollView.subviews
            let reuseViews = views.filter{ ($0.tag < min) || ($0.tag > max) }
            var firstViewTag = self.scrollView.subviews.first!.tag
            //KrNrLog.track("===")
            for view in reuseViews
            {
                //KrNrLog.track("reuse tag=\(view.tag)")
                firstViewTag = firstViewTag - 1
                
                let zoomscrollview = view as! KrNrZoomScrollView
                self.addScrollItemView(item: zoomscrollview, index: firstViewTag, insertToFirstPosition: true)
                
                zoomscrollview.imageManager = self.cachImageManager
                zoomscrollview.asset = assets[firstViewTag]
                zoomscrollview.prepareForReuse()
                zoomscrollview.reloadContents()
            }
            //KrNrLog.track("===END")
            return i
        }
         
    }
    
    //scrolling
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        KrNrLog.track("offset=\(scrollView.contentOffset.x)")
        if draggingStart
        {
            //when a user scroll normally, not scroll quickly, scrollViewWillBeginDragging will be triggered
            //and process'logic will 
            KrNrLog.track("draggingStart, balanceWindow")
        }
        else if(beginDraggingOffset > 0)
        {
            //避免第一次進來時，由於會設定contentOffset，而導致scroll滾動event觸發，所以用beginDraggingOffset判斷是人為scroll還是因為設定了contentOffset而造成的滾動
            let diffOffset = scrollView.contentOffset.x - beginDraggingOffset
            if(diffOffset <= scrollView.frame.width)
            {
                //目前滾動的offset還不到一個畫面的寬度，不做任何檢查
                return
            }
            else
            {
                //當diifOffset差距大於一個frame寬度時
                //表示scroll fast所致，所以這邊要balance一下
                KrNrLog.track("Scroll quickly~~~~~~~~~~, diffOffset=\(diffOffset), call balanceWindow")
            }
        }
        else
        {
            //when setting scrollView.contentOffset, process will return from here.
            return
        }
        
        let page = balanceWindow()
        draggingStart = false
        slideDelegate?.slideTo(currentPage: page, duplicatedCheck: true)
    
//mark it. play video method changed to present a viewcontroller.
//        let playingViews = scrollView.subviews.filter({($0 as? KrNrZoomScrollView)?.isPlayingVideo == true})
//        for item in playingViews
//        {
//            let v = item as! KrNrZoomScrollView
//            KrNrLog.track("playing VIDEO, index=\(v.tag), frame=\(v.frame), STOP it")
//            v.pauseVideo()
//        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        //KrNrLog.track("scrollViewDidEndDecelerating...contentOffset=\(scrollView.contentOffset)")
        //當scroll畫面停止下來時，也再更新一次目前停留的張數
        let currentPage:Int = Int (scrollView.contentOffset.x / scrollView.frame.size.width)
        slideDelegate?.slideTo(currentPage: currentPage, duplicatedCheck: true)
        //currentIndex = currentPage
        //KrNrLog.track("scrollview Decelerating. current Page=\(currentPage)")
//        KrNrLog.track("=====")
//        for item in scrollView.subviews
//        {
//            let v = item as! KrNrZoomScrollView
//
//            KrNrLog.track("index=\(v.tag), frame=\(v.frame), alpha=\(v.alpha)")
//        }
    }

}

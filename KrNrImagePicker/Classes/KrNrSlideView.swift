//
//  BannerView.swift
//  InfiniteScrollView
//
//  Created by aybek can kaya on 17.05.2019.
//  Copyright © 2019 aybek can kaya. All rights reserved.
//

import UIKit
import Photos



public class KrNrSlideView: UIView {
    
    //test image
    var fileNames = ["no1.png", "no2.jpg", "no3.jpg", "no4.jpg", "no5.jpg"]
    
    private let scrollView:UIScrollView = {
        let sc = UIScrollView(frame: .zero)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.isPagingEnabled = true
        return sc
    }()
    
   
    
    private var numberOfItems:Int = 0
    private var cachImageManager:PHCachingImageManager!
    var assets:[PHAsset] = []
    
    var startIndex = 37//31
    var nextIndex = 150//41
    var windowWidth = 10
    let sideSpace:CGFloat = 10.0
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("init BannerView frame=\(frame)")
        print("...total subview scount=\(self.scrollView.subviews.count)")
        cachImageManager = PHCachingImageManager()
        //get permission
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in
                
                let result = (status == .authorized)
                if result {
                    print("OK, get photo permission")
                    self.fetchAssets()
                } else {
                    print("NO. no photo permission")
                }
                
            })
        }
        else{
            fetchAssets()
        }
        
        setUpUI()
    }
    //viewStart
    var draggingStart = false
    var beginDraggingOffset:CGFloat = 0.0
    var currentIndex=0
    
    private func setUpUI() {
        print("setUpUI() start >>> frame=\(frame)")
        //give a default value, real size will update after viewWillLayoytSubviews(call update frame method)
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: frame.size.width + 2 * sideSpace, height: frame.height)
        print("scrollView.frame=\(scrollView.frame), superview=\(self.frame)")
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        print("setUpUI() end   <<<")
    }
    
    func fetchAssets()
    {
        //test featch all phasset
        let phFetchResult = PHAsset.fetchAssets(with: nil)
        self.assets = phFetchResult.objects(at: IndexSet(0..<phFetchResult.count))
        
        nextIndex = startIndex + windowWidth / 2
        if nextIndex >= assets.count
        {
            nextIndex = assets.count - 1
        }
        
        print("total assets count=\(self.assets.count), nextIndex=\(nextIndex)")
        
        DispatchQueue.main.async {
            print("main thread run reloadData()")
            self.reloadData()
        }
        
        print("fetchAssets function done.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func reloadData(numberOfItems:Int) {
       
        self.numberOfItems = numberOfItems
        print("total page count=\(self.numberOfItems)")
        reloadScrollView()
    }
    
    
    
    public func reloadData()
    {
        
        self.numberOfItems = assets.count
        var preIndex = startIndex - windowWidth / 2
        if preIndex < 0
        {
            preIndex = 0
        }
        nextIndex = preIndex + windowWidth
        if nextIndex >= self.numberOfItems
        {
            nextIndex = self.numberOfItems - 1
        }
        
        
        print("preload index from (\(preIndex)) ~ (\(nextIndex))")
        
        let range = (preIndex...nextIndex)
        //print("request photo size=\(self.scrollView.frame.size)")
        
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        let targetSize = PHImageManagerMaximumSize//self.scrollView.frame.size
        for index in range
        {
            let asset = self.assets[index]
            let item = KrNrZoomScrollView(frame: frame)
            item.tag = index
            cachImageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in
                
                
                item.image = image
                print("callback to update index=\(index)...size=\(String(describing: image?.size))")
                
            })
            print("add zoomingView to index=\(index)...")
            self.addViewToIndex(view: item, index: index)
        }
        
        let unitItemSize = bounds.size.width + sideSpace * 2.0
        scrollView.contentSize = CGSize(width: CGFloat(numberOfItems)*unitItemSize, height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(startIndex)*unitItemSize, y: self.scrollView.contentOffset.y)
        
        print("reloadData finial info. unitItemSize=\(unitItemSize), contentSize=\(scrollView.contentSize), contentOffset=\(scrollView.contentOffset)")
    }
    
   
    private func reloadScrollView() {
        guard self.numberOfItems > 0 else { return }
        
        var preIndex = startIndex - windowWidth / 2
        if preIndex < 0
        {
            preIndex = 0
        }
        nextIndex = preIndex + windowWidth
        if nextIndex >= self.numberOfItems
        {
            nextIndex = self.numberOfItems - 1
        }
        
        print("preIndex=\(preIndex) ~ nextIndex=\(nextIndex)")
        
        for index in preIndex...nextIndex {
            
//            let item = UIImageView(frame: .zero)
//            item.tag = index
//            let imageIndex = index % 5
//            item.image = UIImage(named: fileNames[imageIndex])
//            item.con·tentMode = .scaleAspectFit
            
            let item = KrNrZoomScrollView(frame: frame)
            item.tag = index
            let imageIndex = index % 5
            item.image =  UIImage(named: fileNames[imageIndex])
            addViewToIndex(view: item, index: index)
            print("add index=\(index)...count=\(self.scrollView.subviews.count)")
        }
        let newWidth = scrollView.frame.size.width + CGFloat(10*2)
        scrollView.contentSize = CGSize(width: CGFloat(numberOfItems)*newWidth, height: scrollView.frame.size.height)
        
        print("&&&& total subview sclf.scrollView.subviews.count)")
        scrollView.setContentOffset(CGPoint(x: CGFloat(startIndex)*scrollView.frame.size.width, y: self.scrollView.contentOffset.y), animated: false)
        
        //let view = self.scrollView.subviews.last
        //view?.removeFromSuperview()
        scrollView.contentOffset = CGPoint(x: CGFloat(startIndex)*scrollView.frame.size.width, y: self.scrollView.contentOffset.y)
        
        for view in self.scrollView.subviews
        {
            print("view tag=\(view.tag)... name=\(type(of: view)), frame=\(view.frame)")
        }
        
        
        print("total subview scount=\(self.scrollView.subviews.count)")
    }
    
    private func addViewToIndex(view:UIView, index:Int) {
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        
        view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        
        print("==== now scrollView has views =====")
        for item in scrollView.subviews
        {
            print("index=\(item.tag), frame=\(item.frame)")
        }
        print("==== now scrollView has views ===== END")
    }
    
    //viewEnd
    var imageIndex = 0
    
    
   
    
    func swipeLeft()
    {
        self.nextIndex = self.nextIndex - 1
        print("exec LEFT function for nextIndex=\(nextIndex), subview count=\(self.scrollView.subviews.count)")
        var lastItem = self.scrollView.subviews.last! //as! ZoomScrollView
        //print("lastItem frame=\(lastItem.frame), scrollView frame=\(scrollView.frame)")
       
        //if lastItem.frame.size.width < scrollView.frame.size.width
        
        if (lastItem is KrNrZoomScrollView) == false
        {
            print("2 got unKNOWN view(\(String(describing: type(of: lastItem))), remove it")
            lastItem.removeFromSuperview()
            lastItem = self.scrollView.subviews.last! as! KrNrZoomScrollView
            
        }
        lastItem.removeFromSuperview()
        print("remove tagID=\(lastItem.tag)")
      
        
        //get current first item ipreload index from index
        let firstItem = self.scrollView.subviews.first! as! KrNrZoomScrollView
        print("firstItem tag=\(firstItem.tag)")
        lastItem.tag = firstItem.tag - 1
        print("ok now insert index =\(lastItem.tag) to first")
        //test image
        //updateTestImage(for: lastItem.tag, on: (lastItem as! ZoomScrollView))
        //real phone photo
        updateRealImage(for: lastItem.tag, on: lastItem as! KrNrZoomScrollView)
        
        //insert to first
        
        scrollView.insertSubview(lastItem, at: 0)
        //update frame size and position
        lastItem.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(lastItem.tag) + sideSpace, y: 0, width: bounds.size.width, height: scrollView.frame.size.height)
        print("insert item index=\(lastItem.tag) to first, number=\(imageIndex+1)")
        ///end
        
        //for debug used
        for view in scrollView.subviews
        {
            print("index=\(view.tag)")
        }
        print("=====")
    }
    
    func swipeRight()
    {
        
        self.nextIndex = self.nextIndex + 1
        print("exec RIGHT function for nextIndex=\(nextIndex)")
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
        firstItem.tag = self.nextIndex
        
        //test imgae
        //updateTestImage(for: nextIndex, on: firstItem as! ZoomScrollView)
        //real phone photo
        updateRealImage(for: nextIndex, on: firstItem as! KrNrZoomScrollView)
        
        self.addViewToIndex(view: firstItem, index: self.nextIndex)
        print("append item index=\(self.nextIndex) to Last, Number=\(imageIndex+1)")
        
        //for debug used
        for view in scrollView.subviews
        {
            print("index=\(view.tag), frame=\(view.frame)")
        }
        print("=====")
    }
    
    func updateTestImage(for index:Int, on view:KrNrZoomScrollView)
    {
        //test picture
        let imageIndex = index % 5
        let image = UIImage(named: fileNames[imageIndex])
        view.image = image
    }
    
    func updateRealImage(for index:Int, on imageView:KrNrZoomScrollView)
    {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
            
        let targetSize = PHImageManagerMaximumSize//self.scrollView.frame.size
        
        cachImageManager.requestImage(for: self.assets[index], targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in

            let asset = self.assets[index]
            print("update index=\(index) image request done. size=\(image!.size), id=\(asset.localIdentifier)")
            imageView.image = image
            
        })
    }
    
    
    
    
    
    //ViewWillLayoutSubviews會呼叫這一個function
    public func updateFrame(bounds:CGRect)
    {
        print("update frame to bounds=\(bounds)")
        
        let currentPage:Int = Int (scrollView.contentOffset.x / scrollView.frame.size.width)
        
        print("currentPage=\(currentPage), offset=\(scrollView.contentOffset.x), width=\(scrollView.frame.size.width)")
        
        self.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //self.backgroundColor = .red
        
        let scrollViewWidth = self.frame.size.width + (sideSpace * 2)
        //scrollview的frame放在-10位置，bounds width＝320，再多出10的空白，所以其實一個view的長度等於10+320+10=340
        //所以contentSize就是340的倍數。
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: scrollViewWidth, height: self.frame.size.height)
        
        
        
        
        
        //scrollView.backgroundColor = .yellow
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(numberOfItems), height: bounds.size.height)
        scrollView.contentOffset = CGPoint(x: scrollViewWidth * CGFloat(currentPage), y: 0)
        
        var imageview = scrollView.subviews.first!
        print("Before first imageview frame=\(imageview.frame)")
        imageview.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        print("After first imageview frame=\(imageview.frame)")
        
        imageview = scrollView.subviews.first!
        print("CheckAgain first imageview frame=\(imageview.frame)")
        
        for view in scrollView.subviews
        {
            if view is KrNrZoomScrollView
            {
                let index = view.tag
                //這是一個重點，把每一個subview的frame放在以340為倍數的數值，再加上一個10的空白處
                view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.width, height: bounds.height)
                print("index=\(index),  viewFrame=\(view.frame)")
                
                //一併把每一個ZoomScrollView裡面的imageView也一併update frame
                (view as! KrNrZoomScrollView).updateFrame(newFrame: view.frame)
            }
        }
        
    }
    
    
//    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//            print("BeginDragging scrollView.contentOffset.x=\(scrollView.contentOffset.x)")
//
//            draggingStart = true
//            beginDraggingOffset = scrollView.contentOffset.x
//
//            return
//    }
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
                //prePhoto
                if nextIndex == windowWidth
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

                    let centerIndex = (windowWidth / 2) + 1//算出當nextIndex到達最後一張時，centerIndex是自哪一個位置(20page, 5windowsize, centerIndex=17)
                    if i < (self.numberOfItems - centerIndex)
                    {
                        //已經過了中心點，window開始往左邊移動
                        swipeLeft()
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
                //nextPhoto
                if nextIndex == self.numberOfItems - 1
                {
                    print("limit to Right Side, nothing to DO")
                    return
                }
                else
                {
                    let currentOffset = scrollView.contentOffset.x
                    let f = Float(currentOffset / scrollView.frame.width)
                    let i = ceil(f)//無條件進位
                    print("currentOffset=\(currentOffset), width=\(scrollView.frame.width), f=\(f), i=\(i)")

                    let centerIndex = windowWidth / 2
                    if Int(i) > centerIndex
                    {
                        swipeRight()
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

        print("scrollViewDidEndDecelerating...contentOffset=\(scrollView.contentOffset)")

        let currentPage:Int = Int (scrollView.contentOffset.x / scrollView.frame.size.width)

        currentIndex = currentPage
        print("current Page=\(currentPage)")
        print("=====")
        for item in scrollView.subviews
        {
            print("index=\(item.tag), frame=\(item.frame)")
        }
    }

    
//    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
//    {
//        //print("scrollViewWillBeginDecelerating...contentOffset=\(self.scrollView.contentOffset)")
//    }
//
//    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
//    {
//
//    }
//
//    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
//    {
//        //print("scrollViewDidEndDragging...contentOffset=\(self.scrollView.contentOffset)")
//    }


}

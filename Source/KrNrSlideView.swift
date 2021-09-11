//
//  KrNrSlideView.swift
//  KrNrSlideView
//
//  Created by kobe on 17.05.2021.
//  Copyright © 2021 kobe. All rights reserved.
//

import UIKit
import Photos



public class KrNrSlideView: UIView {

    private let scrollView:UIScrollView = {
        let sc = UIScrollView(frame: .zero)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.isPagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        return sc
    }()
    
   
    
    private var assetsCount:Int = 0
    private var cachImageManager:PHCachingImageManager!
    private var assets:[PHAsset]!
    
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
    
    
    
    var currentWindowLastIndex = 150//41
    
    var windowSize = 10
    let sideSpace:CGFloat = 10.0
    var draggingStart = false
    
    
    var beginDraggingOffset:CGFloat = 0.0
    //var currentIndex=0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        //give a zero value, real frame size will update after viewWillLayoytSubviews(call update frame method)
        super.init(frame: CGRect.zero)
        cachImageManager = PHCachingImageManager()
        setupScrollView()
    }
   
    func setupScrollView() {
        //scrollview start at x=-10 position
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: frame.size.width + 2 * sideSpace, height: frame.height)
        scrollView.delegate = self
        self.addSubview(scrollView)
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
//        for i in from...to
//        {
//            waitAssets.append(serialAssets[i])
//        }
        
        var myoptions = options
        if myoptions == nil
        {
            myoptions = PHImageRequestOptions()
            myoptions!.resizeMode = .fast
            myoptions!.deliveryMode = .highQualityFormat
        }

        cachImageManager.startCachingImages(for: waitAssets, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: myoptions)
    }
    
    
    public func loadImageToView()
    {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat

        
        var range = Array(initWindowFirstIndex...initWindowLastIndex)
        let targetSize = PHImageManagerMaximumSize

        print("loadImageToView, index from (\(range.first!)) ~ (\(range.last!))")
        
        //move centerIndex to first position
        range = range.filter { $0 != centerIndex}
        range.insert(centerIndex, at: 0)
        print("request image, range order=\(range), centerIndex=\(centerIndex)")
       
        
        
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
            
            print("index=\(index), insert to position=\(p)")
            
            self.insertScrollItem(item: view, at: p, index: index)
            
            cachImageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in

                view.image = image
                print("windos size=\(self.windowSize), prelad data callback to update index=\(index)...size=\(String(describing: image?.size)), id=\(asset.localIdentifier)")

            })
        }
        
        //update scrollview 'contentSIze' & 'contentOffset'
        let unitItemSize = bounds.size.width + sideSpace * 2.0
        scrollView.contentSize = CGSize(width: CGFloat(assetsCount)*unitItemSize, height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(centerIndex)*unitItemSize, y: self.scrollView.contentOffset.y)
        
        print("scrollView each item, unitItemSize=\(unitItemSize), contentSize=\(scrollView.contentSize), contentOffset=\(scrollView.contentOffset)")
    }
    
   
//    private func reloadScrollView() {
//        guard self.assetsCount > 0 else { return }
//        
//        var preIndex = centerIndex - windowSize / 2
//        if preIndex < 0
//        {
//            preIndex = 0
//        }
//        nextIndex = preIndex + windowSize
//        if nextIndex >= self.assetsCount
//        {
//            nextIndex = self.assetsCount - 1
//        }
//        
//        print("preIndex=\(preIndex) ~ nextIndex=\(nextIndex)")
//        
//        for index in preIndex...nextIndex {
//            
////            let item = UIImageView(frame: .zero)
////            item.tag = index
////            let imageIndex = index % 5
////            item.image = UIImage(named: fileNames[imageIndex])
////            item.con·tentMode = .scaleAspectFit
//            
//            let item = KrNrZoomScrollView(frame: frame)
//            item.tag = index
//            let imageIndex = index % 5
//            item.image =  UIImage(named: fileNames[imageIndex])
//            addViewToIndex(view: item, index: index)
//            print("add index=\(index)...count=\(self.scrollView.subviews.count)")
//        }
//        let newWidth = scrollView.frame.size.width + CGFloat(10*2)
//        scrollView.contentSize = CGSize(width: CGFloat(assetsCount)*newWidth, height: scrollView.frame.size.height)
//        
//        print("&&&& total subview sclf.scrollView.subviews.count)")
//        scrollView.setContentOffset(CGPoint(x: CGFloat(centerIndex)*scrollView.frame.size.width, y: self.scrollView.contentOffset.y), animated: false)
//        
//        //let view = self.scrollView.subviews.last
//        //view?.removeFromSuperview()
//        scrollView.contentOffset = CGPoint(x: CGFloat(centerIndex)*scrollView.frame.size.width, y: self.scrollView.contentOffset.y)
//        
//        for view in self.scrollView.subviews
//        {
//            print("view tag=\(view.tag)... name=\(type(of: view)), frame=\(view.frame)")
//        }
//        
//        
//        print("total subview scount=\(self.scrollView.subviews.count)")
//    }
    
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
    
    private func insertScrollItem(item view:UIView, at position: Int, index:Int)
    {
        scrollView.insertSubview(view, at: position)
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
      
        for item in scrollView.subviews
        {
            print("item type=\(type(of: item))")
        }
        
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
        print("insert item index=\(lastItem.tag) to first, number=\(imageIndex+1)")
        ///end
        
        //for debug used
        for view in scrollView.subviews
        {
            print("index=\(view.tag)")
        }
        print("=====")
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
        print("append item currentWindowLastIndex=\(self.currentWindowLastIndex) to Last, Number=\(imageIndex+1)")
        
        //for debug used
        for view in scrollView.subviews
        {
            print("index=\(view.tag), frame=\(view.frame)")
        }
        print("=====")
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
            
        let targetSize = PHImageManagerMaximumSize//self.scrollView.frame.size
        
        //let imageManager = KrNrImageManager.shared()
        cachImageManager.requestImage(for: assets[index], targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in

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
        
        //print("currentPage=\(currentPage), offset=\(scrollView.contentOffset.x), width=\(scrollView.frame.size.width)")
        
        self.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //self.backgroundColor = .red
        
        let scrollViewWidth = self.frame.size.width + (sideSpace * 2)
        //scrollview的frame放在-10位置，bounds width＝320，再多出10的空白，所以其實一個view的長度等於10+320+10=340
        //所以contentSize就是340的倍數。
        scrollView.frame = CGRect(x: -sideSpace, y: 0, width: scrollViewWidth, height: self.frame.size.height)
        
        
        
        
        
        //scrollView.backgroundColor = .yellow
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(assetsCount), height: bounds.size.height)
        scrollView.contentOffset = CGPoint(x: scrollViewWidth * CGFloat(currentPage), y: 0)
        
        var imageview = scrollView.subviews.first!
        //print("Before first imageview frame=\(imageview.frame)")
        imageview.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //print("After first imageview frame=\(imageview.frame)")
        
        imageview = scrollView.subviews.first!
        //print("CheckAgain first imageview frame=\(imageview.frame)")
        
        for view in scrollView.subviews
        {
            if view is KrNrZoomScrollView
            {
                let index = view.tag
                //這是一個重點，把每一個subview的frame放在以340(5s為例：320螢幕寬+10+10空白)為倍數的數值，再加上一個10的空白處
                view.frame = CGRect(x: (bounds.width + sideSpace * 2) * CGFloat(index) + sideSpace, y: 0, width: bounds.width, height: bounds.height)
                //print("index=\(index),  viewFrame=\(view.frame)")
                
                //一併把每一個ZoomScrollView裡面的imageView也一併update frame
                (view as! KrNrZoomScrollView).updateFrame(newFrame: view.frame)
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
                //nextPhoto
                if currentWindowLastIndex == self.assetsCount - 1
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
        print("=====")
        for item in scrollView.subviews
        {
            print("index=\(item.tag), frame=\(item.frame)")
        }
    }

}

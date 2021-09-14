//
//  ZoomScrollView.swift
//  InfiniteScrollView
//
//  Created by 林詠達 on 2021/1/19.
//  Copyright © 2021 aybek can kaya. All rights reserved.
//

import UIKit

class KrNrZoomScrollView: UIScrollView {

   
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var imageView:UIImageView!
    
    var image:UIImage!
    {
        didSet{
            print("set image. scrollview frame=\(frame)")
            //imageView.frame = frame
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        
        //
        let newFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        super.init(frame: newFrame)
        //print("ZoomScrollView init(), newFrame=\(newFrame)")
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup()
    {
        // image
        imageView = UIImageView(frame: frame)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        maximumZoomScale = 4.0
        minimumZoomScale = 1.0
        zoomScale = 1.0
        
        delegate = self
        
        //contentInset = UIEdgeInsets(top: -100 , left: -100, bottom: -100, right: -100)
        //imageView.frame.size.width = 1000
        //imageView.frame.size.height = 500
    }
    
    override func layoutSubviews() {
        //print("ZoomScrollView layoutSubviews, scrollview frame=\(frame)")
    }
    
    func updateFrame(newFrame: CGRect, animated: Bool, selected cellFrame:CGRect)
    {
        
        print("scrollView update frame to newFrame=\(newFrame)")
        //更新scrollview的contentSize，因為可能旋轉後，contentSize改變了
        contentSize = newFrame.size

        if(animated)
        {
            self.imageView.frame = cellFrame
            print("view need animated, initFrame=\(cellFrame)")
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame = CGRect(x: 0, y: 0, width: newFrame.width, height: newFrame.height)
            }
        }
        else
        {
            print("NO need animated")
            imageView.frame.size = newFrame.size
        }
    }

}

extension KrNrZoomScrollView : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        //print("scrollViewDidZoom- imageView.frame=\(imageView.frame). ScrollView frame=\(self.frame), imageSize=\(imageView.image?.size), zoomScale=\(scrollView.zoomScale), contentSize=\(scrollView.contentSize), contentOffset=\(contentOffset)")
        
       
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {

                //先算出目前實際圖片的長，寬，個別被放大多少倍
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height

                //由於是用imageview跟實際圖片的長寬去比較，所以，如果取比例比較小的那一個倍數
                //就可以知道這張圖是寬的，還是長的。可以知道imageview目前被放大，是哪一個邊比較完全fit
                let ratio = ratioW < ratioH ? ratioW : ratioH
                
                //再利用這一個比例，算出，目前實際被放大的圖片新的size
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio

                //print("ratioW=\(ratioW), ratioH=\(ratioH), newWidth=\(newWidth), newHeight=\(newHeight)")
                
                //這邊其實不太懂為何要用newWidth * scrollView.zoomScale 這一個判斷
                //這一個條件應該是要用在圖片小於imageview的任何一邊長寬的情況
                //但是，我的狀況會把圖片拉大到跟imageview依樣大，所以都會跑到
                //(newWidth - imageView.frame.width)
                //這行意思其實就是，ex:以一張寬的圖片來說
                //目前imagevie被zoom in後，newWidth肯定就是imageview.width
                //而高度就不一定了，imageview的高度會比newHeight大上許多
                //所以newHeight - imageview.height後就是上下的空白處，所以除2
                //contentInset的top & buttom就會是負值
                //這樣就可以讓空白處跑到imageview以外，才不會放大看圖片時，一堆空白地方都看得到
                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                        
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)

                    
                //print("contentInset=\(scrollView.contentInset)")
                
            }

            
        } else {
                scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
}

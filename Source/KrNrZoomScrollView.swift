//
//  ZoomScrollView.swift
//  InfiniteScrollView
//
//  Created by 林詠達 on 2021/1/19.
//  Copyright © 2021 aybek can kaya. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AVKit

class KrNrZoomScrollView: UIScrollView {

    
    var imageManager:PHCachingImageManager?
    fileprivate var shouldUpdateImage = false
    private var currentRequest: PHImageRequestID?
    
    private var videoView:VideoView = {
        let videoview = VideoView()
        videoview.translatesAutoresizingMaskIntoConstraints = false
        videoview.backgroundColor = .red
        videoview.isHidden = true
        return videoview
    }()
    
    private let playButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 150, green: 150, blue: 150, alpha: 0.5)
        button.setTitle("Play", for: .normal)
        //button.isHidden = true
        //button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        //button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        return button
    }()
    
    public var isPlayingVideo:Bool
    {
        get
        {
            if #available(iOS 10.0, *) {
                return(videoView.playerStatus == AVPlayer.TimeControlStatus.playing)
            } else {
                KrNrLog.track("Below ios10, NO TimeControlStatus")
                return true
                // Fallback on earlier versions
            }
        }
    }
   
    public func pauseVideo()
    {
        videoView.pause()
        playButton.setTitle("Play", for: .normal)
    }
    
    @objc func playButtonClicked(_ sender: UIButton, forEvent event: UIEvent)
    {
        guard let ass = asset else
        {
            KrNrLog.track("asset is nil.....")
            return
        }
        
        let buttonText = sender.title(for: .normal)
        KrNrLog.track("\(buttonText!) button clicked...hasCurrentItem=\(videoView.hasPlayItem)")
        if(buttonText == "Pause")
        {
            videoView.pause()
            self.playButton.setTitle("Play", for: .normal)
            return
        }
        
        
        if(videoView.hasPlayItem)
        {
            self.playButton.setTitle("Pause", for: .normal)
            videoView.play()
            return
        }
        PHCachingImageManager().requestAVAsset(forVideo: ass as PHAsset, options:nil, resultHandler: { (asset, audioMix, info) in
         
                  let strArr = ((info! as NSDictionary).object(forKey:"PHImageFileSandboxExtensionTokenKey") as! NSString).components(separatedBy:";")
         
                 let url = strArr.last!
         
                 print(url)
                
                
            
                DispatchQueue.main.async {
                   
                    let url = URL(fileURLWithPath: url)
                    self.videoView.play(with: url)
                    self.playButton.setTitle("Pause", for: .normal)
                
                }
                
            
//            let player = AVPlayer(url: URL(fileURLWithPath: url))
//            let playerController = AVPlayerViewController()
//            playerController.player = player
//                if var topController = UIApplication.shared.keyWindow?.rootViewController {
//                    while let presentedViewController = topController.presentedViewController {
//                        topController = presentedViewController
//
//                        DispatchQueue.main.async {
//                            topController.present(playerController, animated: false, completion: {
//                                player.play()
//                                topController.view.subviews
//                            })
//                        }
//                    }
//                    // topController should now be your topmost view controller
//                }
                
               
         
         })
        
        
//        PHCachingImageManager().requestAVAsset(forVideo: ass as PHAsset, options:nil, resultHandler: { (asset, audioMix, info) in
//
//            let strArr = ((info!,asNSDictionary).object(forKey:"PHImageFileSandboxExtensionTokenKey")as!NSString).components(separatedBy:";")
//
//                 let url = strArr.last！
//
//                 print(url)
//
////                let player = AVPlayer(url: URL(fileURLWithPath: url))
////                let playerController = AVPlayerViewController()
////                playerController.player = player
////                present(playerController, animated: true) {
////                player.play()
//
//        })
        
        
        
    }
    
    internal var imageSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) {
        didSet {
            guard self.imageSize != oldValue else {
                return
            }
            self.shouldUpdateImage = true
        }
    }
    
    internal var asset: PHAsset? {
        didSet {
            
            //self.metadataView.asset = self.asset
            guard self.asset != oldValue || self.imageView.image == nil else {
                return
            }
            self.accessibilityLabel = asset?.accessibilityLabel
            self.shouldUpdateImage = true
        }
    }
    
    func prepareForReuse() {
        
        self.imageView.image = nil
        
        if let currentRequest = self.currentRequest {
            let imageManager = self.imageManager ?? PHImageManager.default()
            
            KrNrLog.track("prepareForReuse, CANCEL requestImage, ID=\(currentRequest)")
            imageManager.cancelImageRequest(currentRequest)
        }
    }
    
    
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
            KrNrLog.track("set image. scrollview frame=\(frame)")
            //imageView.frame = frame
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        
        //
        let newFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        super.init(frame: newFrame)
        KrNrLog.track("ZoomScrollView init(), newFrame=\(newFrame)")
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSubviews()
        
        playButton.layer.cornerRadius = playButton.bounds.midX
        playButton.alpha = 0.5
        KrNrLog.track("playButton.layer.cornerRadius=\(playButton.layer.cornerRadius)")
    }
    
    func setup()
    {
        
        self.backgroundColor = .clear//UIColor.yellow.withAlphaComponent(0.3)
        // image
        imageView = UIImageView(frame: frame)
        //imageView.backgroundColor = .green
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)

       
        //video view
        addSubview(videoView)
        videoView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        //videoView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 16/9).isActive = true
        videoView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        videoView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        //play button
        videoView.addSubview(playButton)
        playButton.frame.origin = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        KrNrLog.track("playbutton.frame=\(playButton.frame)")
        playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.centerXAnchor.constraint(equalTo: videoView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: videoView.centerYAnchor).isActive = true
        
        
//        NSLayoutConstraint(item: playButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 200.0).isActive = true
//        NSLayoutConstraint(item: playButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 100.0).isActive = true



        
       

    
        
        
        maximumZoomScale = 3.0
        minimumZoomScale = 1.0
        zoomScale = 1.0
        
        delegate = self
       
    }
    
   
    override func layoutSubviews() {
        //KrNrLog.track("ZoomScrollView layoutSubviews, scrollview frame=\(frame)")
    }
    
    func updateFrame(newFrame: CGRect, animated: Bool, selected cellFrame:CGRect)
    {
        
        //KrNrLog.track("scrollView update frame to newFrame=\(newFrame)")
        //更新scrollview的contentSize，因為可能旋轉後，contentSize改變了
        contentSize = newFrame.size

        if(animated)
        {
            //KrNrLog.track("image show animated")
            self.imageView.frame = cellFrame
            
            //KrNrLog.track("view need animated, initFrame=\(cellFrame)")
            UIView.animate(withDuration: 1.0) {
                self.imageView.frame = CGRect(x: 0, y: 0, width: newFrame.width, height: newFrame.height)
               // self.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            }
        }
        else
        {
            //KrNrLog.track("NO need animated")
            imageView.frame.size = newFrame.size
        }
    }
    
    internal func reloadContents() {
        guard self.shouldUpdateImage else {
            return
        }
        self.shouldUpdateImage = false
        self.startLoadingImage()
    }
    
    fileprivate func startLoadingImage() {
        self.imageView.image = nil
        guard let asset = self.asset else {
            return
        }
        
        
        
        KrNrLog.track("Load Big Image/Video. media type=\(asset.mediaType.rawValue)")
        let imageManager = self.imageManager ?? PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast//PHImageRequestOptionsResizeMode.fast
        requestOptions.isSynchronous = false
        
        //self.imageView.contentMode = UIView.ContentMode.center
        self.imageView.image = nil
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            autoreleasepool {
                let scale = UIScreen.main.scale > 2 ? 2 : UIScreen.main.scale
                guard let targetSize = self?.imageSize.scaled(with: scale), self?.asset?.localIdentifier == asset.localIdentifier else {
                    KrNrLog.track("!!!! ID asset NOT MATCH !!!!, assetID=\(self?.asset?.localIdentifier ?? "NO ID" ), assetID2=\(asset.localIdentifier)")
                    return
                }
                
                //KrNrLog.track("REQUEST IMageSIze=\(targetSize)")
                self?.currentRequest = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    DispatchQueue.main.async {
                        autoreleasepool {
                            guard let image = image, self?.asset?.localIdentifier == asset.localIdentifier else {
                                //KrNrLog.track("requestImageCALLBACK, ID NOT MATCH, assetID=\(self?.asset?.localIdentifier ?? "NO ID"), assetID2=\(asset.localIdentifier)")
                                return
                            }
                            
                            //KrNrLog.track("CallBack return image SIZE=\(image.size)")
                            //self?.imageView.contentMode = .scaleAspectFill
                            self?.imageView.image = image
                            self?.imageView.isHidden = (asset.mediaType == .image) ? false : true
                            self?.videoView.isHidden = (asset.mediaType == .image) ? true : false
                            //self?.playButton.isHidden = (asset.mediaType == .image) ? true : false
                            KrNrLog.track("playButton frame=\(self?.playButton.frame)")
                        }
                    }
                }
            }
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
        //KrNrLog.track("scrollViewDidZoom- imageView.frame=\(imageView.frame). ScrollView frame=\(self.frame), imageSize=\(imageView.image?.size), zoomScale=\(scrollView.zoomScale), contentSize=\(scrollView.contentSize), contentOffset=\(contentOffset)")
        
       
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

                //KrNrLog.track("ratioW=\(ratioW), ratioH=\(ratioH), newWidth=\(newWidth), newHeight=\(newHeight)")
                
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

                    
                //KrNrLog.track("contentInset=\(scrollView.contentInset)")
                
            }

            
        } else {
                scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
}


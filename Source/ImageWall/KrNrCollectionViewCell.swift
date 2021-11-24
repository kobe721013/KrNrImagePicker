//
//  KrNrCollectionViewCell.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/26.
//

import UIKit
import Photos
class KrNrCollectionViewCell: UICollectionViewCell {
    
    //
    var imageManager:PHCachingImageManager!
    fileprivate var shouldUpdateImage = false
    private var currentRequest: PHImageRequestID?
    internal var imageSize: CGSize = CGSize(width: 100, height: 100) {
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
    
    
    //
    var index = 0
    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemPink
        return label
    }()

    let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = .red
        //把image超過的部分剪掉，才不會把imageview撐大，導致cell的size跑掉
        imageview.clipsToBounds = true
        return imageview
    }()
        
    override init(frame: CGRect) {
            
        super.init(frame: frame)
        contentView.backgroundColor = .purple
        
        
        self.addSubview(imageView)
        //imageview使用autolayout佈局，或使用下面的frame佈局
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        //add label
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0).isActive = true
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
    
        //imageView使用frame佈局，或使用上面的autoLayout佈局
        //imageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
    }
    
    //
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        
        if let currentRequest = self.currentRequest {
            let imageManager = self.imageManager ?? PHImageManager.default()
            
            print("prepareForReuse, CANCEL requestImage, ID=\(currentRequest)")
            imageManager.cancelImageRequest(currentRequest)
        }

    }
    
    internal func reloadContents() {
        guard self.shouldUpdateImage else {
            return
        }
        self.shouldUpdateImage = false
        
        // Set the correct checkmark color
        //self.iconView.tintColor = self.colors?.checkMark ?? self.colors?.link
        
        self.startLoadingImage()
    }
    
    fileprivate func startLoadingImage() {
        self.imageView.image = nil
        guard let asset = self.asset else {
            return
        }
        let imageManager = self.imageManager ?? PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast//PHImageRequestOptionsResizeMode.fast
        requestOptions.isSynchronous = false
        
        self.imageView.contentMode = UIView.ContentMode.center
        self.imageView.image = nil
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            autoreleasepool {
                let scale = UIScreen.main.scale > 2 ? 2 : UIScreen.main.scale
                guard let targetSize = self?.imageSize.scaled(with: scale), self?.asset?.localIdentifier == asset.localIdentifier else {
                    print("!!!! ID asset NOT MATCH !!!!, assetID=\(self?.asset?.localIdentifier ?? "NO ID" ), assetID2=\(asset.localIdentifier)")
                    return
                }
                
                print("REQUEST IMageSIze=\(targetSize)")
                self?.currentRequest = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    DispatchQueue.main.async {
                        autoreleasepool {
                            guard let image = image, self?.asset?.localIdentifier == asset.localIdentifier else {
                                print("requestImageCALLBACK, ID NOT MATCH, assetID=\(self?.asset?.localIdentifier ?? "NO ID"), assetID2=\(asset.localIdentifier)")
                                return
                            }
                            
                            print("CallBack return image SIZE=\(image.size)")
                            self?.imageView.contentMode = .scaleAspectFill
                            self?.imageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    
    func reloadContent()
    {
        let image = UIImage(named: "web_maintenance")
        self.imageView.image = image
    }
    
    //

}

extension CGSize {
    
    internal func scaled(with scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}


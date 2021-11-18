//
//  KrNrCollectionViewCell.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/26.
//

import UIKit

class KrNrCollectionViewCell: UICollectionViewCell {
    
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

}

//
//  HEPhotoBrowserCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/23.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos
class HEPhotoBrowserCell: UICollectionViewCell {
    var imageView : UIImageView!
    
    var model : HEPhotoPickerListModel!{
        didSet{
            let options = PHImageRequestOptions()
            PHImageManager.default().requestImage(for: model.asset,
                                                  targetSize: self.bounds.size,
                                                  contentMode: .aspectFill,
                                                  options: options)
            { (image, nil) in
                self.imageView.image = image
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        self.contentView.addSubview(imageView)
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

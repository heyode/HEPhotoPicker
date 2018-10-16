//
//  HEPhoneBrowserBottomCell.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/25.
//  Copyright © 2018 heyode. All rights reserved.
//

import UIKit
import Photos
class HEPhoneBrowserBottomCell: UICollectionViewCell {
    var imageView : UIImageView!
    
    private var checkBtnnClickClosure : HEPhotoPickerCellClosure?
    var model : HEPhotoPickerListModel!{
        didSet{
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height * scale)
            PHImageManager.default().requestImage(for: model.asset,
                                                  targetSize: thumbnailSize,
                                                  contentMode: .aspectFill,
                                                  options: nil)
            { (image, nil) in
                self.imageView.image = image
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.black
        self.contentView.addSubview(imageView)
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    override var isSelected: Bool{
        didSet{
            if isSelected {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.themeYellow.cgColor
            }else{
                self.layer.borderWidth = 0
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

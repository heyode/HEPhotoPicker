//
//  MasterCell.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/26.
//  Copyright © 2018 heyode. All rights reserved.
//

import UIKit
import Photos
class MasterCell: UICollectionViewCell {
    typealias MasterCellHandle = ()->Void
    @IBOutlet weak var closeBtn: UIButton!
    var closeBtnClickHandle : MasterCellHandle?
    @IBOutlet weak var imageView: UIImageView!
    var model : HEPhotoPickerListModel!{
        didSet{
            let options = PHImageRequestOptions()
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height * scale)
            PHImageManager.default().requestImage(for: model.asset,
                                                  targetSize: thumbnailSize,
                                                  contentMode: .aspectFill,
                                                  options: options)
            { (image, nil) in
                self.imageView.image = image
            }
        }
    }
    @IBAction func closeBtnClick(_ sender: Any) {
        if let blcok = closeBtnClickHandle{
            blcok()
        }
    }
    
}

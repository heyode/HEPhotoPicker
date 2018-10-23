//
//  MasterCell.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/26.
//  Copyright © 2018 heyode. All rights reserved.
//

import UIKit
import Photos
import HEPhotoPicker
class MasterCell: UICollectionViewCell {
    typealias MasterCellHandle = ()->Void
    @IBOutlet weak var closeBtn: UIButton!
    var closeBtnClickHandle : MasterCellHandle?
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func closeBtnClick(_ sender: Any) {
        if let blcok = closeBtnClickHandle{
            blcok()
        }
    }
    
}

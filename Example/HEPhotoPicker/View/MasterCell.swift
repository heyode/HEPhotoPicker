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
    var representedAssetIdentifier : String!
    @IBOutlet weak var durationLab: UILabel!
    @IBOutlet weak var durationBackView: UIView!
    var mediaModel:HEPhotoPickerListModel!{
        didSet{
            imageView.image = UIImage()

            let options = PHImageRequestOptions()
            let scale : CGFloat = 1.5
            self.representedAssetIdentifier = mediaModel.asset.localIdentifier
            let   thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height  * scale )
            PHImageManager.default().requestImage(for: mediaModel.asset,
                                                  targetSize:thumbnailSize,
                                                  contentMode: .aspectFill,
                                                  options: options)
            { (image, nil) in
                DispatchQueue.main.async {
                    if self.representedAssetIdentifier == self.mediaModel.asset.localIdentifier{
                        self.imageView.image = image
                    }
                }
            }
            
            if mediaModel.asset.mediaType == .video{// 如果是视频,加显示时长标签
                durationBackView.isHidden = false
                let timeStamp = lroundf(Float(mediaModel.asset.duration))
                let s = timeStamp % 60
                let m = (timeStamp - s) / 60 % 60
                let time = String(format: "%.2d:%.2d",  m, s)
                durationLab.text = time
                self.layoutSubviews()
            }else{
                durationBackView.isHidden = true
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setMaskColor()
    }
    func setMaskColor(){
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.clear.cgColor,UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        maskLayer.startPoint = CGPoint.init(x: 0, y: 0)
        maskLayer.endPoint = CGPoint.init(x: 0, y: 1)
        maskLayer.locations = [0,1]
        maskLayer.borderWidth = 0
        self.durationBackView?.layer.insertSublayer(maskLayer, at: 0)
        maskLayer.frame = self.durationBackView.bounds 
    }
    @IBAction func closeBtnClick(_ sender: Any) {
        if let blcok = closeBtnClickHandle{
            blcok()
        }
    }
    
}

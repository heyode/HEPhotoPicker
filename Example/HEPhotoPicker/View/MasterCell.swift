//
//  MasterCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/26.
//  Copyright (c) 2018 heyode <1025335931@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
    var mediaModel:HEPhotoAsset!{
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

//  HEPhotoPickerCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/19.
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
typealias HEPhotoPickerCellClosure = (_ btn: UIButton)->Void
typealias HEPhotoPickerCellAlter = ()->Void
class HEPhotoPickerCell: UICollectionViewCell {
    /// 选择器配置
    public var pickerOptions : HEPickerOptions!{
        didSet{
            checkBtn.setImage(pickerOptions.selectedImage, for: .selected)
            checkBtn.setImage(pickerOptions.unselectedImage, for: .normal)
        }
    }
    var imageView : UIImageView!
    var checkBtn  : UIButton!
    var topView : UIView!
    var durationLab : UILabel!
    var durationBackView : UIView!
    var maskLayer : CAGradientLayer!
    var checkBtnnClickClosure : HEPhotoPickerCellClosure?
    var topViewClickBlock : HEPhotoPickerCellAlter?
    var representedAssetIdentifier : String!
    var model : HEPhotoAsset!{
        didSet{
            imageView.image = UIImage()
            checkBtn.isHidden =  !model.isEnableSelected
            checkBtn.isSelected =  model.isSelected
            topView.isHidden =  model.isEnable
            
            let scale = UIScreen.main.scale / 2
            self.representedAssetIdentifier = model.asset.localIdentifier
            
            let   thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height  * scale )
            imageView.image = nil
            HETool.heRequestImage(for: model.asset,
                                                  targetSize:thumbnailSize,
                                                  contentMode: .aspectFill)
            { (image, nil) in
                DispatchQueue.main.async {
                    if self.representedAssetIdentifier == self.model.asset.localIdentifier{
                        self.imageView.image = image
                    }
                }
            }
            
            if model.asset.mediaType == .video{
                durationBackView.isHidden = false
                let timeStamp = lroundf(Float(self.model.asset.duration))
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
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        checkBtn = UIButton.init(type: .custom)
      
  
        checkBtn.addTarget(self, action: #selector(selectedBtnClick(_:)), for: .touchUpInside)
        contentView.addSubview(checkBtn)
        
        topView = UIView()
        topView.isHidden = true
        topView.backgroundColor = UIColor.init(r: 255, g: 255, b:255, a: 0.6)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(topViewClick))
        contentView.addSubview(topView)
        topView.addGestureRecognizer(tap)
        
        
        durationBackView = UIView()
        durationBackView.backgroundColor = UIColor.clear
        durationBackView.isHidden = true
        contentView.addSubview(durationBackView)
        maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.clear.cgColor,UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor]
        maskLayer.startPoint = CGPoint.init(x: 0, y: 0)
        maskLayer.endPoint = CGPoint.init(x: 0, y: 1)
        maskLayer.locations = [0,1]
        maskLayer.borderWidth = 0
        durationBackView.layer.addSublayer(maskLayer)
        
        durationLab = UILabel()
        durationLab.font = UIFont.systemFont(ofSize: 10)
        durationLab.textColor = UIColor.white
    
        durationBackView.addSubview(durationLab)
       
    }
    
    @objc func topViewClick() {
        if let blcok = topViewClickBlock{
            blcok()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let btnW : CGFloat = 25
        checkBtn.frame = CGRect.init(x: self.bounds.width - 3 - btnW, y: 3, width: btnW, height: btnW)
        topView.frame = contentView.bounds
        let durationBackViewH = CGFloat(20)
        durationBackView.frame = CGRect.init(x: 0, y: self.bounds.height - durationBackViewH, width: self.bounds.width, height: durationBackViewH)
        durationLab.sizeToFit()
        durationLab.frame = CGRect.init(x: durationBackView.bounds.width - durationLab.bounds.width - 5, y: (durationBackViewH - durationLab.bounds.height)/2.0, width: durationLab.bounds.width, height: durationLab.bounds.height)
        maskLayer.frame = self.durationBackView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func selectedBtnClick(_ btn: UIButton){
        btn.isSelected = !btn.isSelected
        if let closure = checkBtnnClickClosure {
            closure(btn)
        }
    }
}

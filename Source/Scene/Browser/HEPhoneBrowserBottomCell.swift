//
//  HEPhoneBrowserBottomCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/25.
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
class HEPhoneBrowserBottomCell: UICollectionViewCell {
    var imageView : UIImageView!
    
    private var checkBtnnClickClosure : HEPhotoPickerCellClosure?
    var model : HEPhotoAsset!{
        didSet{
            let scale = UIScreen.main.scale / 2
            let thumbnailSize = CGSize(width: self.bounds.size.width * scale, height: self.bounds.size.height * scale)
            HETool.heRequestImage(for: model.asset,
                                                  targetSize: thumbnailSize,
                                                  contentMode: .aspectFill)
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

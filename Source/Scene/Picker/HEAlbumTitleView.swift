//
//  HEAlbumTitleView.swift
//  HEPhotoPicker
//
//  Created by heyode on 2018/10/30.
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


class HEAlbumTitleView: UIButton {

    //MARK:- 重写init函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage.heinit(name: "nav-arrow-down"), for: .normal)
        setImage(UIImage.heinit(name: "nav-arrow-up"), for: .selected)
        setTitleColor(UIColor.hex(hexString: "222222"), for: .normal)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin = CGFloat(8)
        let btnW = frame.size.width
        let w = titleLabel!.frame.size.width + imageView!.frame.size.width + margin
        titleLabel!.frame.origin.x = (btnW-w)*0.5
        imageView!.frame.origin.x = titleLabel!.frame.maxX + margin
    }
    
}

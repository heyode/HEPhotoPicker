//
//  HEAlbumTitleView.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/10/30.
//

import UIKit


class HEAlbumTitleView: UIButton {
    
    
    //MARK:- 重写init函数
    override init(frame: CGRect) {
        super.init(frame: frame)

        setImage(UIImage.init(named: "nav-arrow-down", in: HETool.bundle, compatibleWith: nil), for: .normal)
        setImage(UIImage.init(named: "nav-arrow-up", in: HETool.bundle, compatibleWith: nil), for: .selected)
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

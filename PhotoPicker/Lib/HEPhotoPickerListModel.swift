//
//  HEPhotoPickerListModel.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/22.
//  Copyright © 2018年 heyode. All rights reserved.
//

import Foundation
import UIKit
import Photos
public class HEPhotoPickerListModel : NSObject{
  

    // 是否选中
    var isSelected = false
    // 是否不可点击，
    var isEnable = true
    var asset = PHAsset()
    // 当前索引
    var index : Int = 0
    init(asset:PHAsset) {
        self.asset = asset
    }
    
}

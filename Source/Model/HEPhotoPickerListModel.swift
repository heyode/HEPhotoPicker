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
    public  var isSelected = false
    // 是否不可点击，
    public  var isEnable = true
    // 图片集合
    public var asset = PHAsset()
    // 当前索引
    public  var index : Int = 0
    init(asset:PHAsset) {
        self.asset = asset
    }
    
}

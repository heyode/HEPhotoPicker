//
//  HEPickerOptions.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/11/20.
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

public enum HEMediaType : Int {
    /// 只显示图片
    case image
    /// 只显示视频
    case video
    /// 所有类型都显示,并且都可以选择
    case imageAndVideo
    /// 所有类型都显示,但只能选一类
    case imageOrVideo
}

open class HEPickerOptions: NSObject {
    /// 要挑选的数据类型
    public var mediaType : HEMediaType = .imageAndVideo
    /// 列表是否按创建时间升序排列
    public var ascendingOfCreationDateSort : Bool = false
    /// 挑选图片的最大个数
    public var maxCountOfImage = 9
    /// 挑选视频的最大个数
    public var maxCountOfVideo = 2
    /// 是否支持图片单选，默认是false，如果是ture只允许选择一张图片（如果 mediaType = imageAndVideo 或者 imageOrVideo 此属性无效）
    public var singlePicture = false
    /// 是否支持视频单选 默认是false，如果是ture只允许选择一个视频（如果 mediaType = imageAndVideo 此属性无效）
    public var singleVideo = false
    ///  实现多次累加选择时，需要传入的选中的模型。为空时表示不需要多次累加
    public var defaultSelections : [HEPhotoAsset]?
    ///  选中样式图片
    public var selectedImage = UIImage.heinit(name: "btn-check-selected")
    ///  未选中样式图片
    public var unselectedImage = UIImage.heinit(name: "btn-check-normal")
    
    ///  自定义字符串
    public var cancelButtonTitle = "取消"
    public var selectDoneButtonTitle = "选择"
    public var maxPhotoWaringTips = "最多只能选择%d个照片"
    public var maxVideoWaringTips = "最多只能选择%d个视频"
    
}

//
//  HEPhotoPickerOptions.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/11/20.
//  Copyright © 2018 heyode. All rights reserved.
//

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

open class HEPhotoPickerOptions: NSObject {
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
    public var defaultSelections : [HEPhotoPickerListModel]?
}

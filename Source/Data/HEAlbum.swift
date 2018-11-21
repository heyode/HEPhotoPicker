//
//  HEAlbum.swift
//  HEPhotoPicker
//
//  Created by heyode on 2018/11/5.
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

/// 相册对象
public class HEAlbum: NSObject {
    
    /// 相册里的数据
    var fetchResult : PHFetchResult<PHAsset>!
    /// 相册的封面
    var albumCover : PHAsset?
    /// 相册标题
    var title : String?
    /// 相册的照片个数
    var count : Int!
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - result: 相册数据
    ///   - title: 标题
    init(result:PHFetchResult<PHAsset>,title:String?) {
        self.title = title
        fetchResult = result
        count = fetchResult.count
        if fetchResult.count > 0 {
            albumCover = fetchResult.firstObject
        }
        
    }
    
}

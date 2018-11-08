//
//  HEAlbum.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/11/5.
//

import UIKit
import Photos
public class HEAlbum: NSObject {
    var fetchResult : PHFetchResult<PHAsset>!
    var albumCover : PHAsset?
    var title : String?
    var count : Int!
    init(result:PHFetchResult<PHAsset>,title:String?) {
        self.title = title
        fetchResult = result
        count = fetchResult.count
        if fetchResult.count > 0 {
            albumCover = fetchResult.firstObject
        }
        
    }
    
}

//
//  HEPhotoManager.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/11/16.
//  Copyright © 2018 heyode. All rights reserved.
//

import UIKit

public class HEPhotoDataManager: NSObject {
    
    public private(set) var photoAssets : [HEPhotoPickerListModel]
    
    private var selectedPhotoIndexes = [Int]()

    init(photoAssets:[HEPhotoPickerListModel]) {
        self.photoAssets = photoAssets
       
    }

   
   
    
    
    
}

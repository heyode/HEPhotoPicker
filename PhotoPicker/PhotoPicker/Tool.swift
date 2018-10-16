//
//  Tool.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/26.
//  Copyright © 2018 heyode. All rights reserved.
//

import Foundation


class Tool: NSObject {
    static func isiPhoneX() -> Bool {
        if kScreenHeight == 812 {
            return true
        }else{
            return false
        }
    }
}

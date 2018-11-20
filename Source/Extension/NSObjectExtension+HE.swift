//
//  NSObjectExtension.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
//

import Foundation
extension NSObject {
    public var className: String {
        return type(of: self).className
    }
    
    public static var className: String {
        return String(describing: self)
    }
}

extension Sequence {
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self {
            if try predicate(element) {
                count += 1
            }
        }
        return count
    }
}


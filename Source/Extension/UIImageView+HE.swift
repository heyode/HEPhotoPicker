//
//  UIImageView+HE.swift
//  HEPhotoPicker
//
//  Created by heyode on 8/31/19.
//

import Foundation

extension UIImage {
    public static func heinit(name:String) -> UIImage?{
        return UIImage(named: name, in: Bundle.heBundle, compatibleWith: nil)
    }

  
}

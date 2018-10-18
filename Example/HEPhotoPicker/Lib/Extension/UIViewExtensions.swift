//
//  UIViewExtensions.swift
//  guiai
//
//  Created by apple on 2018/7/19.
//  Copyright © 2018年 youkouxin. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        // also  set(newValue)
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var maskToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        // also  set(newValue)
        set {
            layer.masksToBounds = newValue
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor.init(cgColor:  layer.borderColor!)
        }
        // also  set(newValue)
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        // also  set(newValue)
        set {
            layer.borderWidth = newValue
        }
    }
}

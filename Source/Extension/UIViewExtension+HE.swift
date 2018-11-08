//
//  NSObjectExtension.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
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
public extension UIViewController {
    
     /// 自定义present方法
     ///
     /// - Parameters:
     ///   - picker: 图片选择器
     ///   - maxCount: 选择图片的最大个数（默认是9）
     ///   - defaultSelections: 已选择的模型（多次累加选择时用）
    public func hePresentPhotoPickerController(picker:HEPhotoPickerViewController ,
                                         defaultSelections:[HEPhotoPickerListModel] = [HEPhotoPickerListModel]()){
     
        let nav = UINavigationController.init(rootViewController: picker)
        present(nav, animated: true, completion: nil)
    }
}

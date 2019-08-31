//
//  NSObjectExtension.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/19.
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
    ///   - animated: 是否需要动画
    func hePresentPhotoPickerController(picker:HEPhotoPickerViewController,animated: Bool){
        let nav = UINavigationController.init(rootViewController: picker)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: animated, completion: nil)
    }
    
      func presentAlert(title:String){
        let title = title
        let alertView = UIAlertController.init(title: "提示", message: title, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
}

//
//  Tool.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/26.
//  Copyright © 2018 heyode. All rights reserved.
//

import Foundation


class HETool: NSObject {
    static var  bundle = Bundle(path: Bundle(for: HETool.self).path(forResource: "HEPhotoPicker", ofType: "bundle")!)!
    
    static func isiPhoneX() -> Bool {
        if kScreenHeight == 812 {
            return true
        }else{
            return false
        }
    }
    static func presentAlert(title:String,viewController:UIViewController){
        let title = title
        let alertView = UIAlertController.init(title: "提示", message: title, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in }
        alertView.addAction(okAction)
        viewController.present(alertView, animated: true, completion: nil)
    }
    
}

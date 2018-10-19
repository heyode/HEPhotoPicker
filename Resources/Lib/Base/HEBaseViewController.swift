//
//  HEBaseViewController.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit

public class HEBaseViewController: UIViewController {

  public  override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
      
    }
    
  public  override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationBar()
    }
    

    
    func configNavigationBar() {
        guard let navi = navigationController else { return }
        if navi.visibleViewController == self {
            navi.navigationBar.barStyle = .default
            navi.navigationBar.setBackgroundImage(UIColor.white.image(), for: .default)
            navi.navigationBar.shadowImage = nil
            navi.setNavigationBarHidden(false, animated: true)
            if navi.viewControllers.count > 1 {
                let budle = Bundle(path: Bundle(for: HEBaseViewController.self).path(forResource: "HEPhotoPicker", ofType: "bundle")!)!
                let backImage = UIImage(named: "nav_back", in: budle, compatibleWith: nil)
                
                navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: backImage?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(pressBack))
            }
        }
    }
    
    @objc func pressBack() {
        navigationController?.popViewController(animated: true)
    }
}

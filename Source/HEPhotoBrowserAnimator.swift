//
//  HEPhotoBrowserAnimator.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/20.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit

//MARK: - 定义协议用来拿到图片起始位置;最终位置和图片
protocol HEPhotoBrowserAnimatorPushDelegate : class {

    /// 获取图片动画前的位置
    ///
    /// - Parameter indexPath: 图片的下标
    /// - Returns: 动画开始前图片在keywindow上的frame
    func imageViewRectOfAnimatorStart(at indexPath : IndexPath) ->CGRect
   
    
    /// 获取图片动画后的位置
    ///
    /// - Parameter indexPath: 图片的下标
    /// - Returns: 动画开始后图片在keywindow上的frame
    func imageViewRectOfAnimatorEnd(at indexPath : IndexPath) ->CGRect
    
    
    /// 获取点击的imageView
    ///
    /// - Parameter indexPath: 图片所在下标
    /// - Returns: 一个和点击的图片宽高比相同的图片视图
    func imageView(at indexPath : IndexPath) ->UIImageView
}

protocol HEPhotoBrowserAnimatorPopDelegate : class{
    /// 获取当前浏览的图片的下标
    ///
    /// - Returns: 当前浏览图片的下标
    func indexOfPopViewImageView() -> IndexPath
    
    /// 获取当前浏览的图片
    ///
    /// - Returns: 当前浏览的图片
    func imageViewOfPopView() -> UIImageView
}

class HEPhotoBrowserAnimator: NSObject {
    weak var popDelegate : HEPhotoBrowserAnimatorPopDelegate?
    weak var pushDelegate : HEPhotoBrowserAnimatorPushDelegate?
    // 用于接受外界的图片索引
    var selIndex : IndexPath?
  
    // 用于接受外界的operation
    var operation:UINavigationController.Operation!
    
   
    func popAnimator(transitionContext: UIViewControllerContextTransitioning) {
        let containerview = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromVC!.view
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! HEPhotoPickerViewController
        let toView = toVC.view

        toView?.alpha = 0
        containerview.backgroundColor = UIColor.clear
        guard let popDel = popDelegate else {
            return
        }
     
         containerview.insertSubview(toView!, aboveSubview: fromView!)
        let imageView: UIImageView = popDel.imageViewOfPopView()
        imageView.contentMode = .scaleAspectFill
        containerview.addSubview(imageView)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            imageView.frame = toVC.homeFrame
             toView?.alpha = 1.0
        }) { (finished: Bool) in
            imageView.removeFromSuperview()
             containerview.backgroundColor = UIColor.clear
            //告诉上下文动画完成
            transitionContext.completeTransition(true)
        }
    }
    func pushAnimator(transitionContext: UIViewControllerContextTransitioning) {
        let containerview = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toVC?.view
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromView = fromVC?.view
        
        toView?.isHidden = true
        containerview.addSubview(toView!)
        //3 执行动画
        //3.1 获取需要执行的imageView
        guard let pushDel = pushDelegate else {
            return
        }
        guard let indexPath = selIndex else {
            return
        }
        //调用方法,得到一张图片
        let imageView = pushDel.imageView(at: indexPath)
        let bgView = UIView.init(frame: containerview.bounds)
        bgView.backgroundColor = UIColor.black
        bgView.addSubview(imageView)
        //将图片添加到父控件中
        containerview.addSubview(bgView)
        
        //设置imageView的起始位置
        
        imageView.frame = pushDel.imageViewRectOfAnimatorStart(at: indexPath)
        
        //设置弹出动画的时候背景颜色为黑色
        fromView?.alpha = 0
        containerview.backgroundColor = UIColor.black
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            imageView.frame = pushDel.imageViewRectOfAnimatorEnd(at: indexPath)
            fromView?.alpha = 1.0
        },completion: { finished in
//            toView?.alpha = 1.0
            bgView.removeFromSuperview()
            toView?.isHidden = false
            
            containerview.backgroundColor = UIColor.clear
            //完成动画
            transitionContext.completeTransition(true)
        })
    }
    
    
    
   
}

extension HEPhotoBrowserAnimator : UIViewControllerAnimatedTransitioning{
    // 返回动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    // 要设置的动画
    //UIKit calls this method when presenting or dismissing a view controller. Use this method to configure the animations associated with your custom transition. You can use view-based animations or Core Animation to configure your animations.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.operation ==  UINavigationController.Operation.pop {
         popAnimator(transitionContext: transitionContext)
        } else {
         pushAnimator(transitionContext: transitionContext)
        }
        
    }
}


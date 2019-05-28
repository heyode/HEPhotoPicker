//
//  HEPhotoBrowserAnimator.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/20.
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

//MARK: - push或者present目标vc需要实现的协议
public protocol HETargetViewControllerDelegate : UIViewController {
    
     /// 目标vc需要展示的UIImageView
     ///
     /// - Returns: 目标vc需要展示的UIImageView
     func getTargetImageView() -> UIImageView
}
//MARK: - 定义协议用来拿到图片起始位置;最终位置和图片
public protocol HEPhotoBrowserAnimatorPushDelegate : class {
    
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
    
    
}

public protocol HEPhotoBrowserAnimatorPopDelegate : class{
    /// 获取当前浏览的图片的下标
    ///
    /// - Returns: 当前浏览图片的下标
    func indexOfPopViewImageView() -> IndexPath
    
    /// 获取当前浏览的图片
    ///
    /// - Returns: 当前浏览的图片
    func imageViewOfPopView() -> UIImageView
}
public enum HETransitionType :Int {
    case navigation
    case modal
}


public class HEPhotoBrowserAnimator: NSObject {
    public var transitionType : HETransitionType = .navigation
    /// transitionType == modal时，判断当前动画是present还是dismiss
    public var isPresented: Bool!
    public  weak var popDelegate : HEPhotoBrowserAnimatorPopDelegate?
    public  weak var pushDelegate : HEPhotoBrowserAnimatorPushDelegate?
    // 用于接受外界的图片索引
    public var selIndex : IndexPath?
    
    // 用于接受外界的operation
    public var operation:UINavigationController.Operation!
    
    // dimmiss不能共用单独写出来
    public func dimmiss(transitionContext: UIViewControllerContextTransitioning){
        guard let popDel = popDelegate ,let index = popDelegate?.indexOfPopViewImageView(),let toFrame = pushDelegate?.imageViewRectOfAnimatorStart(at: index)else {
            return
        }
        let containerview = transitionContext.containerView
      
        let tempImageView = UIImageView()
        tempImageView.image = popDel.imageViewOfPopView().image
        tempImageView.frame = popDel.imageViewOfPopView().frame
        tempImageView.layer.masksToBounds = true
        tempImageView.contentMode = .scaleAspectFill
        containerview.addSubview(tempImageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            tempImageView.frame = toFrame
        }) { (finished: Bool) in
            //告诉上下文动画完成
            transitionContext.completeTransition(true)
        }
    }
    public func popAnimator(transitionContext: UIViewControllerContextTransitioning,isPop:Bool ) {
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) , let popDel = popDelegate ,let index = popDelegate?.indexOfPopViewImageView(),let toFrame = pushDelegate?.imageViewRectOfAnimatorStart(at: index) else {
            return
        }
        let containerview = transitionContext.containerView
     
            if isPop { // pop时的处理
                toViewController.view.alpha = 0
                containerview.addSubview(toViewController.view)
            }else{// dismiss时特殊处理
                let dismissView = transitionContext.view(forKey: UITransitionContextViewKey.from)
                dismissView?.removeFromSuperview()
            }
          
     
        let tempImageView = UIImageView()
        tempImageView.image = popDel.imageViewOfPopView().image
        tempImageView.frame = popDel.imageViewOfPopView().frame
        tempImageView.layer.masksToBounds = true
        tempImageView.contentMode = .scaleAspectFill
        containerview.addSubview(tempImageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            tempImageView.frame = toFrame
            if isPop == true{// pop时的处理
               toViewController.view.alpha = 1.0
            }
            
        }) { (finished: Bool) in
            if isPop{// pop时的处理
                tempImageView.removeFromSuperview()
            }
            //告诉上下文动画完成
            transitionContext.completeTransition(true)
        }
    }
    public func pushAnimator(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? HETargetViewControllerDelegate, let pushDel = pushDelegate,let indexPath = selIndex else {
            return
        }
        let containerView = transitionContext.containerView
        
        let backgroundView = UIView.init(frame: containerView.bounds)
        backgroundView.backgroundColor = UIColor.black
        containerView.addSubview(backgroundView)
        containerView.addSubview(toViewController.view)
        
        let animateImageView = toViewController.getTargetImageView()
        animateImageView.frame =  pushDel.imageViewRectOfAnimatorStart(at: indexPath)
        backgroundView.addSubview(animateImageView)
        
       
        let targartSize = zommView(orgmSize: toViewController.getTargetImageView().frame.size)
        toViewController.view.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            animateImageView.frame = CGRect.init(origin: CGPoint.zero, size: targartSize)
            animateImageView.center = backgroundView.center
            
        },completion: { finished in
            
            backgroundView.removeFromSuperview()
            toViewController.view.isHidden = false
            transitionContext.completeTransition(true)
        })
    }
    
    
   private func zommView(orgmSize:CGSize) -> CGSize {
        var  culH = kScreenHeight
        let culW = kScreenWidth
        let x = orgmSize.width / kScreenWidth
        culH = orgmSize.height * x
        return CGSize.init(width: culW, height: culH)
    }
    
   
    
}

extension HEPhotoBrowserAnimator : UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    // 返回动画时间
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    // 要设置的动画
    //UIKit calls this method when presenting or dismissing a view controller. Use this method to configure the animations associated with your custom transition. You can use view-based animations or Core Animation to configure your animations.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if transitionType == .navigation{
            // 用于push时的过场动画
            if operation ==  UINavigationController.Operation.pop {
                popAnimator(transitionContext: transitionContext,isPop: true)
            } else {
                pushAnimator(transitionContext: transitionContext)
            }
        }else{
            // 用于present时的过场动画
            if isPresented {
                pushAnimator(transitionContext: transitionContext)
            } else {
                popAnimator(transitionContext: transitionContext,isPop: false)
            }
            
        }
        
        
    }
}


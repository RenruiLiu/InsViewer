//
//  CustomAnimationPresentor.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // custom trainsition animation
        let containerView = transitionContext.containerView
        // fromView is the original view(home)
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        // toView is the target view(camera)
        guard let toView = transitionContext.view(forKey: .to) else {return}
        containerView.addSubview(toView)
        
        // toView starts from the left side(negative) of screen
        let startingFrame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // animation
            // toView move to the screen x=0 y=0
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            // fromView move to the right side of screen
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}


class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // custom trainsition animation
        let containerView = transitionContext.containerView
        // fromView is the original view(camera)
        guard let fromView = transitionContext.view(forKey: .from) else {return}
         // toView is the target view(Home)
        guard let toView = transitionContext.view(forKey: .to) else {return}
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // animation
            // fromView move to the left side of screen
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            // toView move to the screen
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)

        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
    
}


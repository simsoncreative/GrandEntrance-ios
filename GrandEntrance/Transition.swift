//
//  Transition.swift
//  GrandEntrance
//
//  Created by Alexander Simson on 2014-08-21.
//  Copyright (c) 2014 Simson Creative Solutions. All rights reserved.
//

import UIKit

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.35;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        
        toView!.frame = CGRectMake(0, transitionContext.containerView().frame.height, 320, transitionContext.containerView().frame.height - 50.0)
        
        transitionContext.containerView().addSubview(toView!)
        
        let positionAnimation = POPSpringAnimation(tension: 50, friction: 10, mass: 1)
        positionAnimation.property = POPAnimatableProperty(name: kPOPLayerPositionY)
        positionAnimation.springBounciness = 8.0
        positionAnimation.toValue = toView!.frame.height/2.0 + 50.0;
        positionAnimation.completionBlock = { _, _ in transitionContext.completeTransition(true) }

        let scaleAnimation = POPSpringAnimation(tension: 100, friction: 10, mass: 1)
        scaleAnimation.property = POPAnimatableProperty(name: kPOPLayerScaleXY)
        scaleAnimation.springBounciness = 15.0
        scaleAnimation.toValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        
        let opacityAnimation = POPBasicAnimation()
        opacityAnimation.property = POPAnimatableProperty(name: kPOPLayerOpacity)
        opacityAnimation.toValue = 0.5
        
        addAnimation(opacityAnimation, opacityAnimation.property.name, fromView!.layer)
        addAnimation(positionAnimation, positionAnimation.property.name, toView!.layer)
        addAnimation(scaleAnimation, scaleAnimation.property.name, fromView!.layer)
    }
}


class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.35;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        
        let positionAnimation = POPBasicAnimation()
        positionAnimation.property = POPAnimatableProperty(name: kPOPLayerPositionY)
        positionAnimation.toValue = transitionContext.containerView().frame.height + fromView!.frame.height/2.0
        positionAnimation.completionBlock = { _, _ in transitionContext.completeTransition(true) }
        
        let scaleAnimation = POPSpringAnimation(tension: 100, friction: 10, mass: 1)
        scaleAnimation.property = POPAnimatableProperty(name: kPOPLayerScaleXY)
        scaleAnimation.springBounciness = 15.0
        scaleAnimation.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        
        let opacityAnimation = POPBasicAnimation()
        opacityAnimation.property = POPAnimatableProperty(name: kPOPLayerOpacity)
        opacityAnimation.toValue = 1.0
        
        addAnimation(positionAnimation, positionAnimation.property.name, fromView!.layer)
        addAnimation(opacityAnimation, opacityAnimation.property.name, toView!.layer)
        addAnimation(scaleAnimation, scaleAnimation.property.name, toView!.layer)
    }
}
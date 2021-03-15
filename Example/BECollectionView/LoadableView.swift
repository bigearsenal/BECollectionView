//
//  LoadableView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView

private var loadingHandle: UInt8 = 0

protocol LoadableView: BELoadableViewType {
    var loadingViews: [UIView] {get}
}

extension LoadableView {
    func showLoading() {
        hideLoading()
        layoutSubviews()
        loadingViews.forEach {
            if let view = $0 as? LoadableView {
                view.showLoading()
                return
            }
            self.addLoadingLayer(for: $0)
        }
    }
    
    func hideLoading() {
        loadingViews.forEach {
            if let view = $0 as? LoadableView {
                view.hideLoading()
                return
            }
            (objc_getAssociatedObject($0, &loadingHandle) as? CAGradientLayer)?.removeFromSuperlayer()
            $0.layer.sublayers?.forEach {$0.isHidden = false}
        }
    }
    
    private func addLoadingLayer(for view: UIView) {
        // get loader
        let loaderLayer = CAGradientLayer()
        
        view.layoutIfNeeded()
        
        let gradientWidth = 0.17
        let gradientFirstStop = 0.1
        let loaderDuration = 0.85
        
        loaderLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        var cornerRadius: CGFloat = 8
        if view.bounds.size.height < 16 {
            cornerRadius = view.bounds.size.height / 2
        }
        loaderLayer.cornerRadius = cornerRadius
        loaderLayer.masksToBounds = true
        loaderLayer.backgroundColor = UIColor.white.cgColor
        view.layer.sublayers?.forEach {$0.isHidden = true}
        view.layer.addSublayer(loaderLayer)
        loaderLayer.startPoint = CGPoint(x: -1.0 + CGFloat(gradientWidth), y: 0)
        loaderLayer.endPoint = CGPoint(x: 1.0 + CGFloat(gradientWidth), y: 0)
        
        loaderLayer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.24).cgColor,
            UIColor.black.withAlphaComponent(0.48).cgColor,
            UIColor.black.withAlphaComponent(0.24).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor
        ]
        
        let startLocations = [
            NSNumber(value: Double(loaderLayer.startPoint.x)),
            NSNumber(value: Double(loaderLayer.startPoint.x)),
            NSNumber(value: 0 as Double),
            NSNumber(value: gradientWidth as Double),
            NSNumber(value: 1 + gradientWidth as Double)
        ]
        
        loaderLayer.locations = startLocations
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = startLocations
        gradientAnimation.toValue = [
            NSNumber(value: 0 as Double),
            NSNumber(value: 1 as Double),
            NSNumber(value: 1 as Double),
            NSNumber(value: 1 + (gradientWidth - gradientFirstStop) as Double),
            NSNumber(value: 1 + gradientWidth as Double)
        ]
        
        gradientAnimation.repeatCount = Float.infinity
//        gradientAnimation.fillMode = .forwards
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.duration = loaderDuration
        loaderLayer.add(gradientAnimation, forKey: "locations")
        
        // save loader
        objc_setAssociatedObject(view, &loadingHandle, loaderLayer, .OBJC_ASSOCIATION_RETAIN)
    }
}

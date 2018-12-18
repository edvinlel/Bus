//
//  Extensions.swift
//  Bus
//
//  Created by Edvin Lellhame on 12/17/18.
//  Copyright © 2018 Edvin Lellhame. All rights reserved.
//

import UIKit

extension UIView {
    //    @discardableResult func anchor(top: NSLayoutYAxisAnchor?, paddingTop: CGFloat, left: NSLayoutXAxisAnchor?, paddingLeft: CGFloat, bottom: NSLayoutYAxisAnchor?, paddingBottom: CGFloat, right: NSLayoutXAxisAnchor?, paddingRight: CGFloat, width: CGFloat, height: CGFloat, withCached cachedConstraints: [NSLayoutConstraint] = []) -> [NSLayoutConstraint] {
    //
    //        NSLayoutConstraint .deactivate(cachedConstraints)
    //        translatesAutoresizingMaskIntoConstraints = false
    //        var resultConstraints: [NSLayoutConstraint] = []
    //
    //        if let top = top {
    //            let topConstraint = self.topAnchor.constraint(equalTo: top, constant: paddingTop)
    //            resultConstraints.append(topConstraint)
    //            topConstraint.isActive = true
    //        }
    //
    //        if let left = left {
    //            let leftConstraint = self.leftAnchor.constraint(equalTo: left, constant: paddingLeft)
    //            resultConstraints.append(leftConstraint)
    //            leftConstraint.isActive = true
    //        }
    //
    //        if let bottom = bottom {
    //            let bottomConstraint = self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom)
    //            resultConstraints.append(bottomConstraint)
    //            bottomConstraint.isActive = true
    //       }
    //
    //        if let right = right {
    //            let rightConstraint = self.rightAnchor.constraint(equalTo: right, constant: -paddingRight)
    //            resultConstraints.append(rightConstraint)
    //            rightConstraint.isActive = true
    //       }
    //
    //        if width != 0 {
    //            let widthConstraint = widthAnchor.constraint(equalToConstant: width)
    //            resultConstraints.append(widthConstraint)
    //            widthConstraint.isActive = true
    //       }
    //
    //        if height != 0 {
    //            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
    //            resultConstraints.append(heightConstraint)
    //            heightConstraint.isActive = true
    //        }
    //
    //        return resultConstraints
    //    }
    
    @discardableResult func anchor(top: NSLayoutYAxisAnchor?, paddingTop: CGFloat, leading: NSLayoutXAxisAnchor?, paddingLeading: CGFloat, bottom: NSLayoutYAxisAnchor?, paddingBottom: CGFloat, trailing: NSLayoutXAxisAnchor?, paddingTrailing: CGFloat, width: CGFloat, height: CGFloat, withCached cachedConstraints: [NSLayoutConstraint] = []) -> [NSLayoutConstraint] {
        
        NSLayoutConstraint .deactivate(cachedConstraints)
        
        translatesAutoresizingMaskIntoConstraints = false
        var resultConstraints: [NSLayoutConstraint] = []
        
        if let top = top {
            let topConstraint = self.topAnchor.constraint(equalTo: top, constant: paddingTop)
            resultConstraints.append(topConstraint)
            topConstraint.isActive = true
        }
        
        if let leading = leading {
            let leadingConstraint = self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading)
            resultConstraints.append(leadingConstraint)
            leadingConstraint.isActive = true
        }
        
        if let bottom = bottom {
            let bottomConstraint = self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom)
            resultConstraints.append(bottomConstraint)
            bottomConstraint.isActive = true
        }
        
        if let trailing = trailing {
            let trailingConstraint = self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing)
            resultConstraints.append(trailingConstraint)
            trailingConstraint.isActive = true
        }
        
        if width != 0 {
            let widthConstraint = widthAnchor.constraint(equalToConstant: width)
            resultConstraints.append(widthConstraint)
            widthConstraint.isActive = true
        }
        
        if height != 0 {
            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
            resultConstraints.append(heightConstraint)
            heightConstraint.isActive = true
        }
        
        return resultConstraints
    }
}

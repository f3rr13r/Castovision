//
//  UIView.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/28/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

// anchoring
extension UIView {
    
    /*-- GROUPED CONSTRAINT DECLARATION -- */
    func anchor(withTopAnchor top: NSLayoutYAxisAnchor?, leadingAnchor leading: NSLayoutXAxisAnchor?, bottomAnchor bottom: NSLayoutYAxisAnchor?, trailingAnchor trailing: NSLayoutXAxisAnchor?, centreXAnchor centreX: NSLayoutXAxisAnchor?, centreYAnchor centreY: NSLayoutYAxisAnchor?, widthAnchor width: CGFloat? = nil, heightAnchor height: CGFloat? = nil, padding: UIEdgeInsets = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: padding.right).isActive = true
        }
        
        if let centreX = centreX {
            centerXAnchor.constraint(equalTo: centreX).isActive = true
        }
        
        if let centreY = centreY {
            centerYAnchor.constraint(equalTo: centreY).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
    /*-- INDIVIDUAL CONSTRAINT DECLARATIONS -- */
    
    // Top
    func setTopAnchor(to view: UIView, withConstant constant: CGFloat = 0) {
        let topAnchor = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: constant)
        self.addConstraint(topAnchor)
    }
    
    // Leading
    func setLeadingAnchor(to view: UIView, withConstant constant: CGFloat = 0) {
        let leadingAnchor = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: constant)
        self.addConstraint(leadingAnchor)
    }
    
    // Bottom
    func setBottomAnchor(to view: UIView, withConstant constant: CGFloat = 0) {
        let bottomAnchor = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: constant)
        self.addConstraint(bottomAnchor)
    }
    
    // Trailing
    func setTrailingAnchor(to view: UIView, withConstant constant: CGFloat = 0) {
        let trailingAnchor = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: constant)
        self.addConstraint(trailingAnchor)
    }
    
    // Width
    func setWidthAnchor(toWidth width: CGFloat) {
        let widthAnchor = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
        self.addConstraint(widthAnchor)
    }
    
    // Height
    func setHeightAnchor(toHeight height: CGFloat) {
        let heightAnchor = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)
        self.addConstraint(heightAnchor)
    }
    
    // Width and height
    func setSize(withWidth width: CGFloat, andHeight height: CGFloat) {
        let widthAnchor = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
        let heightAnchor = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)
        self.addConstraints([widthAnchor, heightAnchor])
    }
    
    
    /*-- RELATION BASED CONSTRAINT DELCARATIONS --*/
    
    // Centre view horizontally and vertically to another view
    func centre(to view: UIView) {
        let centreX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centreY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        self.addConstraints([centreX, centreY])
    }
    
    // Centre view horizontally to another view
    func centreHorizontally(to view: UIView) {
        let centreX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        self.addConstraint(centreX)
    }
    
    
    // Centre view vertically to another view
    func centreVertically(to view: UIView) {
        let centreY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        self.addConstraint(centreY)
    }
    
    
    // Match size to exact size of another view
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    
    // Match size to exact size of superview
    func fillSuperview() {
        anchor(withTopAnchor: superview?.topAnchor, leadingAnchor: superview?.leadingAnchor, bottomAnchor: superview?.bottomAnchor, trailingAnchor: superview?.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
    }
    
}

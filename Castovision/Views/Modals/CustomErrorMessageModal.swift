//
//  CustomErrorMessageModal.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/18/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

struct CustomErrorMessageConfig {
    var title: String
    var body: String
}

class CustomErrorMessageModal: BaseView {
    
    let errorMessageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = grey
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.layer.shadowRadius = 10
        return view
    }()
    var errorMessageTopAnchorContainer: NSLayoutConstraint?
    
    let errorMessageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        label.numberOfLines = 0
        return label
    }()
    
    let errorMessageBodyLabel: UILabel = {
        let label = UILabel()
        label.font = defaultContentFont
        label.textColor = darkGrey
        label.numberOfLines = 0
        return label
    }()
    
    override func setupView() {
        super.setupView()
        isHidden = true
        setupDismissErrorMessageTapGesture()
        anchorChildViews()
    }
    
    func setupDismissErrorMessageTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideErrorMessage))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    func anchorChildViews() {
        addSubview(errorMessageContainer)
        errorMessageContainer.anchor(withTopAnchor: nil, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: centerXAnchor, centreYAnchor: nil)
        errorMessageTopAnchorContainer = NSLayoutConstraint(item: errorMessageContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -1000.0)
        addConstraint(errorMessageTopAnchorContainer!)
        
        errorMessageContainer.addSubview(errorMessageTitleLabel)
        errorMessageTitleLabel.anchor(withTopAnchor: errorMessageContainer.safeAreaLayoutGuide.topAnchor, leadingAnchor: errorMessageContainer.leadingAnchor, bottomAnchor: nil, trailingAnchor: errorMessageContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        errorMessageContainer.addSubview(errorMessageBodyLabel)
        errorMessageBodyLabel.anchor(withTopAnchor: errorMessageTitleLabel.bottomAnchor, leadingAnchor: errorMessageContainer.leadingAnchor, bottomAnchor: errorMessageContainer.bottomAnchor, trailingAnchor: errorMessageContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 14.0, left: horizontalPadding, bottom: -14.0, right: -horizontalPadding))
    }
    
    func showErrorMessageContainer(withErrorMessageConfig errorMessageConfig: CustomErrorMessageConfig) {
        errorMessageTitleLabel.text = errorMessageConfig.title
        errorMessageBodyLabel.text = errorMessageConfig.body
        isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.errorMessageTopAnchorContainer?.constant = 0
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func hideErrorMessage() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.errorMessageTopAnchorContainer?.constant = -self.frame.height
            self.layoutIfNeeded()
        }) { (animationComplete) in
            if animationComplete {
                self.errorMessageTitleLabel.text = ""
                self.errorMessageBodyLabel.text = ""
                self.isHidden = true
            }
        }
    }
}

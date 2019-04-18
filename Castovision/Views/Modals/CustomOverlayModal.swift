//
//  CustomOverlayModal.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/18/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class CustomModalOverlay: BaseView {
    
    // views
    let loadingSpinnerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.layer.cornerRadius = 4.0
        view.alpha = 0.0
        return view
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .gray
        return spinner
    }()
    
    let modalOverlayMessageLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0.0
        label.numberOfLines = 0
        return label
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    override func setupView() {
        super.setupView()
        invalidateIntrinsicContentSize()
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        alpha = 0.0
        isUserInteractionEnabled = false
        
        anchorChildViews()
    }
    
    func anchorChildViews() {
        addSubview(loadingSpinnerContainer)
        loadingSpinnerContainer.anchor(withTopAnchor: topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: nil, widthAnchor: 48.0, heightAnchor: 48.0, padding: .init(top: (screenHeight / 2) - 36.0, left: 0.0, bottom: 0.0, right: 0.0))
        loadingSpinnerContainer.addSubview(loadingSpinner)
        loadingSpinner.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: loadingSpinnerContainer.centerXAnchor, centreYAnchor: loadingSpinnerContainer.centerYAnchor)
        
        addSubview(modalOverlayMessageLabel)
        modalOverlayMessageLabel.anchor(withTopAnchor: loadingSpinnerContainer.bottomAnchor, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 10.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    func showCustomOverlayModal(withMessage message: String) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { (animationComplete) in
            self.modalOverlayMessageLabel.text = message
            self.loadingSpinner.startAnimating()
            UIView.animate(withDuration: 0.2, animations: {
                self.loadingSpinnerContainer.alpha = 1.0
                self.modalOverlayMessageLabel.alpha = 1.0
            })
        }
    }
    
    func hideCustomOverlayModal() {
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingSpinnerContainer.alpha = 0.0
            self.modalOverlayMessageLabel.alpha = 0.0
        }) { (animationComplete) in
            self.modalOverlayMessageLabel.text = ""
            self.loadingSpinner.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.0
            })
        }
    }
}

//
//  LoadingStateModal.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class LoadingStateModal: BaseView {

    let loadingSpinner: UIActivityIndicatorView = {
        let av = UIActivityIndicatorView()
        av.style = UIActivityIndicatorView.Style.white
        av.isHidden = true
        av.hidesWhenStopped = true
        return av
    }()

    override func setupView() {
        super.setupView()
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        alpha = 0.0
        isUserInteractionEnabled = false
        
        anchorChildViews()
    }
    
    func anchorChildViews() {
        self.addSubview(loadingSpinner)
        loadingSpinner.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor)
    }
    
    func showLoadingStateModal() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { (animationComplete) in
            self.loadingSpinner.startAnimating()
            self.loadingSpinner.isHidden = false
        }
    }
    
    func hideLoadingStateModal() {
        self.loadingSpinner.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.0
        }
    }
}

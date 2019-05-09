//
//  TakeSavedModal.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol TakeSavedModalDelegate {
    func filmAnotherTakeButtonPressed()
    func dismissButtonPressed()
}

class LoadingAndTakeSavedModal: BaseView {

    // views
    let loadingStateContainerView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        return view
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        return activityIndicator
    }()
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Optimzing your audition take"
        label.font = smallTitleFont
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let confirmedContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6.0
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.alpha = 0.0
        return view
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Take Saved"
        label.font = smallTitleFont
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Your audition scene take has been saved successfully. Do you want to film another take for this scene?"
        label.textColor = darkGrey
        label.font = defaultContentFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let filmAnotherTakeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Film Take", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(filmAnotherTakeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("No Thanks", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // delegate
    var delegate: TakeSavedModalDelegate?
    
    override func setupView() {
        super.setupView()
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        alpha = 0.0
        anchorSubviews()
    }
    
    func anchorSubviews() {
        // loading
        addSubview(loadingStateContainerView)
        loadingStateContainerView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor)
        
        loadingStateContainerView.addSubview(loadingSpinner)
        loadingSpinner.anchor(withTopAnchor: loadingStateContainerView.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: loadingStateContainerView.centerXAnchor, centreYAnchor: nil)
        loadingStateContainerView.addSubview(loadingLabel)
        loadingLabel.anchor(withTopAnchor: loadingSpinner.bottomAnchor, leadingAnchor: loadingStateContainerView.leadingAnchor, bottomAnchor: loadingStateContainerView.bottomAnchor, trailingAnchor: loadingStateContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        
        // complete
        addSubview(confirmedContainerView)
        confirmedContainerView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor, widthAnchor: 300.0, heightAnchor: nil)
        
        confirmedContainerView.addSubview(headerLabel)
        headerLabel.anchor(withTopAnchor: confirmedContainerView.topAnchor, leadingAnchor: confirmedContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: confirmedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        confirmedContainerView.addSubview(descriptionLabel)
        descriptionLabel.anchor(withTopAnchor: headerLabel.bottomAnchor, leadingAnchor: confirmedContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: confirmedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        confirmedContainerView.addSubview(filmAnotherTakeButton)
        filmAnotherTakeButton.anchor(withTopAnchor: descriptionLabel.bottomAnchor, leadingAnchor: confirmedContainerView.leadingAnchor, bottomAnchor: confirmedContainerView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 150.0, heightAnchor: 60.0, padding: .init(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        confirmedContainerView.addSubview(dismissButton)
        dismissButton.anchor(withTopAnchor: filmAnotherTakeButton.topAnchor, leadingAnchor: filmAnotherTakeButton.trailingAnchor, bottomAnchor: confirmedContainerView.bottomAnchor, trailingAnchor: confirmedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 150.0, heightAnchor: 60.0)
    }
    
    /*-- UI methods --*/
    func show(withStage modalStage: AddProjectVideoModalStage) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { (complete) in
            if modalStage == .loading {
                UIView.animate(withDuration: 0.15, animations: {
                    self.loadingSpinner.startAnimating()
                    self.loadingStateContainerView.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.15, animations: {
                    self.confirmedContainerView.alpha = 1.0
                    self.loadingStateContainerView.alpha = 0.0
                    self.loadingSpinner.stopAnimating()
                })
            }
        }
    }
    
    func hide(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.15, animations: {
            self.confirmedContainerView.alpha = 0.0
        }) { (complete) in
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
            }, completion: { (animationFinished) in
                if (animationFinished) {
                    completion()
                }
            })
        }
    }
    
    /*-- button selector methods --*/
    @objc func filmAnotherTakeButtonPressed() {
        delegate?.filmAnotherTakeButtonPressed()
    }
    
    @objc func dismissButtonPressed() {
        delegate?.dismissButtonPressed()
    }
}

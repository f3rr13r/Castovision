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
    let modalContainerView: UIView = {
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
        addSubview(modalContainerView)
        modalContainerView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor, widthAnchor: 300.0, heightAnchor: nil)
        
        modalContainerView.addSubview(headerLabel)
        headerLabel.anchor(withTopAnchor: modalContainerView.topAnchor, leadingAnchor: modalContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: modalContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        modalContainerView.addSubview(descriptionLabel)
        descriptionLabel.anchor(withTopAnchor: headerLabel.bottomAnchor, leadingAnchor: modalContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: modalContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        modalContainerView.addSubview(filmAnotherTakeButton)
        filmAnotherTakeButton.anchor(withTopAnchor: descriptionLabel.bottomAnchor, leadingAnchor: modalContainerView.leadingAnchor, bottomAnchor: modalContainerView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 150.0, heightAnchor: 60.0, padding: .init(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        modalContainerView.addSubview(dismissButton)
        dismissButton.anchor(withTopAnchor: filmAnotherTakeButton.topAnchor, leadingAnchor: filmAnotherTakeButton.trailingAnchor, bottomAnchor: modalContainerView.bottomAnchor, trailingAnchor: modalContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 150.0, heightAnchor: 60.0)
    }
    
    /*-- UI methods --*/
    func showModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { (complete) in
            if complete {
                UIView.animate(withDuration: 0.15, animations: {
                    self.modalContainerView.alpha = 1.0
                })
            }
        }
    }
    
    func hide(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.15, animations: {
            self.modalContainerView.alpha = 0.0
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

//
//  PaymentOptionsVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/6/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class PaymentOptionsVC: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.text = "Select a Storage Amount"
        label.textColor = darkGrey
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = defaultContentFont
        label.text = "Select your amount of self-tape cloud storage you want to purchase by clicking one of the available buttons below. You must have In-App Purchases enabled in order to make a purchase"
        label.textColor = darkGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let buttonsContainerStackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = UIStackView.Alignment.center
        sv.axis = NSLayoutConstraint.Axis.horizontal
        sv.distribution = UIStackView.Distribution.fillEqually
        sv.spacing = 12.0
        return sv
    }()
    let twoGigabytesButton = PaymentOptionButton(paymentOption: .twoGigabytes)
    let fiveGigabytesButton = PaymentOptionButton(paymentOption: .fiveGigabytes)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar(withTitle: "Storage Options", withSearchBar: false)
        self.view.backgroundColor = .white
        handleChildDelegates()
        anchorChildViews()
    }
    
    func handleChildDelegates() {
        self.twoGigabytesButton.delegate = self
        self.fiveGigabytesButton.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(titleLabel)
        titleLabel.anchor(withTopAnchor: self.view.topAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 40.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(descriptionLabel)
        descriptionLabel.anchor(withTopAnchor: titleLabel.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(buttonsContainerStackView)
        buttonsContainerStackView.anchor(withTopAnchor: descriptionLabel.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 120.0, padding: .init(top: 36.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        buttonsContainerStackView.addArrangedSubview(twoGigabytesButton)
        buttonsContainerStackView.addArrangedSubview(fiveGigabytesButton)
    }
}

// payment option button delegate methods
extension PaymentOptionsVC: PaymentOptionButtonActionDelegate {
    func paymentOptionButtonTapped(withPaymentOptionType paymentOptionType: PaymentOptionType) {
        guard let userId = UserService.instance.currentUser.id else { return }
        
        SharedModalService.instance.showLoadingStateModal()
        
        InAppPurchasesService.instance.makePurchase(withUserId: userId, andProductId: paymentOptionType.rawValue, successCompletion: {
            
            let metabytesToAdd = paymentOptionType == .fiveGigabytes ? 5000.0 : 2000.0
            let newMegabytesTotal = UserService.instance.currentUser.storageGigabytesRemaining! + metabytesToAdd
            UserService.instance.updateUserData(withName: "storageMegabytesRemaining", andValue: newMegabytesTotal, completion: { (didUpdateSuccessfully) in
                if didUpdateSuccessfully {
                    SharedModalService.instance.hideLoadingStateModal()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorMessage(withErrorMessage: "Please restart the app. If your available storage has still not updated, please contact our support team")
                }
            })
            
        }, failedCompletion: { (errorMessage) in
            self.showErrorMessage(withErrorMessage: errorMessage)
        }) {
            
        }
    }
    
    func showErrorMessage(withErrorMessage errorMessage: String) {
        self.dismiss(animated: true, completion: nil)
        let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: errorMessage)
        SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
    }
}

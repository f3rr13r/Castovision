//
//  DeleteAccountVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/12/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class DeleteAccountVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Are you sure that you want to delete your castovision account? All data associated with your account will be removed, and this cannot be undone. This includes any self-taped auditions that you have sent using our account. For security reasons, you will also need to enter your password to authenticate this action"
        label.textColor = darkGrey
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let enterPasswordInput = CustomInputView(inputType: .password, initialInputValue: "", showForgotPasswordButton: true)
    
    let deleteAccountButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Delete My Account", buttonColour: .red, isDisabled: false)
    
    let currentEmailAddress = UserService.instance.currentUser.emailAddress
    var password: String = "" {
        didSet {
            let minCharacterLimit: Int = 6
            if password.count > minCharacterLimit {
                deleteAccountButton.enableButton()
            } else {
                deleteAccountButton.disableButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Delete Account", withSearchBar: false)
        handleChildDelegates()
        anchorChildViews()
    }
    
    func handleChildDelegates() {
        enterPasswordInput.delegate = self
        deleteAccountButton.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(enterPasswordInput)
        enterPasswordInput.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(deleteAccountButton)
        deleteAccountButton.disableButton()
        deleteAccountButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
}

// custom input delegate methods
extension DeleteAccountVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        password = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        password = ""
    }
    
    func forgotPasswordButtonPressed() {
        func forgotPasswordButtonPressed() {
            let forgotPasswordVC = ForgotPasswordVC(emailAddressValue: self.currentEmailAddress ?? "", isPresentedModally: true)
            self.present(forgotPasswordVC, animated: true, completion: nil)
        }
    }
}


// button delegate methods
extension DeleteAccountVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        guard let emailAddress = self.currentEmailAddress else {
            let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to get your account information. Please try again, or contact our support team to get your account removed manually")
            SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
            return
        }
        
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Deleting Account")
        AuthService.instance.deleteAccount(withEmailAddress: emailAddress, andPassword: self.password, failedCompletion: { (errorMessage) in
            SharedModalService.instance.hideCustomOverlayModal()
            let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: errorMessage)
            SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
        }) {
            SharedModalService.instance.hideCustomOverlayModal()
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Couldn't get the appDelegate")
                return
            }
            appDelegate.navigationController?.popToRootViewController(animated: true)
            
            /*-- we have deleted the account and so we are no longer deleting account --*/
            AuthService.instance.isDeletingAccount = false
        }
    }
}

//
//  UpdateAccountEmailAddressVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/12/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import FirebaseAuth

struct EmailAddressUpdater {
    var currentEmailAddress: String
    var newEmailAddress: String
    var currentPassword: String
}

class UpdateAccountEmailAddressVC: UIViewController {

    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your new email address and click the save button to update the changes. For security reasons, you will also need to enter your password to authenticate this action"
        label.textColor = darkGrey
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let enterEmailAddressInput = CustomInputView(inputType: .newEmailAddress)
    let passwordInput = CustomInputView(inputType: .password, initialInputValue: "", showForgotPasswordButton: true)
    
    var emailUpdaterInfo: EmailAddressUpdater = EmailAddressUpdater(
        currentEmailAddress: UserService.instance.currentUser.emailAddress!,
        newEmailAddress: "",
        currentPassword: "") {
        didSet {
            if self.emailUpdaterInfo.newEmailAddress.count > 0 && self.emailUpdaterInfo.newEmailAddress.isValidEmail() && self.emailUpdaterInfo.newEmailAddress != self.emailUpdaterInfo.currentEmailAddress && self.emailUpdaterInfo.currentPassword.count > 6 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Update Account Email", withSearchBar: false)
        addNavigationRightButton()
        handleChildDelegates()
        anchorChildViews()
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updateChanges))
        self.navigationItem.rightBarButtonItem?.tintColor = .red
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleChildDelegates() {
        self.enterEmailAddressInput.delegate = self
        self.passwordInput.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(enterEmailAddressInput)
        enterEmailAddressInput.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(passwordInput)
        passwordInput.anchor(withTopAnchor: enterEmailAddressInput.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func updateChanges() {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        if let currentUser = Auth.auth().currentUser {
            let authCredential: AuthCredential = EmailAuthProvider.credential(withEmail: self.emailUpdaterInfo.currentEmailAddress, password: self.emailUpdaterInfo.currentPassword)
            currentUser.reauthenticateAndRetrieveData(with: authCredential) { (_, error) in
                if error != nil {
                    SharedModalService.instance.hideCustomOverlayModal()
                    self.showErrorModal(withMessage: error!.localizedDescription)
                } else {
                    currentUser.updateEmail(to: self.emailUpdaterInfo.newEmailAddress) { (error) in
                        if error != nil {
                            SharedModalService.instance.hideCustomOverlayModal()
                            self.showErrorModal(withMessage: error!.localizedDescription)
                        } else {
                            UserService.instance.updateUserData(withName: "emailAddress", andValue: self.emailUpdaterInfo.newEmailAddress, completion: { (updatedSuccessfully) in
                                SharedModalService.instance.hideCustomOverlayModal()
                                if updatedSuccessfully {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    self.showErrorModal(withMessage: "We were unable to save your new email address to account. Please try again")
                                }
                            })
                        }
                    }
                }
            }
        } else {
            self.showErrorModal(withMessage: "We could not establish your user account. Please restart your app and try again")
        }
    }
    
    func showErrorModal(withMessage message: String) {
        let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: message)
        SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
    }
}

// custom input delegate methods
extension UpdateAccountEmailAddressVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        if inputType == .newEmailAddress {
            self.emailUpdaterInfo.newEmailAddress = inputValue
        } else {
            self.emailUpdaterInfo.currentPassword = inputValue
        }
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        if inputType == .newEmailAddress {
            self.emailUpdaterInfo.newEmailAddress = ""
        } else {
            self.emailUpdaterInfo.currentPassword = ""
        }
    }
    
    func forgotPasswordButtonPressed() {
        let forgotPasswordVC = ForgotPasswordVC(emailAddressValue: self.emailUpdaterInfo.currentEmailAddress, isPresentedModally: true)
        self.present(forgotPasswordVC, animated: true, completion: nil)
    }
}

//
//  ForgotPasswordVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class ForgotPasswordVC : UIViewController {
    
    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    let backButton = BackButton()
    
    let forgotPasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let emailInputView = CustomInputView(inputType: .emailAddress)
    
    let sendEmailButton = MainActionButton(buttonUseType: .forgotPassword, buttonTitle: "Send Forgot Password Email", buttonColour: UIColor.red, isDisabled: true)
    
    init(emailAddressValue: String, isPresentedModally: Bool = false) {
        self._emailAddress = emailAddressValue
        self.emailInputView.updatedInitialInputValue = emailAddressValue
        self._isPresentedModally = isPresentedModally
        super.init(nibName: nil, bundle: nil)
    }
    
    private var _emailAddress: String {
        didSet {
            if self._emailAddress.count > 0 && self._emailAddress.isValidEmail() {
                self.sendEmailButton.isDisabled = false
            } else {
                self.sendEmailButton.isDisabled = true
            }
        }
    }
    private var _isPresentedModally: Bool
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        handleChildDelegates()
        anchorSubviews()
    }
    
    func handleChildDelegates() {
        emailInputView.delegate = self
        backButton.delegate = self
        sendEmailButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(backButton)
        backButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(forgotPasswordTitleLabel)
        forgotPasswordTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(emailInputView)
        emailInputView.anchor(withTopAnchor: forgotPasswordTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(sendEmailButton)
        sendEmailButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
    }
}

// input delegate methods
extension ForgotPasswordVC : CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self._emailAddress = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self._emailAddress = ""
    }
}

// button delegate methods
extension ForgotPasswordVC: BackButtonDelegate, MainActionButtonDelegate {
    func backButtonPressed() {
        if _isPresentedModally {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        if buttonUseType == .forgotPassword {
            AuthService.instance.sendPasswordResetEmail(withEmailAddress: self._emailAddress) { (response) in
                if response.success {
                    self.backButtonPressed()
                } else {
                    let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "Failed to successfully send a password reset email to the address you provided. Please check the email address and try again")
                    SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
                }
            }
        }
    }
}

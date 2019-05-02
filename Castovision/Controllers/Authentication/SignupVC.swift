//
//  SignupVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {
    
    /*=========================
     views
    =========================*/
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    let backButton = BackButton()
    
    let signUpTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let emailInputView = CustomInputView(inputType: .emailAddress)
    let passwordInputView = CustomInputView(inputType: .password, initialInputValue: "", showForgotPasswordButton: false)
    let reEnterPasswordInputView = CustomInputView(inputType: .reEnterPassword, initialInputValue: "", showForgotPasswordButton: false)
    
    let legalLabel: UILabel = {
        let label = UILabel()
        label.text = "By signing up you are agreeing to the terms and conditions, and also the privacy policy laid out by castovision"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let signUpButton = MainActionButton(buttonUseType: .signUp, buttonTitle: "Sign Up", buttonColour: UIColor.red, isDisabled: true)
    
    /*========================
     variables
    ========================*/
    var signupInfo: SignupInfo = SignupInfo(emailAddress: "", password: "", reEnterPassword: "") {
        didSet {
            if self.signupInfo.emailAddress.count > 0 &&
               self.signupInfo.emailAddress.isValidEmail() &&
               self.signupInfo.password.count > 0 &&
               self.signupInfo.reEnterPassword.count > 0 &&
                self.signupInfo.password == self.signupInfo.reEnterPassword {
                signUpButton.enableButton()
            } else {
                signUpButton.disableButton()
            }
        }
    }
    
    
    /*=======================
     class initialization
    =======================*/
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(emailAddressValue: String, passwordValue: String) {
        emailInputView.updatedInitialInputValue = emailAddressValue
        passwordInputView.updatedInitialInputValue = passwordValue
        reEnterPasswordInputView.updatedInitialInputValue = passwordValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    
    /*========================
     class life-cycle methods
    =======================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        handleChildDelegates()
        anchorSubviews()
        
        /*-- disable the sign up by default --*/
        signUpButton.disableButton()
    }
    
    
    /*========================
     custom methods
    =======================*/
    func handleChildDelegates() {
        emailInputView.delegate = self
        passwordInputView.delegate = self
        reEnterPasswordInputView.delegate = self
        backButton.delegate = self
        signUpButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(backButton)
        backButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(signUpTitleLabel)
        signUpTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(emailInputView)
        emailInputView.anchor(withTopAnchor: signUpTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(passwordInputView)
        passwordInputView.anchor(withTopAnchor: emailInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 16.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(reEnterPasswordInputView)
        reEnterPasswordInputView.anchor(withTopAnchor: passwordInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 16.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(signUpButton)
        signUpButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        self.view.addSubview(legalLabel)
        legalLabel.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: signUpButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: -16.0, right: -horizontalPadding))
    }
}

// input delegate methods
extension SignupVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        updateInputValue(withType: inputType, andValue: inputValue)
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        updateInputValue(withType: inputType, andValue: "")
    }
    
    func updateInputValue(withType inputType: CustomInputType, andValue value: String) {
        switch inputType {
        case .emailAddress:
            self.signupInfo.emailAddress = value
            break
        case .password:
            self.signupInfo.password = value
            break
        case .reEnterPassword:
            self.signupInfo.reEnterPassword = value
            break
        default:
            break;
        }
    }
}

// button delegate methods
extension SignupVC: BackButtonDelegate, MainActionButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        if buttonUseType == .signUp {
            SharedModalService.instance.showCustomOverlayModal(withMessage: "Creating Account")
            AuthService.instance.signUpUser(with: self.signupInfo) { (signUpResponse) in
                SharedModalService.instance.hideCustomOverlayModal()
                if signUpResponse.success {
                    let addAccountNameVC = AddAccountNameVC()
                    self.navigationController?.pushViewController(addAccountNameVC, animated: true)
                } else {
                    let errorMessageConfig: CustomErrorMessageConfig = CustomErrorMessageConfig(title: "Sign Up Error", body: signUpResponse.errorMessage!)
                    SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
                }
            }
        }
    }
}

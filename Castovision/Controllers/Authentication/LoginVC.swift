//
//  LoginVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/28/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

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
    
    let logInTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let emailInputView = CustomInputView(inputType: .emailAddress)
    let passwordInputView = CustomInputView(inputType: .password, initialInputValue: "", showForgotPasswordButton: true)

    
    let goToSignUpButton = MainActionButton(buttonUseType: .goToSignUp, buttonTitle: "I don't have an account yet", buttonColour: UIColor.gray, isDisabled: false, isLoading: false, hasBorderStyling: true)
    let logInButton = MainActionButton(buttonUseType: .logIn, buttonTitle: "Log In", buttonColour: UIColor.red, isDisabled: true)
    
    /*========================
     variables
     ========================*/
    var loginInfo: LoginInfo = LoginInfo(emailAddress: "", password: "") {
        didSet {
            if self.loginInfo.emailAddress.count > 0 &&
               self.loginInfo.emailAddress.isValidEmail() &&
                self.loginInfo.password.count > 0 {
                logInButton.enableButton()
            } else {
                logInButton.disableButton()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func loadView() {
        super.loadView()
        /*--
         check if we user is already logged in, and if so
         then navigate into the main app
        --*/
        if UserDefaults.standard.object(forKey: "userId") != nil {
            self.navigationController?.navigateIntoMainApp(withAnimation: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        handleChildDelegates()
        anchorSubviews()
        
        /*-- disable the login button by default --*/
        logInButton.disableButton()
    }
    
    func handleChildDelegates() {
        emailInputView.delegate = self
        passwordInputView.delegate = self
        goToSignUpButton.delegate = self
        logInButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))

        self.view.addSubview(logInTitleLabel)
        logInTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(emailInputView)
        emailInputView.anchor(withTopAnchor: logInTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(passwordInputView)
        passwordInputView.anchor(withTopAnchor: emailInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 16.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(goToSignUpButton)
        goToSignUpButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        self.view.addSubview(logInButton)
        logInButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: goToSignUpButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -12.0, right: -horizontalPadding))
    }
}

// input delegate methods
extension LoginVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        updateInputValue(withType: inputType, andValue: inputValue)
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        updateInputValue(withType: inputType, andValue: "")
    }
    
    func updateInputValue(withType inputType: CustomInputType, andValue value: String) {
        switch inputType {
        case .emailAddress:
            self.loginInfo.emailAddress = value
            break
        case .password:
            self.loginInfo.password = value
        default:
            break;
        }
    }
    
    func forgotPasswordButtonPressed() {
        let forgotPasswordVC = ForgotPasswordVC()
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
}

// button delegate methods
extension LoginVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        switch buttonUseType {
        case .goToSignUp:
            let signUpVC = SignupVC()
            self.navigationController?.pushViewController(signUpVC, animated: true)
            break
        case .logIn:
            logInUser()
            break
        default: return
        }
    }
    
    private func logInUser() {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Logging In")
        AuthService.instance.logInUser(withLoginInfo: self.loginInfo) { (loginResponse) in
            SharedModalService.instance.hideCustomOverlayModal()
            if loginResponse.success {
                self.navigationController?.navigateIntoMainApp(withAnimation: true)
            } else {
                let errorMessageConfig: CustomErrorMessageConfig = CustomErrorMessageConfig(title: "Logging In Error", body: loginResponse.errorMessage!)
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
            }
        }
    }
}

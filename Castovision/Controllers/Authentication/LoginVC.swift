//
//  LoginVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/28/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    // views
    let logoImageView = LogoImageView()
    
    let logInTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 34.0)
        return label
    }()
    
    let goToSignUpButton = MainActionButton(buttonUseType: .goToSignUp, buttonTitle: "I don't have an account yet", buttonColour: UIColor.lightGray, isDisabled: false, isLoading: false, hasBorderStyling: true)
    
    let logInButton = MainActionButton(buttonUseType: .logIn, buttonTitle: "Log In", buttonColour: UIColor.red, isDisabled: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        handleChildDelegates()
        anchorSubviews()
    }
    
    func handleChildDelegates() {
        goToSignUpButton.delegate = self
        logInButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logInTitleLabel)
        logInTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(goToSignUpButton)
        goToSignUpButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        self.view.addSubview(logInButton)
        logInButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: goToSignUpButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -12.0, right: -horizontalPadding))
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
            // do something here
            break
        default: return
        }
    }
}

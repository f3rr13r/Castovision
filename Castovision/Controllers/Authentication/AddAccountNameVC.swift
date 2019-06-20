//
//  AddAccountNameVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddAccountNameVC: UIViewController {

    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    
    let accountNameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Name"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let accountNameInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your full professional name. This name will be visible to casting directors who view your audition tapes"
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let nameInputView = CustomInputView(inputType: .name)
    
    let saveProfileNameButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Save", buttonColour: UIColor.red, isDisabled: true)
    
    // variables
    var professionalName: String = "" {
        didSet {
            if self.professionalName.count > 0 &&
                !self.professionalName.isValidEmail() {
                saveProfileNameButton.enableButton()
            } else {
                saveProfileNameButton.disableButton()
            }
        }
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
        
        /*-- disable the name button by default --*/
        saveProfileNameButton.disableButton()
    }
    
    func handleChildDelegates() {
        nameInputView.delegate = self
        saveProfileNameButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(accountNameTitleLabel)
        accountNameTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(accountNameInstructionLabel)
        accountNameInstructionLabel.anchor(withTopAnchor: accountNameTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 6.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(nameInputView)
        nameInputView.anchor(withTopAnchor: accountNameInstructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(saveProfileNameButton)
        saveProfileNameButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
    }
}

// button delegate methods
extension AddAccountNameVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        UserService.instance.updateUserData(withName: "profileName", andValue: self.professionalName) { (didSaveSuccessfully) in
            SharedModalService.instance.hideCustomOverlayModal()
            if didSaveSuccessfully {
                let addAccountImageVC = AddAccountImageVC()
                self.navigationController?.pushViewController(addAccountImageVC, animated: true)
            } else {
                let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to save your name to your account. Please try again")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
            }
        }
    }
}

// input delegate methods
extension AddAccountNameVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self.professionalName = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self.professionalName = ""
    }
}

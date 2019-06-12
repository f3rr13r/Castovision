//
//  UpdateAccountNameVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/12/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class UpdateProfileNameVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Update your professional name and click the save button to update the changes"
        label.textColor = darkGrey
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let projectNameInput = CustomInputView(inputType: .name)
    
    let currentAccountName = UserService.instance.currentUser.name
    var newAccountName = UserService.instance.currentUser.name {
        didSet {
            if let newValue = self.newAccountName,
               newValue.count > 0,
                newValue != self.currentAccountName {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Update Profile Name", withSearchBar: false)
        addNavigationRightButton()
        handleChildDelegates()
        anchorChildViews()
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updateChanges))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleChildDelegates() {
        projectNameInput.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(projectNameInput)
        projectNameInput.input.text = newAccountName
        projectNameInput.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func updateChanges() {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        UserService.instance.updateUserData(withName: "profileName", andValue: self.newAccountName) {
            (updatedSuccessfully) in
            SharedModalService.instance.hideCustomOverlayModal()
            if updatedSuccessfully {
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to update your professional name on account. Please try again")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
            }
        }
    }
}

// custom input delegate methods
extension UpdateProfileNameVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self.newAccountName = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self.newAccountName = ""
    }
}

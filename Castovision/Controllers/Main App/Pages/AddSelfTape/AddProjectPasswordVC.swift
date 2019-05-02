//
//  AddProjectPasswordVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddProjectPasswordVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()

    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter an access password for your self-tape audition. This password will be sent along with your self-tape audition, and the recipient will have to put it in order to access your audition tape, so keeping it and you safe"
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let auditionPasswordInputView = CustomInputView(inputType: .projectPassword)
    let reEnterPasswordInputView = CustomInputView(inputType: .reEnterProjectPassword)
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var projectPassword = ProjectPassword(password: "", reEnteredPassword: "") {
        didSet {
            if self.projectPassword.password.count > 0 &&
               self.projectPassword.reEnteredPassword.count > 0 &&
                self.projectPassword.password == self.projectPassword.reEnteredPassword {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Project Password", withSearchBar: false)
        addNavigationRightButton()
        anchorSubviews()
        handleChildDelegates()
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(saveSelfTapeProject))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func saveSelfTapeProject() {
        AddSelfTapeService.instance.updateProjectPassword(withValue: self.projectPassword.password) {
            let addProjectScenesVC = AddProjectScenesVC()
            self.navigationController?.pushViewController(addProjectScenesVC, animated: true)
        }
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(auditionPasswordInputView)
        auditionPasswordInputView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(reEnterPasswordInputView)
        reEnterPasswordInputView.anchor(withTopAnchor: auditionPasswordInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    func handleChildDelegates() {
        auditionPasswordInputView.delegate = self
        reEnterPasswordInputView.delegate = self
    }
}

// delegate methods
extension AddProjectPasswordVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        updateInputValue(withType: inputType, andPasswordValue: inputValue)
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        updateInputValue(withType: inputType, andPasswordValue: "")
    }
    
    func updateInputValue(withType inputType: CustomInputType, andPasswordValue passwordValue: String) {
        switch inputType {
        case .projectPassword:
            self.projectPassword.password = passwordValue
            break
        case .reEnterProjectPassword:
            self.projectPassword.reEnteredPassword = passwordValue
            break
        default:
            break
        }
    }
}

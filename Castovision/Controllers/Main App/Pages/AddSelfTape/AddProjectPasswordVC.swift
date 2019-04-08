//
//  AddProjectPasswordVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddProjectPasswordVC: UIViewController {

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
    
    let createProjectButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Create Project", buttonColour: UIColor.red, isDisabled: true)
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Project Password", withSearchBar: false)
        anchorSubviews()
        handleChildDelegates()
    }
    
    func anchorSubviews() {
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(auditionPasswordInputView)
        auditionPasswordInputView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(reEnterPasswordInputView)
        reEnterPasswordInputView.anchor(withTopAnchor: auditionPasswordInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(createProjectButton)
        createProjectButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
    
    func handleChildDelegates() {
        createProjectButton.delegate = self
    }
}

// delegate methods
extension AddProjectPasswordVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        let addProjectScenesVC = AddProjectScenesVC()
        self.navigationController?.pushViewController(addProjectScenesVC, animated: true)
    }
}

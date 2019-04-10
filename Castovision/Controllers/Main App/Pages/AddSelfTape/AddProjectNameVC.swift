//
//  CreateTapeVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddProjectNameVC: UIViewController {
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the name of the project that you will be submitting this self-tape audition for. This will be used to inform the recipient about what they are watching, but can also be used to help you to find it by searching in your self-tape feed page"
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let auditionNameInputView = CustomInputView(inputType: .projectName)
    
    let nextButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Next", buttonColour: UIColor.red, isDisabled: true)
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Project Name", withSearchBar: false)
        anchorSubviews()
        handleChildDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AddSelfTapeService.instance.initializeNewSelfTapeProject()
    }
    
    func anchorSubviews() {
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(auditionNameInputView)
        auditionNameInputView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(nextButton)
        nextButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
    
    func handleChildDelegates() {
        nextButton.delegate = self
    }
}

// delegate methods
extension AddProjectNameVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        let addProjectPasswordVC = AddProjectPasswordVC()
        self.navigationController?.pushViewController(addProjectPasswordVC, animated: true)
    }
}

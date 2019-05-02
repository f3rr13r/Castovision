//
//  CreateTapeVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddProjectNameVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the name of the project that you will be submitting this self-tape audition for. This will be used to inform the recipient about what they are watching, but can also be used to help you to find it by searching in your self-tape feed page"
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let auditionNameInputView = CustomInputView(inputType: .projectName)
    
    var projectName: String = "" {
        didSet {
            self.navigationItem.rightBarButtonItem?.isEnabled = self.projectName.count > 0 ? true : false
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Project Name", withSearchBar: false)
        addHiddenNavigationLeftButton()
        addNavigationRightButton()
        anchorSubviews()
        handleChildDelegates()
    }
    
    func addHiddenNavigationLeftButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem?.tintColor = .clear
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(saveSelfTapeProject))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func saveSelfTapeProject() {
        AddSelfTapeService.instance.updateProjectName(withValue: self.projectName) {
            let addProjectPasswordVC = AddProjectPasswordVC()
            self.navigationController?.pushViewController(addProjectPasswordVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AddSelfTapeService.instance.initializeNewSelfTapeProject()
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(auditionNameInputView)
        auditionNameInputView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    func handleChildDelegates() {
        auditionNameInputView.delegate = self
    }
}

// delegate methods
extension AddProjectNameVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        updatePageState(withProjectNameValue: inputValue)
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        updatePageState(withProjectNameValue: "")
    }
    
    func updatePageState(withProjectNameValue projectNameValue: String) {
        self.projectName = projectNameValue
    }
}

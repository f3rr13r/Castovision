//
//  AddProjectMailingList.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/24/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import SPStorkController

class AddProjectMailingListVC: UIViewController {

    // views
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the email addresses of the people you want to send this self-tape audition to, or select from your saved email addresses. We will also send an email to you so that you can see it aswell."
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let addEmailButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: #selector(addEmailButtonPressed), for: .touchUpInside)
        return button
    }()
    let addEmailButtonIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "add-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
    }()
    
    let seeSavedListButton: UIButton = {
        let button = UIButton()
        button.setTitle("See saved addresses", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 4.0
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(seeSavedListButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let enterEmailInputView = CustomInputView(inputType: .emailAddress)
    
    private let _emailAddressCellId: String = "emailAddressCellId"
    lazy var selectedEmailAddressesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInsetAdjustmentBehavior = .never
        cv.delegate = self
        cv.dataSource = self
        cv.register(EmailAddressCell.self, forCellWithReuseIdentifier: self._emailAddressCellId)
        return cv
    }()
    
    let noEmailSelectedContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let noEmailSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "No email addresses selected"
        label.font = defaultContentFont
        label.textColor = grey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // variables
    private var _selfTapeProject: Project = Project()
    private var _user: User = User()
    
    var currentEmailInputViewValue: String = "" {
        didSet {
            if self.currentEmailInputViewValue.count > 0 &&
                self.currentEmailInputViewValue.isValidEmail() &&
                !self.mailingList.contains(self.currentEmailInputViewValue) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.addEmailButton.backgroundColor = UIColor.red
                }) { (animationComplete) in
                    self.addEmailButton.isEnabled = true
                }
            } else {
                addEmailButton.isEnabled = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.addEmailButton.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                })
            }
        }
    }
    
    var mailingList: [String] = [] {
        didSet {
            AddSelfTapeService.instance.updateProjectEmailAddressList(withMailingList: self.mailingList) {
                // do we need this?
            }
            
            DispatchQueue.main.async {
                self.selectedEmailAddressesCollectionView.reloadData()
                self.noEmailSelectedContainerView.isHidden = self.mailingList.count > 0 ? true : false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        lockDeviceVertically()
        configureNavigationBar(withTitle: "Add Mailing List", withSearchBar: false)
        configureNavigationButtons()
        anchorSubviews()
        handleChildDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUserAndSelfTapeProject()
    }
    
    func getCurrentUserAndSelfTapeProject() {
        /*-- user --*/
        self._user = UserService.instance.currentUser
        
        /*-- self tape --*/
        AddSelfTapeService.instance.getUpdatedSelfTapeProject { (updatedProject) in
            self._selfTapeProject = updatedProject
            self.mailingList = self._selfTapeProject.currentMailingList ?? []
        }
    }
    
    func configureNavigationButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendSelfTapeProject))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
    }
    
    @objc func addEmailButtonPressed() {
        self.mailingList.append(self.currentEmailInputViewValue)
        self.enterEmailInputView.input.text = ""
        self.enterEmailInputView.dismissKeyboard()
        self.currentEmailInputViewValue = ""
    }
    
    @objc func seeSavedListButtonPressed() {
        guard let savedEmailAddresses = self._user.savedEmailAddresses else { return }
        let savedEmailAddressesVC = SavedEmailAddressesVC(savedAddresses: savedEmailAddresses, emailAddresses: self.mailingList)
        savedEmailAddressesVC.delegate = self
        
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = screenHeight * 0.75
        
        savedEmailAddressesVC.transitioningDelegate = transitionDelegate
        savedEmailAddressesVC.modalPresentationStyle = .custom
        savedEmailAddressesVC.modalPresentationCapturesStatusBarAppearance = true
        
        self.present(savedEmailAddressesVC, animated: true, completion: nil)
    }
    
    @objc func sendSelfTapeProject() {
        // do something here
    }
    
    func anchorSubviews() {
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(addEmailButton)
        addEmailButton.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 50.0, heightAnchor: 50.0, padding: .init(top: 20.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        addEmailButton.addSubview(addEmailButtonIcon)
        addEmailButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: addEmailButton.centerXAnchor, centreYAnchor: addEmailButton.centerYAnchor, widthAnchor: 20.0, heightAnchor: 20.0)
        
        self.view.addSubview(enterEmailInputView)
        enterEmailInputView.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: addEmailButton.leadingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -12.0))
        
        self.view.addSubview(seeSavedListButton)
        seeSavedListButton.anchor(withTopAnchor: addEmailButton.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(selectedEmailAddressesCollectionView)
        selectedEmailAddressesCollectionView.anchor(withTopAnchor: seeSavedListButton.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(noEmailSelectedContainerView)
        noEmailSelectedContainerView.anchor(withTopAnchor: seeSavedListButton.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        noEmailSelectedContainerView.addSubview(noEmailSelectedLabel)
        noEmailSelectedLabel.anchor(withTopAnchor: nil, leadingAnchor: noEmailSelectedContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: noEmailSelectedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: noEmailSelectedContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    func handleChildDelegates() {
        enterEmailInputView.delegate = self
    }
}

// collection view delegate and data source methods
extension AddProjectMailingListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mailingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let emailAddressCell = collectionView.dequeueReusableCell(withReuseIdentifier: self._emailAddressCellId, for: indexPath) as? EmailAddressCell else {
            return UICollectionViewCell()
        }
        emailAddressCell.configureCell(withEmailAddress: self.mailingList[indexPath.item])
        return emailAddressCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mailingList.removeAll(where: { $0 == self.mailingList[indexPath.item] })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24.0, left: 0.0, bottom: 24.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50.0)
    }
}

// custom input delegate methods
extension AddProjectMailingListVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self.currentEmailInputViewValue = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self.currentEmailInputViewValue = ""
    }
}

// pop up cv delegate
extension AddProjectMailingListVC: SavedEmailAddressesVCDelegate {
    func updateMailingList(withUpdatedMailingList updatedMailingList: [String]) {
        self.mailingList = updatedMailingList
    }
}

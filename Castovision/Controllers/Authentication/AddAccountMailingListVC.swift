//
//  AddAccountMailingListVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/11/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddAccountMailingListVC: UIViewController {

    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    let backButton = BackButton()
    let topRightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 20.0, bottom: 6.0, right: 20.0)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(topRightButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let accountMailingListTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mailing List"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let accountMailingListInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "If you have email addresses that you will be regularly sending your self-taped auditions to e.g - your agent, then add them to your mailing list, and you won't have to enter their address in the future"
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
    
    let emailInputView = CustomInputView(inputType: .emailAddress)
    
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
    
    let noEmailSelectedContainerView = UIView()
    
    let noEmailSelectedLabel: UILabel = {
        let label = UILabel()
        label.text = "No email addresses added"
        label.font = defaultContentFont
        label.textColor = darkGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var currentEmailInputViewValue: String = "" {
        didSet {
            if self.currentEmailInputViewValue.count > 0 && self.currentEmailInputViewValue.isValidEmail() && !self.mailingList.contains(self.currentEmailInputViewValue) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.addEmailButton.backgroundColor = .red
                }) { (animationComplete) in
                    self.addEmailButton.isEnabled = true
                }
            } else {
                self.addEmailButton.isEnabled = false
                UIView.animate(withDuration: 0.2) {
                    self.addEmailButton.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                }
            }
        }
    }
    
    var mailingList: [String] = [] {
        didSet {
            self.selectedEmailAddressesCollectionView.reloadData()
            self.noEmailSelectedContainerView.isHidden = self.mailingList.count > 0 ? true : false
            let topRightButtonText = self.mailingList.count > 0 ? "Save" : "Skip"
            let topRightButtonColor: UIColor = self.mailingList.count > 0 ? .red : grey
            self.topRightButton.setTitle(topRightButtonText, for: .normal)
            self.topRightButton.setTitleColor(topRightButtonColor, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        handleChildDelegates()
        anchorSubviews()
    }
    
    func handleChildDelegates() {
        emailInputView.delegate = self
        backButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(backButton)
        backButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(topRightButton)
        topRightButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: backButton.centerYAnchor, widthAnchor: nil)
        
        self.view.addSubview(accountMailingListTitleLabel)
        accountMailingListTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(accountMailingListInstructionLabel)
        accountMailingListInstructionLabel.anchor(withTopAnchor: accountMailingListTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 6.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(addEmailButton)
        addEmailButton.anchor(withTopAnchor: accountMailingListInstructionLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 50.0, heightAnchor: 50.0, padding: .init(top: 20.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        addEmailButton.addSubview(addEmailButtonIcon)
        addEmailButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: addEmailButton.centerXAnchor, centreYAnchor: addEmailButton.centerYAnchor, widthAnchor: 20.0, heightAnchor: 20.0)
        
        self.view.addSubview(emailInputView)
        emailInputView.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: addEmailButton.leadingAnchor, centreXAnchor: nil, centreYAnchor: addEmailButton.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -12.0))
        
        self.view.addSubview(selectedEmailAddressesCollectionView)
        selectedEmailAddressesCollectionView.anchor(withTopAnchor: emailInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(noEmailSelectedContainerView)
        noEmailSelectedContainerView.anchor(withTopAnchor: emailInputView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        noEmailSelectedContainerView.addSubview(noEmailSelectedLabel)
        noEmailSelectedLabel.anchor(withTopAnchor: nil, leadingAnchor: noEmailSelectedContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: noEmailSelectedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: noEmailSelectedContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func addEmailButtonPressed() {
        self.mailingList.append(self.currentEmailInputViewValue)
        self.emailInputView.input.text = ""
        self.emailInputView.dismissKeyboard()
        self.currentEmailInputViewValue = ""
    }
    
    @objc func topRightButtonPressed() {
        if self.mailingList.count > 0 {
            SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
            UserService.instance.updateUserData(withName: "savedEmailAddresses", andValue: self.mailingList) { (didSaveSuccessfully) in
                SharedModalService.instance.hideCustomOverlayModal()
                if didSaveSuccessfully {
                    self.navigateIntoMainApp()
                } else {
                    let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to save your mailing list to your account. Please try again")
                    SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
                }
            }
        } else {
            self.navigateIntoMainApp()
        }
    }
    
    func navigateIntoMainApp() {
        self.navigationController?.navigateIntoMainApp()
    }
}

// collection view delegate and datasource methods
extension AddAccountMailingListVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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

// custom input and button delegate methods
extension AddAccountMailingListVC: CustomInputViewDelegate, BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self.currentEmailInputViewValue = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self.currentEmailInputViewValue = ""
    }
}

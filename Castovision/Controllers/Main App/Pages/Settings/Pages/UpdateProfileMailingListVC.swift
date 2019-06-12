//
//  UpdateProfileMailingListVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/12/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class UpdateProfileMailingListVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Update your current saved emails and click the save button to update the changes"
        label.textColor = darkGrey
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
    
    let addEmailInput = CustomInputView(inputType: .emailAddress)
    
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
    
    var addEmailInputViewValue: String = "" {
        didSet {
            if self.addEmailInputViewValue.count > 0 &&
               self.addEmailInputViewValue.isValidEmail() &&
                !(self.newMailingList?.contains(self.addEmailInputViewValue))! {
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
    
    let currentMailingList = UserService.instance.currentUser.savedEmailAddresses
    var newMailingList = UserService.instance.currentUser.savedEmailAddresses {
        didSet {
            if let newMailingList = self.newMailingList {
                self.selectedEmailAddressesCollectionView.reloadData()
                self.navigationItem.rightBarButtonItem?.isEnabled = (newMailingList.count > 0 && newMailingList != currentMailingList) ? true : false
                self.noEmailSelectedContainerView.isHidden = newMailingList.count > 0 ? true : false
            } else {
                self.noEmailSelectedContainerView.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Update Saved Emails", withSearchBar: false)
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
        self.addEmailInput.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(addEmailButton)
        addEmailButton.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 50.0, heightAnchor: 50.0, padding: .init(top: 24.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        addEmailButton.addSubview(addEmailButtonIcon)
        addEmailButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: addEmailButton.centerXAnchor, centreYAnchor: addEmailButton.centerYAnchor, widthAnchor: 20.0, heightAnchor: 20.0)
        
        self.view.addSubview(addEmailInput)
        addEmailInput.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: addEmailButton.leadingAnchor, centreXAnchor: nil, centreYAnchor: addEmailButton.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -12.0))
        
        self.view.addSubview(selectedEmailAddressesCollectionView)
        selectedEmailAddressesCollectionView.anchor(withTopAnchor: addEmailInput.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(noEmailSelectedContainerView)
        noEmailSelectedContainerView.isHidden = self.newMailingList!.count > 0 ? true : false
        noEmailSelectedContainerView.anchor(withTopAnchor: addEmailInput.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        noEmailSelectedContainerView.addSubview(noEmailSelectedLabel)
        noEmailSelectedLabel.anchor(withTopAnchor: nil, leadingAnchor: noEmailSelectedContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: noEmailSelectedContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: noEmailSelectedContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func addEmailButtonPressed() {
        self.newMailingList?.append(self.addEmailInputViewValue)
        self.addEmailInput.input.text = ""
        self.addEmailInput.dismissKeyboard()
        self.addEmailInputViewValue = ""
    }
    
    @objc func updateChanges() {
        guard let updatedMailingList = self.newMailingList else { return }
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        UserService.instance.updateUserData(withName: "savedEmailAddresses", andValue: updatedMailingList) { (updatedSuccessfully) in
            SharedModalService.instance.hideCustomOverlayModal()
            if updatedSuccessfully {
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to update your saved email addresses on account. Please try again")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
            }
        }
    }
}

// collection view delegate and datasource methods
extension UpdateProfileMailingListVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newMailingList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let emailAddressCell = collectionView.dequeueReusableCell(withReuseIdentifier: self._emailAddressCellId, for: indexPath) as? EmailAddressCell else {
            return UICollectionViewCell()
        }
        emailAddressCell.configureCell(withEmailAddress: self.newMailingList![indexPath.item])
        return emailAddressCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.newMailingList?.removeAll(where: { $0 == self.newMailingList?[indexPath.item] })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24.0, left: 0.0, bottom: 24.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: 50.0)
    }
}

// input delegate methods
extension UpdateProfileMailingListVC: CustomInputViewDelegate {
    func inputValueDidChange(inputType: CustomInputType, inputValue: String) {
        self.addEmailInputViewValue = inputValue
    }
    
    func inputClearButtonPressed(inputType: CustomInputType) {
        self.addEmailInputViewValue = ""
    }
}

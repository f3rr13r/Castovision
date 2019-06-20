//
//  ProfileVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import SPStorkController

class ProfileVC: UIViewController {
    
    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = grey.cgColor
        view.layer.cornerRadius = 6.0
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = lightGrey
        iv.layer.cornerRadius = 40.0
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let accountDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Account Details"
        label.font = smallTitleFont
        label.textColor = UIColor.black
        return label
    }()
    
    let topTextContainerView = UIView()
    
    let nameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Professional Name"
        label.font = smallContentFont
        label.textColor = darkGrey
        return label
    }()
    
    let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    let accountCreatedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Account Created"
        label.font = smallContentFont
        label.textColor = darkGrey
        return label
    }()
    
    let profileAccountCreatedLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    let gigabytesRemainingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = grey.cgColor
        view.layer.cornerRadius = 6.0
        return view
    }()
    
    let gigabytesUsageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Available Storage"
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    let storageIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "storage-icon-with-border")
        return iv
    }()
    
    let buyMoreStorageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Buy More Storage", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        button.titleLabel?.font = defaultButtonFont
        button.layer.cornerRadius = 4.0
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
        button.addTarget(self, action: #selector(buyMoreStorage), for: .touchUpInside)
        return button
    }()
    
    let storageTextContainerView = UIView()
    
    let totalGigabytesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Storage"
        label.font = smallContentFont
        label.textColor = darkGrey
        return label
    }()
    
    let totalGigabytesLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var profileInfo: User? {
        didSet {
            if let updatedProfileInfo = self.profileInfo {
                // check for values
                guard let updatedProfileImageData = updatedProfileInfo.profileImageData else { return }
                guard let updatedProfileName = updatedProfileInfo.name else { return }
                guard let updatedAccountCreatedDate = updatedProfileInfo.accountCreatedDate else { return }
                guard let updatedRemainingStorage = updatedProfileInfo.storageGigabytesRemaining else { return }
                
                // populate the simple UI elements
                profileImageView.image = UIImage(data: updatedProfileImageData)
                profileNameLabel.text = updatedProfileName
               
                // get the date into a workable string format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                let accountCreatedStringDate = dateFormatter.string(from: updatedAccountCreatedDate)
                profileAccountCreatedLabel.text = "\(accountCreatedStringDate)"
                
                // do storage stuff
                let totalGigabytes: CGFloat = CGFloat(updatedRemainingStorage / 1000).rounded(toPlaces: 2)
                totalGigabytesLabel.text = "\(totalGigabytes)gb"
            } else {
                // show loading / empty states
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = lightGrey
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Profile", withSearchBar: false)
        addHiddenNavigationLeftButton()
        addNavigationRightButton()
        getUserData()
        anchorSubviews()
        setupViewShadowing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserService.instance.delegate = self
    }
    
    func addHiddenNavigationLeftButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem?.tintColor = .clear
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings-icon"), style: .plain, target: self, action: #selector(settingsButtonPressed))
    }
    
    func getUserData() {
        self.profileInfo = UserService.instance.currentUser
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(topContainerView)
        topContainerView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: horizontalPadding, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        topContainerView.addSubview(accountDetailsLabel)
        accountDetailsLabel.anchor(withTopAnchor: topContainerView.topAnchor, leadingAnchor: topContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: topContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        topContainerView.addSubview(profileImageView)
        profileImageView.anchor(withTopAnchor: accountDetailsLabel.bottomAnchor, leadingAnchor: topContainerView.leadingAnchor, bottomAnchor: topContainerView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 80.0, heightAnchor: 80.0, padding: .init(top: 20.0, left: horizontalPadding, bottom: -20.0, right: 0.0))
        
        topContainerView.addSubview(topTextContainerView)
        topTextContainerView.anchor(withTopAnchor: accountDetailsLabel.bottomAnchor, leadingAnchor: profileImageView.trailingAnchor, bottomAnchor: nil, trailingAnchor: topContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: 12.0, bottom: -24.0, right: -horizontalPadding))
        
        topTextContainerView.addSubview(nameTitleLabel)
        nameTitleLabel.anchor(withTopAnchor: topTextContainerView.topAnchor, leadingAnchor: topTextContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: topTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        topTextContainerView.addSubview(profileNameLabel)
        profileNameLabel.anchor(withTopAnchor: nameTitleLabel.bottomAnchor, leadingAnchor: topTextContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: topTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        topTextContainerView.addSubview(accountCreatedTitleLabel)
        accountCreatedTitleLabel.anchor(withTopAnchor: profileNameLabel.bottomAnchor, leadingAnchor: topTextContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: topTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 8.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        topTextContainerView.addSubview(profileAccountCreatedLabel)
        profileAccountCreatedLabel.anchor(withTopAnchor: accountCreatedTitleLabel.bottomAnchor, leadingAnchor: topTextContainerView.leadingAnchor, bottomAnchor:topTextContainerView.bottomAnchor, trailingAnchor: topTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil)
        
        self.view.addSubview(gigabytesRemainingContainerView)
        gigabytesRemainingContainerView.anchor(withTopAnchor: topContainerView.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        gigabytesRemainingContainerView.addSubview(gigabytesUsageTitleLabel)
        gigabytesUsageTitleLabel.anchor(withTopAnchor: gigabytesRemainingContainerView.topAnchor, leadingAnchor: gigabytesRemainingContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: gigabytesRemainingContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        gigabytesRemainingContainerView.addSubview(storageIconImageView)
        storageIconImageView.anchor(withTopAnchor: gigabytesUsageTitleLabel.bottomAnchor, leadingAnchor: gigabytesRemainingContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 80.0, heightAnchor: 80.0, padding: .init(top: 20.0, left: 21.0, bottom: 0.0, right: 0.0))
        
        gigabytesRemainingContainerView.addSubview(storageTextContainerView)
        storageTextContainerView.anchor(withTopAnchor: nil, leadingAnchor: storageIconImageView.trailingAnchor, bottomAnchor: nil, trailingAnchor: gigabytesRemainingContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: storageIconImageView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 12.0, bottom: 0.0, right: -horizontalPadding))
        
        storageTextContainerView.addSubview(totalGigabytesTitleLabel)
        totalGigabytesTitleLabel.anchor(withTopAnchor: storageTextContainerView.topAnchor, leadingAnchor: storageTextContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: storageTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        storageTextContainerView.addSubview(totalGigabytesLabel)
        totalGigabytesLabel.anchor(withTopAnchor: totalGigabytesTitleLabel.bottomAnchor, leadingAnchor: storageTextContainerView.leadingAnchor, bottomAnchor: storageTextContainerView.bottomAnchor, trailingAnchor: storageTextContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        gigabytesRemainingContainerView.addSubview(buyMoreStorageButton)
        buyMoreStorageButton.anchor(withTopAnchor: storageIconImageView.bottomAnchor, leadingAnchor: nil, bottomAnchor: gigabytesRemainingContainerView.bottomAnchor, trailingAnchor: gigabytesRemainingContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -20.0, right: -horizontalPadding))
    }
    
    func setupViewShadowing() {
        let viewsToShadow: [UIView] = [topContainerView, gigabytesRemainingContainerView]
        viewsToShadow.forEach { (view) in
            view.layer.shadowColor = darkGrey.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            view.layer.shadowRadius = 6.0
            view.layer.shadowOpacity = 0.2
            view.layer.masksToBounds = false
        }
    }
    
    @objc func settingsButtonPressed() {
        let settingsVC = SettingsVC()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func buyMoreStorage() {
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = 360.0
        
        let paymentOptionsVC = PaymentOptionsVC()
        paymentOptionsVC.transitioningDelegate = transitionDelegate
        paymentOptionsVC.modalPresentationStyle = .custom
        paymentOptionsVC.modalPresentationCapturesStatusBarAppearance = true
        
        self.present(paymentOptionsVC, animated: true, completion: nil)
    }
}

// User service delegate
extension ProfileVC: UserServiceDelegate {
    func currentUserWasUpdated(updatedData: User) {
        self.profileInfo = updatedData
    }
}

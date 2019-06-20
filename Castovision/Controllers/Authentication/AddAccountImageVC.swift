//
//  AddAccountImageVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVFoundation

class AddAccountImageVC: UIViewController {
    
    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    let backButton = BackButton()
    
    let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 20.0, bottom: 6.0, right: 20.0)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(skipButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let accountImageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Picture"
        label.textColor = .black
        label.font = largeTitleFont
        return label
    }()
    
    let accountImageInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please pick a suitable photograph (headshot) for your account profile picture. This will be visible to casting directors who view your audition tapes"
        label.textColor = .black
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let addPhotoButton = MainActionButton(buttonUseType: .openImagePickerVC, buttonTitle: "Select Profile Picture", buttonColour: .red, isDisabled: false)
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 80.0
        iv.layer.masksToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    let changeProfileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 4.0
        button.setTitle("Change Image", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 16.0, bottom: 6.0, right: 16.0)
        button.titleLabel?.font = defaultButtonFont
        button.addTarget(self, action: #selector(openImagePickerVC), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let savePhotoButton = MainActionButton(buttonUseType: .saveProfileImage, buttonTitle: "Save Profile Picture", buttonColour: .red, isDisabled: false)

    let permissionDeniedView = PermissionDeniedView(title: "Camera Access Denied", message: "Castovision is unable to access your camera or phone library, and so cannot provide this feature. You can update the app's camera access permissions at anytime by going to castovision inside your phone settings", canShowButton: false)
    
    // variables
    var profileImage: UIImage? = nil {
        didSet {
            if let profileImage = self.profileImage {
                profileImageView.image = profileImage
                profileImageView.isHidden = false
                changeProfileImageButton.isHidden = false
                addPhotoButton.isHidden = true
                savePhotoButton.isHidden = false
            } else {
                profileImageView.image = nil
                profileImageView.isHidden = true
                changeProfileImageButton.isHidden = true
                addPhotoButton.isHidden = false
                savePhotoButton.isHidden = true
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
        checkCameraUsagePermissionState()
        handleChildDelegates()
        anchorSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*-- adding two app delegate notification observers here.
         1.) app did return to foreground for when user leaves the app manually and then returns
         2.) user navigated through to settings and then pressed the phone back button
         to return to the app
         --*/
        NotificationCenter.default.addObserver(self, selector: #selector(appDelegateNotificationTriggered), name: .appDidReturnToForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDelegateNotificationTriggered), name: .appDidReturnToActiveState, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appDelegateNotificationTriggered() {
        checkCameraUsagePermissionState()
    }
    
    func checkCameraUsagePermissionState(andRequestPermissionIfNecessary canRequestPermission: Bool = true) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            DispatchQueue.main.async {
                if self.permissionDeniedView.isVisible() {
                    self.permissionDeniedView.hide()
                }
            }
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            DispatchQueue.main.async {
                self.permissionDeniedView.show()
            }
        } else {
            if canRequestPermission {
                self.requestCameraUsagePermissions()
            }
        }
    }
    
    func requestCameraUsagePermissions() {
        AVCaptureDevice.requestAccess(for: .video) { (_) in
            self.checkCameraUsagePermissionState(andRequestPermissionIfNecessary: false)
        }
    }
    
    func handleChildDelegates() {
        backButton.delegate = self
        addPhotoButton.delegate = self
        savePhotoButton.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(backButton)
        backButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(skipButton)
        skipButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: backButton.centerYAnchor)
        
        self.view.addSubview(accountImageTitleLabel)
        accountImageTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(accountImageInstructionLabel)
        accountImageInstructionLabel.anchor(withTopAnchor: accountImageTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 6.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(addPhotoButton)
        addPhotoButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        let profileImageButtonDiamater: CGFloat = 160.0
        self.view.addSubview(profileImageView)
        profileImageView.anchor(withTopAnchor: accountImageInstructionLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: profileImageButtonDiamater, heightAnchor: profileImageButtonDiamater, padding: .init(top: 48.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(changeProfileImageButton)
        changeProfileImageButton.anchor(withTopAnchor: profileImageView.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: profileImageView.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        savePhotoButton.isHidden = true
        self.view.addSubview(savePhotoButton)
        savePhotoButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -6.0, right: -horizontalPadding))
        
        /*-- no camera permissions view --*/
        self.view.addSubview(permissionDeniedView)
        permissionDeniedView.anchor(withTopAnchor: accountImageTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
    }
    
    @objc func openImagePickerVC() {
        let phoneCameraOptionsAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let openCameraOption = UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.presentImagePickerVC(withSourceType: .camera)
        })
        openCameraOption.setValue(UIColor.black, forKey: "titleTextColor")
        phoneCameraOptionsAlert.addAction(openCameraOption)
        
        let openPhoneLibraryOption = UIAlertAction(title: "Photo Album", style: .default, handler: { (action: UIAlertAction) in
            self.presentImagePickerVC(withSourceType: .photoLibrary)
        })
        openPhoneLibraryOption.setValue(UIColor.black, forKey: "titleTextColor")
        phoneCameraOptionsAlert.addAction(openPhoneLibraryOption)
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            phoneCameraOptionsAlert.dismiss(animated: true, completion: nil)
        })
        cancelOption.setValue(UIColor.red, forKey: "titleTextColor")
        phoneCameraOptionsAlert.addAction(cancelOption)
        self.present(phoneCameraOptionsAlert, animated: true, completion: nil)
    }
    
    @objc func skipButtonPressed() {
        self.navigateToMailingListVC()
    }
    
    func saveProfileImageToAccount() {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        guard let profileImage = self.profileImage else {
            SharedModalService.instance.hideCustomOverlayModal()
            showErrorMessage(withMessage: "We were unable to identify your selected image. Please try selecting the image again, then retry")
            return
        }
        UserService.instance.updateUserData(withName: "profileImageUrl", andValue: profileImage) { (updatedSuccessfully) in
            SharedModalService.instance.hideCustomOverlayModal()
            if updatedSuccessfully {
                self.navigateToMailingListVC()
            } else {
                self.showErrorMessage(withMessage: "We were unable to update your account with your profile image. Please try again, or click skip to have a go later on")
            }
        }
    }
    
    func showErrorMessage(withMessage message: String) {
        let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: message)
        SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
    }
    
    func navigateToMailingListVC() {
        let addAccountMailingListVC = AddAccountMailingListVC()
        self.navigationController?.pushViewController(addAccountMailingListVC, animated: true)
    }
}

// button delegate methods
extension AddAccountImageVC: BackButtonDelegate, MainActionButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
        if buttonUseType == .openImagePickerVC {
            openImagePickerVC()
        }
        
        if buttonUseType == .saveProfileImage {
            saveProfileImageToAccount()
        }
    }
}

// image picker controller methods and delegate methods
extension AddAccountImageVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentImagePickerVC(withSourceType sourceType: UIImagePickerController.SourceType) {
        let imagePickerVC: UIImagePickerController = {
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            return vc
        }()
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePickerVC.sourceType = sourceType
            self.present(imagePickerVC, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            updateProfileImageUploadButton(withImage: editedImage)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            updateProfileImageUploadButton(withImage: originalImage)
        } else {
            // handle the error
        }
    }
    
    func updateProfileImageUploadButton(withImage image: UIImage) {
        profileImage = image
    }
}

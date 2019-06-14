//
//  UpdateProfileImageVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/12/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVFoundation

class UpdateProfileImageVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Update your professional image and click the save button to update the changes"
        label.textColor = darkGrey
        label.font = defaultContentFont
        label.numberOfLines = 0
        return label
    }()
    
    let cameraPermissionsAuthorizedContainer = UIView()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 80.0
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let openImagePickerButton = MainActionButton(buttonUseType: .openImagePickerVC, buttonTitle: "Change Profile Picture", buttonColour: .red, isDisabled: false)
    
    let cameraPermissionsDeniedContainer = UIView()
    
    let permissionDeniedView = PermissionDeniedView(title: "Camera Access Denied", message: "Castovision is unable to access your camera or phone library, and so cannot provide this feature. You can update the app's camera access permissions at anytime by going to castovision inside your phone settings", canShowButton: false)
    
    let currentProfileImage = UserService.instance.currentUser.profileImageData
    var newProfileImage: UIImage? = nil {
        didSet {
            if let newProfileImage = self.newProfileImage {
                self.profileImageView.image = newProfileImage
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Update Profile Image", withSearchBar: false)
        checkCameraUsagePermissionState()
        addNavigationRightButton()
        handleChildDelegates()
        anchorChildViews()
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
                self.cameraPermissionsDeniedContainer.isHidden = true
                self.cameraPermissionsAuthorizedContainer.isHidden = false
            }
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            DispatchQueue.main.async {
                self.cameraPermissionsAuthorizedContainer.isHidden = true
                self.cameraPermissionsDeniedContainer.isHidden = false
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
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(updateChanges))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleChildDelegates() {
        self.openImagePickerButton.delegate = self
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(instructionLabel)
        instructionLabel.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(cameraPermissionsAuthorizedContainer)
        cameraPermissionsAuthorizedContainer.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        let profileImageButtonDiamater: CGFloat = 160.0
        profileImageView.image = UIImage(data: self.currentProfileImage!)
        cameraPermissionsAuthorizedContainer.addSubview(profileImageView)
        profileImageView.anchor(withTopAnchor: cameraPermissionsAuthorizedContainer.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: cameraPermissionsAuthorizedContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: profileImageButtonDiamater, heightAnchor: profileImageButtonDiamater, padding: .init(top: 48.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        cameraPermissionsAuthorizedContainer.addSubview(openImagePickerButton)
        openImagePickerButton.anchor(withTopAnchor: nil, leadingAnchor: cameraPermissionsAuthorizedContainer.leadingAnchor, bottomAnchor: cameraPermissionsAuthorizedContainer.bottomAnchor, trailingAnchor: cameraPermissionsAuthorizedContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
        
        self.view.addSubview(cameraPermissionsDeniedContainer)
        cameraPermissionsDeniedContainer.anchor(withTopAnchor: instructionLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        cameraPermissionsDeniedContainer.addSubview(permissionDeniedView)
        permissionDeniedView.anchor(withTopAnchor: nil, leadingAnchor: cameraPermissionsDeniedContainer.leadingAnchor, bottomAnchor: nil, trailingAnchor: cameraPermissionsDeniedContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: cameraPermissionsDeniedContainer.centerYAnchor)
    }
    
    @objc func updateChanges() {
        SharedModalService.instance.showCustomOverlayModal(withMessage: "Updating Account")
        UserService.instance.updateUserData(withName: "profileImageUrl", andValue: newProfileImage) { (updatedSuccessfully) in
            SharedModalService.instance.hideCustomOverlayModal()
            if updatedSuccessfully {
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to update your profile image on account. Please try again")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
            }
        }
    }
}

// button delegate methods
extension UpdateProfileImageVC: MainActionButtonDelegate {
    func mainActionButtonPressed(fromButtonUseType buttonUseType: MainActionButtonType) {
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
}

// image picker controller methods and delegate methods
extension UpdateProfileImageVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
            self.newProfileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.newProfileImage = originalImage
        } else {
            let errorConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to get the data for the image that you selected. Please try again")
            SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorConfig)
        }
    }
}

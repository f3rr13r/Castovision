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
        iv.image = #imageLiteral(resourceName: "castovision-logo-background")
        return iv
    }()
    
    let logoImageView = LogoImageView()
    let backButton = BackButton()
    
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
    
    let profileImageUploadButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "empty-profile-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 80.0
        button.addTarget(self, action: #selector(profileImageUploadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let permissionDeniedView = PermissionDeniedView(title: "Camera Access Denied", message: "Castovision is unable to access your camera or phone library, and so cannot provide this feature. You can update the camera access permission at anytime inside of your phone settings")
    
    // image picker controller
    lazy var imagePickerVC: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        return vc
    }()
    
    // variables
    var canEnableSaveButton: Bool = false {
        didSet {
            // update the main action button state
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
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
            if permissionDeniedView.isVisible() {
                permissionDeniedView.hide()
            }
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            permissionDeniedView.show()
        } else {
            if canRequestPermission {
                requestCameraUsagePermissions()
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
        imagePickerVC.delegate = self
    }
    
    func anchorSubviews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: screenWidth * 1.25, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(backButton)
        backButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(logoImageView)
        logoImageView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        self.view.addSubview(accountImageTitleLabel)
        accountImageTitleLabel.anchor(withTopAnchor: logoImageView.bottomAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        self.view.addSubview(accountImageInstructionLabel)
        accountImageInstructionLabel.anchor(withTopAnchor: accountImageTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 6.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        let profileImageButtonDiamater: CGFloat = 160.0
        self.view.addSubview(profileImageUploadButton)
        profileImageUploadButton.anchor(withTopAnchor: accountImageInstructionLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.safeAreaLayoutGuide.centerXAnchor, centreYAnchor: nil, widthAnchor: profileImageButtonDiamater, heightAnchor: profileImageButtonDiamater, padding: .init(top: 48.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        /*-- no camera permissions view --*/
        self.view.addSubview(permissionDeniedView)
        permissionDeniedView.anchor(withTopAnchor: accountImageTitleLabel.bottomAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        
    }
    
    @objc func profileImageUploadButtonPressed() {
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

// button delegate methods
extension AddAccountImageVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

// image picker controller methods and delegate methods
extension AddAccountImageVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentImagePickerVC(withSourceType sourceType: UIImagePickerController.SourceType) {
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
        profileImageUploadButton.setImage(image, for: .normal)
        canEnableSaveButton = true
    }
}

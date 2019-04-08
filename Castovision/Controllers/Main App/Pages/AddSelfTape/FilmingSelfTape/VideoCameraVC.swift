//
//  VideoCameraVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import CameraManager
import AVKit

protocol VideoCameraVCDelegate {
    func backButtonPressed()
}

class VideoCameraVC: UIViewController {

    // views
    let cameraView = UIView()
    let interactionsView = UIView()
    
    let backButton: BackButton = {
        let button = BackButton()
        button.backgroundColor = .clear
        button.backArrowIcon.tintColor = .white
        return button
    }()
    
    // variables
    private var _sceneNumber: Int
    private var _cameraManager: CameraManager = CameraManager()
    private var _timer: Timer!
    private var _isCameraRecording: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                self.interactionsView.alpha = self._isCameraRecording ? 0.0 : 1.0
                self.interactionsView.isUserInteractionEnabled = self._isCameraRecording ? false : true
            }, completion: nil)
        }
    }
    
    // delegate
    var delegate: VideoCameraVCDelegate?
    
    init(sceneNumber: Int) {
        self._sceneNumber = sceneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        handleChildDelegates()
        anchorSubviews()
        setupVideoCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // do some camera stuff here
    }
    
    func handleChildDelegates() {
        backButton.delegate = self
    }
    
    func anchorSubviews() {
        // camera view
        self.view.addSubview(cameraView)
        cameraView.anchor(withTopAnchor: self.view.topAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: self.view.centerXAnchor, centreYAnchor: self.view.centerYAnchor)
        
        // interactions view (on top)
        self.view.addSubview(interactionsView)
        interactionsView.anchor(withTopAnchor: self.view.topAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: self.view.centerXAnchor, centreYAnchor: self.view.centerYAnchor)
        
        interactionsView.addSubview(backButton)
        backButton.anchor(withTopAnchor: interactionsView.topAnchor, leadingAnchor: interactionsView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
    }
    
    func setupVideoCamera() {
        // set the preferred properties for the camera manager
        _cameraManager.cameraDevice = .back
        _cameraManager.flashMode = .off
        _cameraManager.cameraOutputMode = .videoWithMic
        _cameraManager.cameraOutputQuality = .high
        _cameraManager.writeFilesToPhoneLibrary = false
        _cameraManager.focusMode = .continuousAutoFocus
        _cameraManager.exposureMode = .continuousAutoExposure
        
        // expose the camera to the device screen
        _cameraManager.addPreviewLayerToView(self.cameraView)
    }
    
    @objc func toggleRecording() {
        self._isCameraRecording = !self._isCameraRecording
        if _isCameraRecording {
            self._cameraManager.stopVideoRecording(nil)
        } else {
            self._cameraManager.startRecordingVideo()
        }
    }
}

// button delegate methods
extension VideoCameraVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.dismissVideoFilmingNavigationVC()
    }
}

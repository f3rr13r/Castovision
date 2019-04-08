//
//  videotest.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit
import CoreMedia
import CameraManager

//class CameraVC: UIViewController {
//
//    // views
//    let cameraView: UIView = {
//        let view = UIView()
//        return view
//    }()
//
//    let switchTorchButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(toggleTorchButtonPressed), for: .touchUpInside)
//        return button
//    }()
//
//    let switchTorchIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.image = #imageLiteral(resourceName: "torch-icon").withRenderingMode(.alwaysTemplate)
//        iv.tintColor = .white
//        return iv
//    }()
//
//    let bottomGradientView: GradientView = {
//        let gradientView = GradientView()
//        gradientView.colors = [UIColor.clear, ditloOffBlack.withAlphaComponent(0.4)]
//        return gradientView
//    }()
//
//    let recordingInstructionLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Press the button above to start recording"
//        label.textColor = .white
//        label.textAlignment = .center
//        label.font = smallParagraphFont
//        return label
//    }()
//
//    let startRecordingButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(startVideoRecordingButtonPressed), for: .touchUpInside)
//        button.layer.borderColor = UIColor.white.cgColor
//        button.layer.borderWidth = 4.0
//        button.layer.cornerRadius = 30.0
//        return button
//    }()
//
//    let recordingButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(stopVideoRecordingButtonPressed), for: .touchUpInside)
//        button.layer.cornerRadius = 30.0
//        button.isHidden = true
//        return button
//    }()
//
//    let progressShape = CAShapeLayer()
//    let backgroundShape = CAShapeLayer()
//
//    let recordingButtonInsideView: UIView = {
//        let view = UIView()
//        view.backgroundColor = ditloRed.withAlphaComponent(0.5)
//        view.layer.cornerRadius = 23.0
//        view.isUserInteractionEnabled = false
//        return view
//    }()
//
//    // variables
//    var cameraManager: CameraManager?
//    var isCameraRecording: Bool = false
//    var timer: Timer!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .black
//        anchorSubviews()
//        setupCamera()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        cameraManager?.flashMode = .off
//        stopRecording(andLeavePage: true)
//        //self.animatorView.stopAnimation()
//    }
//
//    func anchorSubviews() {
//        // camera view
//        self.view.addSubview(cameraView)
//        cameraView.fillSuperview()
//
//        // toggle torch mode button
//        self.view.addSubview(switchTorchButton)
//        switchTorchButton.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: screenWidth / 3, heightAnchor: 30.0, padding: .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
//        self.switchTorchButton.addSubview(switchTorchIcon)
//        switchTorchIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.switchTorchButton.trailingAnchor, centreXAnchor: nil, centreYAnchor: self.switchTorchButton.centerYAnchor, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
//
//        // bottom gradient view
//        self.view.addSubview(bottomGradientView)
//        bottomGradientView.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: safeAreaScreenHeight * 0.25)
//
//        // recording instruction label
//        self.view.addSubview(recordingInstructionLabel)
//        recordingInstructionLabel.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: -24.0, right: -horizontalPadding))
//
//        // start recording button
//        self.view.addSubview(startRecordingButton)
//        startRecordingButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: recordingInstructionLabel.topAnchor, trailingAnchor: nil, centreXAnchor: self.view.centerXAnchor, centreYAnchor: nil, widthAnchor: 60.0, heightAnchor: 60.0, padding: .init(top: 0.0, left: 0.0, bottom: -12.0, right: 0.0))
//
//        // stop recording button
//        self.view.addSubview(recordingButton)
//        recordingButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: recordingInstructionLabel.topAnchor, trailingAnchor: nil, centreXAnchor: self.view.centerXAnchor, centreYAnchor: nil, widthAnchor: 60.0, heightAnchor: 60.0, padding: .init(top: 0.0, left: 0.0, bottom: -12.0, right: 0.0))
//        recordingButton.transform = CGAffineTransform(rotationAngle: -89.5)
//
//        // inside button animation stuff
//        self.recordingButton.addSubview(recordingButtonInsideView)
//        recordingButtonInsideView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.recordingButton.centerXAnchor, centreYAnchor: self.recordingButton.centerYAnchor, widthAnchor: 46.0, heightAnchor: 46.0)
//
//        recordingButton.layer.addSublayer(backgroundShape)
//        backgroundShape.frame = CGRect(x: 30, y: 30, width: 60.0, height: 60.0)
//        backgroundShape.path = UIBezierPath(ovalIn: backgroundShape.frame).cgPath
//        backgroundShape.position = recordingButton.center
//        backgroundShape.strokeColor = ditloRed.withAlphaComponent(0.5).cgColor
//        backgroundShape.lineWidth = 4.0
//        backgroundShape.fillColor = UIColor.clear.cgColor
//
//        recordingButton.layer.addSublayer(progressShape)
//        progressShape.frame = backgroundShape.frame
//        progressShape.path = backgroundShape.path
//        progressShape.position = backgroundShape.position
//        progressShape.strokeColor = ditloRed.cgColor
//        progressShape.lineWidth = backgroundShape.lineWidth
//        progressShape.fillColor = UIColor.clear.cgColor
//    }
//
//    func setupCamera() {
//        // show the overlay modal whilst initial camera setup takes places.
//        SharedModalsService.instance.showCustomOverlayModal(withMessage: "Initializing camera...")
//
//        // instantiate the camera manager
//        cameraManager = CameraManager()
//
//        // set the preferred properties for the camera manager
//        cameraManager?.cameraDevice = .back
//        cameraManager?.animateCameraDeviceChange = false
//        cameraManager?.flashMode = .off
//        cameraManager?.cameraOutputMode = .videoWithMic
//        cameraManager?.cameraOutputQuality = .high
//        cameraManager?.writeFilesToPhoneLibrary = false
//        cameraManager?.focusMode = .continuousAutoFocus
//        cameraManager?.exposureMode = .continuousAutoExposure
//        cameraManager?.shouldRespondToOrientationChanges = false
//
//        // expose the camera to the device screen
//        cameraManager?.addPreviewLayerToView(self.cameraView)
//
//        // camera is initialized so hide the overlay
//        SharedModalsService.instance.hideCustomOverlayModal()
//    }
//}
//
//// camera related functionality
//extension CameraVC {
//    @objc func toggleTorchButtonPressed() {
//        if cameraManager?.flashMode == .off {
//            cameraManager?.flashMode = .on
//            switchTorchIcon.tintColor = ditloYellow
//        } else {
//            cameraManager?.flashMode = .off
//            switchTorchIcon.tintColor = .white
//        }
//    }
//
//    @objc func startVideoRecordingButtonPressed() {
//        if !isCameraRecording {
//            cameraManager?.startRecordingVideo()
//        }
//        toggleRecordingButtons(toRecordingState: true)
//        updateRecordingInstructionLabel(toIsRecordingState: true)
//    }
//
//    @objc func stopVideoRecordingButtonPressed() {
//        stopRecording()
//    }
//
//    func toggleRecordingButtons(toRecordingState shouldShowRecordingState: Bool) {
//        self.view.isUserInteractionEnabled = false
//        if !shouldShowRecordingState {
//            // go back to start recording button
//            recordingButton.isHidden = true
//            startRecordingButton.isHidden = false
//            isCameraRecording = false
//            stopRecordingAnimation()
//        } else {
//            // go to recording state
//            startRecordingButton.isHidden = true
//            recordingButton.isHidden = false
//            isCameraRecording = true
//            startRecordingAnimation()
//        }
//        self.view.isUserInteractionEnabled = true
//    }
//
//    func startRecordingAnimation() {
//        // border chase animation
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = progressShape.strokeStart
//        animation.toValue = progressShape.strokeEnd
//        animation.duration = 1.0
//        animation.repeatCount = .infinity
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
//        progressShape.add(animation, forKey: nil)
//
//        // inner fade animation
//        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
//            UIView.animate(withDuration: 1.0, animations: {
//                self.recordingButtonInsideView.backgroundColor = ditloRed
//            }) { (_) in
//                UIView.animate(withDuration: 1.0, animations: {
//                    self.recordingButtonInsideView.backgroundColor = ditloRed.withAlphaComponent(0.5)
//                }, completion: nil)
//            }
//        })
//        timer.fire()
//    }
//
//    func stopRecording(andLeavePage isLeavingPage: Bool = false) {
//        if isCameraRecording {
//            toggleRecordingButtons(toRecordingState: false)
//            updateRecordingInstructionLabel(toIsRecordingState: false)
//            cameraManager?.stopVideoRecording({ (videoURL, error) -> Void in
//                if !isLeavingPage {
//                    if let playbackVideoURL = videoURL {
//                        DispatchQueue.main.async {
//                            let cameraPlaybackVC = CameraPlaybackVC(videoUrl: playbackVideoURL)
//                            self.navigationController?.pushViewController(cameraPlaybackVC, animated: true)
//                        }
//                    }
//                }
//            })
//        }
//    }
//
//    func stopRecordingAnimation() {
//        timer.invalidate()
//        recordingButtonInsideView.backgroundColor = ditloRed.withAlphaComponent(0.5)
//    }
//
//    func updateRecordingInstructionLabel(toIsRecordingState isRecording: Bool) {
//        let recordingMessage: String = isRecording ? "Press the button again to finished recording" : "Press the button above to start recording"
//        recordingInstructionLabel.text = recordingMessage
//    }
//}

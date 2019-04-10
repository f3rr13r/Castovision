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
    
    let recordingButton: UIButton = {
        let button = UIButton()
        button.layer.zPosition = 1
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        return button
    }()
    
    let recordingButtonOuterRingView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 25.0
        view.layer.borderWidth = 4.0
        view.layer.borderColor = UIColor.red.cgColor
        return view
    }()
    
    let recordingButtonCentreCircle: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 20.0
        return view
    }()
    
    let timeContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        return view
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .black
        label.font = defaultContentFont
        label.textAlignment = .center
        return label
    }()
    
    // variables
    private var _sceneNumber: Int
    private var _cameraManager: CameraManager = CameraManager()
    private var _timer: Timer?
    private var _time: Double = 0.0
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
        if _isCameraRecording {
            _cameraManager.stopVideoRecording(nil)
            stopTimerLabel()
        }
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
        
        // back button
        interactionsView.addSubview(backButton)
        backButton.anchor(withTopAnchor: interactionsView.safeAreaLayoutGuide.topAnchor, leadingAnchor: interactionsView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
        
        // recording button
        self.view.insertSubview(recordingButton, aboveSubview: interactionsView)
        recordingButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 50.0, heightAnchor: 50.0, padding: .init(top: 0.0, left: 10.0, bottom: -10.0, right: 0.0))
        recordingButton.addSubview(recordingButtonOuterRingView)
        recordingButtonOuterRingView.fillSuperview()
        recordingButtonOuterRingView.addSubview(recordingButtonCentreCircle)
        recordingButtonCentreCircle.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: recordingButtonOuterRingView.centerXAnchor, centreYAnchor: recordingButtonOuterRingView.centerYAnchor, widthAnchor: 40.0, heightAnchor: 40.0)
        
        // timer
        self.view.addSubview(timeContainerView)
        timeContainerView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -10.0, right: -10.0))
        timeContainerView.addSubview(timeLabel)
        timeLabel.anchor(withTopAnchor: timeContainerView.topAnchor, leadingAnchor: timeContainerView.leadingAnchor, bottomAnchor: timeContainerView.bottomAnchor, trailingAnchor: timeContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 4.0, left: 12.0, bottom: -4.0, right: -12.0))
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
        if _isCameraRecording {
            stopTimerLabel()
            self._cameraManager.stopVideoRecording { (videoURL, error) in
                if error != nil {
                    // handle error message
                } else {
                    guard let videoURL = videoURL else {
                        // handle error
                        return
                    }
                    self.navigateToEditSceneVC(withVideoURL: videoURL)
                }
            }
        } else {
            self._cameraManager.startRecordingVideo()
            startTimerLabel()
        }
        
        self._isCameraRecording = !self._isCameraRecording
    }
    
    func startTimerLabel() {
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
            self.startRecordingButtonAnimation()
            self._time += 1.0
            let hours = Int(self._time / 3600)
            let minutes = Int((self._time.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(self._time.truncatingRemainder(dividingBy: 60))
            self.timeLabel.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        })
    }
    
    func startRecordingButtonAnimation() {
        UIView.animate(withDuration: 1.0) {
            self.recordingButtonOuterRingView.alpha = self.recordingButtonOuterRingView.alpha == 1.0 ? 0.65 : 1.0
            self.recordingButtonCentreCircle.alpha = self.recordingButtonCentreCircle.alpha == 1.0 ? 0.65 : 1.0
        }
    }
    
    func stopTimerLabel() {
        stopRecordingButtonAnimation()
        _timer!.invalidate()
        _time = 0.0
        timeLabel.text = "00:00:00"
    }
    
    func stopRecordingButtonAnimation() {
        self.recordingButtonOuterRingView.alpha = 1.0
        self.recordingButtonCentreCircle.alpha = 1.0
    }
    
    func navigateToEditSceneVC(withVideoURL videoURL: URL) {
        // get the duration of the video for the take's endTime
        let startTime = 0.0
        let endTime = getVideoEndTime(fromVideoURL: videoURL)
        let take = Take(videoUrl: videoURL, startTime: startTime, endTime: endTime, numberOfViews: 0)
        print("startTime: ", startTime)
        print("endTime: ", endTime)
        let editSceneTakeVC = EditSceneTakeVC(take: take, sceneNumber: self._sceneNumber)
        self.navigationController?.pushViewController(editSceneTakeVC, animated: true)
    }
    
    func getVideoEndTime(fromVideoURL videoURL: URL) -> Double {
        let asset = AVAsset(url: videoURL)
        let endTime = asset.duration.seconds
        return endTime
    }
}

// button delegate methods
extension VideoCameraVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.dismissVideoFilmingNavigationVC()
    }
}

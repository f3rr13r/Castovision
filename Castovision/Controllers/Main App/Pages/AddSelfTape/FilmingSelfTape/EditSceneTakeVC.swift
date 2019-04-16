//
//  EditSceneTakeVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit
import CoreMedia
import PryntTrimmerView

class EditSceneTakeVC: UIViewController {

    // views
    let interactionsView: UIView = {
        let view = UIView()
        view.layer.zPosition = 1
        return view
    }()
    
    let backButton: BackButton = {
        let button = BackButton()
        button.backgroundColor = .clear
        button.backArrowIcon.tintColor = .white
        return button
    }()
    
    let saveTakeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 4.0
        button.setTitle("Save Take", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = defaultButtonFont
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
        button.addTarget(self, action: #selector(saveTakeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.style = .white
        spinner.stopAnimating()
        return spinner
    }()
    
    let togglePlayButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(togglePlayButtonPressed), for: .touchUpInside)
        return button
    }()
    let togglePlayButtonIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "play-icon")
        return iv
    }()
    
    var trimmerViewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        return view
    }()
    var trimmerView: TrimmerView = {
        let tv = TrimmerView()
        tv.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        tv.mainColor = grey
        tv.handleColor = darkGrey
        tv.positionBarColor = .red
        return tv
    }()
    
    // we won't instantiate this until needed
    var saveTakeModal: TakeSavedModal = {
        let modal = TakeSavedModal()
        modal.layer.zPosition = 1.0
        return modal
    }()
    
    // take and scene number
    private var _take: Take
    private var _sceneNumber: Int
    
    // video player variables
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    
    var isVideoPlaying: Bool = false {
        didSet {
            if self.isVideoPlaying {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "pause-icon")
            } else {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "play-icon")
            }
        }
    }
    
    var needSaveButtonLoadingState: Bool = false {
        didSet {
            if self.needSaveButtonLoadingState {
                saveTakeButton.setTitleColor(.clear, for: .normal)
                saveTakeButton.isEnabled = false
                loadingSpinner.startAnimating()
            } else {
                loadingSpinner.stopAnimating()
                saveTakeButton.setTitleColor(.white, for: .normal)
                saveTakeButton.isEnabled = true
            }
        }
    }
    
    init(take: Take, sceneNumber: Int) {
        self._take = take
        self._sceneNumber = sceneNumber
        super.init(nibName: nil, bundle: nil)
        self.setupAVPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        handleChildDelegates()
        anchorSubviews()
    }
    
    func handleChildDelegates() {
        backButton.delegate = self
        saveTakeModal.delegate = self
    }
    
    func anchorSubviews() {
        // interactions view (on top)
        self.view.addSubview(interactionsView)
        interactionsView.anchor(withTopAnchor: self.view.topAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: self.view.centerXAnchor, centreYAnchor: self.view.centerYAnchor)
        
        // back button
        interactionsView.addSubview(backButton)
        backButton.anchor(withTopAnchor: interactionsView.safeAreaLayoutGuide.topAnchor, leadingAnchor: interactionsView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
        
        // save take button
        interactionsView.addSubview(saveTakeButton)
        saveTakeButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: interactionsView.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: backButton.centerYAnchor, widthAnchor: nil, heightAnchor: 36.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -10.0))
        saveTakeButton.addSubview(loadingSpinner)
        loadingSpinner.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: saveTakeButton.centerXAnchor, centreYAnchor: saveTakeButton.centerYAnchor)
        
        // toggle play button
        interactionsView.addSubview(togglePlayButton)
        togglePlayButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 40.0, heightAnchor: 60.0, padding: .init(top: 0.0, left: 0.0, bottom: -12.0, right: 0.0))
        togglePlayButton.addSubview(togglePlayButtonIconImageView)
        togglePlayButtonIconImageView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: togglePlayButton.centerXAnchor, centreYAnchor: togglePlayButton.centerYAnchor, widthAnchor: 24.0, heightAnchor: 24.0)
        
        // video range slider
        self.interactionsView.addSubview(trimmerViewContainer)
        trimmerViewContainer.anchor(withTopAnchor: nil, leadingAnchor: togglePlayButton.trailingAnchor, bottomAnchor: interactionsView.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: interactionsView.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: trimmerViewHeight, padding: .init(top: 0.0, left: 10.0, bottom: -12.0, right: -10.0))
        
        trimmerViewContainer.addSubview(trimmerView)
        trimmerView.anchor(withTopAnchor: trimmerViewContainer.topAnchor, leadingAnchor: trimmerViewContainer.leadingAnchor, bottomAnchor: trimmerViewContainer.bottomAnchor, trailingAnchor: trimmerViewContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: trimmerViewWidth, heightAnchor: trimmerViewHeight)
        
        self.setupTrimmerView()
    }
    
    func setupTrimmerView() {
        /*-- for some reason the trimmer view requies the main branch here --*/
        DispatchQueue.main.async {
            if let videoUrl = self._take.videoUrl {
                let videoAsset = AVAsset(url: videoUrl)
                
                self.trimmerView.asset = videoAsset
                self.trimmerView.delegate = self
                self.trimmerView.minDuration = 0.0
                self.trimmerView.maxDuration = videoAsset.duration.seconds
            }
        }
    }
    
    @objc func saveTakeButtonPressed() {
        self.needSaveButtonLoadingState = true
        
        if let trimmerViewStartTime = self.trimmerView.startTime,
            let trimmerViewEndTime = self.trimmerView.endTime {
            let videoDurationCMTime = CMTimeSubtract(trimmerViewEndTime, trimmerViewStartTime)
            let updatedVideoDuration = CMTimeGetSeconds(videoDurationCMTime)

            self._take.videoDuration = updatedVideoDuration
            VideoHelperMethodsService.instance.generateThumbnail(forVideoAtTempUrl: self._take.videoUrl!, atTime: trimmerViewStartTime, completion: { (thumbnailImageData) in
                self._take.videoThumbnailUrl = thumbnailImageData
                
                VideoHelperMethodsService.instance.trimVideo(sourceURL: self._take.videoUrl!, startTime: trimmerViewStartTime, endTime: trimmerViewEndTime, completion: { (croppedVideo, didCropSuccessfully) in
                    if didCropSuccessfully {
                        DispatchQueue.main.async {
                            print(croppedVideo!)
                            self._take.videoUrl = croppedVideo
                            
                            AddSelfTapeService.instance.addNewSceneTake(withValue: self._take, forSceneNumber: self._sceneNumber) {
                                self.needSaveButtonLoadingState = false
                                
                                self.view.addSubview(self.saveTakeModal)
                                self.saveTakeModal.fillSuperview()
                                self.saveTakeModal.showModal()
                            }
                        }
                    }
                })
            })
        } else {
            self.needSaveButtonLoadingState = false
        }
    }
}

// button delegate methods
extension EditSceneTakeVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

// custom modal view delegate methods
extension EditSceneTakeVC: TakeSavedModalDelegate {
    func filmAnotherTakeButtonPressed() {
        saveTakeModal.hide {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func dismissButtonPressed() {
        saveTakeModal.hide {
            self.navigationController?.dismissVideoFilmingNavigationVC()
        }
    }
}

// video playback methods
extension EditSceneTakeVC {
    func setupAVPlayer() {
        // instantiate the player item
        guard let videoUrl = self._take.videoUrl else { return }
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: videoUrl)
        
        // notifications for video when video ends
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // instantiate the av player
        player = AVPlayer(playerItem: playerItem)
        
        // instantiate the av player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        // add player layer to the VC
        self.view.layer.addSublayer(playerLayer!)
    }
    
    @objc func togglePlayButtonPressed() {
        
        guard let player = player else { return }
        
        if !isVideoPlaying {
            player.play()
            startPlaybackTimeChecker()
        } else {
            player.pause()
            stopPlaybackTimeChecker()
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

// trimmer view delegate
extension EditSceneTakeVC: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        isVideoPlaying = false
        //player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        isVideoPlaying = false
    }
}

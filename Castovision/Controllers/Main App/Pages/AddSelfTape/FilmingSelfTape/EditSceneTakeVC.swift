//
//  EditSceneTakeVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit
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
    
    private var _videoURL: URL
    
    // video player variables
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var startTime: Double?
    var endTime: Double?
    
    var isVideoPlaying: Bool = false {
        didSet {
            if self.isVideoPlaying {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "pause-icon")
            } else {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "play-icon")
            }
        }
    }
    
    init(videoURL: URL) {
        self._videoURL = videoURL
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
    }
    
    func anchorSubviews() {
        // interactions view (on top)
        self.view.addSubview(interactionsView)
        interactionsView.anchor(withTopAnchor: self.view.topAnchor, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: self.view.centerXAnchor, centreYAnchor: self.view.centerYAnchor)
        
        // back button
        interactionsView.addSubview(backButton)
        backButton.anchor(withTopAnchor: interactionsView.safeAreaLayoutGuide.topAnchor, leadingAnchor: interactionsView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
        
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
            self.trimmerView.minDuration = 0.0
            let videoAsset = AVAsset(url: self._videoURL)
            let maxDurationCMTime = CMTimeGetSeconds(videoAsset.duration)
            let maxDuration = Double(maxDurationCMTime)
            self.trimmerView.maxDuration = maxDuration
            self.trimmerView.delegate = self
            self.trimmerView.asset = AVAsset(url: self._videoURL)
        }
    }
}

// button delegate methods
extension EditSceneTakeVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

// video playback methods
extension EditSceneTakeVC {
    func setupAVPlayer() {
        // instantiate the player item
        let playerItem: AVPlayerItem = AVPlayerItem(url: self._videoURL)
        
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
        if !isVideoPlaying {
            player?.play()
            startPlaybackTimeChecker()
        } else {
            player?.pause()
            stopPlaybackTimeChecker()
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        print("item did finish playing")
        player?.pause()
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
    func didChangePositionBar(_ playerTime: CMTime) {
        handleAVPlayerUpdate(withPlayerTime: playerTime)
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        handleAVPlayerUpdate(withPlayerTime: playerTime)
    }
    
    func handleAVPlayerUpdate(withPlayerTime playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.pause()
        isVideoPlaying = false
    }
}

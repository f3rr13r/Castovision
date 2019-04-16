//
//  TakeViewerVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/16/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit

class TakeViewerVC: UIViewController {
    
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
    
    let labelContainerView = UIView()
    
    let sceneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = smallTitleFont
        label.textColor = .white
        return label
    }()
    
    let sceneTakeLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = defaultContentFont
        label.textColor = .white
        return label
    }()
    
    let playActionsBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 12.0
        blurView.clipsToBounds = true
        return blurView
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
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = defaultContentFont
        label.textColor = .white
        label.text = "00:00"
        return label
    }()
    
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.4)
        slider.setThumbImage(#imageLiteral(resourceName: "progress-slider"), for: .normal)
        slider.layer.cornerRadius = slider.frame.height / 2
        slider.addTarget(self, action: #selector(progressSliderValueDidChange), for: .valueChanged)
        return slider
    }()
    
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = defaultContentFont
        label.textColor = .white
        label.text = "00:00"
        return label
    }()
    
    // take, take number and scene number
    private var _take: Take
    private var _takeNumber: Int
    private var _sceneNumber: Int
    
    // video player variables
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isVideoPlaying: Bool = false {
        didSet {
            if self.isVideoPlaying {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "pause-icon")
            } else {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "play-icon")
            }
        }
    }
    
    var isVideoBarVisible: Bool = true
    
    init(sceneNumber: Int, takeNumber: Int, take: Take) {
        self._sceneNumber = sceneNumber
        self._takeNumber = takeNumber
        self._take = take
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAVPlayer()
        self.addTapGestureRecognizer()
        self.handleChildDelegates()
        self.anchorSubviews()
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func userDidTap(_ tap: UITapGestureRecognizer) {
        let tapLocation = tap.location(in: self.view)
        if !playActionsBlurView.bounds.contains(tapLocation) {
            toggleIsVideoBarVisibleStatus()
        }
    }
    
    func toggleIsVideoBarVisibleStatus() {
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.playActionsBlurView.alpha = self.isVideoBarVisible ? 0.0 : 1.0
        }) { (animationComplete) in
            self.view.isUserInteractionEnabled = true
        }
        
        self.isVideoBarVisible = !self.isVideoBarVisible
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
        
        // label container view and labels
        interactionsView.addSubview(labelContainerView)
        labelContainerView.anchor(withTopAnchor: nil, leadingAnchor: backButton.trailingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: backButton.centerYAnchor)
        
        // scene number label
        sceneNumberLabel.text = "Scene \(self._sceneNumber)"
        labelContainerView.addSubview(sceneNumberLabel)
        sceneNumberLabel.anchor(withTopAnchor: labelContainerView.topAnchor, leadingAnchor: labelContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: labelContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        // scene take label
        sceneTakeLabel.text = "Take \(self._takeNumber)"
        labelContainerView.addSubview(sceneTakeLabel)
        sceneTakeLabel.anchor(withTopAnchor: sceneNumberLabel.bottomAnchor, leadingAnchor: labelContainerView.leadingAnchor, bottomAnchor: labelContainerView.bottomAnchor, trailingAnchor: labelContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        // blur view
        interactionsView.addSubview(playActionsBlurView)
        playActionsBlurView.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 60.0)
        
        // toggle play button
        playActionsBlurView.contentView.addSubview(togglePlayButton)
        togglePlayButton.anchor(withTopAnchor: playActionsBlurView.topAnchor, leadingAnchor: playActionsBlurView.leadingAnchor, bottomAnchor: playActionsBlurView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 40.0, heightAnchor: nil, padding: .init(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0))
        togglePlayButton.addSubview(togglePlayButtonIconImageView)
        togglePlayButtonIconImageView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: togglePlayButton.centerXAnchor, centreYAnchor: togglePlayButton.centerYAnchor, widthAnchor: 24.0, heightAnchor: 24.0)
        
        // start time label
        playActionsBlurView.contentView.addSubview(startTimeLabel)
        startTimeLabel.anchor(withTopAnchor: nil, leadingAnchor: togglePlayButton.trailingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: togglePlayButton.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0))
        
        // end time label
        playActionsBlurView.contentView.addSubview(endTimeLabel)
        endTimeLabel.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: playActionsBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: togglePlayButton.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        
        // progress bar
        playActionsBlurView.contentView.addSubview(progressSlider)
        progressSlider.anchor(withTopAnchor: nil, leadingAnchor: startTimeLabel.trailingAnchor, bottomAnchor: nil, trailingAnchor: endTimeLabel.leadingAnchor, centreXAnchor: nil, centreYAnchor: togglePlayButton.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 12.0, bottom: 0.0, right: -12.0))
    }
    
    func setupProgressBar() {
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
            let duration = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
            
            // set the progress slider value to the current playing time
            self.progressSlider.value = Float((CMTimeGetSeconds(time) / duration))
            
            // update start time label
            let currentTimeInSeconds = CMTimeGetSeconds(time)
            let currentMinutes = Int((currentTimeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            let currentSeconds = Int(currentTimeInSeconds.truncatingRemainder(dividingBy: 60))
            self.startTimeLabel.text = String(format: "%02i:%02i", currentMinutes, currentSeconds)
        }
    }
    
    @objc func progressSliderValueDidChange() {
        guard let player = player else { return }
        guard let duration = player.currentItem?.duration else { return }
        
        player.pause()
        isVideoPlaying = false
        
        let durationSeconds = CMTimeGetSeconds(duration)
        let value = Float64(self.progressSlider.value) * durationSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 1)

        player.seek(to: seekTime)
    }
}

// video player stuff
extension TakeViewerVC {
    func setupAVPlayer() {
        // guard check if we have a video url
        guard let videoUrl = self._take.videoUrl else { return }
        
        // instantiate the player item
        let playerItem: AVPlayerItem = AVPlayerItem(url: videoUrl)
        
        // notifications for video when video ends
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // instantiate the player
        player = AVPlayer(playerItem: playerItem)
        
        // notification for when video is ready
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        // instantiate the av player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        // add player layer to the VC
        self.view.layer.addSublayer(playerLayer!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            // set the end time label
            guard let duration = player?.currentItem?.duration else { return }
            
            let durationInSeconds = CMTimeGetSeconds(duration)
            let minutes = Int((durationInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
            
            self.endTimeLabel.text = String(format: "-%02i:%02i", minutes, seconds)
        }
    }
    
    @objc func togglePlayButtonPressed() {
        
        guard let player = self.player else { return }
        
        if !isVideoPlaying {
            setupProgressBar()
            player.play()
        } else {
            player.pause()
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        player?.seek(to: .zero)
        isVideoPlaying = false
        if !isVideoBarVisible {
            toggleIsVideoBarVisibleStatus()
        }
    }
}

// delegate methods
extension TakeViewerVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.dismissVideoFilmingNavigationVC()
    }
}

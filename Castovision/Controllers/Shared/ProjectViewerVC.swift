//
//  ProjectViewerVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit

class ProjectViewerVC: UIViewController {
    
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
    
    let projectNameLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = smallTitleFont
        label.textColor = .white
        return label
    }()
    
    let projectCreatedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = defaultContentFont
        label.textColor = .white
        return label
    }()
    
    let previousVideoButtonContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    let previousVideoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goToPreviousVideoButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let previousVideoButtonIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
    }()
    
    let nextVideoButtonContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    let nextVideoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goToNextVideoButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let nextVideoButtonIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "forward-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
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
    
    let sceneAndTakeNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = smallTitleFont
        label.textColor = .white
        return label
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.white
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // private variables
    private var _project: Project = Project()
    private var _projectPlayerItems: [ProjectPlayerItem] = []
    private var _currentVideoIndex: Int = 0
    
    
    // video player variables
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private var isVideoPlaying: Bool = false {
        didSet {
            if self.isVideoPlaying {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "pause-icon")
            } else {
                togglePlayButtonIconImageView.image = #imageLiteral(resourceName: "play-icon")
            }
        }
    }
    
    private var isVideoBarVisible: Bool = true
    
    // initializer methods
    init(project: Project) {
        self._project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.addTapGestureRecognizer()
        self.handleChildDelegates()
        self.anchorChildViews()
        self.setProjectNameAndDateLabel()
        self.configurePlayerItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // clear it out
        self._project = Project()
        self.player?.pause()
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
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
            self.interactionsView.alpha = self.isVideoBarVisible ? 0.0 : 1.0
        }) { (animationComplete) in
            self.view.isUserInteractionEnabled = true
        }
        
        self.isVideoBarVisible = !self.isVideoBarVisible
    }
    
    func handleChildDelegates() {
        backButton.delegate = self
    }
    
    func setProjectNameAndDateLabel() {
        guard let projectName = self._project.projectName else {
            projectNameLabel.text = "Project name not found"
            return
        }
        projectNameLabel.text = projectName
        
        guard let projectCreatedDate = self._project.timeStamp else {
           projectCreatedDateLabel.text  = "Project created date not found"
           return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        projectCreatedDateLabel.text = dateFormatter.string(from: projectCreatedDate)
    }
    
    func anchorChildViews() {
        // interactions view (on top)
        self.view.addSubview(interactionsView)
        interactionsView.fillSuperview()
        
        // back button
        interactionsView.addSubview(backButton)
        backButton.anchor(withTopAnchor: interactionsView.safeAreaLayoutGuide.topAnchor, leadingAnchor: interactionsView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 20.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
        
        // label container view and labels
        interactionsView.addSubview(labelContainerView)
        labelContainerView.anchor(withTopAnchor: nil, leadingAnchor: backButton.trailingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: backButton.centerYAnchor)
        
        // scene number label
        labelContainerView.addSubview(projectNameLabel)
        projectNameLabel.anchor(withTopAnchor: labelContainerView.topAnchor, leadingAnchor: labelContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: labelContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        // scene take label
        labelContainerView.addSubview(projectCreatedDateLabel)
        projectCreatedDateLabel.anchor(withTopAnchor: projectNameLabel.bottomAnchor, leadingAnchor: labelContainerView.leadingAnchor, bottomAnchor: labelContainerView.bottomAnchor, trailingAnchor: labelContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
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
        
        // previous video button
        interactionsView.addSubview(previousVideoButtonContainerBlurView)
        previousVideoButtonContainerBlurView.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: self.view.safeAreaLayoutGuide.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0))
        previousVideoButtonContainerBlurView.contentView.addSubview(previousVideoButton)
        previousVideoButton.anchor(withTopAnchor: previousVideoButtonContainerBlurView.topAnchor, leadingAnchor: previousVideoButtonContainerBlurView.leadingAnchor, bottomAnchor: previousVideoButtonContainerBlurView.bottomAnchor, trailingAnchor: previousVideoButtonContainerBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 32.0, heightAnchor: 32.0)
        previousVideoButton.addSubview(previousVideoButtonIcon)
        previousVideoButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: previousVideoButton.centerXAnchor, centreYAnchor: previousVideoButton.centerYAnchor, widthAnchor: 22.0, heightAnchor: 22.0)
        
        // next video button
        interactionsView.addSubview(nextVideoButtonContainerBlurView)
        nextVideoButtonContainerBlurView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: self.view.safeAreaLayoutGuide.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -8.0))
        nextVideoButtonContainerBlurView.contentView.addSubview(nextVideoButton)
        nextVideoButton.anchor(withTopAnchor: nextVideoButtonContainerBlurView.topAnchor, leadingAnchor: nextVideoButtonContainerBlurView.leadingAnchor, bottomAnchor: nextVideoButtonContainerBlurView.bottomAnchor, trailingAnchor: nextVideoButtonContainerBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 32.0, heightAnchor: 32.0)
        nextVideoButton.addSubview(nextVideoButtonIcon)
        nextVideoButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nextVideoButton.centerXAnchor, centreYAnchor: nextVideoButton.centerYAnchor, widthAnchor: 22.0, heightAnchor: 22.0)
        
        // scene and take label
        interactionsView.addSubview(sceneAndTakeNumberLabel)
        sceneAndTakeNumberLabel.anchor(withTopAnchor: nil, leadingAnchor: playActionsBlurView.leadingAnchor, bottomAnchor: playActionsBlurView.topAnchor, trailingAnchor: playActionsBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 12.0, bottom: -12.0, right: -12.0))
        
        // loading spinner
        self.view.addSubview(loadingSpinner)
        loadingSpinner.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: self.view.centerXAnchor, centreYAnchor: self.view.centerYAnchor)
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
    
    func updateEndTimeLabel() {
        let currentItemDuration = self._projectPlayerItems[self._currentVideoIndex].playerItemDuration
        let durationInSeconds = CGFloat(currentItemDuration)
        
        let minutes = Int((durationInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
        
        self.endTimeLabel.text = String(format: "-%02i:%02i", minutes, seconds)
    }
    
    func updateSceneAndTakeLabel() {
        let sceneNumber = self._projectPlayerItems[self._currentVideoIndex].sceneNumber
        let takeNumber = self._projectPlayerItems[self._currentVideoIndex].takeNumber
        
        sceneAndTakeNumberLabel.text = "Scene \(sceneNumber) - Take \(takeNumber)"
    }
}

// video player specific stuff
extension ProjectViewerVC {
    func configurePlayerItems() {
        guard let projectScenes = self._project.scenes else { return }
        projectScenes.forEach { (scene) in
            guard let sceneNumber = scene.sceneNumber,
                let sceneTakes = scene.takes else { return }
            for i in 0..<sceneTakes.count {
                guard let takeVideoUrl = sceneTakes[i].videoUrl else { return }
                guard let takeDuration = sceneTakes[i].videoDuration else { return }
                let takeNumber = i + 1
                let playerItem = CachingPlayerItem(url: takeVideoUrl, customFileExtension: "mp4")
                self.addPlayerItemDidFinishPlayingObserver(forPlayerItem: playerItem)
                playerItem.download()
                
                let projectPlayerItem = ProjectPlayerItem(sceneNumber: sceneNumber, takeNumber: takeNumber, playerItem: playerItem, playerItemDuration: takeDuration)
                self._projectPlayerItems.append(projectPlayerItem)
            }
        }
        
        setupAVPlayer()
    }
    
    func setupAVPlayer() {
        self.loadingSpinner.startAnimating()
        self.interactionsView.isUserInteractionEnabled = false
        
        if self._projectPlayerItems.count > 0 {
            /*-- set up the player --*/
            self.player = AVPlayer(playerItem: self._projectPlayerItems[self._currentVideoIndex].playerItem)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            self.player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            /*-- setup initial label and progress bar stuff --*/
            self.updateEndTimeLabel()
            self.updateSceneAndTakeLabel()
            self.setupProgressBar()
            
            /*-- setup the player layer --*/
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer?.frame = self.view.bounds
            self.playerLayer?.videoGravity = .resizeAspectFill
            
            /*-- add player layer to the view --*/
            self.view.layer.addSublayer(playerLayer!)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // video loaded stuff
        if keyPath == "status" {
            guard let player = object as? AVPlayer else { return }
            if player.status == .readyToPlay {
                self.loadingSpinner.stopAnimating()
                self.interactionsView.isUserInteractionEnabled = true
            }
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
    
    @objc func goToPreviousVideoButtonPressed() {
        if !isVideoPlaying {
            if self._currentVideoIndex > 0 {
                self._currentVideoIndex -= 1
                self.player?.replaceCurrentItem(with: self._projectPlayerItems[self._currentVideoIndex].playerItem)
                updateEndTimeLabel()
                updateSceneAndTakeLabel()
            } else {
                self.player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
            }
        }
    }
    
    @objc func goToNextVideoButtonPressed() {
        if !isVideoPlaying {
            if self._currentVideoIndex < (self._projectPlayerItems.count - 1) {
                self._currentVideoIndex += 1
                self.player?.replaceCurrentItem(with: self._projectPlayerItems[self._currentVideoIndex].playerItem)
                updateEndTimeLabel()
                updateSceneAndTakeLabel()
            }
        }
    }
    
    func addPlayerItemDidFinishPlayingObserver(forPlayerItem playerItem: CachingPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func playerItemDidFinishPlaying() {
        if self._currentVideoIndex == (self._projectPlayerItems.count - 1) {
            self.isVideoPlaying = false
            self._currentVideoIndex = 0
            self.player?.replaceCurrentItem(with: self._projectPlayerItems[_currentVideoIndex].playerItem)
            self.resetVideoStartTimes()
            self.isVideoBarVisible = true
        } else {
            self.player?.pause()
            self._currentVideoIndex += 1
            self.player?.replaceCurrentItem(with: self._projectPlayerItems[_currentVideoIndex].playerItem)
            self.resetVideoStartTimes(excludingAtIndex: self._currentVideoIndex)
            self.player?.play()
        }
        
        self.updateEndTimeLabel()
        self.updateSceneAndTakeLabel()
        self.setupProgressBar()
    }
    
    func resetVideoStartTimes(excludingAtIndex indexToExclude: Int? = nil) {
        if indexToExclude == nil {
            self._projectPlayerItems.forEach { (projectPlayerItem) in
                projectPlayerItem.playerItem.seek(to: CMTime.zero, completionHandler: nil)
            }
        } else {
            for i in 0..<self._projectPlayerItems.count {
                if i != indexToExclude {
                    self._projectPlayerItems[i].playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            }
        }
    }
}

// delegate methods
extension ProjectViewerVC: BackButtonDelegate {
    func backButtonPressed() {
        self.navigationController?.dismissVideoFilmingNavigationVC()
    }
}

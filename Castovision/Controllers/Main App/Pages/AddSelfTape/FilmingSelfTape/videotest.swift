//
//  videotest.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

//import UIKit
//import AVKit
//
//class CameraPlaybackVC: UIViewController {
//    
//    // views
//    let bottomGradientView: GradientView = {
//        let gradientView = GradientView()
//        gradientView.colors = [UIColor.clear, ditloOffBlack.withAlphaComponent(0.4)]
//        return gradientView
//    }()
//    
//    let progressBar: UIProgressView = {
//        let pb = UIProgressView(progressViewStyle: .bar)
//        pb.layer.masksToBounds = true
//        pb.layer.cornerRadius = pb.frame.height / 2.0
//        pb.trackTintColor = ditloRed.withAlphaComponent(0.4)
//        pb.progressTintColor = ditloRed
//        pb.layer.zPosition = 1.0
//        return pb
//    }()
//    
//    let playbackInstructionLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Review your ditlo video, and proceed if you’re happy"
//        label.textColor = .white
//        label.textAlignment = .center
//        label.font = smallParagraphFont
//        label.layer.zPosition = 1.0
//        return label
//    }()
//    
//    let playButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
//        button.layer.borderColor = UIColor.white.cgColor
//        button.layer.borderWidth = 4.0
//        button.layer.cornerRadius = 30.0
//        button.layer.zPosition = 1.0
//        button.isHidden = true
//        return button
//    }()
//    
//    let playButtonIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.image = #imageLiteral(resourceName: "play-icon")
//        return iv
//    }()
//    
//    let pauseButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(pauseVideo), for: .touchUpInside)
//        button.layer.borderColor = UIColor.white.cgColor
//        button.layer.borderWidth = 4.0
//        button.layer.cornerRadius = 30.0
//        button.layer.zPosition = 1.0
//        return button
//    }()
//    
//    let pauseButtonIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.image = #imageLiteral(resourceName: "pause-icon")
//        return iv
//    }()
//    
//    let rejectButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(rejectButtonPressed), for: .touchUpInside)
//        button.layer.zPosition = 1.0
//        return button
//    }()
//    
//    let rejectButtonIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.image = #imageLiteral(resourceName: "red-cross-icon")
//        return iv
//    }()
//    
//    let acceptButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
//        button.layer.zPosition = 1.0
//        return button
//    }()
//    
//    let accepteButtonIcon: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.image = #imageLiteral(resourceName: "green-tick-icon")
//        return iv
//    }()
//    
//    // variables
//    private var _videoUrl: URL? = nil
//    var isVideoPlaying: Bool = true
//    var player: AVPlayer?
//    var playerLayer: AVPlayerLayer?
//    
//    convenience init() {
//        self.init()
//    }
//    
//    init(videoUrl: URL) {
//        super.init(nibName: nil, bundle: nil)
//        self._videoUrl = videoUrl
//        handleVideoPlayback(withVideoUrl: videoUrl)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .black
//        setupTapGestureRecognizer()
//        anchorSubviews()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        resetVideo()
//        pauseVideo()
//    }
//    
//    func setupTapGestureRecognizer() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(userTapped(_:)))
//        tap.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tap)
//    }
//    
//    @objc func userTapped(_ tap: UITapGestureRecognizer) {
//        
//        // set out specific cases for tap zones
//        let bottomPadding: CGFloat = -safeAreaTopPadding
//        let leftTapZone = CGRect(x: 0.0, y: 0.0, width: screenWidth * 0.2, height: screenHeight - bottomPadding)
//        
//        // set the tap location
//        let tapLocation = tap.location(in: self.view)
//        
//        if leftTapZone.contains(tapLocation) {
//            if isVideoPlaying {
//                resetVideoAndPlay()
//            } else {
//                resetVideo()
//            }
//        } else {
//            if isVideoPlaying {
//                pauseVideo()
//            } else {
//                playVideo()
//            }
//        }
//    }
//    
//    func anchorSubviews() {
//        // bottom gradient view
//        self.view.addSubview(bottomGradientView)
//        bottomGradientView.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: safeAreaScreenHeight * 0.25)
//        
//        // progress bar
//        self.view.addSubview(progressBar)
//        progressBar.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: self.view.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -2.0, right: 0.0))
//        
//        // playback instruction label
//        self.view.addSubview(playbackInstructionLabel)
//        playbackInstructionLabel.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: -24.0, right: -horizontalPadding))
//        
//        // play button (hidden by default as video automatically plays)
//        self.view.addSubview(playButton)
//        playButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: playbackInstructionLabel.topAnchor, trailingAnchor: nil, centreXAnchor: self.view.centerXAnchor, centreYAnchor: nil, widthAnchor: 60.0, heightAnchor: 60.0, padding: .init(top: 0.0, left: 0.0, bottom: -12.0, right: 0.0))
//        playButton.addSubview(playButtonIcon)
//        playButtonIcon.fillSuperview()
//        
//        // pause button
//        self.view.addSubview(pauseButton)
//        pauseButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: playbackInstructionLabel.topAnchor, trailingAnchor: nil, centreXAnchor: self.view.centerXAnchor, centreYAnchor: nil, widthAnchor: 60.0, heightAnchor: 60.0, padding: .init(top: 0.0, left: 0.0, bottom: -12.0, right: 0.0))
//        pauseButton.addSubview(pauseButtonIcon)
//        pauseButtonIcon.fillSuperview()
//        
//        // reject button
//        self.view.addSubview(rejectButton)
//        rejectButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.leadingAnchor, bottomAnchor: nil, trailingAnchor: playButton.leadingAnchor, centreXAnchor: nil, centreYAnchor: playButton.centerYAnchor, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -12.0))
//        rejectButton.addSubview(rejectButtonIcon)
//        rejectButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: rejectButton.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: rejectButton.centerYAnchor, widthAnchor: 24.0, heightAnchor: 24.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
//        
//        // accept button
//        self.view.addSubview(acceptButton)
//        acceptButton.anchor(withTopAnchor: nil, leadingAnchor: playButton.trailingAnchor, bottomAnchor: nil, trailingAnchor: self.view.trailingAnchor, centreXAnchor: nil, centreYAnchor: playButton.centerYAnchor, widthAnchor: nil, heightAnchor: 30.0, padding: .init(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0))
//        acceptButton.addSubview(accepteButtonIcon)
//        accepteButtonIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: acceptButton.trailingAnchor, centreXAnchor: nil, centreYAnchor: acceptButton.centerYAnchor, widthAnchor: 30.0, heightAnchor: 30.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
//    }
//    
//    @objc func rejectButtonPressed() {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @objc func acceptButtonPressed() {
//        let videoPrivacyVC = VideoPrivacyVC()
//        self.navigationController?.pushViewController(videoPrivacyVC, animated: true)
//    }
//}
//
//// video player methods
//extension CameraPlaybackVC {
//    // setup the video player
//    func handleVideoPlayback(withVideoUrl videoUrl: URL) {
//        // Set up the player item and the playing item notification
//        let playerItem: AVPlayerItem = AVPlayerItem(url: videoUrl)
//        NotificationCenter.default.addObserver(self, selector: #selector(resetVideoAndPlay), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
//        
//        // instantiate player with player item
//        player = AVPlayer(playerItem: playerItem)
//        
//        // instantiate player layer with player,
//        // settings it's specific properties
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.frame = self.view.bounds
//        playerLayer?.videoGravity = .resizeAspectFill
//        
//        // add layer to the VC and play video
//        self.view.layer.addSublayer(self.playerLayer!)
//        playVideo()
//    }
//    
//    @objc func playVideo() {
//        player?.play()
//        isVideoPlaying = true
//        handleCentreButtonState(toVideoPlayingState: true)
//        setupProgressBar()
//    }
//    
//    @objc func pauseVideo() {
//        player?.pause()
//        handleCentreButtonState(toVideoPlayingState: false)
//        isVideoPlaying = false
//    }
//    
//    func handleCentreButtonState(toVideoPlayingState isVideoPlaying: Bool) {
//        playButton.isHidden = isVideoPlaying
//        pauseButton.isHidden = !isVideoPlaying
//    }
//    
//    func setupProgressBar() {
//        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
//            let duration = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
//            self.progressBar.progress = Float((CMTimeGetSeconds(time) / duration))
//        }
//    }
//    
//    @objc func resetVideo() {
//        player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
//    }
//    
//    @objc func resetVideoAndPlay() {
//        resetVideo()
//        playVideo()
//    }
//}

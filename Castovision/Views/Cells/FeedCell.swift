//
//  FeedCell.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import MarqueeLabel

protocol FeedCellDelegate {
    func playProjectVideoButtonPressed(withProjectInfo projectInfo: Project)
    func expandButtonPressed(withProjectInfo projectInfo: Project)
    func sendButtonPressed(withProjectInfo projectInfo: Project)
}

class FeedCell: BaseCell {
    
    // views
    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = grey
        return iv
    }()
    
    lazy var playProjectVideoButton = UIButton()
    
    let expandProjectContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    lazy var expandProjectButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let expandProjectButtonIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "list-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
    }()
    
    let numberOfViewsContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    let viewsIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "views-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
    }()
    
    let viewsLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = defaultContentFont
        label.textColor = .white
        return label
    }()
    
    let timeLabelContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = defaultContentFont
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let metadataContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let projectNameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Project Name"
        label.font = smallContentFont
        label.textColor = darkGrey
        return label
    }()
    
    let projectNameLabel: MarqueeLabel = {
        let marqueeLabel = MarqueeLabel()
        marqueeLabel.font = smallTitleFont
        marqueeLabel.textColor = darkGrey
        marqueeLabel.trailingBuffer = 8.0
        marqueeLabel.fadeLength = 6.0
        return marqueeLabel
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 4.0
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = defaultButtonFont
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
        return button
    }()
    
    // delegate
    var delegate: FeedCellDelegate?
    
    // variables
    private var _project: Project?
    
    func configureCell(withProjectInfo projectInfo: Project) {
        self._project = projectInfo
        
        guard let thumbnailImageData = projectInfo.scenes?[0].takes?[0].videoThumbnailUrl,
              let projectName = projectInfo.projectName,
              let numberOfViews = projectInfo.numberOfViews else {
            return
        }
        thumbnailImageView.image = UIImage(data: thumbnailImageData)
        
        projectNameLabel.text = projectName
        
        viewsLabel.text = "\(numberOfViews)"
        
        getProjectDuration(withProject: projectInfo)
    }
    
    func getProjectDuration(withProject project: Project) {
        var sceneDuration: Double = 0
        project.scenes?.forEach({ (scene) in
            scene.takes?.forEach({ (take) in
                if let takeDuration = take.videoDuration {
                    sceneDuration += takeDuration
                }
            })
        })
        
        // format it to the string
        let hours = Int(sceneDuration / 3600)
        let minutes = Int((sceneDuration.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(sceneDuration.truncatingRemainder(dividingBy: 60))
        let formattedTimeString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        
        // put it on the screen
        timeLabel.text = formattedTimeString
    }
    
    override func setupViews() {
        super.setupViews()
        /*-- disable the content clickability as we have custom button actions to permit --*/
        configureCellUI()
        anchorChildViews()
    }
    
    func configureCellUI() {
        // content
        contentView.layer.cornerRadius = 6.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = lightGrey.cgColor
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        // cell shadowing
        layer.shadowColor = darkGrey.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    func anchorChildViews() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.anchor(withTopAnchor: self.contentView.topAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: feedCellThumbnailImageHeight)
        
        contentView.addSubview(playProjectVideoButton)
        playProjectVideoButton.anchor(withTopAnchor: thumbnailImageView.topAnchor, leadingAnchor: thumbnailImageView.leadingAnchor, bottomAnchor: thumbnailImageView.bottomAnchor, trailingAnchor: thumbnailImageView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        contentView.addSubview(expandProjectContainerBlurView)
        expandProjectContainerBlurView.anchor(withTopAnchor: thumbnailImageView.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: thumbnailImageView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 8.0, left: 0.0, bottom: 0.0, right: -8.0))
        expandProjectContainerBlurView.contentView.addSubview(expandProjectButton)
        expandProjectButton.fillSuperview()
        expandProjectButton.addSubview(expandProjectButtonIconImageView)
        expandProjectButtonIconImageView.anchor(withTopAnchor: expandProjectButton.topAnchor, leadingAnchor: expandProjectButton.leadingAnchor, bottomAnchor: expandProjectButton.bottomAnchor, trailingAnchor: expandProjectButton.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 24.0, heightAnchor: 24.0, padding: .init(top: 2.0, left: 8.0, bottom: -2.0, right: -8.0))
        
        contentView.addSubview(numberOfViewsContainerBlurView)
        numberOfViewsContainerBlurView.anchor(withTopAnchor: nil, leadingAnchor: thumbnailImageView.leadingAnchor, bottomAnchor: thumbnailImageView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 8.0, bottom: -8.0, right: 0.0))
        numberOfViewsContainerBlurView.contentView.addSubview(viewsIconImageView)
        viewsIconImageView.anchor(withTopAnchor: numberOfViewsContainerBlurView.topAnchor, leadingAnchor: numberOfViewsContainerBlurView.leadingAnchor, bottomAnchor: numberOfViewsContainerBlurView.bottomAnchor, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: 20.0, heightAnchor: 20.0, padding: .init(top: 2.0, left: 8.0, bottom: -2.0, right: 0.0))
        numberOfViewsContainerBlurView.contentView.addSubview(viewsLabel)
        viewsLabel.anchor(withTopAnchor: nil, leadingAnchor: viewsIconImageView.trailingAnchor, bottomAnchor: nil, trailingAnchor: numberOfViewsContainerBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: viewsIconImageView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 8.0, bottom: 0.0, right: -8.0))
        
        contentView.addSubview(timeLabelContainerBlurView)
        timeLabelContainerBlurView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: thumbnailImageView.bottomAnchor, trailingAnchor: thumbnailImageView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -8.0, right: -8.0))
        timeLabelContainerBlurView.contentView.addSubview(timeLabel)
        timeLabel.anchor(withTopAnchor: timeLabelContainerBlurView.topAnchor, leadingAnchor: timeLabelContainerBlurView.leadingAnchor, bottomAnchor: timeLabelContainerBlurView.bottomAnchor, trailingAnchor: timeLabelContainerBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 4.0, left: 12.0, bottom: -4.0, right: -12.0))
        
        contentView.addSubview(metadataContainerView)
        metadataContainerView.anchor(withTopAnchor: thumbnailImageView.bottomAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: self.contentView.bottomAnchor, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        
        metadataContainerView.addSubview(sendButton)
        sendButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: metadataContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: metadataContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -8.0))
        
        let rightPadding: CGFloat = 16.0 + sendButton.frame.width
        
        metadataContainerView.addSubview(projectNameTitleLabel)
        projectNameTitleLabel.anchor(withTopAnchor: metadataContainerView.topAnchor, leadingAnchor: metadataContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 8.0, left: 8.0, bottom: 0.0, right: -rightPadding))
        
        metadataContainerView.addSubview(projectNameLabel)
        projectNameLabel.anchor(withTopAnchor: projectNameTitleLabel.bottomAnchor, leadingAnchor: metadataContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 8.0, bottom: 0.0, right: -rightPadding))
        
        /*-- setup the button selector methods now that we have views in the cell --*/
        handleTargetSelectorMethods()
    }
}

// button target selector stuff
extension FeedCell {
    
    func handleTargetSelectorMethods() {
        // enable the buttons
        let cellButtons: [UIButton] = [playProjectVideoButton, expandProjectButton, sendButton]
        cellButtons.forEach { (button) in
            button.isEnabled = true
            button.isUserInteractionEnabled = true
        }
        
        // setup up button target selector methods
        playProjectVideoButton.addTarget(self, action: #selector(playProjectVideoButtonPressed), for: .touchUpInside)
        expandProjectButton.addTarget(self, action: #selector(expandProjectButtonPressed), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendProjectButtonPressed), for: .touchUpInside)
    }
    
    @objc func playProjectVideoButtonPressed() {
        guard let projectInfo = self._project else { return }
        delegate?.playProjectVideoButtonPressed(withProjectInfo: projectInfo)
    }
    
    @objc func expandProjectButtonPressed() {
        guard let projectInfo = self._project else { return }
        delegate?.playProjectVideoButtonPressed(withProjectInfo: projectInfo)
    }
    
    @objc func sendProjectButtonPressed() {
        guard let projectInfo = self._project else { return }
        delegate?.playProjectVideoButtonPressed(withProjectInfo: projectInfo)
    }
}

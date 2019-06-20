//
//  SceneTakeCell2.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol SceneTakeCellDelegate {
    func deleteTake(take: Take)
}

extension SceneTakeCellDelegate {
    func deleteTake(take: Take) {}
}

class SceneTakeCell: BaseCell {
    
    // views
    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = grey
        return iv
    }()
    
    let timeContainerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 4.0
        blurView.clipsToBounds = true
        return blurView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .white
        label.font = defaultContentFont
        label.textAlignment = .center
        return label
    }()
    
    let metadataContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6.0
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    let takeNumberLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    let fileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = smallContentFont
        label.textColor = darkGrey
        return label
    }()
    
    lazy var deleteTakeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete Take", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = defaultButtonFont
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 6.0
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 12.0)
        return button
    }()
    
    // delegate
    var delegate: SceneTakeCellDelegate?
    
    private var _take: Take = Take() {
        didSet {
            if let videoThumbnailData = self._take.videoThumbnailData {
                if let videoThumbnailImage = UIImage(data: videoThumbnailData) {
                    thumbnailImageView.image = videoThumbnailImage
                }
            }
            
            if let videoDuration = self._take.videoDuration {
                timeLabel.text = secondToHoursMinutesAndSeconds(withDuration: videoDuration)
            } else {
                timeLabel.text = "-"
            }
            
            if let videoFileSize = self._take.fileSize {
                var videoFileSizeString = "File size: "
                // kilobytes
                if videoFileSize < 1 {
                    videoFileSizeString += "\(CGFloat(videoFileSize * 1000).rounded(toPlaces: 1))kb"
                    
                    // megabytes
                } else if videoFileSize < 1000 {
                    videoFileSizeString += "\(CGFloat(videoFileSize).rounded(toPlaces: 1))mb"
                    
                    // gigabytes
                } else {
                    videoFileSizeString += "\((CGFloat(videoFileSize) / 1000).rounded(toPlaces: 1))gb"
                }
                
                fileSizeLabel.text = videoFileSizeString
            } else {
                fileSizeLabel.text = "-"
            }
        }
    }
    
    private var _takeNumber: Int? {
        didSet {
            if let takeNumber = self._takeNumber {
                takeNumberLabel.text = "Take \(takeNumber)"
            }
        }
    }
    
    func configureCell(withTake take: Take, takeNumber: Int, isSceneDeletable: Bool) {
        self._take = take
        self._takeNumber = takeNumber
        self.deleteTakeButton.isHidden = isSceneDeletable ? false : true
    }
    
    override func setupViews() {
        super.setupViews()
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
        
        self.addSubview(timeContainerBlurView)
        timeContainerBlurView.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: thumbnailImageView.bottomAnchor, trailingAnchor: thumbnailImageView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -10.0, right: -10.0))
        timeContainerBlurView.contentView.addSubview(timeLabel)
        timeLabel.anchor(withTopAnchor: timeContainerBlurView.topAnchor, leadingAnchor: timeContainerBlurView.leadingAnchor, bottomAnchor: timeContainerBlurView.bottomAnchor, trailingAnchor: timeContainerBlurView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 4.0, left: 12.0, bottom: -4.0, right: -12.0))
        
        contentView.addSubview(metadataContainerView)
        metadataContainerView.anchor(withTopAnchor: thumbnailImageView.bottomAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: self.contentView.bottomAnchor, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: -20.0, right: 0.0))
        
        metadataContainerView.addSubview(takeNumberLabel)
        takeNumberLabel.anchor(withTopAnchor: metadataContainerView.topAnchor, leadingAnchor: metadataContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 8.0, left: 8.0, bottom: 0.0, right: 0.0))
        
        metadataContainerView.addSubview(fileSizeLabel)
        fileSizeLabel.anchor(withTopAnchor: takeNumberLabel.bottomAnchor, leadingAnchor: metadataContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 1.0, left: 8.0, bottom: 0.0, right: 0.0))
        
        metadataContainerView.addSubview(deleteTakeButton)
        deleteTakeButton.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: metadataContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: metadataContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -8.0))
        
        // add the button targets now that the cell has it's views in place
        setupButtonTargets()
    }
    
    func setupButtonTargets() {
        deleteTakeButton.addTarget(self, action: #selector(deleteTakeButtonPressed), for: .touchUpInside)
    }
    
    @objc func deleteTakeButtonPressed() {
        delegate?.deleteTake(take: self._take)
    }
    
    override func prepareForReuse() {
        // views
        thumbnailImageView.image = nil
        takeNumberLabel.text = nil
        fileSizeLabel.text = nil
        
        // variables
        self._take = Take()
        self._takeNumber = nil
    }
}

// helper methods
func secondToHoursMinutesAndSeconds(withDuration duration: Double) -> String {
    let hours = Int(duration / 3600)
    let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
    let formattedTimeString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    
    return formattedTimeString
}

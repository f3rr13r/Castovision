//
//  AddSceneCell.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/4/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol AddSceneCellDelegate {
    func addNewTakeButtonPressed(insideAuditionScene auditionScene: Int)
}

private let takesCellId = "takesCellId"

class AddSceneCell: BaseCell {
    
    // views
    let sceneTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        label.font = smallTitleFont
        return label
    }()
    
    lazy var takesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: takesCellId)
        return cv
    }()
    var takesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    lazy var addTakeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = grey
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(addTakeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let addTakeButtonContentContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let addTakeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = false
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "tab-bar-camera-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = darkGrey
        return iv
    }()
    
    let addTakeButtonLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.text = "Click here to start filming a take"
        label.textColor = darkGrey
        label.font = defaultButtonFont
        label.textAlignment = .center
        return label
    }()
    
    // delegate
    var delegate: AddSceneCellDelegate?
    
    // variables
    let width: CGFloat = screenWidth - (horizontalPadding * 2)
    let height: CGFloat = screenWidth * 0.5
    
    var auditionScene: AuditionScene? {
        didSet {
            if let auditionScene = self.auditionScene {
                self.sceneNumber = auditionScene.sceneNumber
                self.takes = auditionScene.sceneTakes
            }
        }
    }
    
    var sceneNumber: Int? {
        didSet {
            if let sceneNumber = self.sceneNumber {
                sceneTitleLabel.text = "Scene \(sceneNumber)"
            }
        }
    }
    
    var takes: [String] = [] {
        didSet {
            takesCollectionView.reloadData()
            takesCollectionViewHeightConstraint.constant = takesCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.layoutIfNeeded()
        }
    }
    
    func setupSceneCell(withAuditionScene auditionScene: AuditionScene) {
        self.auditionScene = auditionScene
    }
    
    override func setupViews() {
        super.setupViews()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        anchorSubviews()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return contentView.systemLayoutSizeFitting(CGSize(width: screenWidth - (horizontalPadding * 2), height: 1))
    }
    
    func anchorSubviews() {
        self.contentView.addSubview(sceneTitleLabel)
        sceneTitleLabel.anchor(withTopAnchor: self.contentView.topAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: width, heightAnchor: 14.0)
        
        self.contentView.addSubview(takesCollectionView)
        takesCollectionView.anchor(withTopAnchor: sceneTitleLabel.bottomAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: nil, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: width, heightAnchor: nil)
        
        takesCollectionViewHeightConstraint = NSLayoutConstraint(item: takesCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: takesCollectionView.collectionViewLayout.collectionViewContentSize.height)
        addConstraint(takesCollectionViewHeightConstraint)
        
        self.contentView.addSubview(addTakeButton)
        addTakeButton.anchor(withTopAnchor: takesCollectionView.bottomAnchor, leadingAnchor: self.contentView.leadingAnchor, bottomAnchor: self.contentView.bottomAnchor, trailingAnchor: self.contentView.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: width, heightAnchor: height, padding: .init(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0))
        
        addTakeButton.addSubview(addTakeButtonContentContainer)
        addTakeButtonContentContainer.anchor(withTopAnchor: nil, leadingAnchor: addTakeButton.leadingAnchor, bottomAnchor: nil, trailingAnchor: addTakeButton.trailingAnchor, centreXAnchor: addTakeButton.centerXAnchor, centreYAnchor: addTakeButton.centerYAnchor)

        addTakeButtonContentContainer.addSubview(addTakeIconImageView)
        addTakeIconImageView.anchor(withTopAnchor: addTakeButtonContentContainer.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: addTakeButtonContentContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0)

        addTakeButtonContentContainer.addSubview(addTakeButtonLabel)
        addTakeButtonLabel.anchor(withTopAnchor: addTakeIconImageView.bottomAnchor, leadingAnchor: addTakeButtonContentContainer.leadingAnchor, bottomAnchor: addTakeButtonContentContainer.bottomAnchor, trailingAnchor: addTakeButtonContentContainer.trailingAnchor, centreXAnchor: addTakeButtonContentContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func addTakeButtonPressed() {
        guard let auditionScene = self.auditionScene else { return }
        delegate?.addNewTakeButtonPressed(insideAuditionScene: auditionScene.sceneNumber)
    }
}

// collection view delegate and data source methods
extension AddSceneCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.takes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: takesCellId, for: indexPath)
        cell.backgroundColor = grey
        cell.layer.cornerRadius = 4.0
        return cell
    }
}

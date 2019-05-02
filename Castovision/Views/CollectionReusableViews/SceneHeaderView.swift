//
//  SceneHeaderView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/7/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol SceneHeaderViewDelegate {
    func deleteSceneButtonPressed(withSceneNumber sceneNumber: Int)
}

class SceneHeaderView: BaseReusableView {
    
    // views
    let deleteSceneButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteSceneButtonPressed), for: .touchUpInside)
        return button
    }()
    
    let deleteSceneButtonIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "delete-icon")
        return iv
    }()
    
    let sceneTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = darkGrey
        label.font = smallTitleFont
        return label
    }()
    
    var delegate: SceneHeaderViewDelegate?
    
    private var _sceneNumber: Int?
    
    func configureSceneView(withSceneNumber sceneNumber: Int, andNeedsDeleteButton needsDeleteButton: Bool) {
        self._sceneNumber = sceneNumber
        
        /*-- title label --*/
        sceneTitleLabel.text = "Scene \(sceneNumber)"
        
        /*-- button --*/
        deleteSceneButton.isHidden = needsDeleteButton ? false : true
    }
    
    override func setupViews() {
        super.setupViews()
        //self.backgroundColor = .white
        anchorChildViews()
    }
    
    func anchorChildViews() {
        addSubview(deleteSceneButton)
        deleteSceneButton.anchor(withTopAnchor: topAnchor, leadingAnchor: nil, bottomAnchor: bottomAnchor, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        deleteSceneButton.addSubview(deleteSceneButtonIconImageView)
        deleteSceneButtonIconImageView.anchor(withTopAnchor: nil, leadingAnchor: deleteSceneButton.leadingAnchor, bottomAnchor: nil, trailingAnchor: deleteSceneButton.trailingAnchor, centreXAnchor: nil, centreYAnchor: deleteSceneButton.centerYAnchor, widthAnchor: 20.0, heightAnchor: 20.0, padding: .init(top: 0.0, left: screenWidth * 0.5, bottom: 0.0, right: -horizontalPadding))
        
        addSubview(sceneTitleLabel)
        sceneTitleLabel.anchor(withTopAnchor: nil, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: centerYAnchor, widthAnchor: sceneHeaderViewWidth, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: 0.0))
    }
    
    @objc func deleteSceneButtonPressed() {
        guard let sceneNumber = self._sceneNumber else { return }
        delegate?.deleteSceneButtonPressed(withSceneNumber: sceneNumber)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sceneTitleLabel.text = "-"
    }
}

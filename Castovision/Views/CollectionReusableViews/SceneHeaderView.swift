//
//  SceneHeaderView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/7/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class SceneHeaderView: BaseReusableView {
    
    // views
    let sceneTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = darkGrey
        label.font = smallTitleFont
        return label
    }()
    
    func configureSceneView(withSceneNumber sceneNumber: Int) {
        sceneTitleLabel.text = "Scene \(sceneNumber)"
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(sceneTitleLabel)
        sceneTitleLabel.anchor(withTopAnchor: nil, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: centerYAnchor, widthAnchor: sceneHeaderViewWidth, heightAnchor: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sceneTitleLabel.text = "-"
    }
}

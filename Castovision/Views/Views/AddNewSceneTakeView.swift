//
//  AddNewSceneTakeView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/7/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol AddNewSceneTakeViewDelegate {
    func addNewSceneTake(forTake takeNumber: Int, forScene sceneNumber: Int)
}

class AddNewSceneTakeView: BaseView {

    // views
    let addSceneTakeContentContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    let addSceneTakeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = false
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "tab-bar-camera-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = darkGrey
        return iv
    }()
    
    let addSceneTakeLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.text = "Click here to start filming a take"
        label.textColor = darkGrey
        label.font = defaultButtonFont
        label.textAlignment = .center
        return label
    }()
    
    // delegate
    var delegate: AddNewSceneTakeViewDelegate?
    
    // variables
    var parentSceneNumber: Int?
    var parentTakeNumber: Int?
    
    override func setupView() {
        super.setupView()
        backgroundColor = grey
        layer.cornerRadius = 6.0
        setupTapGestureRecognizer()
        anchorSubviews()
    }
    
    func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userDidTap))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func userDidTap() {
        if let parentSceneNumber = self.parentSceneNumber,
           let parentTakeNumber = self.parentTakeNumber {
            delegate?.addNewSceneTake(forTake: parentTakeNumber, forScene: parentSceneNumber)
        } else {
            print("Couldn't find either scene or take")
        }
    }
    
    func anchorSubviews() {
        addSubview(addSceneTakeContentContainer)
        addSceneTakeContentContainer.anchor(withTopAnchor: nil, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor)
        
        addSceneTakeContentContainer.addSubview(addSceneTakeIconImageView)
        addSceneTakeIconImageView.anchor(withTopAnchor: addSceneTakeContentContainer.topAnchor, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: addSceneTakeContentContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: 30.0, heightAnchor: 30.0)
        
        addSceneTakeContentContainer.addSubview(addSceneTakeLabel)
        addSceneTakeLabel.anchor(withTopAnchor: addSceneTakeIconImageView.bottomAnchor, leadingAnchor: addSceneTakeContentContainer.leadingAnchor, bottomAnchor: addSceneTakeContentContainer.bottomAnchor, trailingAnchor: addSceneTakeContentContainer.trailingAnchor, centreXAnchor: addSceneTakeContentContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 12.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
}

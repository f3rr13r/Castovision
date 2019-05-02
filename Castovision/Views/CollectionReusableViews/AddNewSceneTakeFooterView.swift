//
//  AddNewSceneFooterView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/4/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol AddNewSceneTakeFooterViewDelegate {
    func addNewSceneTake(forSceneNumber sceneNumber: Int)
}

class AddNewSceneTakeFooterView: BaseReusableView {
    
    // views
    let addNewSceneTakeView = AddNewSceneTakeView()
    
    // delegate
    var delegate: AddNewSceneTakeFooterViewDelegate?
    
    func configureSceneFooterView(withSceneNumber sceneNumber: Int) {
        addNewSceneTakeView.parentSceneNumber = sceneNumber
    }
    
    override func setupViews() {
        super.setupViews()
        handleChildDelegates()
        anchorSubviews()
    }
    
    func anchorSubviews() {
        addSubview(addNewSceneTakeView)
        addNewSceneTakeView.anchor(withTopAnchor: topAnchor, leadingAnchor: leadingAnchor, bottomAnchor: bottomAnchor, trailingAnchor: trailingAnchor, centreXAnchor: centerXAnchor, centreYAnchor: nil, widthAnchor: addNewSceneTakeViewWidth, heightAnchor: addNewSceneTakeViewHeight, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
}

// add new scene view delegate methods
extension AddNewSceneTakeFooterView: AddNewSceneTakeViewDelegate {
    func addNewSceneTake(forScene sceneNumber: Int) {
        delegate?.addNewSceneTake(forSceneNumber: sceneNumber)
    }
    
    func handleChildDelegates() {
        addNewSceneTakeView.delegate = self
    }
}

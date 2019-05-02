//
//  ExpandedAddNewSceneFooterView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/7/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol ExpandedAddNewSceneFooterViewDelegate: AddNewSceneTakeFooterViewDelegate {
    func addNewScene()
}

class ExpandedAddNewSceneFooterView: BaseReusableView {
    
    // views
    let addNewSceneTakeView = AddNewSceneTakeView()
    let addNewSceneView = AddNewSceneView()
    
    // delegate
    var delegate: ExpandedAddNewSceneFooterViewDelegate?
    
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
        addNewSceneTakeView.anchor(withTopAnchor: topAnchor, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: addNewSceneTakeViewWidth, heightAnchor: addNewSceneTakeViewHeight, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        
        addSubview(addNewSceneView)
        addNewSceneView.anchor(withTopAnchor: addNewSceneTakeView.bottomAnchor, leadingAnchor: leadingAnchor, bottomAnchor: bottomAnchor, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: addNewSceneViewWidth, heightAnchor: addNewSceneViewHeight, padding: .init(top: 20.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
}

extension ExpandedAddNewSceneFooterView: AddNewSceneTakeViewDelegate, AddNewSceneViewDelegate {
    func handleChildDelegates() {
        addNewSceneTakeView.delegate = self
        addNewSceneView.delegate = self
    }
    
    func addNewSceneTake(forScene sceneNumber: Int) {
        delegate?.addNewSceneTake(forSceneNumber: sceneNumber)
    }
    
    func addNewScene() {
        delegate?.addNewScene()
    }
}

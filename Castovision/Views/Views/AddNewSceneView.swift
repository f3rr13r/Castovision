//
//  AddNewSceneView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/7/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol AddNewSceneViewDelegate {
    func addNewScene()
}

class AddNewSceneView: BaseView {

    // views
    let contentContainerView = UIView()
    let plusIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "add-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .red
        return iv
    }()
    let addNewSceneLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Scene"
        //label.textColor = .black
        label.textColor = .red
        label.font = defaultButtonFont
        return label
    }()

    // delegate
    var delegate: AddNewSceneViewDelegate?
    
    override func setupView() {
        super.setupView()
        //backgroundColor = grey
        layer.cornerRadius = 6.0
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2.0
        setupTapGestureRecognizer()
        anchorSubviews()
    }
    
    func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userDidTap))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func userDidTap() {
        delegate?.addNewScene()
    }
    
    func anchorSubviews() {
        addSubview(contentContainerView)
        contentContainerView.anchor(withTopAnchor: topAnchor, leadingAnchor: nil, bottomAnchor: bottomAnchor, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: nil)
        contentContainerView.addSubview(plusIconImageView)
        plusIconImageView.anchor(withTopAnchor: nil, leadingAnchor: contentContainerView.leadingAnchor, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: nil, centreYAnchor: contentContainerView.centerYAnchor, widthAnchor: 14.0, heightAnchor: 14.0)
        contentContainerView.addSubview(addNewSceneLabel)
        addNewSceneLabel.anchor(withTopAnchor: nil, leadingAnchor: plusIconImageView.trailingAnchor, bottomAnchor: nil, trailingAnchor: contentContainerView.trailingAnchor, centreXAnchor: nil, centreYAnchor: contentContainerView.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0))
    }
}

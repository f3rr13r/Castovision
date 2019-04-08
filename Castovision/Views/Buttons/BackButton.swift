//
//  BackButton.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

protocol BackButtonDelegate {
    func backButtonPressed()
}

class BackButton: UIButton {

    // views
    let backArrowIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    // delegate
    var delegate: BackButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        anchorSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func anchorSubviews() {
        addSubview(backArrowIcon)
        backArrowIcon.anchor(withTopAnchor: nil, leadingAnchor: leadingAnchor, bottomAnchor: nil, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: centerYAnchor, widthAnchor: 22.0, heightAnchor: 22.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
}

// selector method
extension BackButton {
    @objc func backButtonPressed() {
        delegate?.backButtonPressed()
    }
}

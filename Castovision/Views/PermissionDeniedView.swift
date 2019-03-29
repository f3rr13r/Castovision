//
//  PermissionDeniedView.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class PermissionDeniedView: BaseView {
    
    // views
    let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = defaultContentFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let goToSettingsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go to settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 4.0
        button.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        button.addTarget(self, action: #selector(goToSettingsButtonPressed), for: .touchUpInside)
        return button
    }()
    
    init(title: String, message: String) {
        self.titleLabel.text = title
        self.messageLabel.text = message
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        isHidden = true
        backgroundColor = .white
        addSubview(contentContainer)
        contentContainer.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: nil, centreXAnchor: centerXAnchor, centreYAnchor: centerYAnchor, widthAnchor: screenWidth - (horizontalPadding * 2), heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
        anchorSubviews()
    }
    
    func anchorSubviews() {
        contentContainer.addSubview(titleLabel)
        titleLabel.anchor(withTopAnchor: contentContainer.topAnchor, leadingAnchor: contentContainer.leadingAnchor, bottomAnchor: nil, trailingAnchor: contentContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
        contentContainer.addSubview(messageLabel)
        messageLabel.anchor(withTopAnchor: titleLabel.bottomAnchor, leadingAnchor: contentContainer.leadingAnchor, bottomAnchor: nil, trailingAnchor: contentContainer.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0))
        contentContainer.addSubview(goToSettingsButton)
        goToSettingsButton.anchor(withTopAnchor: messageLabel.bottomAnchor, leadingAnchor: nil, bottomAnchor: contentContainer.bottomAnchor, trailingAnchor: nil, centreXAnchor: contentContainer.centerXAnchor, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 24.0, left: 0.0, bottom: 0.0, right: 0.0))
    }
    
    func isVisible() -> Bool {
        return !isHidden
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    @objc func goToSettingsButtonPressed() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

//
//  LogoImageView.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/28/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class LogoImageView: BaseView {

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "logo")
        return iv
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(logoImageView)
        logoImageView.fillSuperview()
    }
}

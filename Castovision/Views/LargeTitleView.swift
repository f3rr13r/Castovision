//
//  LargeTitleView.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class LargeTitleView: BaseView {

    // views
    let largeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 42.0, weight: .heavy)
        return label
    }()
    
    init(title: String) {
        self.titleName = title
        super.init(frame: .zero)
        
        addSubview(largeTitleLabel)
        largeTitleLabel.anchor(withTopAnchor: topAnchor, leadingAnchor: leadingAnchor, bottomAnchor: bottomAnchor, trailingAnchor: trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var titleName: String {
        didSet {
            largeTitleLabel.text = titleName
        }
    }
}

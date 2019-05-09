//
//  SavedAddressCell.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/24/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class SavedAddressCell: BaseCell {
    
    let tickIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "tick-icon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = green
        return iv
    }()
    
    let emailAddressLabel: UILabel = {
        let label = UILabel()
        label.font = smallTitleFont
        label.textColor = darkGrey
        return label
    }()
    
    // variables
    private var _emailAddress: String!
    
    override func setupViews() {
        super.setupViews()
        self.contentView.isUserInteractionEnabled = false
        anchorChildViews()
    }
    
    func configureCell(withEmailAddress emailAddress: String, andSelectableState isSelectable: Bool, andDisabledState isDisabled: Bool = false) {
        self._emailAddress = emailAddress
        emailAddressLabel.text = emailAddress
        emailAddressLabel.textColor = isDisabled ? grey : darkGrey
        tickIcon.isHidden = isSelectable
    }
    
    func anchorChildViews() {
        self.addSubview(tickIcon)
        tickIcon.anchor(withTopAnchor: nil, leadingAnchor: nil, bottomAnchor: nil, trailingAnchor: self.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: self.centerYAnchor, widthAnchor: 20.0, heightAnchor: 20.0, padding: .init(top: 0.0, left: 0.0, bottom: 0.0, right: -horizontalPadding))
        
        self.addSubview(emailAddressLabel)
        emailAddressLabel.anchor(withTopAnchor: nil, leadingAnchor: self.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: nil, trailingAnchor: tickIcon.leadingAnchor, centreXAnchor: nil, centreYAnchor: self.centerYAnchor, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
}

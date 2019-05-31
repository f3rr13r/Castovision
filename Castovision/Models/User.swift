//
//  User.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/17/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

struct User {
    var id: String?
    var name: String?
    var emailAddress: String?
    var profileImageData: Data?
    var accountCreatedDate: Date?
    var storageGigabytesRemaining: Double?
    var savedEmailAddresses: [String]?
    var stripeCustomerId: String?
    
    init(id: String? = nil, name: String? = nil, emailAddress: String? = nil, profileImageData: Data? = nil, accountCreatedDate: Date? = nil, storageGigabytesRemaining: Double? = nil, savedEmailAddresses: [String]? = nil, stripeCustomerId: String? = nil) {
        self.id = id
        self.name = name
        self.emailAddress = emailAddress
        self.profileImageData = profileImageData
        self.accountCreatedDate = accountCreatedDate
        self.storageGigabytesRemaining = storageGigabytesRemaining
        self.savedEmailAddresses = savedEmailAddresses
        self.stripeCustomerId = stripeCustomerId
    }
}

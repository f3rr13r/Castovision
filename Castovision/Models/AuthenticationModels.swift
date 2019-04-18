//
//  AuthenticationModels.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/16/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation

// protocols
protocol AuthInfoProtocol {
    var emailAddress: String { get set }
    var password: String { get set }
}

// structs
struct LoginInfo: AuthInfoProtocol {
    var emailAddress: String
    var password: String
}

struct SignupInfo: AuthInfoProtocol {
    var emailAddress: String
    var password: String
    var reEnterPassword: String
}

struct AuthResponse {
    var success: Bool
    var errorMessage: String?
}

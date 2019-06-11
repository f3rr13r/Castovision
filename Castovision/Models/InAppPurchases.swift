//
//  InAppPurchasesAlertType.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

enum InAppPurchasesAlertType {
    case setProductIds
    case disabled
    case restored
    case purchased
    
    var message: String {
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}

struct TransactionInfo {
    var userId: String
    var productId: String
    var transactionId: String
    var state: InAppPurchasesAlertType
    var stateMessage: String
    var date: Date
    var price: CGFloat
}

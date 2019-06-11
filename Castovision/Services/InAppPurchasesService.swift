//
//  InAppPurchasesService.swift
//  Castovision
//
//  Created by Harry Ferrier on 6/6/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import FirebaseFirestore

class InAppPurchasesService: NSObject {
    
    //MARL:- singleton declaration
    static let instance = InAppPurchasesService()
    
    // we need to get the specfic productId of the selected item and make a purchase
    func makePurchase(withUserId userId: String, andProductId productId: String, successCompletion: @escaping () -> (), failedCompletion: @escaping (String) -> (), cancelledCompletion: @escaping () -> ()) {
        if SwiftyStoreKit.canMakePayments {
            SwiftyStoreKit.purchaseProduct(productId) { (result) in
                switch result {
                case .success(let purchaseDetails):
                    self.updateDatabaseWithTransactions(withUserId: userId, andPurchaseDetails: purchaseDetails, successCompletion: {
                        successCompletion()
                    }, failedCompletion: { (errorMessage) in
                        failedCompletion(errorMessage)
                    })
                    
                    break;
                case .error(let error):
                    switch error.code {
                    case .unknown:
                        failedCompletion("Unknown error. Please contact support")
                        break
                    case .clientInvalid:
                        failedCompletion("You are not authorized to make this payment. Please check the status in your phone settings")
                        break
                    case .paymentCancelled:
                        cancelledCompletion()
                        break
                    case .paymentInvalid:
                        failedCompletion("Your purchase identifier was invalid. Please try again")
                        break
                    case .paymentNotAllowed:
                        failedCompletion("You're device is not set up to make in-app purchase. Please change this in your phone settings")
                        break
                    case .storeProductNotAvailable:
                        failedCompletion("The product is not available in the current storefront")
                        break
                    case .cloudServicePermissionDenied:
                        failedCompletion("Access to cloud service information is not allowed")
                        break
                    case .cloudServiceNetworkConnectionFailed:
                        failedCompletion("Could not connect to the network. Please check your internet connection and try again")
                        break
                    case .cloudServiceRevoked:
                        failedCompletion("User has revoked permission to use this cloud service. Please update these permissions and try again")
                        break
                    default: failedCompletion(error.localizedDescription)
                    }
                }
            }
        } else {
            failedCompletion("You're device is not set up to make in-app purchase. Please change this in your phone settings")
        }
    }
    
    func updateDatabaseWithTransactions(withUserId userId: String, andPurchaseDetails purchaseDetails: PurchaseDetails, successCompletion: @escaping () -> (), failedCompletion: @escaping (String) -> ()) {
        let productId = purchaseDetails.productId
        let storageAmount = purchaseDetails.productId == "CASTOSTORE5GB" ? "5GB" : "2GB"
        let price = purchaseDetails.productId == "CASTOSTORE5GB" ? "£9.99" : "£4.99"
        let date = Date()

        Firestore.firestore().collection(_PURCHASE_HISTORY).addDocument(data: [
            "userId": userId,
            "productId": productId,
            "storageAmount": storageAmount,
            "price": price,
            "date": date
        ]) { (error) in
            if error != nil {
                failedCompletion(error!.localizedDescription)
            } else {
                successCompletion()
            }
        }
    }
}

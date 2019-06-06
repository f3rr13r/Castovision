//
//  StripeService.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/30/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation
import FirebaseFunctions
import Stripe

/*-- will we need this in future for a castovision store which sells tripods other film recording equipment? --*/

class StripeService: NSObject, STPCustomerEphemeralKeyProvider {
    
    static let instance = StripeService()
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("Creating customer key")
        guard UserService.instance.currentUser.stripeCustomerId != nil else {
            let error = "Could not retrieve user token" as! Error
            completion(nil, error)
            return
        }
        
        /*-- fix it for now, but in future can we get this dynamically? --*/
        let stripeCustomerId = UserService.instance.currentUser.stripeCustomerId
        let data = ["customer_id": stripeCustomerId, "api_version": apiVersion]
        
        Functions.functions().httpsCallable("createStripeCustomerToken").call(data) { (result, error) in
            if error != nil {
                completion(nil, error)
            } else {
                completion(result?.data as? [AnyHashable : Any], nil)
            }
        }
    }
}

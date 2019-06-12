//
//  AuthService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/16/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let instance = AuthService()
    
    typealias AuthResponseCompletion = (AuthResponse) -> ()
    
    func logInUser(withLoginInfo loginInfo: LoginInfo, completion: @escaping (AuthResponse) -> ()) {
        Auth.auth().signIn(withEmail: loginInfo.emailAddress, password: loginInfo.password) { (data, error) in
            if error != nil {
                let logInErrorResponse: AuthResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                completion(logInErrorResponse)
            } else {
                if let userId = data?.user.uid {
                    self.setUserDefaults(withUserId: userId)
                    let logInSuccessResponse: AuthResponse = AuthResponse(success: true, errorMessage: nil)
                    completion(logInSuccessResponse)
                } else {
                    let databaseStorageErrorResponse = AuthResponse(success: false, errorMessage: "Something went wrong when retreiving your account. Please restart the app")
                    completion(databaseStorageErrorResponse)
                }
            }
        }
    }
    
    func signUpUser(with signUpInfo: SignupInfo, completion: @escaping AuthResponseCompletion) {
        Auth.auth().createUser(withEmail: signUpInfo.emailAddress, password: signUpInfo.password) { (data, error) in
            if error != nil {
                let signUpErrorResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                completion(signUpErrorResponse)
            } else {
                if let userId = data?.user.uid {
                    UserService.instance.storeCurrentUserData(atUserId: userId, withEmailAddress: signUpInfo.emailAddress, completion: { (didStoreUserDataSuccessfully) in
                        if didStoreUserDataSuccessfully {
                            Auth.auth().signIn(withEmail: signUpInfo.emailAddress, password: signUpInfo.password, completion: { (data, error) in
                                if error != nil {
                                    let logInErrorResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                                    completion(logInErrorResponse)
                                } else {
                                    let logInSuccessResponse = AuthResponse(success: true, errorMessage: nil)
                                    self.setUserDefaults(withUserId: userId)
                                    completion(logInSuccessResponse)
                                }
                            })
                        } else {
                            let databaseStorageErrorResponse = AuthResponse(success: false, errorMessage: "Something went wrong when creating your account. Please restart the app")
                            completion(databaseStorageErrorResponse)
                        }
                    })
                } else {
                    let noUserIdErrorResponse = AuthResponse(success: false, errorMessage: "Something went wrong in the sign up process. Please restart the app")
                    completion(noUserIdErrorResponse)
                }
            }
        }
    }
    
    func setUserDefaults(withUserId userId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(userId, forKey: "userId")
        userDefaults.synchronize()
    }
    
    func sendForgotPasswordEmail(withEmailAddress emailAddress: String, completion: @escaping AuthResponseCompletion) {
        Auth.auth().fetchSignInMethods(forEmail: emailAddress) { (availableMethods, error) in
            if error != nil {
                let forgotPasswordErrorResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                completion(forgotPasswordErrorResponse)
            } else {
                if let availableMethods = availableMethods,
                    availableMethods.count > 0 {
                    Auth.auth().sendPasswordReset(withEmail: emailAddress) { (error) in
                        if error != nil {
                            let forgotPasswordErrorResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                            completion(forgotPasswordErrorResponse)
                        } else {
                            let forgotPasswordSuccessResponse = AuthResponse(success: true, errorMessage: nil)
                            completion(forgotPasswordSuccessResponse)
                        }
                    }
                } else {
                    let noEmailRegisteredErrorResponse = AuthResponse(success: false, errorMessage: "There is no account registered with this email address")
                    completion(noEmailRegisteredErrorResponse)
                }
            }
        }
    }
    
    func sendPasswordResetEmail(withEmailAddress emailAddress: String, completion: @escaping AuthResponseCompletion) {
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { (error) in
            if error != nil {
                let emailSendFailedResponse = AuthResponse(success: false, errorMessage: error?.localizedDescription)
                completion(emailSendFailedResponse)
            } else {
                let emailSendCompleteResponse = AuthResponse(success: true, errorMessage: nil)
                completion(emailSendCompleteResponse)
            }
        }
    }
    
    func logoutUser(completion: (Bool) -> ()) {
        do {
            try Auth.auth().signOut()
            let userDefaults = UserDefaults.standard
            UserService.instance.clearCurrentUser()
            userDefaults.removeObject(forKey: "userId")
            userDefaults.synchronize()
            completion(true)
        } catch {
            completion(false)
        }
    }
}

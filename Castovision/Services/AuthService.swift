//
//  AuthService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/16/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol AuthServiceDelegate {
    func isDeletingAccountValueChanged(toValue isDeletingValue: Bool)
}

class AuthService {
    
    static let instance = AuthService()
    
    typealias AuthResponseCompletion = (AuthResponse) -> ()
    
    var delegate: AuthServiceDelegate?
    
    var isDeletingAccount: Bool = false {
        didSet {
            delegate?.isDeletingAccountValueChanged(toValue: self.isDeletingAccount)
        }
    }
    
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
    
    func deleteAccount(withEmailAddress emailAddress: String, andPassword password: String, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        if let currentUser = Auth.auth().currentUser {
            self.isDeletingAccount = true
            let authCredential: AuthCredential = EmailAuthProvider.credential(withEmail: emailAddress, password: password)
            currentUser.reauthenticateAndRetrieveData(with: authCredential) { (data, error) in
                if error != nil {
                    self.isDeletingAccount = false
                    failedCompletion(error!.localizedDescription)
                } else {
                    guard let userId = data?.user.uid else {
                        self.isDeletingAccount = false
                        failedCompletion("We cannot find your user account data at the moment. Please try again, or contact our support team to get your account deleted manually")
                        return
                    }
                    
                    let db: Firestore = Firestore.firestore()
                    self.deletePurchaseDocument(withDb: db, userId: userId, failedCompletion: { (errorMessage) in
                        self.isDeletingAccount = false
                        failedCompletion(errorMessage)
                    }, successCompletion: {
                        self.deleteAuditionDocuments(withDb: db, userId: userId, failedCompletion: { (errorMessage) in
                            self.isDeletingAccount = false
                            failedCompletion(errorMessage)
                        }, successCompletion: {
                            self.deleteUserDocument(withDb: db, userId: userId, failedCompletion: { (errorMessage) in
                                self.isDeletingAccount = false
                                failedCompletion(errorMessage)
                            }, successCompletion: {
                                self.deleteFromAuthAndClearLocalStorage(withEmailAddress: emailAddress, andPassword: password, failedCompletion: { (errorMessage) in
                                    self.isDeletingAccount = false
                                    failedCompletion(errorMessage)
                                }, successCompletion: {
                                    self.isDeletingAccount = false
                                    successCompletion()
                                })
                            })
                        })
                    })
                }
            }
        } else {
            let errorMessage = "We were unable to grab you account user data. Please try again, or contact our support team to get your account deleted manually"
            failedCompletion(errorMessage)
        }
    }
    
    func deletePurchaseDocument(withDb db: Firestore, userId: String, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        var numberOfDocuments: Int = 0
        var numberOfDeletedDocuments: Int = 0
        let purchaseRef = db.collection(_PURCHASE_HISTORY)
        let currentUserPurchaseDocuments = purchaseRef.whereField(_OWNER_ID, isEqualTo: userId)
        currentUserPurchaseDocuments.getDocuments(completion: { (snapshot, error) in
            if error != nil {
                failedCompletion(error!.localizedDescription)
            } else {
                if let documents = snapshot?.documents {
                    numberOfDocuments = documents.count
                    if numberOfDocuments > 0 {
                        documents.forEach({ (document) in
                            document.reference.delete(completion: { (error) in
                                if error != nil {
                                    failedCompletion(error!.localizedDescription)
                                } else {
                                    numberOfDeletedDocuments += 1
                                    
                                    if numberOfDeletedDocuments == numberOfDocuments {
                                        successCompletion()
                                    }
                                }
                            })
                        })
                    } else {
                        successCompletion()
                    }
                }
            }
        })
    }
    
    func deleteAuditionDocuments(withDb db: Firestore, userId: String, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        var numberOfDocuments: Int = 0
        var numberOfDeletedDocuments: Int = 0
        let auditionsRef = db.collection(_AUDITION_TAPES)
        let currentUserAuditionDocuments = auditionsRef.whereField(_OWNER_ID, isEqualTo: userId)
        currentUserAuditionDocuments.getDocuments { (snapshot, error) in
            if error != nil {
                failedCompletion(error!.localizedDescription)
            } else {
                if let documents = snapshot?.documents {
                    numberOfDocuments = documents.count
                    if numberOfDocuments > 0 {
                        let storage = Storage.storage()
                        for document in documents {
                            let data = document.data()
                            if let scenes = data["scenes"] as? [[String: Any]] {
                                for scene in scenes {
                                    if let takes = scene["takes"] as? [[String: Any]] {
                                        for take in takes {
                                            if let takeVideoUrl = take["videoUrl"] as? String,
                                                let takeThumbnailUrl = take["videoThumbnailUrl"] as? String {
                                                let takeVideo = storage.reference(forURL: takeVideoUrl)
                                                print(takeVideo.fullPath)
                                                takeVideo.delete(completion: { (error) in
                                                    if error != nil {
                                                        failedCompletion(error!.localizedDescription)
                                                    }
                                                })
                                                let takeThumbnail = storage.reference(forURL: takeThumbnailUrl)
                                                takeThumbnail.delete(completion: { (error) in
                                                    if error != nil {
                                                        failedCompletion(error!.localizedDescription)
                                                    }
                                                })
                                            } else {
                                                failedCompletion("Something went wrong when trying to get a valid audition video and thumbnail storage reference. Please try again, or contact our support team to get your account deleted manually")
                                            }
                                        }
                                    } else {
                                        failedCompletion("Something went wrong when trying to get specific audition scene take data. Please try again, or contact our support team to get your account deleted manually")
                                    }
                                }
                            } else {
                                failedCompletion("Something went wrong when trying to get specific audition scene data. Please try again, or contact our support team to get your account deleted manually")
                            }
                            
                            document.reference.delete(completion: { (error) in
                                if error != nil {
                                    failedCompletion(error!.localizedDescription)
                                } else {
                                    numberOfDeletedDocuments += 1
                                    
                                    if numberOfDeletedDocuments == numberOfDocuments {
                                        successCompletion()
                                    }
                                }
                            })
                        }
                    } else {
                        successCompletion()
                    }
                }
            }
        }
    }
    
    func deleteUserDocument(withDb db: Firestore, userId: String, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        let usersRef = db.collection(_USERS)
        let currentUserDocument = usersRef.document(userId)
        currentUserDocument.getDocument { (document, error) in
            if error != nil {
                failedCompletion(error!.localizedDescription)
            } else {
                if let document = document,
                       document.exists {
                    if let data = document.data(),
                       let profileImageUrl = data["profileImageUrl"] as? String {
                        let storage = Storage.storage()
                        let profileImage = storage.reference(forURL: profileImageUrl)
                        profileImage.delete(completion: { (error) in
                            if error != nil {
                                failedCompletion("Something went wrong when trying to get your user profile image from storage. Please try again, or contact our support team to get your account deleted manually")
                            }
                        })
                    }
                    
                    document.reference.delete(completion: { (error) in
                        if error != nil {
                            failedCompletion(error!.localizedDescription)
                        } else {
                            successCompletion()
                        }
                    })
                } else {
                    failedCompletion("Could not find your user information in the database. Please try again, or contact our support team to get your account deleted manually")
                }
            }
        }
    }
    
    func deleteFromAuthAndClearLocalStorage(withEmailAddress emailAddress: String, andPassword password: String, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        /*-- clear the caches --*/
        AssetCachingService.instance.clearCaches()
        
        /*-- auth --*/
        if let currentUser = Auth.auth().currentUser {
            let authCredentials: AuthCredential = EmailAuthProvider.credential(withEmail: emailAddress, password: password)
            currentUser.reauthenticateAndRetrieveData(with: authCredentials) { (_, error) in
                if error != nil {
                    failedCompletion(error!.localizedDescription)
                } else {
                    currentUser.delete(completion: { (error) in
                        if error != nil {
                            failedCompletion(error!.localizedDescription)
                        } else {
                            let userDefaults = UserDefaults.standard
                            UserService.instance.clearCurrentUser()
                            userDefaults.removeObject(forKey: "userId")
                            userDefaults.synchronize()
                            successCompletion()
                        }
                    })
                }
            }
        }
    }
}

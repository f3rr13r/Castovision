//
//  UserService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/16/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class UserService {
    
    static let instance = UserService()
    
    // initialize the cloud firestore and storage buckets
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    
    required init() {
        let settings = db.settings
        db.settings = settings
    }
    
    // store current user
    var currentUser = User()
    
    /*========================
            GET METHODS
    ========================*/
    func getCurrentUserDataFromCloudFirestore(completion: @escaping (Bool) -> ()) {
        if currentUser.id == nil {
            guard let userId = UserDefaults.standard.object(forKey: "userId") as? String else {
                completion(false)
                return
            }
            
            let currentUserRef = db.collection(_USERS).document(userId)
            currentUserRef.addSnapshotListener { (document, error) in
                if error != nil {
                    completion(false)
                } else {
                    if let document = document, document.exists {
                        if let data = document.data() {
                            
                            self.currentUser.id = userId
                            self.currentUser.name = data["profileName"] as? String ?? "Name not found"
                            self.currentUser.emailAddress = data["emailAddress"] as? String ?? "Email address not found"
                            guard let timeStamp = data["accountCreatedDate"] as? Timestamp else {
                                completion(false)
                                return
                            }
                            self.currentUser.accountCreatedDate = timeStamp.dateValue()
                            self.currentUser.storageGigabytesRemaining = data["storageMegabytesRemaining"] as? Double ?? 0.0
                            
                            /*-- profile image --*/
                            do {
                                // check the cache here first
                                
                                // if not in cash, do the following
                                guard let profileImageURL = data["profileImageUrl"] as? String else {
                                    // give a locally stored default image
                                    return
                                }
                                
                                do {
                                    let imageData = try Data(contentsOf: URL(string: profileImageURL)!)
                                    let profileImage = UIImage(data: imageData)
                                    self.currentUser.profileImage = profileImage
                                } catch {
                                    // give locally stored default image
                                    return
                                }
                            }
                            completion(true)
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    
    /*========================
            SET METHODS
     ========================*/
    func storeCurrentUserData(atUserId userId: String, withEmailAddress emailAddress: String, completion: @escaping (Bool) -> ()) {
        db.collection(_USERS).document(userId).setData([
            "emailAddress": emailAddress,
            "storageMegabytesRemaining": 5000.00,
            "accountCreatedDate": FieldValue.serverTimestamp()
        ]) { (error) in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    func updateUserData<T>(withName name: String, andValue value: T, completion: @escaping (Bool) -> ()) {
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? String else { completion(false); return }
        
        if name == "profileImageUrl" {
            storeProfileImageInStorageBucket(withUserId: userId, andProfileImage: value as! UIImage) { (storedSuccessfully, imageLocationString) in
                if storedSuccessfully {
                    print("image Location string stored successfully")
                    self.db.collection(_USERS).document(userId).setData([
                        name: imageLocationString!
                        ], merge: true, completion: { (error) in
                            if error != nil {
                                completion(false)
                            } else {
                                completion(true)
                            }
                    })
                } else {
                    completion(false)
                }
            }
        } else {
            db.collection(_USERS).document(userId).setData([
                name: value
            ], merge: true) { (error) in
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func storeProfileImageInStorageBucket(withUserId userId: String, andProfileImage image: UIImage, completion: @escaping (_ storageSuccessful: Bool, _ storageLocationUrl: String?) -> ()) {
        guard let imageData = image.pngData() else { print("Failed to get representation"); completion(false, nil); return }
        let profileImageStorageRef = storage.reference().child("profile-images/").child("\(userId)_profileImage")
        profileImageStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("1. \(String(describing: error?.localizedDescription))")
                completion(false, nil)
            } else {
                profileImageStorageRef.downloadURL(completion: { (locationUrl, error) in
                    if error != nil {
                        completion(false, nil)
                    } else {
                        completion(true, locationUrl?.absoluteString)
                    }
                })
                
            }
        }
    }
    
    
    func clearCurrentUser() {
        self.currentUser = User()
    }
}

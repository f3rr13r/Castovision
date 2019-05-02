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
    
    // typealiases
    typealias failedCompletion = (String) -> ()
    typealias successCompletion = ([Project]) -> ()
    typealias scenesSuccessCompletion = ([Scene]) -> ()
    typealias takesSuccessCompletion = ([Take]) -> ()
    
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
                            self.currentUser.savedEmailAddresses = data["savedEmailAddresses"] as? [String] ?? []
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
    
    func getCurrentUserAuditions(failedCompletion: @escaping failedCompletion, successCompletion: @escaping successCompletion) {
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? String else {
            failedCompletion("Something went wrong when attempting to retrieve your audition projects. Refresh the page by swiping down")
            return
        }
        
        var auditionProjects: [Project] = []
        
        let auditionTapesRef = db.collection(_AUDITION_TAPES)
        let currentUserAuditionTapeDocuments = auditionTapesRef.whereField(_OWNER_ID, isEqualTo: userId)
        currentUserAuditionTapeDocuments.getDocuments { (querySnapshot, error) in
            if error != nil {
                // completion(someting bad)
            } else {
                if let documents = querySnapshot?.documents {
                    let auditionProjectsCount: Int = documents.count
                    var updatedProjectsCount: Int = 0
                    
                    documents.forEach({ (documentSnapshot) in
                        let documentData = documentSnapshot.data()
                        var useableTimeStamp: Date = Date()
                        if let serverTimeStamp = documentData["createdDate"] as? Timestamp {
                            useableTimeStamp = serverTimeStamp.dateValue()
                        }
                        
                        /*-- initialzie project --*/
                        var auditionProject = Project(
                            timeStamp: useableTimeStamp,
                            ownerId: userId,
                            projectName: documentData["projectName"] as? String ?? "No project name found",
                            projectPassword: documentData["projectPassword"] as? String ?? "No project password found",
                            scenes: [],
                            numberOfViews: documentData["numberOfViews"] as? Int ?? 0,
                            currentMailingList: []
                        )
                        
                        guard let scenesObjectData = documentData["scenes"] as? [[String: Any]] else {
                            print("Something went wrong")
                            return
                        }
                        
                        /*-- model the scenes data into something workable --*/
                        self.modelSceneObjectDataToAuditionScenes(withObjectData: scenesObjectData, failedCompletion: { (failedMessage) in
                            failedCompletion(failedMessage)
                        }, successCompletion: { (scenes) in
                            auditionProject.scenes = scenes
                            
                            auditionProjects.append(auditionProject)
                            
                            updatedProjectsCount += 1
                            if updatedProjectsCount == auditionProjectsCount {
                                /*-- order the projects array by date descending --*/
                                let orderedProjectsArray: [Project] = auditionProjects.sorted(by: { $0.timeStamp!.timeIntervalSince1970 > $1.timeStamp!.timeIntervalSince1970 })
                                
                                /*-- pass back the array --*/
                                successCompletion(orderedProjectsArray)
                            }
                        })
                    })
                }
            }
        }
    }
    
    func modelSceneObjectDataToAuditionScenes(withObjectData objectData: [[String: Any]], failedCompletion: @escaping failedCompletion, successCompletion: scenesSuccessCompletion) {
        var scenes: [Scene] = []
        
        let scenesCount = objectData.count
        var updatedScenesCount = 0
        
        for sceneObjectData in objectData {
            guard let sceneNumber = sceneObjectData["sceneNumber"] as? Int,
                let sceneTakesObjectData = sceneObjectData["takes"] as? [[String: Any]] else {
                    failedCompletion("Failed to get scene data")
                    return
            }
            var scene: Scene = Scene(sceneNumber: sceneNumber, takes: [])
            
            /*-- model the takes data into something workable --*/
            modelTaskObjectDataToTakes(withObjectData: sceneTakesObjectData, failedCompletion: { (failedMessage) in
                failedCompletion(failedMessage)
            }) { (takes) in
                scene.takes = takes
                scenes.append(scene)
                
                updatedScenesCount += 1
                if updatedScenesCount == scenesCount {
                    successCompletion(scenes)
                }
            }
        }
    }
    
    func modelTaskObjectDataToTakes(withObjectData objectData: [[String: Any]], failedCompletion: @escaping failedCompletion, successCompletion: takesSuccessCompletion) {
        var takes: [Take] = []
        
        let takesCount = objectData.count
        var updatedTakesCount = 0
        
        for takeObjectData in objectData {
            
            // get the basic data
            guard let fileSize = takeObjectData["fileSize"] as? Double,
                let videoDuration = takeObjectData["videoDuration"] as? Double,
                let videoUrlString = takeObjectData["videoUrl"] as? String,
                let videoThumbnailUrlString = takeObjectData["videoThumbnailUrl"] as? String,
                let videoUrl = URL(string: videoUrlString),
                let videoThumbnailUrl = URL(string: videoThumbnailUrlString) else {
                    failedCompletion("Failed to get scene take data")
                    return
            }
            
            // make data from the video thumbnail url
            do {
                let videoThumbnailUrlData = try Data(contentsOf: videoThumbnailUrl)
                
                let take: Take = Take(
                    videoThumbnailUrl: videoThumbnailUrlData,
                    videoUrl: videoUrl,
                    videoDuration: videoDuration,
                    fileSize: fileSize
                )
                
                takes.append(take)
                
                updatedTakesCount += 1
                if takesCount == updatedTakesCount {
                    successCompletion(takes)
                }
                
            } catch let error {
                failedCompletion(error.localizedDescription)
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

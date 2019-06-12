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

protocol UserServiceDelegate {
    func currentUserWasUpdated(updatedData: User)
}

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
    var currentUser = User() {
        didSet {
            delegate?.currentUserWasUpdated(updatedData: self.currentUser)
        }
    }
    var projects: [Project] = []
    
    var delegate: UserServiceDelegate?
    
    /*========================
            GET METHODS
    ========================*/
    func getCurrentUserDataFromCloudFirestore(isInitializing: Bool = false, successCompletion: @escaping () -> (), failedCompletion: @escaping () -> (), updaterCompletion: @escaping (User) -> ()) {
        
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? String else {
            failedCompletion()
            return
        }
        
        let currentUserRef: DocumentReference = db.collection(_USERS).document(userId)
        currentUserRef.addSnapshotListener { (document, error) in
            if error != nil {
                failedCompletion()
            } else {
                if let document = document, document.exists {
                    if let data = document.data() {
                        self.currentUser.id = userId
                        self.currentUser.name = data["profileName"] as? String ?? "Name not found"
                        self.currentUser.emailAddress = data["emailAddress"] as? String ?? "Email address not found"
                        self.currentUser.savedEmailAddresses = data["savedEmailAddresses"] as? [String] ?? []
                        self.currentUser.stripeCustomerId = data["stripe_customer_id"] as? String ?? nil
                        guard let timeStamp = data["accountCreatedDate"] as? Timestamp else {
                            failedCompletion()
                            return
                        }
                        self.currentUser.accountCreatedDate = timeStamp.dateValue()
                        self.currentUser.storageGigabytesRemaining = data["storageMegabytesRemaining"] as? Double ?? 0.0
                        
                        /*-- profile image --*/
                        if let profileImageUrl = data["profileImageUrl"] as? String {
                            AssetCachingService.instance.getCachedImage(withKey: profileImageUrl, completion: { (responseStatus, imageData) in
                                switch responseStatus {
                                    case .imageFound:
                                        guard let profileImageData = imageData else {
                                            failedCompletion()
                                            return
                                        }
                                        
                                        self.currentUser.profileImageData = profileImageData
                                        break
                                    
                                        case .noValueFound:
                                            do {
                                                let imageData = try Data(contentsOf: URL(string: profileImageUrl)!)
                                                self.currentUser.profileImageData = imageData
                                                AssetCachingService.instance.setCachedImage(withKey: profileImageUrl, andImageData: imageData)
                                                break
                                            } catch {
                                                break
                                            }
                                        }
                                    })
                        } else {
                            do {
                                guard let noProfileImageURL = Bundle.main.url(forResource: "no-profile-selected-icon", withExtension: "png") else {
                                    failedCompletion()
                                    return
                                }
                                self.currentUser.profileImageData = try Data(contentsOf: noProfileImageURL)
                                return
                            } catch {
                                failedCompletion()
                            }
                            return
                        }
                        
                        if isInitializing {
                            successCompletion()
                        } else {
                            updaterCompletion(self.currentUser)
                        }
                    }
                } else {
                    failedCompletion()
                }
            }
        }
    }
    
    func getCurrentUserAuditions(failedCompletion: @escaping failedCompletion, successCompletion: @escaping successCompletion) {
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? String else {
            failedCompletion("Something went wrong when attempting to retrieve your audition projects. Refresh the page by swiping down")
            return
        }
        
        let auditionTapesRef = db.collection(_AUDITION_TAPES)
        let currentUserAuditionTapeDocuments = auditionTapesRef.whereField(_OWNER_ID, isEqualTo: userId)
        currentUserAuditionTapeDocuments.addSnapshotListener { (querySnapshot, error) in
            
            var auditionProjects: [Project] = []
            
            if error != nil {
                failedCompletion("Something went wrong when attempting to retrieve your audition projects. Refresh the page by swiping down")
            } else {
                if let documents = querySnapshot?.documents {
                    let auditionProjectsCount: Int = documents.count
                    var updatedProjectsCount: Int = 0
                    
                    if auditionProjectsCount > 0 {
                        documents.forEach({ (documentSnapshot) in
                            let projectId = documentSnapshot.documentID
                            let documentData = documentSnapshot.data()
                            var useableTimeStamp: Date = Date()
                            if let serverTimeStamp = documentData["createdDate"] as? Timestamp {
                                useableTimeStamp = serverTimeStamp.dateValue()
                            }
                            
                            /*-- initialzie project --*/
                            var auditionProject = Project(
                                id: projectId,
                                timeStamp: useableTimeStamp,
                                ownerId: userId,
                                projectName: documentData["projectName"] as? String ?? "No project name found",
                                projectPassword: documentData["projectPassword"] as? String ?? "No project password found",
                                scenes: [],
                                numberOfViews: documentData["numberOfViews"] as? Int ?? 0,
                                currentMailingList: documentData["currentMailingList"] as? [String] ?? []
                            )
                            
                            guard let scenesObjectData = documentData["scenes"] as? [[String: Any]] else {
                                failedCompletion("Something went wrong when attempting to retrieve your audition projects. Refresh the page by swiping down")
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
                    } else {
                        successCompletion(auditionProjects)
                    }
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
                    let sortedScenes = scenes.sorted(by: { $0.sceneNumber! < $1.sceneNumber! })
                    successCompletion(sortedScenes)
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
                let takeNumber = takeObjectData["takeNumber"] as? Int,
                let videoDuration = takeObjectData["videoDuration"] as? Double,
                let videoUrlString = takeObjectData["videoUrl"] as? String,
                let videoThumbnailUrlString = takeObjectData["videoThumbnailUrl"] as? String,
                let videoUrl = URL(string: videoUrlString),
                let videoThumbnailUrl = URL(string: videoThumbnailUrlString) else {
                    failedCompletion("Failed to get scene take data")
                    return
            }
            
            // check if we have the image on disk already. If we do just set it. If we don't then save it to cache for future
            let key = videoThumbnailUrl.absoluteString
            var videoThumbnailURLData: Data!
            
            AssetCachingService.instance.getCachedImage(withKey: key) { (responseStatus, imageData) in
                switch responseStatus {
                    case .imageFound:
                        guard let data = imageData else {
                            do {
                                videoThumbnailURLData = try Data(contentsOf: videoThumbnailUrl)
                            } catch {
                               failedCompletion("Failed to get scene take data")
                            }
                            return
                        }
                        
                        videoThumbnailURLData = data
                    break
                    
                    case .noValueFound:
                        do {
                            videoThumbnailURLData = try Data(contentsOf: videoThumbnailUrl)
                        } catch {
                            failedCompletion("Failed to get scene take data")
                        }
                    break
                }
                
                let take: Take = Take(
                    takeNumber: takeNumber,
                    videoThumbnailUrl: videoThumbnailURLData,
                    videoUrl: videoUrl,
                    videoDuration: videoDuration,
                    fileSize: fileSize
                )
                
                takes.append(take)
                
                updatedTakesCount += 1
                if takesCount == updatedTakesCount {
                    if takesCount > 1 {
                        let sortedTakes = takes.sorted(by: { $0.takeNumber! < $1.takeNumber! })
                        successCompletion(sortedTakes)
                    } else {
                        successCompletion(takes)
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

//
//  AddSelfTapeService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AddSelfTapeService {
    
    // singleton reference
    static let instance = AddSelfTapeService()
    
    // initialize the cloud firestore and storage buckets
    let db: Firestore = Firestore.firestore()
    let storage: Storage = Storage.storage()
    
    // typealiases
    typealias updateCompletion = () -> ()
    typealias uploadingStatusCompletion = (_ status: UploadStatus) -> ()
    typealias uploadingFailedCompletion = (_ failureMessage: String) -> ()
    typealias uploadingSuccessCompletion = (_ successMessage: String) -> ()
    
    typealias uploadingTakeSuccessCompletion = (_ successMessage: String, _ takeObject: [String: Any]) -> ()
    typealias uploadingSceneSuccessCompletion = (_ successMessage: String, _ scenesObject: [String: Any]) -> ()
    
    // locally stored project
    private var _selfTapeProject: Project = Project()
    private var _projectId: String?
    private var _projectThumbnailUrlString: String?
    
    
    func initializeNewSelfTapeProject() {
        self._selfTapeProject = Project()
        self._selfTapeProject.scenes = []
        let scene: Scene = Scene(sceneNumber: 1, takes: [])
        self._selfTapeProject.scenes?.append(scene)
    }
    
    func getUpdatedSelfTapeProject(completion: (Project) -> ()) {
        completion(_selfTapeProject)
    }
    
    func updateProjectName(withValue value: String, completion: updateCompletion) {
        _selfTapeProject.projectName = value
        completion()
    }
    
    func updateProjectPassword(withValue value: String, completion: updateCompletion) {
        _selfTapeProject.projectPassword = value
        completion()
    }
    
    func updateProjectEmailAddressList(withMailingList mailingList: [String], completion: updateCompletion) {
        _selfTapeProject.currentMailingList = mailingList
        completion()
    }
    
    func addNewProjectScene(completion: (Project) -> ()) {
        let newSceneNumber = self._selfTapeProject.scenes!.count + 1
        let newScene = Scene(sceneNumber: newSceneNumber, takes: [])
        self._selfTapeProject.scenes?.append(newScene)
        completion(self._selfTapeProject)
    }
    
    func addNewSceneTake(withValue take: Take, forSceneNumber sceneNumber: Int, completion: updateCompletion) {
        self._selfTapeProject.scenes?[sceneNumber - 1].takes?.append(take)
        completion()
    }
    
    func deleteScene(withSceneNumberToDelete sceneNumberToDelete: Int, completion: (Project) -> ()) {
        if let projectScenes = _selfTapeProject.scenes {
            for sceneIndex in 0..<projectScenes.count {
                if let sceneNumber = projectScenes[sceneIndex].sceneNumber,
                    sceneNumber == sceneNumberToDelete {
                        _selfTapeProject.scenes?.remove(at: sceneIndex)
                        completion(_selfTapeProject)
                }
            }
        }
    }
    
    func deleteSceneTake(withValue take: Take, completion: (Project) -> ()) {
        if let projectScenes = _selfTapeProject.scenes {
            for sceneIndex in 0..<projectScenes.count {
                if var sceneTakes = projectScenes[sceneIndex].takes {
                    for takeIndex in 0..<sceneTakes.count {
                        if let videoThumbnailOfTakeToDelete = take.videoThumbnailUrl,
                            let currentTakeVideoThumbnail = sceneTakes[takeIndex].videoThumbnailUrl,
                            sceneTakes[takeIndex].videoThumbnailUrl == videoThumbnailOfTakeToDelete {
                            if videoThumbnailOfTakeToDelete == currentTakeVideoThumbnail {
                                _selfTapeProject.scenes?[sceneIndex].takes?.remove(at: takeIndex)
                                completion(_selfTapeProject)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func upload(updateStatus: @escaping uploadingStatusCompletion, uploadFailed: @escaping uploadingFailedCompletion, uploadSucceeded: @escaping uploadingSuccessCompletion) {
        
        /*-- fire off the status update --*/
        var updateInfo: UploadStatus = UploadStatus(progressNumber: 0.0, progressMessage: "Preparing Upload") {
            didSet {
                updateStatus(updateInfo)
            }
        }
        
        /*-- do all applicable property existence checks first --*/
        guard let userId: String = UserService.instance.currentUser.id,
              let scenes: [Scene] = self._selfTapeProject.scenes,
              let projectName: String = self._selfTapeProject.projectName,
              let projectPassword: String = self._selfTapeProject.projectPassword,
              let mailingList: [String] = self._selfTapeProject.currentMailingList else {
                uploadFailed("Failed to get your project information")
                return
        }
        
        /*-- model for passing to the database --*/
        var projectInfo: [String: Any] = [
            "ownerId": userId,
            "createdDate": FieldValue.serverTimestamp(),
            "numberOfViews": 0,
            "projectName": projectName,
            "projectPassword": projectPassword,
            "currentMailingList": mailingList
        ]
        
        /*-- dispatch queue stuff --*/
        let scenesDispatchGroup = DispatchGroup()
        let scenesDispatchQueue = DispatchQueue(label: "scenesDispatchQueue")
        let scenesDispatchSemaphore = DispatchSemaphore(value: 0)
    
        /*-- utility variables --*/
        var sceneNumber: Int = 0
        var scenesObject: [[String: Any]] = []
        
        /*-- do the counter --*/
        scenesDispatchQueue.async {
            for i in 0..<scenes.count {
                sceneNumber = i + 1
                scenesDispatchGroup.enter()
                
                self.modelSceneData(withScene: scenes[i], sceneNumber: sceneNumber, currentProgress: updateInfo.progressNumber, userId: userId, updateCompletion: { (newUploadStatus) in
                    updateInfo = newUploadStatus
                }, failedCompletion: { (errorMessage) in
                    uploadFailed(errorMessage)
                }, successCompletion: { (successMessage, sceneObject) in
                    print("Uploading Scene \(sceneNumber)")
                    scenesObject.append(sceneObject)
                    
                    // leave the dispatch group
                    scenesDispatchSemaphore.signal()
                    scenesDispatchGroup.leave()
                })
                scenesDispatchSemaphore.wait()
            }
        }
        
        scenesDispatchGroup.notify(queue: scenesDispatchQueue) {
            projectInfo["scenes"] = scenesObject
            
            self.storeProjectToDatabase(withProjectInfo: projectInfo, updateCompletion: { (newUploadStatus) in
                updateInfo = newUploadStatus
            }, failedCompletion: { (errorMessage) in
                uploadFailed(errorMessage)
            }, successCompletion: { (successMessage) in
                
                /*-- if the user has added email addresses then send to them --*/
                if let emailAddresses = self._selfTapeProject.currentMailingList,
                    emailAddresses.count > 0 {
                    updateInfo = UploadStatus(progressNumber: 0.0, progressMessage: "Sending your project to invitees")
                    self.sendProjectToRequestedEmails(withEmailAddresses: emailAddresses, andProject: self._selfTapeProject, failedCompletion: { (errorMessage) in
                        uploadFailed(errorMessage)
                    }, successCompletion: {
                        updateInfo = UploadStatus(progressNumber: 100.0, progressMessage: "Self-tape uploaded and sent")
                        uploadSucceeded("Self-tape uploaded and sent")
                    })
                } else {
                    updateInfo = UploadStatus(progressNumber: 100.0, progressMessage: "Self-tape uploaded and sent")
                    uploadSucceeded(successMessage)
                }
            })
        }
    }
    
    func modelSceneData(withScene scene: Scene, sceneNumber: Int, currentProgress: CGFloat, userId: String, updateCompletion: @escaping uploadingStatusCompletion, failedCompletion: @escaping uploadingFailedCompletion, successCompletion: @escaping uploadingSceneSuccessCompletion) {
        
        var scenesUpdateInfo: UploadStatus = UploadStatus(progressNumber: currentProgress, progressMessage: "") {
            didSet {
                updateCompletion(scenesUpdateInfo)
            }
        }
        
        /*-- do all applicable property existence checks first --*/
        guard var sceneNumber = scene.sceneNumber,
            let takes = scene.takes else {
            failedCompletion("Unable to get scene information")
            return
        }
        
        /*-- scene object --*/
        var sceneObject: [String: Any] = [
            "sceneNumber": sceneNumber,
            "sceneId": UUID().uuidString,
            "ownerId": userId
        ]
        
        /*-- dispatch queue stuff --*/
        let takesDispatchGroup = DispatchGroup()
        let takesDispatchQueue = DispatchQueue(label: "scenesDispatchQueue")
        let takesDispatchSemaphore = DispatchSemaphore(value: 0)
        
        /*-- ulitity variables --*/
        var takesObject: [[String: Any]] = []
        var takeNumber: Int = 0
        var takesCompletionsNumber: Int = 0
        
        takesDispatchQueue.async {
            for i in 0..<takes.count {
                takeNumber = i + 1
                takesDispatchGroup.enter()

                self.uploadAndModelTakeData(withTake: takes[i], sceneNumber: sceneNumber, takeNumber: takeNumber, currentProgress: currentProgress, userId: userId, updateCompletion: { (newUploadStatus) in
                    scenesUpdateInfo = newUploadStatus
                }, failedCompletion: { (errorMessage) in
                    failedCompletion(errorMessage)
                }, successCompletion: { (successMessage, takeObject) in
                    takesCompletionsNumber += 1
                    print("Scene \(sceneNumber) - Take \(takeNumber) uploaded successfully")
                    takesObject.append(takeObject)
                    
                    // leave the dispatch group
                    takesDispatchSemaphore.signal()
                    takesDispatchGroup.leave()
                })
                takesDispatchGroup.wait()
            }
        }
        
        takesDispatchGroup.notify(queue: takesDispatchQueue) {
            sceneObject["takes"] = takesObject
            successCompletion("Scene \(sceneNumber) uploaded successfully", sceneObject)
        }
    }
    
    func uploadAndModelTakeData(withTake take: Take, sceneNumber: Int, takeNumber: Int, currentProgress: CGFloat, userId: String, updateCompletion: @escaping uploadingStatusCompletion, failedCompletion: @escaping uploadingFailedCompletion, successCompletion: @escaping uploadingTakeSuccessCompletion) {
        
        var updateInfo: UploadStatus = UploadStatus(progressNumber: currentProgress, progressMessage: "") {
            didSet {
                updateCompletion(updateInfo)
            }
        }
        
        /*-- do all applicable property existence checks first --*/
        guard let takeVideoUrl = take.videoUrl,
              let takeVideoDuration = take.videoDuration,
              let takeVideoThumbnailData = take.videoThumbnailData,
              let takeVideoFileSize = take.fileSize else {
                failedCompletion("Failed to get information for a Scene \(sceneNumber) take")
                return
        }
        
        var takeObject: [String: Any] = [
            "takeNumber": takeNumber,
            "videoDuration": takeVideoDuration,
            "fileSize": takeVideoFileSize,
            "takeId": UUID().uuidString
        ]
        
        /*-- do the storage stuff here --*/
        updateInfo = UploadStatus(progressNumber: 0.0, progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber)")
        
        /*-- attempt to extract the video data --*/
        do {
            let takeVideoData = try Data(contentsOf: takeVideoUrl)
            let takeVideoMetadata = StorageMetadata()
            takeVideoMetadata.contentType = "video/mp4"
            
            let takeVideoUID = "\(userId)_takeVideo_\(UUID().uuidString)"
            let videoStorageRef = storage.reference().child(_AUDITION_TAPES).child(userId).child(takeVideoUID)
            
            /*-- attempt to put the video data to storage --*/
            let takeVideoUploadTask = videoStorageRef.putData(takeVideoData, metadata: takeVideoMetadata)
            
            /*-- storage upload status observers --*/
            takeVideoUploadTask.observe(.progress) { (snapshot) in
                updateInfo = UploadStatus(progressNumber: CGFloat(snapshot.progress!.fractionCompleted), progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber)")
            }
            
            takeVideoUploadTask.observe(.failure) { (snapshot) in
                failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber)")
            }
            
            takeVideoUploadTask.observe(.success) { (_) in
                
                videoStorageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber)")
                    } else {
                        
                        guard let takeVideoStorageUrlString = url?.absoluteString else {
                            failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber)")
                            return
                        }
                        
                        updateInfo = UploadStatus(progressNumber: 0.0, progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber) thumbnail")
                        
                        /*-- success done - next we do thumbnail --*/
                        let takeVideoThumbnailUID = "\(userId)_videoThumbnails_\(UUID().uuidString)"
                        let takeVideoThumbnailStorageRef = self.storage.reference().child(_AUDITION_TAKE_THUMBNAILS).child(userId).child(takeVideoThumbnailUID)
                        
                        /*-- put the thumbnail data to storage --*/
                        let takeVideoThumbnailUploadTask = takeVideoThumbnailStorageRef.putData(takeVideoThumbnailData)
                        
                        /*-- storage upload observers --*/
                        takeVideoThumbnailUploadTask.observe(.progress) { (snapshot) in
                            updateInfo = UploadStatus(progressNumber: CGFloat(snapshot.progress!.fractionCompleted), progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber) thumbnail")
                        }
                        
                        takeVideoThumbnailUploadTask.observe(.failure) { (snapshot) in
                            failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber) thumbnail")
                        }
                        
                        takeVideoThumbnailUploadTask.observe(.success) { (_) in
                            
                            takeVideoThumbnailStorageRef.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber) thumbnail")
                                } else {
                                    
                                    guard let takeVideoThumbnailStorageUrlString = url?.absoluteString else {
                                        failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber) thumbnail")
                                        return
                                    }
                                    
                                    takeObject["videoUrl"] = takeVideoStorageUrlString
                                    takeObject["videoThumbnailUrl"] = takeVideoThumbnailStorageUrlString
                                    
                                    // store first thumbnail for the email
                                    if sceneNumber == 1 && takeNumber == 1 {
                                        self._projectThumbnailUrlString = takeVideoThumbnailStorageUrlString
                                    }
                                    
                                    successCompletion("Uploaded Scene \(sceneNumber) - Take \(takeNumber) successfully", takeObject)
                                }
                            })
                            
                        }
                    }
                })
            }
        } catch {
            failedCompletion("Failed to upload Scene \(sceneNumber) - Take \(takeNumber) to the cloud")
        }
    }
    
    func storeProjectToDatabase(withProjectInfo projectInfo: [String: Any], updateCompletion: @escaping uploadingStatusCompletion, failedCompletion: @escaping uploadingFailedCompletion, successCompletion: @escaping uploadingSuccessCompletion) {
        
        var updateInfo: UploadStatus = UploadStatus(progressNumber: 0.0, progressMessage: "Saving scenes cloud information to database") {
            didSet {
                updateCompletion(updateInfo)
            }
        }
        
        /*-- database pathing --*/
        let auditionsDatabasePath: CollectionReference = self.db.collection(_AUDITION_TAPES)
        let projectId: String = UUID().uuidString
        let projectDataBasePath: DocumentReference = auditionsDatabasePath.document(projectId)
        
        /*-- save the projectId for the email --*/
        self._projectId = projectId
        
        /*-- set the data in firebase database --*/
        projectDataBasePath.setData(projectInfo) { (error) in
            if error != nil {
                failedCompletion("Failed to save project info in the database")
            } else {
                updateInfo = UploadStatus(progressNumber: 100.0, progressMessage: "Audution successfully saved to the database")
                successCompletion("Audition upload successfully!")
            }
        }
    }
    
    func sendProjectToRequestedEmails(withEmailAddresses emailAddresses: [String], andProject project: Project, failedCompletion: @escaping (String) -> (), successCompletion: @escaping () -> ()) {
        
        guard let projectName = project.projectName,
              let projectPassword = project.projectPassword,
              let actorName = UserService.instance.currentUser.name,
              let actorProfileUrlString = UserService.instance.currentUser.profileImageUrl?.absoluteString else {
                failedCompletion("1.Failed to send your self-taped audition to your invitees. Go to feed, and click 'send' to try again")
                return
        }
        
        /*-- try project id --*/
        var projectId: String = ""
        if project.id != nil {
            projectId = project.id!
        } else if self._projectId != nil {
            projectId = self._projectId!
        } else {
            failedCompletion("2.Failed to send your self-taped audition to your invitees. Go to feed, and click 'send' to try again")
        }
        
        /*-- try project thumbnail --*/
        var projectThumbnailUrlString: String = ""
        if project.scenes?[0].takes?[0].videoThumbnailUrl != nil {
            projectThumbnailUrlString = (project.scenes?[0].takes?[0].videoThumbnailUrl!.absoluteString)!
        } else if self._projectThumbnailUrlString != nil {
            projectThumbnailUrlString = self._projectThumbnailUrlString!
        } else {
            failedCompletion("3.Failed to send your self-taped audition to your invitees. Go to feed, and click 'send' to try again")
        }
        
        // send it to functions
        Functions.functions().httpsCallable("sendSelftapeProject").call([
            "emails": emailAddresses,
            "projectId": projectId,
            "projectName": projectName,
            "projectPassword": projectPassword,
            "projectThumbnailUrlString": projectThumbnailUrlString,
            "actorName": actorName,
            "actorThumbnailUrlString": actorProfileUrlString
        ]) { (result, error) in
            if error != nil {
                failedCompletion(error!.localizedDescription)
            } else {
                successCompletion()
            }
        }
    }
    
    func reset() {
        self._selfTapeProject = Project()
        self._projectId = nil
        self._projectThumbnailUrlString = nil
    }
}


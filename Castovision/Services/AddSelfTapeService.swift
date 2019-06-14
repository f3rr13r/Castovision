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
    typealias uploadSceneSuccessCompletion = (_ successMessage: String, _ scenesObject: [String: Any]) -> ()
    
    // locally stored project
    private var _selfTapeProject: Project = Project()
    
    
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
    
    
    /*-- upload the self tape project --*/
    func upload(updateStatus: @escaping uploadingStatusCompletion, uploadFailed: @escaping uploadingFailedCompletion, uploadSucceeded: @escaping uploadingSuccessCompletion) {
        
        /*-- observable uploading update status variable so we can pass back values for the progress to be displayed to the user in real time --*/
        var updateInfo: UploadStatus = UploadStatus(progressNumber: 0.0, progressMessage: "Preparing upload") {
                didSet {
                    updateStatus(updateInfo)
            }
        }
        
        /*-- do all applicable property existence checks first --*/
        guard let userId: String = UserService.instance.currentUser.id,
              let scenes: [Scene] = self._selfTapeProject.scenes,
              let projectName: String = self._selfTapeProject.projectName,
              let projectPassword: String = self._selfTapeProject.projectPassword else {
            
                uploadFailed("Failed to get your project information")
                return
        }
        
        /*-- add the intial database entry --*/
        let auditionsDatabasePath: CollectionReference = self.db.collection(_AUDITION_TAPES)
        let projectId: String = UUID().uuidString
        let projectDatabasePath: DocumentReference = auditionsDatabasePath.document(projectId)
        
        /*-- set the initial data for the project in firebase database --*/
        projectDatabasePath.setData([
            "ownerId": userId,
            "createdDate": FieldValue.serverTimestamp(),
            "numberOfViews": 0,
            "projectName": projectName,
            "projectPassword": projectPassword,
        ]) { (setDataError) in
            if setDataError != nil {
                uploadFailed("Failed to store initial project information")
            } else {
                var scenesObjectArray: [[String: Any]] = []
                
                /*-- keep reference to the number of success completions that we get --*/
                var numberOfSuccessCompletions: Int = 0
                
                /*-- loop through the available scenes --*/
                for sceneIndex in 0..<scenes.count {
                    // what do we need to do here
                    // we need to map a scenes object
                    self.modelSceneDataToObject(withUserId: userId, scene: scenes[sceneIndex], currentProgressNumber: 0, uploadUpdateStatus: { (updatedUploadStatus) in
                        updateInfo = updatedUploadStatus
                    }, uploadFailed: { (uploadFailedMessage) in
                        uploadFailed(uploadFailedMessage)
                    }, uploadSuccess: { (uploadSuccessMessage, updatedSceneObject) in
                        scenesObjectArray.append(updatedSceneObject)
                        numberOfSuccessCompletions += 1
                        if numberOfSuccessCompletions == scenes.count {
                            projectDatabasePath.updateData([
                                "scenes": scenesObjectArray
                                ], completion: { (updateDataError) in
                                    if updateDataError != nil {
                                        uploadFailed("Failed to store project information")
                                    } else {
                                        uploadSucceeded(uploadSuccessMessage)
                                    }
                            })
                        }
                    })
                }
            }
        }
    }
    
    /*-- scene saver method --*/
    func modelSceneDataToObject(withUserId userId: String, scene: Scene, currentProgressNumber: CGFloat, uploadUpdateStatus: @escaping uploadingStatusCompletion, uploadFailed: @escaping uploadingFailedCompletion, uploadSuccess: @escaping uploadSceneSuccessCompletion) {
        
        /*-- observable status updater which will feed back to parent --*/
        var updateInfo: UploadStatus = UploadStatus(progressNumber: currentProgressNumber, progressMessage: "") {
            didSet {
                uploadUpdateStatus(updateInfo)
            }
        }
        
        /*-- value check. without these we cannot proceed --*/
        guard let sceneNumber = scene.sceneNumber,
            let takes = scene.takes else {
            uploadFailed("Unable to get scene information")
            return
        }
        
        var sceneObject: [String: Any] = [
            "sceneNumber": sceneNumber,
            "sceneId": UUID().uuidString,
            "ownerId": userId,
            "takes": []
        ]
        
        var takesObjectArray: [[String: Any]] = []
        var numberOfSuccessCompletions: Int = 0
        
        /*-- loop through the available takes --*/
        for takeIndex in 0..<takes.count {
            guard let takeNumber = takes[takeIndex].takeNumber else {
                uploadFailed("Unable to get scene information")
                return
            }
            storeAndModelTakeData(withUserId: userId, sceneNumber: sceneNumber, takeNumber: takeNumber, take: takes[takeIndex], currentProgressNumber: currentProgressNumber, updatedUpdateStatus: { (updatedUpdateInfo) in
                updateInfo = updatedUpdateInfo
            }, uploadFailed: { (failedMessage) in
                uploadFailed(failedMessage)
            }) { (successMessage, updatedTakeObject) in
                    takesObjectArray.append(updatedTakeObject)
                    
                    // check the successful completions
                    numberOfSuccessCompletions += 1
                    if numberOfSuccessCompletions == takes.count {
                        sceneObject["takes"] = takesObjectArray
                        uploadSuccess(successMessage, sceneObject)
                    }
                }
            }
        }
    
    /*-- scene takes method --*/
    func storeAndModelTakeData(withUserId userId: String, sceneNumber: Int, takeNumber: Int, take: Take, currentProgressNumber: CGFloat, updatedUpdateStatus: @escaping uploadingStatusCompletion, uploadFailed: @escaping uploadingFailedCompletion, uploadSuccess: @escaping uploadingTakeSuccessCompletion) {
        
        /*-- observable status updater which will feed back to parent --*/
        var updateInfo: UploadStatus = UploadStatus(progressNumber: currentProgressNumber, progressMessage: "") {
            didSet {
                updatedUpdateStatus(updateInfo)
            }
        }
        
        /*-- check for values which are imperitive. if we don't have them then kill it --*/
        guard let takeVideoUrl = take.videoUrl,
              let takeVideoDuration = take.videoDuration,
              let takeVideoThumbnailData = take.videoThumbnailUrl,
              let takeVideoFileSize = take.fileSize else {
                uploadFailed("Failed to get information for a Scene \(sceneNumber) take")
                return
        }
        
        /*-- attempt to extract the video data --*/
        do {
            
            let takeVideoData = try Data(contentsOf: takeVideoUrl)
            
            let takeVideoMetadata = StorageMetadata()
            takeVideoMetadata.contentType = "video/mp4"
            
            let takeVideoUID = "\(userId)_takeVideo_\(UUID().uuidString)"
            let videoStorageRef = storage.reference().child(_AUDITION_TAPES).child(userId).child(takeVideoUID)
            
            /*-- put the video data into storage --*/
            let takeVideoUploadTask = videoStorageRef.putData(takeVideoData, metadata: takeVideoMetadata)
            
            /*-- add observers to the upload task --*/
            takeVideoUploadTask.observe(.progress) { (snapshot) in
                updateInfo = UploadStatus(progressNumber: CGFloat(snapshot.progress!.fractionCompleted), progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber)")
            }
            
            takeVideoUploadTask.observe(.failure) { (snapshot) in
                uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) on our database")
            }
            
            takeVideoUploadTask.observe(.success) { (snapshot) in
                
                /*-- video in the firebase storage bucket. get download url --*/
                videoStorageRef.downloadURL(completion: { (takeVideoStorageUrl, error) in
                    if error != nil {
                        uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) on our database")
                    } else {
                        guard let takeVideoStorageUrlString = takeVideoStorageUrl?.absoluteString else {
                            uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) on our database")
                            return
                        }
                        
                        /*-- next we do the thumbnail --*/
                        let takeVideoThumbnailUID = "\(userId)_video-thumbnails_\(UUID().uuidString)"
                        let takeVideoThumbnailStorageRef = self.storage.reference().child(_AUDITION_TAKE_THUMBNAILS).child(userId).child(takeVideoThumbnailUID)
                        
                        /*-- put the thumbnail into storage --*/
                        let takeVideoThumbnailUploadTask = takeVideoThumbnailStorageRef.putData(takeVideoThumbnailData)
                        
                        /*-- add the observers --*/
                        takeVideoThumbnailUploadTask.observe(.progress, handler: { (snapshot) in
                            updateInfo = UploadStatus(progressNumber: CGFloat(snapshot.progress!.fractionCompleted), progressMessage: "Uploading Scene \(sceneNumber) - Take \(takeNumber)")
                        })
                        
                        takeVideoThumbnailUploadTask.observe(.failure, handler: { (snapshot) in
                            uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) thumbnail on our database")
                        })
                        
                        takeVideoThumbnailUploadTask.observe(.success, handler: { (snapshot) in
                            
                            /*-- thumbnail in the firebase storage bucket. get download url --*/
                            takeVideoThumbnailStorageRef.downloadURL(completion: { (takeThumbnailStorageUrl, error) in
                                if error != nil {
                                    uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) thumbnail on our database")
                                } else {
                                    guard let takeVideoThumbnailStorageUrlString = takeThumbnailStorageUrl?.absoluteString else {
                                            uploadFailed("Failed to store Scene \(sceneNumber) - Take \(takeNumber) thumbnail on our database")
                                        return
                                    }
                                    
                                    /*-- unique reference to take --*/
                                    let updatedTakeObject: [String: Any] = [
                                        "takeNumber": takeNumber,
                                        "videoThumbnailUrl": takeVideoThumbnailStorageUrlString,
                                        "videoUrl": takeVideoStorageUrlString,
                                        "videoDuration": takeVideoDuration,
                                        "fileSize": takeVideoFileSize,
                                        "takeId": UUID().uuidString
                                    ]
                                    
                                    uploadSuccess("Take uploaded and saved successfully", updatedTakeObject)
                                }
                            })
                        })
                    }
                })
            }
            
        } catch {
            uploadFailed("Failed to get video data for Scene \(sceneNumber) - Take \(takeNumber)")
        }
    }
    
    func reset() {
        self._selfTapeProject = Project()
    }
}


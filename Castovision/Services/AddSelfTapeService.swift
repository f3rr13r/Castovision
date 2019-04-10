//
//  AddSelfTapeService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class AddSelfTapeService {
    
    static let instance = AddSelfTapeService()
    
    typealias updateCompletion = () -> ()
    
    private var _selfTapeProject: Project = Project()
    
    func initializeNewSelfTapeProject() {
        self._selfTapeProject = Project()
        self._selfTapeProject.scenes = []
        let scene: Scene = Scene(sceneNumber: 1, takes: [], numberOfViews: nil)
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
    
    func addNewProjectScene(completion: (Project) -> ()) {
        let newSceneNumber = self._selfTapeProject.scenes!.count + 1
        let newScene = Scene(sceneNumber: newSceneNumber, takes: [], numberOfViews: nil)
        self._selfTapeProject.scenes?.append(newScene)
        completion(self._selfTapeProject)
    }
    
    func addNewSceneTake(withValue take: Take, forSceneNumber sceneNumber: Int, completion: updateCompletion) {
        self._selfTapeProject.scenes?[sceneNumber - 1].takes?.append(take)
        completion()
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
                                sceneTakes.remove(at: takeIndex)
                                completion(_selfTapeProject)
                            }
                        }
                    }
                }
            }
        }
    }
}


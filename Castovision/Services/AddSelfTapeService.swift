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
    
    private var selfTapeProject: Project = Project()
    
    func initializeNewSelfTapeProject() {
        let scene: Scene = Scene(sceneNumber: 1, takes: [], numberOfViews: nil)
        self.selfTapeProject.scenes?.append(scene)
    }
    
    func getUpdatedSelfTapeProject(completion: (Project) -> ()) {
        completion(selfTapeProject)
    }
    
    func updateProjectName(withValue value: String, completion: updateCompletion) {
        selfTapeProject.projectName = value
    }
    
    func updateProjectPassword(withValue value: String, completion: updateCompletion) {
        selfTapeProject.projectPassword = value
    }
    
    func addNewProjectScene(completion: (Project) -> ()) {
        let newSceneNumber = selfTapeProject.scenes!.count + 1
        let newScene = Scene(sceneNumber: newSceneNumber, takes: [], numberOfViews: nil)
        self.selfTapeProject.scenes?.append(newScene)
        completion(self.selfTapeProject)
    }
    
    func addNewSceneTake(withValue take: Take, forSceneNumber sceneNumber: Int, completion: updateCompletion) {
        for i in 0..<self.selfTapeProject.scenes!.count {
            if self.selfTapeProject.scenes![i].sceneNumber == sceneNumber {
                self.selfTapeProject.scenes![i].takes?.append(take)
                completion()
            }
        }
    }
}


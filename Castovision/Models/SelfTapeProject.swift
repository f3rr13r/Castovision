//
//  SelfTapeProject.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation

struct Project {
    var timeStamp: Date?
    var ownerId: String?
    var projectName: String?
    var projectPassword: String?
    var scenes: [Scene]?
    
    init(timeStamp: Date? = nil, ownerId: String? = nil, projectName: String? = nil, projectPassword: String? = nil, scenes: [Scene]? = nil) {
        self.timeStamp = nil
        self.ownerId = nil
        self.projectName = nil
        self.projectPassword = nil
        self.scenes = nil
    }
}

struct Scene {
    var sceneNumber: Int?
    var takes: [Take]?
    var numberOfViews: Int?
    
    init(sceneNumber: Int? = nil, takes: [Take]? = nil, numberOfViews: Int? = nil) {
        self.sceneNumber = sceneNumber
        self.takes = takes
        self.numberOfViews = numberOfViews
    }
}

struct Take {
    var videoUrl: URL?
    var startTime: Double?
    var endTime: Double?
    var numberOfViews: Int?
    
    init(videoUrl: URL? = nil, startTime: Double? = nil, endTime: Double? = nil, numberOfViews: Int? = nil) {
        self.videoUrl = videoUrl
        self.startTime = startTime
        self.endTime = endTime
        self.numberOfViews = numberOfViews
    }
}

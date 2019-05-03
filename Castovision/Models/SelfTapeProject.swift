//
//  SelfTapeProject.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation

struct Project: Encodable {
    var timeStamp: Date?
    var ownerId: String?
    var projectName: String?
    var projectPassword: String?
    var scenes: [Scene]?
    var numberOfViews: Int?
    var currentMailingList: [String]?
    
    init(timeStamp: Date? = nil, ownerId: String? = nil, projectName: String? = nil, projectPassword: String? = nil, scenes: [Scene]? = nil, numberOfViews: Int? = nil, currentMailingList: [String]? = []) {
        self.timeStamp = timeStamp
        self.ownerId = ownerId
        self.projectName = projectName
        self.projectPassword = projectPassword
        self.scenes = scenes
        self.numberOfViews = numberOfViews
        self.currentMailingList = currentMailingList
    }
}

struct Scene: Encodable {
    var sceneNumber: Int?
    var takes: [Take]?
    
    init(sceneNumber: Int? = nil, takes: [Take]? = nil) {
        self.sceneNumber = sceneNumber
        self.takes = takes
    }
}

struct Take: Encodable {
    var takeNumber: Int?
    var videoThumbnailUrl: Data?
    var videoUrl: URL?
    var videoDuration: Double?
    var numberOfViews: Int?
    var fileSize: Double?
    
    init(takeNumber: Int? = nil, videoThumbnailUrl: Data? = nil, videoUrl: URL? = nil, videoDuration: Double? = nil, fileSize: Double? = nil) {
        self.takeNumber = takeNumber
        self.videoThumbnailUrl = videoThumbnailUrl
        self.videoUrl = videoUrl
        self.videoDuration = videoDuration
        self.fileSize = fileSize
    }
}

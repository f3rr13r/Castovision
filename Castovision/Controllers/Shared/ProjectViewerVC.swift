//
//  ProjectViewerVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit

class ProjectViewerVC: UIViewController {
    
    
    // private variables
    private var _project: Project = Project()
    
    // video player variables
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isVideoPlaying: Bool = false {
        didSet {
            if self.isVideoPlaying {
                // change to pause image
            } else {
                // change to play image
            }
        }
    }
    
    var isVideoBarVisible: Bool = true
    
    // initializer methods
    init(project: Project) {
        self._project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setupAVPlayer()
        self.addTapGestureRecognizer()
        self.handleChildDelegates()
        self.anchorChildViews()
    }
    
    func addTapGestureRecognizer() {
        
    }
    
    func handleChildDelegates() {
        
    }
    
    func anchorChildViews() {
        
    }
}

// video player specific stuff
extension ProjectViewerVC {
    func setupAVPlayer() {
        
    }
}

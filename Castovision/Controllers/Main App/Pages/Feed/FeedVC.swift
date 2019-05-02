//
//  FeedVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

private let feedCellId = "FeedCellId"

class FeedVC: UICollectionViewController {

    // views
    lazy var feedSearchVC = FeedSearchVC()
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var auditionProjects: [Project] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        anchorChildViews()
        self.configureNavigationBar(withTitle: "Feed", withSearchBar: true, withSearchResultsController: feedSearchVC)
        self.configureCollectionView()
        
        /*-- we need this for the search controller --*/
        definesPresentationContext = true    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUpdatedUserAuditionProjects()
    }
    
    func getUpdatedUserAuditionProjects() {
        UserService.instance.getCurrentUserAuditions(failedCompletion: { (failedMessage) in
            print(failedMessage)
        }) { (updatedAuditionProjects) in
            self.auditionProjects = updatedAuditionProjects
            self.feedSearchVC.injectData(forAuditionProjects: self.auditionProjects)
        }
    }
    
    func anchorChildViews() {
        self.view.insertSubview(backgroundImageView, belowSubview: collectionView)
        backgroundImageView.fillSuperview()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        layout.itemSize = CGSize(width: feedCellWidth, height: feedCellHeight)
        layout.minimumLineSpacing = 12.0
        self.collectionView!.collectionViewLayout = layout
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.auditionProjects.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
        feedCell.delegate = self
        feedCell.configureCell(withProjectInfo: self.auditionProjects[indexPath.item])
        return feedCell
    }
}

// feed cell delegate methods
extension FeedVC: FeedCellDelegate {
    func playProjectVideoButtonPressed(withProjectInfo projectInfo: Project) {
        print("FEED VC - play project video button pressed")
    }
    
    func expandButtonPressed(withProjectInfo projectInfo: Project) {
        print("FEED VC - expand button pressed")
    }
    
    func sendButtonPressed(withProjectInfo projectInfo: Project) {
        print("FEED VC - send button pressed")
    }
}

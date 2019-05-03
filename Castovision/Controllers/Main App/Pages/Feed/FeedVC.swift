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
    
    let loadingView = LoadingView()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    var auditionProjects: [Project] = [] {
        didSet {
            if self.auditionProjects.count > 0 {
                
                collectionView.reloadData()
            } else {
                // show no data state
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.getUpdatedUserAuditionProjects()
        self.lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Feed", withSearchBar: true, withSearchResultsController: feedSearchVC)
        self.anchorChildViews()
        self.configureCollectionView()
        
        /*-- we need this for the search controller --*/
        definesPresentationContext = true
    }
    
    @objc func getUpdatedUserAuditionProjects() {
        DispatchQueue.global(qos: .background).async {
            UserService.instance.getCurrentUserAuditions(failedCompletion: { (failedMessage) in
                self.loadingView.isHidden = true
                let errorMessageConfig = CustomErrorMessageConfig(title: "Oops!", body: "Something went wrong when trying to retrieve your self-tape projects. Check your internet connection, and click 'refresh' to try again")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
            }) { (updatedAuditionProjects) in
                print(updatedAuditionProjects)
                self.loadingView.fadeOut()
                if updatedAuditionProjects.count > 0 {
                    self.auditionProjects = updatedAuditionProjects
                    self.feedSearchVC.injectData(forAuditionProjects: self.auditionProjects)
                } else {
                        // show a no data state
                }
            }
        }
    }
    
    func anchorChildViews() {
        self.view.insertSubview(backgroundImageView, belowSubview: collectionView)
        backgroundImageView.fillSuperview()
        
        self.view.insertSubview(loadingView, aboveSubview: collectionView)
        loadingView.fillSuperview()
    }
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        layout.itemSize = CGSize(width: feedCellWidth, height: feedCellHeight)
        layout.minimumLineSpacing = 12.0
        
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = layout
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
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
        let projectViewerVC = ProjectViewerVC(project: projectInfo)
        let landscapeModeContainerVC = LandscapeModeContainerVC(rootViewController: projectViewerVC)
        self.present(landscapeModeContainerVC, animated: true, completion: nil)
    }
    
    func expandButtonPressed(withProjectInfo projectInfo: Project) {
        let expandedProjectScenesVC = ExpandedProjectScenesVC(projectInfo: projectInfo)
        self.navigationController?.pushViewController(expandedProjectScenesVC, animated: true)
    }
    
    func sendButtonPressed(withProjectInfo projectInfo: Project) {
        let sendProjectEmailVC = SendProjectEmailVC()
        self.navigationController?.pushViewController(sendProjectEmailVC, animated: true)
    }
}


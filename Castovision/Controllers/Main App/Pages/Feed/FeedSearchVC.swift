//
//  FeedSearchVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/30/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class FeedSearchVC: UIViewController {
    
    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    private var feedCellId: String = "feedCellId"
    lazy var projectSearchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        layout.itemSize = CGSize(width: feedCellWidth, height: feedCellHeight)
        layout.minimumLineSpacing = 12.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.isHidden = true
        cv.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
        return cv
    }()
    
    private var _auditionProjects: [Project] = [] {
        didSet {
            self._projectSearchResults = self._auditionProjects
        }
    }
    
    private var _projectSearchResults: [Project] = [] {
        didSet {
            projectSearchResultsCollectionView.isHidden = self._auditionProjects.count == 0
            projectSearchResultsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        anchorChildViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardHeightObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func injectData(forAuditionProjects auditionProjects: [Project]) {
        self._auditionProjects = auditionProjects
    }
    
    func setKeyboardHeightObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("keyboard will show")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            updateCollectionViewLayout(withBottomEdgeInset: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide() {
        updateCollectionViewLayout(withBottomEdgeInset: 20.0)
    }
    
    func updateCollectionViewLayout(withBottomEdgeInset bottomEdgeInset: CGFloat) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: bottomEdgeInset, right: 20.0)
        layout.itemSize = CGSize(width: feedCellWidth, height: feedCellHeight)
        layout.minimumLineSpacing = 12.0
        projectSearchResultsCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(projectSearchResultsCollectionView)
        projectSearchResultsCollectionView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil)
    }
}

// search updating
extension FeedSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchValue = searchController.searchBar.text else { return }
        self._projectSearchResults = self._auditionProjects.filter({ (project) -> Bool in
            guard let projectName = project.projectName else { return false }
            return projectName.contains(find: searchValue)
        })
    }
}

// collection view delegate and datasource methods
extension FeedSearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._projectSearchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
        feedCell.delegate = self
        feedCell.configureCell(withProjectInfo: self._projectSearchResults[indexPath.item])
        return feedCell
    }
}

// feed cell delegate methods
extension FeedSearchVC: FeedCellDelegate {
    func playProjectVideoButtonPressed(withProjectInfo projectInfo: Project) {
        let projectViewerVC = ProjectViewerVC()
        self.navigationController?.pushViewController(projectViewerVC, animated: true)
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

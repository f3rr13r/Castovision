//
//  ExpandedProjectScenesVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class ExpandedProjectScenesVC: UIViewController {

    // views
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "loading-background")
        return iv
    }()
    
    private let _sceneHeaderId: String = "sceneHeaderId"
    private let _takeCellId: String = "takeCellId"
    lazy var scenesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(SceneHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self._sceneHeaderId)
        cv.register(SceneTakeCell.self, forCellWithReuseIdentifier: self._takeCellId)
        return cv
    }()
    
    // variables
    private var _projectInfo: Project = Project() {
        didSet {
            scenesCollectionView.reloadData()
        }
    }

    // custom initializer
    init(projectInfo: Project) {
        self._projectInfo = projectInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // auto rotation prevention
    override var shouldAutorotate: Bool {
        return false
    }
    
    // life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        anchorChildViews()
        
        guard let projectName = self._projectInfo.projectName else { return }
        configureNavigationBar(withTitle: projectName, withSearchBar: false)
    }
    
    func anchorChildViews() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        self.view.addSubview(scenesCollectionView)
        scenesCollectionView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil)
    }
}

// collection view delegate and datasource methods
extension ExpandedProjectScenesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let scenesCount = self._projectInfo.scenes?.count else { return 0 }
        return scenesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let takesCount = self._projectInfo.scenes?[section].takes?.count else { return 0 }
        return takesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            // section header
            guard let sceneNumber = self._projectInfo.scenes?[indexPath.section].sceneNumber,
                  let sceneHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self._sceneHeaderId, for: indexPath) as? SceneHeaderView else {
                return UICollectionReusableView()
            }
            sceneHeaderView.configureSceneView(withSceneNumber: sceneNumber, andNeedsDeleteButton: false)
            return sceneHeaderView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let take = self._projectInfo.scenes?[indexPath.section].takes?[indexPath.item],
            let sceneTakeCell = collectionView.dequeueReusableCell(withReuseIdentifier: self._takeCellId, for: indexPath) as? SceneTakeCell else {
                return UICollectionViewCell()
        }
        sceneTakeCell.configureCell(withTake: take, isSceneDeletable: false)
        return sceneTakeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sceneTake = self._projectInfo.scenes?[indexPath.section].takes?[indexPath.item],
            let sceneNumber = self._projectInfo.scenes?[indexPath.section].sceneNumber else {
                return
        }
        // instantiate the takeViewerVC, feed it into the videoFilmingNavigationVC and present it
        let takeViewerVC = TakeViewerVC(sceneNumber: sceneNumber, takeNumber: indexPath.item + 1, take: sceneTake)
        let videoFilmingNavigationVC = VideoFilmingNavigationVC(rootViewController: takeViewerVC)
        self.present(videoFilmingNavigationVC, animated: true, completion: nil)
    }
}

// collection view inset and element sizing methods
extension ExpandedProjectScenesVC: UICollectionViewDelegateFlowLayout {
    
    // section insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: horizontalPadding, bottom: 0.0, right: horizontalPadding)
    }
    
    // header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: sceneHeaderViewWidth, height: sceneHeaderViewHeight)
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: projectSceneCellContentWidth, height: projectSceneCellContentHeight)
    }
    
    // section cell spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

//
//  AddProjectScenesVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/3/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

private let sceneHeaderCellId: String = "sceneHeaderCellId"
private let projectSceneCellId: String = "projectSceneCellId"
private let sceneFooterCellId: String = "sceneFooterCellId"
private let extendedSceneFooterCellId: String = "extendedSceneFooterCellId"

class AddProjectScenesVC: UIViewController {
    lazy var projectScenesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(SceneHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sceneHeaderCellId)
        cv.register(SceneCell.self, forCellWithReuseIdentifier: projectSceneCellId)
        cv.register(AddNewSceneTakeFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: sceneFooterCellId)
        cv.register(ExpandedAddNewSceneFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: extendedSceneFooterCellId)
        return cv
    }()
    
    let saveProjectButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Save Project", buttonColour: UIColor.red, isDisabled: true)
    
    // variables
    var auditionScenes: [AuditionScene] = [
            AuditionScene(
                sceneNumber: 1,
                sceneTakes: []
            )
        ] {
        didSet {
            updateCollectionViewState()
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Add Scenes", withSearchBar: false)
        anchorSubviews()
    }
    
    func updateCollectionViewState() {
        self.projectScenesCollectionView.reloadData()
        self.projectScenesCollectionView.invalidateIntrinsicContentSize()
        DispatchQueue.main.async {            
            self.projectScenesCollectionView.scrollToBottomSection()
        }
    }
    
    func anchorSubviews() {
        self.view.addSubview(saveProjectButton)
        saveProjectButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
        
        self.view.addSubview(projectScenesCollectionView)
        projectScenesCollectionView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: saveProjectButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
}

// collection view datasource, delegate methods
extension AddProjectScenesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    // number of sections (scenes)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return auditionScenes.count
    }
    
    // number of takes in each scene
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return auditionScenes[section].sceneTakes.count
    }
    
    // scene cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sceneCell = collectionView.dequeueReusableCell(withReuseIdentifier: projectSceneCellId, for: indexPath) as? SceneCell else {
            return UICollectionViewCell()
        }
        return sceneCell
    }
    
    // scene header and footer (including add new scene if expanded)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // kind of 'header'
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sceneHeaderCellId, for: indexPath) as? SceneHeaderView else {
                return UICollectionReusableView()
            }
            headerView.configureSceneView(withSceneNumber: auditionScenes[indexPath.section].sceneNumber)
            return headerView
        }
        
        // kind of 'footer'
        if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == (auditionScenes.count - 1) {
                // expandable footer
                guard let expandableFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: extendedSceneFooterCellId, for: indexPath) as? ExpandedAddNewSceneFooterView else {
                        return UICollectionReusableView()
                    }
                expandableFooter.configureSceneFooterView(withSceneNumber: self.auditionScenes[indexPath.section].sceneNumber)
                expandableFooter.delegate = self
                return expandableFooter
            } else {
               // default footer
                guard let defaultFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sceneFooterCellId, for: indexPath) as? AddNewSceneTakeFooterView else {
                        return UICollectionReusableView()
                }
                defaultFooter.configureSceneFooterView(withSceneNumber: self.auditionScenes[indexPath.section].sceneNumber)
                defaultFooter.delegate = self
                return defaultFooter
            }
        }
        
        // if neither then something has gone wrong so let's just
        // send back an empty default reusable view
        return UICollectionReusableView()
    }
}

// collection view inset and element sizing methods
extension AddProjectScenesVC: UICollectionViewDelegateFlowLayout {
    
    // section insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
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
    
    // footer sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == (auditionScenes.count - 1) {
            return CGSize(width: expandedAddNewSceneFooterViewWidth, height: expandedAddNewSceneFooterViewHeight)
        } else {
            return CGSize(width: addNewSceneTakeFooterViewWidth, height: addNewSceneTakeFooterViewHeight)
        }
    }
}

// cell footers delegate methods
extension AddProjectScenesVC: ExpandedAddNewSceneFooterViewDelegate, AddNewSceneTakeFooterViewDelegate {
    func addNewSceneTake(forSceneNumber sceneNumber: Int) {
        let videoCameraVC = VideoCameraVC(sceneNumber: sceneNumber)
        let videoFilmingNavigationVC = VideoFilmingNavigationVC(rootViewController: videoCameraVC)
        self.present(videoFilmingNavigationVC, animated: true, completion: nil)
    }
    
    func addNewScene() {
        let newScene = AuditionScene(sceneNumber: auditionScenes.count + 1, sceneTakes: [])
        auditionScenes.append(newScene)
    }
}

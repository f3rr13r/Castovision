//
//  AddProjectScenesVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/3/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

private let sceneHeaderCellId: String = "sceneHeaderCellId"
private let projectSceneTakeCellId: String = "projectSceneCellId"
private let sceneFooterCellId: String = "sceneFooterCellId"
private let extendedSceneFooterCellId: String = "extendedSceneFooterCellId"

class AddProjectScenesVC: UIViewController {
    lazy var projectScenesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(SceneHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sceneHeaderCellId)
        cv.register(SceneTakeCell.self, forCellWithReuseIdentifier: projectSceneTakeCellId)
        cv.register(AddNewSceneTakeFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: sceneFooterCellId)
        cv.register(ExpandedAddNewSceneFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: extendedSceneFooterCellId)
        return cv
    }()
    
    // variables
    var needsScrollingAnimation: Bool = false
    var selfTapeProject: Project = Project() {
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
        configureNavigationBar(withTitle: "Add Scenes", withSearchBar: false)
        addNavigationRightButton()
        anchorSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentSelfTapeProject()
    }
    
    func getCurrentSelfTapeProject() {
        AddSelfTapeService.instance.getUpdatedSelfTapeProject { (updatedProject) in
            self.needsScrollingAnimation = false
            self.selfTapeProject = updatedProject
        }
    }
    
    func updateCollectionViewState() {
        self.projectScenesCollectionView.reloadData()
        self.projectScenesCollectionView.invalidateIntrinsicContentSize()
        if self.needsScrollingAnimation {
            DispatchQueue.main.async {
                self.projectScenesCollectionView.scrollToBottomSection()
            }
        }
    }
    
    func addNavigationRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveSelfTapeProject))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
    }

    func anchorSubviews() {
        self.view.addSubview(projectScenesCollectionView)
        projectScenesCollectionView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: 0.0, right: -horizontalPadding))
    }
    
    @objc func saveSelfTapeProject() {
        
    }
}

// collection view datasource, delegate methods
extension AddProjectScenesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    // number of sections (scenes)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let scenesCount = selfTapeProject.scenes?.count else {
            return 0
        }
        return scenesCount
    }
    
    // number of takes in each scene
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let takesCount = selfTapeProject.scenes?[section].takes?.count else {
            return 0
        }
        return takesCount
    }
    
    // scene cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sceneCell = collectionView.dequeueReusableCell(withReuseIdentifier: projectSceneTakeCellId, for: indexPath) as? SceneTakeCell else {
            return UICollectionViewCell()
        }
        if let sceneTake = selfTapeProject.scenes?[indexPath.section].takes?[indexPath.item] {
            /*-- configure the cell --*/
            sceneCell.configureCell(withTake: sceneTake)
            sceneCell.delegate = self
        }
        
        return sceneCell
    }
    
    // cell selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sceneTake = selfTapeProject.scenes?[indexPath.section].takes?[indexPath.item],
            let sceneNumber = selfTapeProject.scenes?[indexPath.section].sceneNumber {
                // instantiate the takeViewerVC, feed it into the videoFilmingNavigationVC and present it
                let takeViewerVC = TakeViewerVC(sceneNumber: sceneNumber, takeNumber: indexPath.item + 1, take: sceneTake)
                let videoFilmingNavigationVC = VideoFilmingNavigationVC(rootViewController: takeViewerVC)
                self.present(videoFilmingNavigationVC, animated: true, completion: nil)
            
        } else {
            print("Couldn't get the scene take or scene number")
        }
    }
    
    // scene header and footer (including add new scene if expanded)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // kind of 'header'
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sceneHeaderCellId, for: indexPath) as? SceneHeaderView else {
                return UICollectionReusableView()
            }
            guard let sceneNumber = self.selfTapeProject.scenes?[indexPath.section].sceneNumber else {
                return UICollectionReusableView()
            }
            headerView.configureSceneView(withSceneNumber: sceneNumber)
            return headerView
        }
        
        // kind of 'footer'
        if kind == UICollectionView.elementKindSectionFooter {
            guard let scenesCount = selfTapeProject.scenes?.count else {
                return UICollectionReusableView()
            }
            
            if indexPath.section == (scenesCount - 1) {
                // expandable footer
                guard let expandableFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: extendedSceneFooterCellId, for: indexPath) as? ExpandedAddNewSceneFooterView else {
                        return UICollectionReusableView()
                    }
                guard let sceneNumber = self.selfTapeProject.scenes?[indexPath.section].sceneNumber else {
                    return UICollectionReusableView()
                }
                
                expandableFooter.configureSceneFooterView(withSceneNumber: sceneNumber)
                expandableFooter.delegate = self
                return expandableFooter
            } else {
               // default footer
                guard let defaultFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sceneFooterCellId, for: indexPath) as? AddNewSceneTakeFooterView else {
                        return UICollectionReusableView()
                }
                guard let sceneNumber = selfTapeProject.scenes?[indexPath.item].sceneNumber else {
                    return UICollectionReusableView()
                }
                defaultFooter.configureSceneFooterView(withSceneNumber: sceneNumber)
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
        guard let scenesCount = self.selfTapeProject.scenes?.count else {
            return CGSize.zero
        }
        
        if section == (scenesCount - 1) {
            return CGSize(width: expandedAddNewSceneFooterViewWidth, height: expandedAddNewSceneFooterViewHeight)
        } else {
            return CGSize(width: addNewSceneTakeFooterViewWidth, height: addNewSceneTakeFooterViewHeight)
        }
    }
}

extension AddProjectScenesVC: SceneTakeCellDelegate {
    func deleteTake(take: Take) {
        let deleteTakeConfirmationAlert = UIAlertController(title: nil, message: "Do you want to delete this take? This action is permenant, and cannot be undone", preferredStyle: .actionSheet)
        
        let deleteTakeOption = UIAlertAction(title: "Delete Take", style: .default) { (deleteTakeOptionClicked) in
            AddSelfTapeService.instance.deleteSceneTake(withValue: take, completion: { (updatedSelfTapeProject) in
                print(updatedSelfTapeProject)
                self.selfTapeProject = updatedSelfTapeProject
            })
        }
        deleteTakeOption.setValue(UIColor.red, forKey: "titleTextColor")
        
        let cancelOption = UIAlertAction(title: "No Thanks", style: .cancel) { (cancelOptionClicked) in
            deleteTakeConfirmationAlert.dismiss(animated: true, completion: nil)
        }
        cancelOption.setValue(UIColor.black, forKey: "titleTextColor")
        
        deleteTakeConfirmationAlert.addAction(deleteTakeOption)
        deleteTakeConfirmationAlert.addAction(cancelOption)
        
        self.present(deleteTakeConfirmationAlert, animated: true, completion: nil)
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
        AddSelfTapeService.instance.addNewProjectScene { (updatedSelfTapeProject) in
            self.needsScrollingAnimation = true
            self.selfTapeProject = updatedSelfTapeProject
        }
    }
}

//
//  AddProjectScenesVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/3/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

private let projectSceneCellId: String = "projectSceneCellId"
private let addNewSceneFooterId: String = "addNewSceneFooterId"

class AddProjectScenesVC: UIViewController {

    lazy var projectScenesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: screenWidth - (horizontalPadding * 2), height: 10.0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(AddSceneCell.self, forCellWithReuseIdentifier: projectSceneCellId)
        cv.register(AddNewSceneFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: addNewSceneFooterId)
        return cv
    }()
    
    let saveProjectButton = MainActionButton(buttonUseType: .unspecified, buttonTitle: "Save Project", buttonColour: UIColor.red, isDisabled: true)
    
    // variables
    var auditionScenes: [AuditionScene] = [] {
        didSet {
            updateCollectionViewState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureNavigationBar(withTitle: "Add Scenes", withSearchBar: false)
        anchorSubviews()
    }
    
    func updateCollectionViewState() {
        self.projectScenesCollectionView.reloadData()
        self.projectScenesCollectionView.invalidateIntrinsicContentSize()
        DispatchQueue.main.async {
            self.projectScenesCollectionView.scrollToItem(at: IndexPath(item: self.auditionScenes.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func anchorSubviews() {
        self.view.addSubview(saveProjectButton)
        saveProjectButton.anchor(withTopAnchor: nil, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: 50.0, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
        
        self.view.addSubview(projectScenesCollectionView)
        projectScenesCollectionView.anchor(withTopAnchor: self.view.safeAreaLayoutGuide.topAnchor, leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, bottomAnchor: saveProjectButton.topAnchor, trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, centreXAnchor: nil, centreYAnchor: nil, widthAnchor: nil, heightAnchor: nil, padding: .init(top: 0.0, left: horizontalPadding, bottom: -20.0, right: -horizontalPadding))
    }
}

// collection view datasource, delegate and delegate flow layout methods
extension AddProjectScenesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.auditionScenes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sceneCell = collectionView.dequeueReusableCell(withReuseIdentifier: projectSceneCellId, for: indexPath) as? AddSceneCell else {
            return UICollectionViewCell()
        }
        sceneCell.setupSceneCell(withAuditionScene: auditionScenes[indexPath.item])
        sceneCell.delegate = self
        return sceneCell
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: addNewSceneFooterId, for: indexPath) as? AddNewSceneFooterView else {
                return UICollectionReusableView()
            }
            
            footer.delegate = self
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomEdgeInset: CGFloat = self.auditionScenes.count == 0 ? 0.0 : 20.0
        return UIEdgeInsets(top: 20.0, left: 0.0, bottom: bottomEdgeInset, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth - (horizontalPadding * 2), height: 50.0)
    }
}

// scene cell delegate methods
extension AddProjectScenesVC: AddSceneCellDelegate {
    func addNewTakeButtonPressed(insideAuditionScene auditionScene: Int) {
        for i in 0..<self.auditionScenes.count {
            if self.auditionScenes[i].sceneNumber == auditionScene {
                self.auditionScenes[i].sceneTakes.append("")
            }
        }
        updateCollectionViewState()
    }
}

// footer delegate methods
extension AddProjectScenesVC: AddNewSceneFooterViewDelegate {
    func addNewSceneButtonPressed() {
        let auditionScene = AuditionScene(sceneNumber: auditionScenes.count + 1, sceneTakes: [])
        self.auditionScenes.append(auditionScene)
    }
}

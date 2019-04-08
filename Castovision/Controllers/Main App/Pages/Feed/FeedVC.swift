//
//  FeedVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {

    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Feed", withSearchBar: true)
        self.configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        layout.itemSize = CGSize(width: screenWidth - (horizontalPadding * 2), height: 220.0)
        layout.minimumLineSpacing = 12.0
        self.collectionView!.collectionViewLayout = layout
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.init(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
        cell.layer.cornerRadius = 6.0
        return cell
    }
}

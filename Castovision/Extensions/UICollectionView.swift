//
//  UICollectionView.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func scrollToBottomSection() {
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - (addNewSceneViewHeight + 20.0))
        self.setContentOffset(bottomOffset, animated: true)
        self.layoutIfNeeded()
    }
}

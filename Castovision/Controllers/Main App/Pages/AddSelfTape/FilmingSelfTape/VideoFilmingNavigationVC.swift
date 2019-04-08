//
//  VideoFilmingNavigationVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class VideoFilmingNavigationVC: UINavigationController {
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        self.lockNavigtaionDeviceHorizontally()
    }
}

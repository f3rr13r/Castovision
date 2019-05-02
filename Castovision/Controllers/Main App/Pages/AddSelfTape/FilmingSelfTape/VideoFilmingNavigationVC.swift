//
//  VideoFilmingNavigationVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/8/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class VideoFilmingNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.isNavigationBarHidden = true
        self.lockNavigtaionDeviceHorizontally()
    }
}

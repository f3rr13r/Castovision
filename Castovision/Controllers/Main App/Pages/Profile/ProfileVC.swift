//
//  ProfileVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockDeviceVertically()
        self.configureNavigationBar(withTitle: "Profile", withSearchBar: false)
    }
}

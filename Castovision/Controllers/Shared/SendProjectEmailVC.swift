//
//  SendProjectEmailVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class SendProjectEmailVC: UIViewController {

    let label: UILabel = {
        let l = UILabel()
        l.text = "Send Project Email VC"
        l.textAlignment = .center
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(label)
        label.fillSuperview()
    }
}

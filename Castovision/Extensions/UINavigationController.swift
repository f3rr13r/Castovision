//
//  UINavigationController.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /*--
     animate into main app
     --*/
    func navigateIntoMainApp(withAnimation needsAnimation: Bool = false) {
        let mainAppNavigationVC = MainAppNavigationVC()
        
        if needsAnimation {
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromTop
            self.view.layer.add(transition, forKey: kCATransition)
        }
        
        self.pushViewController(mainAppNavigationVC, animated: false)
    }
    
    /*--
     filming camera navigation VC stuff
    --*/
    func lockNavigtaionDeviceHorizontally() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateDeviceOrientation(toOrientation: .landscapeRight)
    }
    
    func lockNavigationDeviceVertically() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateDeviceOrientation(toOrientation: .portrait)
        
    }
    
    func dismissVideoFilmingNavigationVC() {
        self.lockNavigationDeviceVertically()
        self.dismiss(animated: true, completion: nil)
    }
}

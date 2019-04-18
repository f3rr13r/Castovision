//
//  SharedModalService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/18/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class SharedModalService {
    
    static let instance = SharedModalService()
    
    private var _appDelegate: AppDelegate?
    private var _navigationController: UINavigationController?
    
    func initializeSharedModalsMethodsClass(withAppDelegate appDelegate: AppDelegate, andNavigationController navigationController: UINavigationController) {
        _appDelegate = appDelegate
        _navigationController = navigationController
        
        addCustomModalViewsTo(navigationController: _navigationController!)
    }
    
    func addCustomModalViewsTo(navigationController: UINavigationController) {
        let customModalOverlay = CustomModalOverlay()
        navigationController.view.addSubview(customModalOverlay)
        customModalOverlay.fillSuperview()
        
        let customErrorMessageModal = CustomErrorMessageModal()
        navigationController.view.addSubview(customErrorMessageModal)
        customErrorMessageModal.fillSuperview()
    }
    
    /*--
     custom modal
     --*/
    func showCustomOverlayModal(withMessage message: String) {
        if let navigationController = _navigationController {
            for subview in navigationController.view.subviews {
                if let customModalOverlay = subview as? CustomModalOverlay {
                    customModalOverlay.showCustomOverlayModal(withMessage: message)
                }
            }
        }
    }
    
    func hideCustomOverlayModal() {
        if let navigationController = _navigationController {
            for subview in navigationController.view.subviews {
                if let customModalOverlay = subview as? CustomModalOverlay {
                    customModalOverlay.hideCustomOverlayModal()
                }
            }
        }
    }
    
    
    /*--
     error message modal methods -- we will close it from within
     --*/
    func showErrorMessageModal(withErrorMessageConfig errorMessageConfig: CustomErrorMessageConfig) {
        if let navigationController = _navigationController {
            for subview in navigationController.view.subviews {
                if let errorMessageModal = subview as? CustomErrorMessageModal {
                    errorMessageModal.showErrorMessageContainer(withErrorMessageConfig: errorMessageConfig)
                }
            }
        }
    }
    
}

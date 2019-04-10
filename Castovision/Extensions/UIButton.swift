//
//  UIButton.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//
import UIKit

extension UIButton {
    private func actionHandleBlock(action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControl.Event, ForAction action:@escaping () -> Void) {
        self.actionHandleBlock(action: action)
        self.addTarget(self, action: Selector(("triggerActionHandleBlock")), for: control)
    }
}

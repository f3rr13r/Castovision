//
//  NotificationName.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    /*-- app delegate life cycle notifications --*/
    static let appDidReturnToForeground = Notification.Name("appDidReturnToForeground")
    static let appDidReturnToActiveState = Notification.Name("appDidReturnToActiveState")
}

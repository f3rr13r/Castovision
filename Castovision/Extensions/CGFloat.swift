//
//  CGFloat.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/23/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

extension CGFloat {
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

//
//  Sizes.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/29/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

// Screen size for dynamic view sizing
let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height

// safe area padding
let window = UIApplication.shared.keyWindow
let safeAreaTopPadding: CGFloat  = (window?.safeAreaInsets.top)!
let safeAreaBottomPadding: CGFloat  = (window?.safeAreaInsets.bottom)!
let safeAreaScreenWidth: CGFloat = screenWidth
let safeAreaScreenHeight: CGFloat = screenHeight - (safeAreaTopPadding + safeAreaBottomPadding)

// horizontal padding
let horizontalPadding: CGFloat = 20.0

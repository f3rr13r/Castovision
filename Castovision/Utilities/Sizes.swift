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

// specific custom sizing
let projectSceneCellContentWidth: CGFloat = screenWidth - (horizontalPadding * 2.0)
let projectSceneCellContentHeight: CGFloat = projectSceneCellContentWidth * 0.6

let feedCellWidth: CGFloat = projectSceneCellContentWidth
let feedCellThumbnailImageHeight: CGFloat = projectSceneCellContentHeight
let feedCellHeight: CGFloat = projectSceneCellContentHeight + 64.0

let projectSceneCellWidth: CGFloat = projectSceneCellContentWidth
let projectSceneCellHeight: CGFloat = feedCellHeight + 10.0

let sceneHeaderViewWidth: CGFloat = projectSceneCellContentWidth
let sceneHeaderViewHeight: CGFloat = 56.0

let addNewSceneViewWidth: CGFloat = projectSceneCellContentWidth
let addNewSceneViewHeight: CGFloat = 50.0

let addNewSceneFooterViewWidth: CGFloat = addNewSceneViewWidth
let addNewSceneFooterViewHeight: CGFloat = addNewSceneViewHeight

let addNewSceneTakeViewWidth: CGFloat = projectSceneCellContentWidth
let addNewSceneTakeViewHeight: CGFloat = projectSceneCellContentHeight

let addNewSceneTakeFooterViewWidth = addNewSceneTakeViewWidth
let addNewSceneTakeFooterViewHeight = addNewSceneTakeViewHeight

let expandedAddNewSceneFooterViewWidth = projectSceneCellContentWidth
let expandedAddNewSceneFooterViewHeight = addNewSceneTakeViewHeight + 20.0 + addNewSceneViewHeight + 20.0

let trimmerViewWidth: CGFloat = (screenWidth - (safeAreaTopPadding + safeAreaBottomPadding + 10.0))
let trimmerViewHeight: CGFloat = 60.0

//
//  MainAppNavigationVC.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

class MainAppNavigationVC: UITabBarController, AuthServiceDelegate {

    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    let createTapeVC = AddProjectNameVC()
    let profileVC = ProfileVC()
    
    private var _isDeletingUserAccount: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        getUserData()
        configureTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AuthService.instance.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthService.instance.delegate = nil
    }
    
    func isDeletingAccountValueChanged(toValue isDeletingValue: Bool) {
        _isDeletingUserAccount = isDeletingValue
    }
    
    func getUserData() {
        UserService.instance.getCurrentUserDataFromCloudFirestore(isInitializing: true, successCompletion: {
            /*-- don't think we need this here --*/
        }, failedCompletion: {
            if !self._isDeletingUserAccount {
                let errorMessageConfig = CustomErrorMessageConfig(title: "Something went wrong", body: "We were unable to successfully retrieve your account information. Please try again by starting the app")
                SharedModalService.instance.showErrorMessageModal(withErrorMessageConfig: errorMessageConfig)
            }
        }) { (_) in
            /*-- we don't need to do anything here --*/
        }
    }
    
    func configureTabBar() {
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = .red
        self.tabBar.unselectedItemTintColor = UIColor.init(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
        
        let feedNavigationVC = configureNavigationController(withRootViewController: feedVC, tabBarItemTitle: "Feed", tabBarItemImageName: "tab-bar-home-icon", searchBarNeeds: true, andTagValue: 0)
        feedNavigationVC.lockNavigationDeviceVertically()
        
        let createTapeNavigationVC = configureNavigationController(withRootViewController: createTapeVC, tabBarItemTitle: "Add Self-tape", tabBarItemImageName: "tab-bar-camera-icon", searchBarNeeds: false, andTagValue: 1)
        
        let profileNavigationVC = configureNavigationController(withRootViewController: profileVC, tabBarItemTitle: "Profile", tabBarItemImageName: "tab-bar-profile-icon", searchBarNeeds: false, andTagValue: 2)
        profileNavigationVC.lockNavigationDeviceVertically()
        
        let navigationControllersList: [UINavigationController] = [feedNavigationVC, createTapeNavigationVC, profileNavigationVC]
        self.viewControllers = navigationControllersList
    }
    
    func configureNavigationController(withRootViewController rootViewController: UIViewController, tabBarItemTitle: String, tabBarItemImageName: String, searchBarNeeds needsSearchBar: Bool, andTagValue tagValue: Int) -> UINavigationController {
        /*-- instantiate navigation controller with root view controller --*/
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        /*-- set navigation bar specified styles and config --*/
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationBar.backgroundColor = .white
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = false
        
        /*-- set navigation item specified styles and config --*/
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        if needsSearchBar {
            let searchController = UISearchController(searchResultsController: nil)
            navigationController.navigationItem.searchController = searchController
        }
        
        /*-- set tab bar item config --*/
        let tabBarItemImage = UIImage(named: tabBarItemImageName)?.withRenderingMode(.alwaysTemplate)
        navigationController.tabBarItem = UITabBarItem(title: tabBarItemTitle, image: tabBarItemImage, tag: tagValue)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: -2.0, right: 0.0)
        
        /*-- add logo to the navigation controller --*/
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = #imageLiteral(resourceName: "logo")
        navigationController.navigationItem.titleView = logoImageView
        
        
        return navigationController
    }
}

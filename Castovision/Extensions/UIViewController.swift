//
//  UIViewController.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/2/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import MarqueeLabel

extension UIViewController {
    
    func configureNavigationBar(withTitle title: String, withSearchBar needsSearchBar: Bool, withSearchResultsController searchResultsController: UIViewController? = nil) {
        
        /*-- set the title --*/
        self.navigationItem.title = title

        /*-- logo (required) --*/
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = #imageLiteral(resourceName: "logo-padded")
        self.navigationItem.titleView = logoImageView
        
        /*-- search bar (optional -- found only on FeedVC) --*/
        if needsSearchBar {
            guard let searchResultsController = searchResultsController else { return }
            let searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.searchResultsUpdater = searchResultsController as? UISearchResultsUpdating
            searchController.searchBar.sizeToFit()
            searchController.searchBar.returnKeyType = .done
            searchController.searchBar.keyboardAppearance = .dark
            searchController.delegate = self as? UISearchControllerDelegate
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search by project name..."
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    func lockScreenHorizontally() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateDeviceOrientation(toOrientation: .landscapeRight)
    }
    
    func lockDeviceVertically() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateDeviceOrientation(toOrientation: .portrait)

    }
}


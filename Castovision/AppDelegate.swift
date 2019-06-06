//
//  AppDelegate.swift
//  Castovision
//
//  Created by Harry Ferrier on 3/28/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import Firebase
//import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    
    var orientation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupInitialEntryVC()
        configureFirebase()
        //configureStripe()
        return true
    }
    
    func setupInitialEntryVC() {
        // initialize the device window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        // instantiate the loginVC
        let loginVC = LoginVC()
        
        // setup the navigation controller and set the loginVC as the root view controller
        navigationController = UINavigationController(rootViewController: loginVC)
        navigationController?.isNavigationBarHidden = true
        
        // set the initial view controller of the window as the navigation controller, then present it
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // now that we have instantiated the navigation controller, let's add the top level modals to it
        SharedModalService.instance.initializeSharedModalsMethodsClass(withAppDelegate: self, andNavigationController: self.navigationController!)
    }
    
    private func configureFirebase() {
        FirebaseApp.configure()
    }
    
//    private func configureStripe() {
//        let publishableKey = "pk_test_ndhxgsTnjbmaIsVlCZH75jTa00CmeuysrU"
//        STPPaymentConfiguration.shared().publishableKey = publishableKey
//    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientation
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: .appDidReturnToForeground, object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: .appDidReturnToActiveState, object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


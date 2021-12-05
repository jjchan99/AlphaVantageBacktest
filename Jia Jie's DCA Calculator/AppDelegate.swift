//
//  AppDelegate.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 12/9/21.
//

import UIKit
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    let tabBarController = TabViewController()
    let navController = UINavigationController()
    var navCoordinator: NavigationCoordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13, *) {
                      // do only pure app launch stuff, not interface stuff
        } else {
            self.window = UIWindow()
            navCoordinator = NavigationCoordinator(navigationController: navController)
            navCoordinator!.pushSearchViewController()
            let homeViewController = CloudKitViewController()
            tabBarController.viewControllers = [navController, homeViewController]
            
            window!.rootViewController = tabBarController
            window!.makeKeyAndVisible()
        }
        return true
    }
}


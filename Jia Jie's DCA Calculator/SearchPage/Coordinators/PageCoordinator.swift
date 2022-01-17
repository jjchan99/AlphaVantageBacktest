//
//  PageCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 1/12/21.
//

import Foundation
import UIKit
import SwiftUI

class PageCoordinator: NSObject, Coordinator {
    
    var parentCoordinator: NavigationCoordinator?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    //MARK: DEPENDENCIES
    var rawDataDaily: Daily!
    var name: String!
    var type: String!
    var symbol: String!
    var dailyToMonthlyHandler: DailyOHLCHandler?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        parentCoordinator!.rawDataDaily = nil
    }

    func start(name: String, symbol: String, type: String) {
        let vc = CandleViewController(symbol: symbol)
        let coordinator = GraphManager(sorted: rawDataDaily.sorted!)
        vc.coordinator = coordinator
        childCoordinators.append(coordinator)
        navigationController.pushViewController(CandleViewController(symbol: symbol), animated: true)
    }
    
    
    
    
    
}

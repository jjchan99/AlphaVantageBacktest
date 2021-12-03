//
//  PageCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 1/12/21.
//

import Foundation
import UIKit

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
        dailyToMonthlyHandler = .init(daily: rawDataDaily)
        let calculatorCoordinator = CalculatorCoordinator(navigationController: navigationController)
        calculatorCoordinator.parentCoordinator = self
        calculatorCoordinator.populatePickerData()
        childCoordinators.append(calculatorCoordinator)
        
        let calculatorVC = CalculatorViewController(name: name, symbol: symbol, type: type)
        calculatorVC.view.backgroundColor = .white
        calculatorVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setValue(true, forKey: "hidesShadow")
        calculatorVC.coordinator = calculatorCoordinator
        calculatorVC.dateView.datePicker.delegate = calculatorCoordinator
        
        let pageVC = PageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: .none)
        pageVC.coordinator = self
        let financialsVC = FinancialsViewController(symbol: symbol)
        let candleVC = CandleViewController(symbol: symbol)
        
        
        let candleCoordinator = CandleCoordinator(sorted: rawDataDaily.sorted!, daily: rawDataDaily)
        childCoordinators.append(candleCoordinator)
        candleVC.coordinator = candleCoordinator
        candleVC.daily = rawDataDaily
        candleVC.sorted = rawDataDaily.sorted!
        pageVC.setViewControllers([candleVC], direction: .forward, animated: false) { _ in }
        pageVC.collection = [candleVC, calculatorVC, financialsVC]
        navigationController.pushViewController(pageVC, animated: false)
    }
    
    
    
    
    
}

//
//  MainCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/9/21.
//

import Foundation
import UIKit
import Combine

class NavigationCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var childCoordinators: [Coordinator] = []
    
    var RawDCAData: Daily?
    
    var subscribers = Set<AnyCancellable>()
    
    var handler: DailyOHLCHandler?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func pushSearchViewController() {
        navigationController.delegate = self
        let vc = SearchViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushCalculatorVC(name: String, symbol: String, type: String) {
        Log.queue(action: "pushCalculatorVC")
        let child = CalculatorCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.parentCoordinator = self
        handler = DailyOHLCHandler(daily: RawDCAData!)
        child.sortedData = handler!.getMonthlyOHLC()
//        print("Inspect daily for 2021-10-29: \(RawDCAData!.timeSeries!["2021-10-29"]!)")
//        print("Inspect daily for 2021-11-01: \(RawDCAData!.timeSeries!["2021-11-01"]!)")
//        print("Inspect daily for 2021-10-01: \(RawDCAData!.timeSeries!["2021-10-01"]!)")
//        print("Inspect daily for 2021-09-01: \(RawDCAData!.timeSeries!["2021-09-01"]!)")
//        print("Inspect daily for 2021-08-02: \(RawDCAData!.timeSeries!["2021-08-02"]!)")
        child.populatePickerData()
        child.childCoordinators = self.childCoordinators
        child.start(name: name, symbol: symbol, type: type)
    }
    
    func childDidExit(_ child: Coordinator?) {
        let initialCount = childCoordinators.count
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                Log.queue(action: "Child successfully exited")
                break
            } else {
                fatalError()
            }
        }
        
        let oneItemRemoved = initialCount - 1 == childCoordinators.count
        guard oneItemRemoved else { fatalError() }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        
        //MARK: CHECK IF PUSHED
        if navigationController.viewControllers.contains(fromViewController) { return }
        
        //MARK: VIEWCONTROLLER WAS POPPED
        if let vc = fromViewController as? PageViewController {
            let calculatorVC = vc.collection![0] as! CalculatorViewController
            childDidExit(calculatorVC.coordinator)
        } else {
            fatalError()
        }
    }
    
}

//
//  CalculatorCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/9/21.
//

import Foundation
import UIKit
import Combine

class CalculatorCoordinator: NSObject, Coordinator {
    
    weak var parentCoordinator: NavigationCoordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    //MARK: PICKER DATA AND DISPLAY
    var yearArray: [String] = []
    var monthArray: [ArraySlice<String>] = []
    @Published var selectedDate: String = ""
    
    lazy var conditionalNumberOfMonths: Int = {
        return self.monthArray[0].count
    }()
    
    
    //MARK: CALCULATOR DEPEDENCIES
    var sortedData: [OHLC]?
    var initialInvestment: Double = 0
    var monthlyInvestment: Double = 0
    var monthIndex: Int?
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        parentCoordinator!.RawDCAData = nil
    }
    
    func start(name: String, symbol: String, type: String) {
        let vc = CalculatorViewController(name: name, symbol: symbol, type: type)
        vc.view.backgroundColor = .white
        //vc.view.layer.insertSublayer(ColorFactory.gradient(vc.view), at: 0)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setValue(true, forKey: "hidesShadow")
        vc.coordinator = self
        vc.dateView.datePicker.delegate = self
        
        let pc = PageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: .none)
        let fc = FinancialsViewController(symbol: symbol)
        let cc = CandleViewController(symbol: symbol)
        cc.daily = parentCoordinator!.RawDCAData!
        cc.sorted = cc.daily!.timeSeries!.sorted { $0.key > $1.key }
        pc.setViewControllers([vc], direction: .forward, animated: false) { _ in }
        pc.collection = [vc, fc, cc]
        navigationController.pushViewController(pc, animated: false)
    }
    
    func populatePickerData() {
        let handler = parentCoordinator!.handler!
        let value = handler.returnPickerData(self.sortedData!)
        self.yearArray = value.yearArray
        self.monthArray = value.monthArray
    }
    
    func getDCAResult() -> (result: [DCAResult], meta: DCAResultMeta) {
        let calculator = DCACalculator(initialInvestment: initialInvestment, monthlyInvestment: monthlyInvestment, sortedData: sortedData!, monthIndex: monthIndex!)
        
        let output = calculator.calculate()
        print("DCA result: \(output.result)")
        
        return (output.result, output.meta)
    }
    
    func publishMonthIndex(monthIndexDidPublish: @autoclosure () -> ()) {
        monthIndexDidPublish()
    }
}

extension CalculatorCoordinator: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.yearArray.count
        } else {
            return conditionalNumberOfMonths
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        switch component {
         case 0:
            return self.yearArray[row]
         case 1:
            if self.yearArray.count > 1 && pickerView.selectedRow(inComponent: 0) == self.yearArray.count - 1 {
                guard self.monthArray.last!.count > row else { return nil }
                let monthTitle = getMonth(row: self.monthArray.last!.count - 1 - row, inverse: true)
            
            return monthTitle
            } else if self.yearArray.count == 1 {
            let monthTitle = monthArray[0][row]
           
            return monthTitle
            } else {
            return getMonth(row: row, inverse: false)
            }
            
        default:
            return nil
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            conditionalNumberOfMonths = self.monthArray[row].count
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: false)
        case 1:
            do{}
        default:
            return
        }
        
        updateUI: do {
    
        self.monthIndex = 0
        
        for idx in 0..<pickerView.selectedRow(inComponent: 0) {
            self.monthIndex! += (self.monthArray[idx].count)
        }
       
        self.monthIndex! += self.monthArray[pickerView.selectedRow(inComponent: 0)].count - 1 - pickerView.selectedRow(inComponent: 1)
        
        let selectedYear = self.yearArray[pickerView.selectedRow(inComponent: 0)]
        
        let triedToLoadWhileScrolling: Bool = self.yearArray.count > 1 && pickerView.selectedRow(inComponent: 0) == self.yearArray.count - 1 ? self.monthArray.last!.count < row : false
        guard !triedToLoadWhileScrolling else {
            let selectedMonth = getMonth(row: 11 - (self.monthArray.last!.count - 1), inverse: false)
            self.selectedDate = "\(selectedMonth)\n\(selectedYear)"
            return }
        let inverse: Bool = self.yearArray.count > 1 && pickerView.selectedRow(inComponent: 0) == self.yearArray.count - 1 ? true : false
        let row = self.yearArray.count > 1 && pickerView.selectedRow(inComponent: 0) == self.yearArray.count - 1 ? self.monthArray.last!.count - 1 - pickerView.selectedRow(inComponent: 1) : pickerView.selectedRow(inComponent: 1)
            let selectedMonth = self.yearArray.count > 1 ? getMonth(row: row, inverse: inverse) : self.monthArray[0][row]
        self.selectedDate = "\(selectedMonth)\n\(selectedYear)"
        }
    }
}

extension CalculatorCoordinator {

//MARK: HELPER FUNCTIONS
private func getMonth(row: Int, inverse: Bool) -> String {
let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let idx = inverse ? 11-row : row
    return monthArray[idx]
}
}

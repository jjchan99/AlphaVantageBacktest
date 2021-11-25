//
//  FinancialModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import Foundation

struct FinancialModel {
    
    let balanceSheet: BalanceSheet
    let incomeStatement: IncomeStatement
    let earnings: Earnings?
    
    init(balanceSheet: BalanceSheet, incomeStatement: IncomeStatement, earnings: Earnings?) {
        self.balanceSheet = balanceSheet
        self.incomeStatement = incomeStatement
        self.earnings = earnings
    }
    
    func getROE() -> (ROE: [Double], stamp: [String]) {
        let bs = balanceSheet.annualReports
        let pl = incomeStatement.annualReports
        var array: [Double] = []
        var timeArray: [String] = []
        for idx in 0..<bs.count {
            guard bs[idx].fiscalDateEnding == pl[idx].fiscalDateEnding else { fatalError() }
            let equity = Double(bs[idx].totalShareholderEquity)!
            let ni = Double(pl[idx].netIncome)!
            let roe = ni / equity
            let stamp = bs[idx].fiscalDateEnding
            array.append(roe)
            timeArray.append(stamp)
        }
        return (array, timeArray)
    }
    
    func getROA() -> (ROA: [Double], stamp: [String]) {
        let bs = balanceSheet.annualReports
        let pl = incomeStatement.annualReports
        var array: [Double] = []
        var timeArray: [String] = []
        for idx in 0..<bs.count {
            guard bs[idx].fiscalDateEnding == pl[idx].fiscalDateEnding else { fatalError() }
            let totalAssets = Double(bs[idx].totalAssets)!
            let ni = Double(pl[idx].netIncome)!
            let roa = ni / totalAssets
            let stamp = bs[idx].fiscalDateEnding
            array.append(roa)
            timeArray.append(stamp)
        }
        return (array, timeArray)
    }
    
    func getDebtToEquity() -> (debtToEquity: [Double], stamp: [String]) {
        let bs = balanceSheet.annualReports
        var array: [Double] = []
        var timeArray: [String] = []
        for idx in 0..<bs.count {
            let totalLiabilities = Double(bs[idx].totalLiabilities)!
            let totalEquity = Double(bs[idx].totalShareholderEquity)!
            let debtToEquity = totalLiabilities / totalEquity
            let stamp = bs[idx].fiscalDateEnding
            array.append(debtToEquity)
            timeArray.append(stamp)
        }
        return (array, timeArray)
    }
    
    func getWorkingCapitalRatio() -> (workingCapital: [Double], stamp: [String]) {
        let bs = balanceSheet.annualReports
        var array: [Double] = []
        var timeArray: [String] = []
        for idx in 0..<bs.count {
            let currentAssets = Double(bs[idx].totalCurrentAssets)!
            let currentLiabilities = Double(bs[idx].totalCurrentLiabilities)!
            let workingCapitalRatio = currentAssets / currentLiabilities
            let stamp = bs[idx].fiscalDateEnding
            array.append(workingCapitalRatio)
            timeArray.append(stamp)
        }
        return (array, timeArray)
    }
    
    
    
    func dupont() -> (dupont: [Dupont], stamp: [String]) {
        let bs = balanceSheet.annualReports
        let pl = incomeStatement.annualReports
        var array: [Dupont] = []
        var timeArray: [String] = []
        for idx in 0..<bs.count {
            guard bs[idx].fiscalDateEnding == pl[idx].fiscalDateEnding else { fatalError() }
            let stamp = bs[idx].fiscalDateEnding
            let netIncome = Double(pl[idx].netIncome)!
            let sales = Double(pl[idx].totalRevenue)!
            let totalAssets = Double(bs[idx].totalAssets)!
            let totalEquity = Double(bs[idx].totalShareholderEquity)!
            let dupont = Dupont(netIncome: netIncome, sales: sales, totalAssets: totalAssets, totalEquity: totalEquity)
            array.append(dupont)
            timeArray.append(stamp)
        }
        return (array, timeArray)
    }
  
    internal struct Dupont {
        
        internal init(netIncome: Double, sales: Double, totalAssets: Double, totalEquity: Double) {
            self.netIncome = netIncome
            self.sales = sales
            self.totalAssets = totalAssets
            self.totalEquity = totalEquity
        }
        
        let netIncome: Double
        let sales: Double
        let totalAssets: Double
        let totalEquity: Double
        
        var profitMargin: Double {
            return netIncome / sales
        }
        
        var totalAssetTurnover: Double {
            return sales / totalAssets
        }
        
        var equityMultiplier: Double {
            return totalAssets / totalEquity
        }
        
        var roe: Double {
            return profitMargin * totalAssetTurnover * equityMultiplier
        }
        
    }
    
    
    
    
}

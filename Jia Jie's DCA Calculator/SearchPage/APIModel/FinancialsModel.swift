//
//  FinancialsModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import Foundation

struct IncomeStatement: Codable {
    var symbol: String
    var annualReports: [Data]
    
    internal struct Data: Codable {
        var fiscalDateEnding: String
        var reportedCurrency: String
        var grossProfit: String
        var totalRevenue: String
        var costOfRevenue: String
        var costofGoodsAndServicesSold: String
        var operatingIncome: String
        var sellingGeneralAndAdministrative: String
        var researchAndDevelopment: String
        var operatingExpenses: String
        var investmentIncomeNet: String
        var netInterestIncome: String
        var interestIncome: String
        var interestExpense: String
        var nonInterestIncome: String
        var otherNonOperatingIncome: String
        var depreciation: String
        var depreciationAndAmortization: String
        var incomeBeforeTax: String
        var incomeTaxExpense: String
        var interestAndDebtExpense: String
        var netIncomeFromContinuingOperations: String
        var comprehensiveIncomeNetOfTax: String
        var ebit: String
        var ebitda: String
        var netIncome: String
    }
}

struct BalanceSheet: Codable {
    var symbol: String
    var annualReports: [Data]
    
    internal struct Data: Codable {
        var fiscalDateEnding: String
        var reportedCurrency: String
        var totalAssets: String
        var totalCurrentAssets: String
        var cashAndCashEquivalentsAtCarryingValue: String
        var cashAndShortTermInvestments: String
        var inventory: String
        var currentNetReceivables: String
        var totalNonCurrentAssets: String
        var propertyPlantEquipment: String
        var accumulatedDepreciationAmortizationPPE: String
        var intangibleAssets: String
        var intangibleAssetsExcludingGoodwill: String
        var goodwill: String
        var investments: String
        var longTermInvestments: String
        var shortTermInvestments: String
        var otherCurrentAssets: String
        var otherNonCurrrentAssets: String
        var totalLiabilities: String
        var totalCurrentLiabilities: String
        var currentAccountsPayable: String
        var deferredRevenue: String
        var currentDebt: String
        var shortTermDebt: String
        var totalNonCurrentLiabilities: String
        var capitalLeaseObligations: String
        var longTermDebt: String
        var currentLongTermDebt: String
        var longTermDebtNoncurrent: String
        var shortLongTermDebtTotal: String
        var otherCurrentLiabilities: String
        var otherNonCurrentLiabilities: String
        var totalShareholderEquity: String
        var treasuryStock: String
        var retainedEarnings: String
        var commonStock: String
        var commonStockSharesOutstanding: String
    }
}

struct Earnings: Codable {
    var symbol: String
    var annualEarnings: [annualEarningsData]
    var quarterlyEarnings: [quarterlyEarningsData]
    
    internal struct annualEarningsData: Codable {
        var fiscalDateEnding: String
        var reportedEPS: String
    }
    
    internal struct quarterlyEarningsData: Codable {
        var fiscalDateEnding: String
        var reportedDate: String
        var reportedEPS: String
        var estimatedEPS: String
        var surprise: String
        var surprisePercentage: String
    }
}

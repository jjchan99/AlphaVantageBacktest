//
//  FinancialsAPI.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import Foundation
import Combine

struct FinancialsAPI {
    
    enum FinancialsType {
        case BalanceSheet, IncomeStatement, Earnings
    }
    
    private enum APIError: Error {
        case percentEncoding
        case failedRequest
        case invalidUrl
    }
    
    var BSkey: String {
        return BSkeys.randomElement() ?? ""
    }
    
    var PLkey: String {
        return PLkeys.randomElement() ?? ""
    }
    
    var earningsKey: String {
        return earningsKeys.randomElement() ?? ""
    }
    
    private func getUrl(symbolQuery: String, type: FinancialsType) -> URL? {
        switch type {
        case .BalanceSheet:
            return URL(string: "https://www.alphavantage.co/query?function=BALANCE_SHEET&symbol=\(symbolQuery)&apikey=\(BSkey)")
        case .IncomeStatement:
            return URL(string: "https://www.alphavantage.co/query?function=INCOME_STATEMENT&symbol=\(symbolQuery)&apikey=\(PLkey)")
        case .Earnings:
            return URL(string: "https://www.alphavantage.co/query?function=EARNINGS&symbol=\(symbolQuery)&apikey=\(earningsKey)")
        }
    }
    
    private let BSkeys = ["CWE7R1C8NCO2YOLG", "R3OOQ9KJD11QU8OG"]
    private let PLkeys = ["AGJ57OWXWZTMCEMF", "AYJV1IWXC7UJ24BF"]
    private let earningsKeys = ["MG2UVIM7NF3RBQB3", "1DBKTSCFBF85FZ3Q"]
    
    
    func fetchBalanceSheetPublisher(_ symbolQuery: String) -> AnyPublisher<BalanceSheet, Error> {
        
        guard let symbolQuery = symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
    
        let url = getUrl(symbolQuery: symbolQuery, type: .BalanceSheet)
        
        if let url = url {
            
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                return publisher
                    .tryMap { value in
                        return value.0
                    }
                    .decode(type: BalanceSheet.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchIncomeStatementPublisher(_ symbolQuery: String) -> AnyPublisher<IncomeStatement, Error> {
        
        guard let symbolQuery = symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
    
        let url = getUrl(symbolQuery: symbolQuery, type: .IncomeStatement)
        
        if let url = url {
            
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                return publisher
                    .tryMap { value in
                        return value.0
                    }
                    .decode(type: IncomeStatement.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchEarningsPublisher(_ symbolQuery: String) -> AnyPublisher<Earnings, Error> {
        
        guard let symbolQuery = symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
    
        let url = getUrl(symbolQuery: symbolQuery, type: .IncomeStatement)
        
        if let url = url {
            
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                return publisher
                    .tryMap { value in
                        return value.0
                    }
                    .decode(type: Earnings.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
}


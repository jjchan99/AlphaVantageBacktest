//
//  CloudViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 6/12/21.
//

import Foundation
import SwiftUI
import Combine

class CloudViewModel: ObservableObject {
    var userName: String = ""
    var permission: Bool = false
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    var subscribers = Set<AnyCancellable>()
    
    let bot: TradeBot = .init(budget: 69, account: .init(cash: 69, accumulatedShares: 0), conditions: [], cashBuyPercentage: 1, sharesSellPercentage: 0.69)!
    let condition: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.69), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: nil)!
    
    @Published var fetched: [TradeBot]? { didSet
    {  Log.queue(action: "Fetch success")
        print("\(fetched)")
    }
    }
    
    var fetchedConditions: [EvaluationCondition]? { didSet
    { Log.queue(action: "Fetched conditions successfully")
        print("here are the conditions: \(fetchedConditions)")
    }
    }
    
    func upload(bot: TradeBot) {
        CloudKitUtility.add(item: bot) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                Log.queue(action: "Upload success: \(result)")
            }
        }
    }
    
    func upload(condition: EvaluationCondition) {
        CloudKitUtility.add(item: condition) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                Log.queue(action: "Upload success: \(result)")
            }
        }
    }
    
    func fetch() {
        let predicate: NSPredicate = .init(value: true)
        CloudKitUtility.fetch(predicate: predicate, recordType: "TradeBot")
            .sink { success in
                switch success {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                DispatchQueue.main.async {
                fetched = value
                }
            }
            .store(in: &subscribers)

    }
    
    func fetchCondition() {
        let predicate: NSPredicate = .init(value: true)
        CloudKitUtility.fetch(predicate: predicate, recordType: "EvaluationCondition")
            .sink { success in
                switch success {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                fetchedConditions = value
            }
            .store(in: &subscribers)
    }
    
    func test(parent: TradeBot) {
        let anotherOne: EvaluationCondition = .init(technicalIndicator: .RSI(period: 12, value: 0.55), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: nil)!
        CloudKitUtility.add(item: parent) { [unowned self] result in
            CloudKitUtility.saveArray(array: [condition, anotherOne], for: parent) { success in
                Log.queue(action: "Louis Van Gaals' army: \(success)")
            }
        }
    }

    
    
    func fetchChildren(parent: TradeBot) {
        CloudKitUtility.fetchChildren(parent: parent, children: "EvaluationCondition")
            .sink { value in
                switch value {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [unowned self] value in
                self.fetchedConditions = value
            }
            .store(in: &subscribers)

    }
    

}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
        Text("username: \(viewModel.userName)")
        Text("permission: \(viewModel.permission ? "true" : "false")")
            Text("is signed into icloud: \(viewModel.isSignedInToiCloud ? "true" : "false")")
        Text("error: \(viewModel.error)")
                Button(action: {
                    viewModel.test(parent: viewModel.bot)
                }, label: {
                    Text("Click me")
                })
                Button(action: {
                    viewModel.fetch()
                }, label: {
                    Text("Get the Parent.")
                })
                Button(action: {
                    viewModel.fetchChildren(parent: viewModel.fetched![0])
                }, label: {
                    Text("Get the CHILLLREN")
                })
            }
        }
        .frame(width: viewModel.width, height: viewModel.height)
    }
}

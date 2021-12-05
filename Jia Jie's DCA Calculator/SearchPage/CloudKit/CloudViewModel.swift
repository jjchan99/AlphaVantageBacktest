//
//  CloudViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 6/12/21.
//

import Foundation
import SwiftUI

class CloudViewModel: ObservableObject {
    var userName: String = ""
    var permission: Bool = false
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    
    let bot: TradeBot = .init(budget: 69, account: .init(cash: 69, accumulatedShares: 0), conditions: [], cashBuyPercentage: 1, sharesSellPercentage: 0.69)!
    var fetched: [TradeBot]?
    
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
                fetched = value
            }

    }
    

}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    var body: some View {
        ZStack {
            VStack {
        Text("username: \(viewModel.userName)")
        Text("permission: \(viewModel.permission ? "true" : "false")")
            Text("is signed into icloud: \(viewModel.isSignedInToiCloud ? "true" : "false")")
        Text("error: \(viewModel.error)")
                Button(action: {
                    viewModel.upload(bot: viewModel.bot)
                }, label: {
                    Text("Upload a bot")
                })
                List {
                    if viewModel.fetched != nil {
                        ForEach(0..<viewModel.fetched!.count) { idx in
                            Text("Budget: \(viewModel.fetched![idx].budget)")
                            Text("Cash: \(viewModel.fetched![idx].account.cash)")
                            Text("Accumulated shares: \(viewModel.fetched![idx].account.accumulatedShares)")
                    }
                }
                }
            }
        }
        .frame(width: viewModel.width, height: viewModel.height)
    }
}

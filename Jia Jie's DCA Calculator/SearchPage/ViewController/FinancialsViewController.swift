//
//  FinancialsViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import UIKit
import Combine
import SwiftUI

class FinancialsViewController: UIViewController {
    
    let symbol: String
    var subscribers = Set<AnyCancellable>()
    let viewModel = FinancialsViewModel()
    var roeView: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        fetchBS()
//        fetchIncomeStatement()
//        fetchEarnings()
        roeView = UIHostingController(rootView: AnyView(ROEView().environmentObject(viewModel)))
        view.addSubview(roeView!.view)
        roeView!.view.activateConstraints(reference: view, constraints: [.top(), .leading()], identifier: "roeView")
    }
    
    func fetchBS() {
        FinancialsAPI().fetchBalanceSheetPublisher(symbol)
            .sink { value in
                switch value {
                case let .failure(error):
                    print("BS Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                viewModel.bs = value
            }
            .store(in: &subscribers)
    }
    
    func fetchEarnings() {
        FinancialsAPI().fetchEarningsPublisher(symbol)
            .sink { value in
                switch value {
                case let .failure(error):
                    print("Earnings error: \(error.localizedDescription)")
                case .finished:
                    Log.queue(action: "fetchEarnings success")
                    break
                }
            } receiveValue: { [unowned self] value in
                viewModel.earnings = value
            }
            .store(in: &subscribers)
    }
    
    func fetchIncomeStatement() {
        FinancialsAPI().fetchIncomeStatementPublisher(symbol)
            .sink { value in
                switch value {
                case let .failure(error):
                    print("P/L error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                viewModel.pl = value
            }
            .store(in: &subscribers)
            
    }
    
    init(symbol: String) {
        self.symbol = symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

////
////  BotViewController.swift
////  Jia Jie's DCA Calculator
////
////  Created by Jia Jie Chan on 3/12/21.
////
//
//import Foundation
//import UIKit
//
//class BotCoordinator: NSObject, Coordinator {
//
//    let sorted: [OHLC]
//    let symbol: String
//
//
////    var bot: TradeBot? { didSet {
////        let todaysDate = Date().string(format: "yyyy-MM-dd")
////        if sorted.last!.stamp != todaysDate {
////
////        } else {
////            bot?.database.
////        }
////    }
//
//
//}
//
//struct OHLCFactory {
//
//    let symbol: String
//
//    init(symbol: String) {
//        self.symbol = symbol
//    }
//
//    func fetchDaily(completion: @escaping (Daily) -> Void) {
//        CandleAPI().fetchDaily(symbol)
//            .sink { value in
//                switch value {
//                case let .failure(error):
//                    print(error)
//                case .finished:
//                    break
//                }
//            } receiveValue: { value in
//                if value.timeSeries == nil {
//                    print(value.note)
//                } else {
//                  completion(value)
//                }
//            }
//    }
//
//    func fetchIntraday() {
//
//    }
//
//
//    func generateIndicators(indicator: TechnicalIndicators) {
//        switch indicator {
//        case .movingAverage(period: <#T##Int#>):
//
//        case .RSI(value: <#T##Double#>):
//
//        case .bollingerBands(lowerBounds: <#T##Double#>, upperBounds: <#T##Double#>):
//
//
//        }
//    }
//
//}
//
//class BotViewController: UIViewController {
//
//    var viewModel: BotViewModel
//    var coordinator: BotCoordinator
//
//    override func viewDidLoad() {
//        viewModel.createBotButtonTapped = { [unowned self] in
//            coordinator.bot = viewModel.createBot()
//        }
//    }
//
//
//
//}

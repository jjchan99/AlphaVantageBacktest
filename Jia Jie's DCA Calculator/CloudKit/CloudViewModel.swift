//
//  CloudViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 6/12/21.
//

import Foundation
import SwiftUI
import Combine

fileprivate func sort(for tb: TradeBot) -> TradeBot {
    var tb = tb
    tb.conditions = tb.conditions.sorted { arg1, arg2 in
        arg1.enterOrExit == .enter ? true : false
    }
    return tb
}

class CloudViewModel: ObservableObject {
    var subscribers = Set<AnyCancellable>()
    @Published var retrievals: [TradeBot] = []
//    {
//        didSet {
//            if retrievals.count > oldValue.count {
//                retrievals[retrievals.count - 1] = sort(for: retrievals.last!)
//            }
//        }
//    }
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    @Published var daily: Daily?
    @Published var tb: TradeBot?
}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    @ViewBuilder func footer(index: Int, idx: Int) -> some View {
                    ForEach(0..<viewModel.retrievals[index].conditions[idx].andCondition.count, id: \.self) { indx in
                    
                    let andCond = viewModel.retrievals[index].conditions[idx].andCondition[indx]
                    let keyTitle = InputViewModel.keyTitle(condition: andCond)
                    let lastIndex: Bool = idx == viewModel.retrievals[index].conditions.count - 1
                    let lastEntryIndex: Bool = viewModel.retrievals[index].conditions[idx].enterOrExit == .enter && viewModel.retrievals[index].conditions[idx + 1].enterOrExit == .exit
                    let andCount = viewModel.retrievals[index].conditions[idx].andCondition.count
                    
                    lastEntryIndex || lastIndex ?
                        AnyView(
                            Text("AND all conditions met:")
                        )
                        : AnyView(EmptyView())
                        
                    lastEntryIndex || lastIndex ?
                        AnyView(
                           Text(keyTitle)
                        )
                    : AnyView(EmptyView())
                            
                        
                       
                    }
    }
    
    var stratView: some View {
        ForEach(0..<viewModel.retrievals.count, id: \.self) { index in
        Section {
            ForEach(0..<viewModel.retrievals[index].conditions.count, id: \.self) { idx in
             
             let firstExitIndex: Bool = viewModel.retrievals[index].conditions[idx].enterOrExit == .exit &&
             viewModel.retrievals[index].conditions[idx - 1].enterOrExit == .enter
             
             
            idx == 0 ?
            AnyView(Text("Enter under one of the following:"))
             :
             firstExitIndex ?
             AnyView(Text("Exit under one of the following:"))
             : AnyView(EmptyView())
             
             
            let condition = viewModel.retrievals[index].conditions[idx]
            let keyTitle = InputViewModel.keyTitle(condition: condition)
                        
            Text(keyTitle)
            
            footer(index: index, idx: idx)
                }
            }
        header: {
            HStack {
            Text("Strategy \(index + 1)")
                Spacer()
                Button {
                    BotAccountCoordinator.delete(tb: viewModel.retrievals[index]) {
                        viewModel.retrievals.remove(at: index)
                    }
                } label: {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    Text("Delete")
                        .foregroundColor(.red)
                    }
                }

            }
        }
        }
        
    }
    
    var body: some View {
                NavigationView {
                    List {
                     stratView
                    }
                }
                .navigationTitle("My strategy")
                .onAppear {
                    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
                    UITableView.appearance().backgroundColor = #colorLiteral(red: 0.9586906126, green: 0.9586906126, blue: 0.9586906126, alpha: 1)
                    
                    BotAccountCoordinator.fetchAllBots()
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
            
                            } receiveValue: { tb in
                                viewModel.retrievals.removeAll()
                                let tb = tb.map { each in
                                    sort(for: each)
                                }
                                viewModel.retrievals.append(contentsOf: tb)
                            }
                            .store(in: &viewModel.subscribers)
                }
            }
        }
       


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
    var subscribers = Set<AnyCancellable>()
    @Published var retrievals: TradeBot?
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    @Published var daily: Daily?
    @Published var tb: TradeBot?
}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    var body: some View {
//        ZStack {
//            VStack(spacing: 20) {
//                Button(action: {
//                    BotAccountCoordinator.upload(tb: BotAccountCoordinator.specimen()) {
//                        Log.queue(action: "Upload success")
//                    }
//                }, label: {
//                    Text("Click me")
//                })
//                Button(action: {
//                    BotAccountCoordinator.fetchBot()
//                        .receive(on: DispatchQueue.main)
//                        .sink { _ in
//
//                        } receiveValue: { tb in
//                            viewModel.retrievals = tb
//                        }
//                        .store(in: &viewModel.subscribers)
//
//                }, label: {
//                    Text("Get the Parent.")
//                })
//                Button {
//                    if viewModel.retrievals != nil {
//                        BotAccountCoordinator.delete(tb: viewModel.retrievals!) {
//                        print("Delete success")
//                    }
//                    }
//                } label: {
//                    Text("Delete the tb")
//                }
                NavigationView {
                Form {
                    Section {
                        if viewModel.retrievals != nil {
                            Text("Something came up.")
                        }
                    } header: {
                     Text("Suarez")
                    }
                }
                .navigationTitle("My strategy")
                }
                .onAppear {
                    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
                    UITableView.appearance().backgroundColor = #colorLiteral(red: 0.9586906126, green: 0.9586906126, blue: 0.9586906126, alpha: 1)
                    
                    BotAccountCoordinator.fetchBot()
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
            
                            } receiveValue: { tb in
                                viewModel.retrievals = tb
                            }
                            .store(in: &viewModel.subscribers)
                }
            }
        }
       

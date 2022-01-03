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
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    @Published var daily: Daily?
    @Published var tb: TradeBot?
}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button(action: {
                    BotAccountCoordinator.upload() {
                        Log.queue(action: "Upload success")
                    }
                }, label: {
                    Text("Click me")
                })
                Button(action: {
                    BotAccountCoordinator.fetchBot()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            
                        } receiveValue: { tb in
                            
                        }
                        .store(in: &viewModel.subscribers)

                }, label: {
                    Text("Get the Parent.")
                })
            }
        }
        .frame(width: viewModel.width, height: viewModel.height)
    }
}

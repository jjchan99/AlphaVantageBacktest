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
    var subscribers = Set<AnyCancellable>()
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(390).wScaled()
    
    let coordinator = BotAccountCoordinator()
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
                    viewModel.coordinator.upload()
                }, label: {
                    Text("Click me")
                })
                Button(action: {
                    viewModel.coordinator.fetchBot()
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

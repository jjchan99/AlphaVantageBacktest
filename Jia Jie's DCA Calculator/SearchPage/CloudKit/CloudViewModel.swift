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
                }, label: {
                    Text("Get the Parent.")
                })
                Button(action: {
                    viewModel.coordinator.fetchConditions()
                }, label: {
                    Text("Get the CHILLLREN")
                })
                Button(action: {
                    viewModel.coordinator.fetchAndConditions()
                }, label: {
                    Text("Get the AND COnditionz")
                })
                Button(action: {
                    viewModel.coordinator.inspect()
                }, label: {
                    Text("Inspect >:)")
                })
            }
        }
        .frame(width: viewModel.width, height: viewModel.height)
    }
}

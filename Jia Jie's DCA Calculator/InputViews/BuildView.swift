//
//  BuildView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/4/22.
//

import SwiftUI

struct BuildView: View {
    @EnvironmentObject var vm: InputViewModel
    @Binding var factoryReset: Bool
    @State var buildButtonDidClick: Bool = false
    
    init(factoryReset: Binding<Bool>) {
        self._factoryReset = factoryReset
    }
    
    var buildView: some View {
        return VStack {
            Section {
            ForEach(Array(vm.repo.entryOr.values), id: \.self) { condition in
                Text(InputViewModel.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.entryOr.isEmpty {
                    Text("Entry OR conditions")
                }
            }
            
            Section {
            ForEach(Array(vm.repo.entryAnd.values), id: \.self) { condition in
                Text(InputViewModel.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.entryAnd.isEmpty {
                    Text("Entry AND conditions")
                }
            }
            
            Section {
            ForEach(Array(vm.repo.exitOr.values), id: \.self) { condition in
                Text(InputViewModel.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.exitOr.isEmpty {
                    Text("Exit OR conditions")
                }
            }
            
            Section {
            ForEach(Array(vm.repo.exitAnd.values), id: \.self) { condition in
                Text(InputViewModel.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.exitAnd.isEmpty {
                    Text("Exit AND conditions")
                }
            }
            Button {
                vm.build {
                    Log.queue(action: "Upload success")
                    self.factoryReset = false
                }
                buildButtonDidClick = true
            } label: {
                Text("Build")
            }

        }
        Spacer()
    }
    
    var progressView: some View {
        return ProgressView()
    }
    
    var body: some View {
       !buildButtonDidClick ?
        AnyView(buildView)
        : AnyView(progressView)
    }
}

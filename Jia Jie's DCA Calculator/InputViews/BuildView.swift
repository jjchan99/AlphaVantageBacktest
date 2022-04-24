//
//  BuildView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/4/22.
//

import SwiftUI

struct BuildView: View {
    @EnvironmentObject var vm: InputViewModel
    
    var body: some View {
        VStack {
            Section {
            ForEach(Array(vm.repo.entryTriggers.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.entryTriggers.isEmpty {
                    Text("Entry AND conditions")
                }
            }
            
           
            
            Section {
            ForEach(Array(vm.repo.entryTrade.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.entryTrade.isEmpty {
                    Text("Entry OR conditions")
                }
            }
            
            Section {
            ForEach(Array(vm.repo.exitTriggers.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.exitTriggers.isEmpty {
                    Text("Exit AND conditions")
                }
            }
            
           
            
            Section {
            ForEach(Array(vm.repo.exitTrade.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            } header: {
                if !vm.repo.exitTrade.isEmpty {
                    Text("Exit OR conditions")
                }
            }
            Button {
                vm.build {
                    Log.queue(action: "Upload success")
                }
            } label: {
                Text("Build")
            }

        }
        Spacer()
      

    }
}

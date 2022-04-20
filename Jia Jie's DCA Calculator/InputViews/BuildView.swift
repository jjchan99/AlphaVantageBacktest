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
            ForEach(Array(vm.repo.entryTriggers.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            ForEach(Array(vm.repo.entryTrade.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            ForEach(Array(vm.repo.exitTriggers.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
            ForEach(Array(vm.repo.exitTrade.values), id: \.self) { condition in
                Text(vm.keyTitle(condition: condition))
                    .font(.caption)
            }
        }
    }
}

//
//  CloudViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 6/12/21.
//

import Foundation
import SwiftUI

class CloudViewModel: ObservableObject {
    var userName: String = ""
    var permission: Bool = false
    var isSignedInToiCloud: Bool = false
    var error: String = ""
}

struct CloudView: View {
    @EnvironmentObject var viewModel: CloudViewModel
    var body: some View {
        VStack {
        Text(viewModel.userName)
        Text("\(viewModel.permission)")
        Text("\(viewModel.isSignedInToiCloud)")
        Text(viewModel.error)
        }
    }
}

//
//  HomeView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/12/21.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: CloudViewModel
    
    var body: some View {
        if vm.tb != nil {
            List {
        }
    }
}

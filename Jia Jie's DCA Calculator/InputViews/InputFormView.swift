//
//  InputForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct InputCustomizationView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var isPresented: Bool = false
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    @State var section2active : Bool = false
    
    var body: some View {
        NavigationView {
                Form {
                    Section {
                        Picker("Selected", selection: $long) {
                            Text("Go long").tag(true)
                            Text("Go short").tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                        .frame(width: 0.985 * vm.width)
                    } header: {
                       Text("Indicate your position")
                    }
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.entryTriggers.keys), id: \.self) { key in
                            HStack {
                                Text(key)

                            Spacer()
                                Button("Edit") {
                                    vm.selectedDictIndex = 0
                                    vm.restoreIndexPath(condition: vm.repo.entryTriggers[key]!)
                                    vm.restoreInputs()
                                    isPresented = true
                                }
                                .sheet(isPresented: $isPresented) {
                                    PopupView(shouldPopToRootView: self.$isActive, entryForm: false)
                                }
                            }
                        }
                        .onDelete { _ in }

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $isActive) {
                            SelectorView(rootIsActive: self.$isActive, selectedDictIndex: 0)
                                .navigationTitle("Entry Trigger")
                        } label: {
                            HStack {
                            Image(systemName: "plus.circle")
                            Text("Add entry trigger")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.entryTrade.keys), id: \.self) { key in
                            HStack {
                                Text(key)
                            Spacer()
                                Button("Edit") {
                                    vm.selectedDictIndex = 1
                                    vm.restoreIndexPath(condition: vm.repo.entryTrade[key])
                                    vm.restoreInputs()
                                    isPresented = true
                                }
                                .sheet(isPresented: $isPresented) {
                                    PopupView(shouldPopToRootView: self.$isActive, entryForm: false)
                                }
                            }
                        }

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $section2active) {
                            SelectorView(rootIsActive: self.$section2active, selectedDictIndex: 1)
                                .navigationTitle("Trade Condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus.circle")
                            Text("Add trade condition")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                }
            .navigationTitle("Entry strategy")
            .toolbar {
                EditButton()
                    
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
     
    }
}

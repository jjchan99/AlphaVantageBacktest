//
//  InputForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct InputFormView: View {
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
                                    vm.transitionState(condition: vm.repo.entryTriggers[key]!)
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
                            Image(systemName: "plus")
                            Text("Add trade setup") //AND POOL
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
                                    vm.transitionState(condition: vm.repo.entryTrade[key])
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
                            Image(systemName: "plus")
                            Text("Add trigger") //BASE
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        NavigationLink {
                         ExitFormView()
                        } label: {
                         Text("Set exit triggers")
                        }
                    }
                    .disabled(vm.repo.entryTriggers.isEmpty && vm.repo.entryTrade.isEmpty)
                    
                }
            .navigationTitle("Entry strategy")
            .toolbar {
                EditButton()
                    
            }
            .onAppear {
                vm.entry = true
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
                UITableView.appearance().backgroundColor = #colorLiteral(red: 0.9586906126, green: 0.9586906126, blue: 0.9586906126, alpha: 1)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
     
    }
}

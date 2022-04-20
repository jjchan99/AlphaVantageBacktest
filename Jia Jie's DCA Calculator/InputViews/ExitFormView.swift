//
//  ExitForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/1/22.
//

import Foundation
import SwiftUI

struct ExitFormView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var isPresented: Bool = false
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    @State var section2active : Bool = false
    
    var body: some View {
       
                Form {
                   
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.exitTriggers.values), id: \.self) { condition in
                            HStack {
                                Text(vm.keyTitle(condition: condition))
                                    .font(.caption)

                            Spacer()
                                Button("Edit") {
                                    vm.transitionState(condition: condition)
                                    vm.selectedDictIndex = 0
                                    vm.restoreInputs()
                                    isPresented = true
                                }
                            }
                        }
                        .onDelete { _ in }

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $isActive) {
                            SelectorView(rootIsActive: self.$isActive, selectedDictIndex: 0)
                                .navigationTitle("Exit Trigger")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add exit trigger")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.exitTrade.values), id: \.self) { condition in
                            HStack {
                                Text(vm.keyTitle(condition: condition))
                                    .font(.caption)
                            Spacer()
                                Button("Edit") {
                                    vm.transitionState(condition: condition)
                                    vm.selectedDictIndex = 1
                                    vm.restoreInputs()
                                    isPresented = true
                                }
                            }
                        }

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $section2active) {
                            SelectorView(rootIsActive: self.$section2active, selectedDictIndex: 1)
                                .navigationTitle("Exit Condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add exit condition")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        NavigationLink {
                          BuildView()
                                .environmentObject(vm)
                        } label: {
                         Text("Review and Build")
                        }
                    }

                }
            .navigationTitle("Exit strategy")
            .toolbar {
                EditButton()
                    
            }
            .onAppear {
                vm.resetInputs()
                vm.entry = false
            }
            .customSheet(isPresented: $isPresented, frame: vm.frame) {
                            PopupView(shouldPopToRootView: $isActive, entryForm: false)
                                .environmentObject(vm)
            }
     
    }
}


//
//  ExitForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/1/22.
//

import Foundation
import SwiftUI

struct ExitFormView: View {
    @EnvironmentObject var vm: InputViewModel<MA>
    @State private var isPresented: Bool = false
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    @State var section2active : Bool = false
    
    var body: some View {
       
                Form {
                   
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.exitTriggers.keys), id: \.self) { key in
                            HStack {
                                Text(key)

                            Spacer()
                                Button("Edit") {
                                    vm.transitionState(condition: vm.repo.exitTriggers[key]!)
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
                            
                            ForEach(Array(vm.repo.exitTrade.keys), id: \.self) { key in
                            HStack {
                                Text(key)
                            Spacer()
                                Button("Edit") {
                                    vm.transitionState(condition: vm.repo.exitTrade[key])
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
                                .navigationTitle("Exit Condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add exit condition")
                            }
                        }
                        .isDetailLink(false)
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
     
    }
}


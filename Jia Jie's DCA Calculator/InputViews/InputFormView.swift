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
    @EnvironmentObject var repo: InputRepository
    
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
                            
                            ForEach(Array(vm.repo.entryOr.values), id: \.self) { condition in
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
                                .navigationTitle("Add OR condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add OR condition") //AND POOL
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.entryOr.values), id: \.self) { condition in
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
                                .navigationTitle("Add AND condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add AND condition") //BASE
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        NavigationLink {
                         ExitFormView()
                        } label: {
                         Text("Proceed to exit strategy")
                        }
                    }
                    .disabled(vm.repo.entryOr.isEmpty && vm.repo.entryAnd.isEmpty)
                    
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
        .customSheet(isPresented: $isPresented, frame: vm.frame) {
                        PopupView(shouldPopToRootView: $isActive, entryForm: false)
                            .environmentObject(vm)
        }
     
    }
}

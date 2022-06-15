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
    @State var factoryReset: Bool = false
    
    @State private var isPresented: Bool = false
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    @State var section2active : Bool = false
    
    func delete0(at offsets: IndexSet){
        if let ndx = offsets.first {
            let item = vm.repo.entryOr.sorted(by: >)[ndx]
            vm.repo.entryOr.removeValue(forKey: item.key)
        }
    }
    
    func delete1(at offsets: IndexSet){
        if let ndx = offsets.first {
            let item = vm.repo.entryAnd.sorted(by: >)[ndx]
            vm.repo.entryAnd.removeValue(forKey: item.key)
        }
    }
    
    var DCA: some View {
        Section {
            if let condition = vm.repo.holdingPeriod {
                ForEach(0..<1) { _ in
                HStack {
                Text("Enter trade at regular \(vm.factory.holdingPeriod!)-day interval")
                    .font(.caption)
                Spacer()
                    Button {
                        vm.transitionState(condition: condition)
                        vm.restoreInputs()
                        isPresented = true
                    } label: {
                        Text("Edit")
                    }
                }
                }
                .onDelete { _ in
                    vm.repo.holdingPeriod = nil
                    vm.factory = vm.factory.resetHoldingPeriod()
                }
            }
        } header: {
            Button {
                vm.transitionState(key: "DCA")
                vm.updateValidationState()
                isPresented = true
            } label: {
                HStack {
                Image(systemName: "plus")
                Text("Dollar-Cost Averaging")
                }
            }
        }
    }
    
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
                                Text(InputViewModel.keyTitle(condition: condition))
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
                        .onDelete(perform: delete0)

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
                            
                            ForEach(Array(vm.repo.entryAnd.values), id: \.self) { condition in
                            HStack {
                                Text(InputViewModel.keyTitle(condition: condition))
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
                            .onDelete(perform: delete1)

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
                    
                    DCA
                    
                    Section {
                        NavigationLink(isActive: $factoryReset) {
                            ExitFormView(factoryReset: $factoryReset)
                                .environmentObject(vm)
                                .environmentObject(vm.repo)
                        } label: {
                         Text("Proceed to exit strategy")
                        }
                        .isDetailLink(false)
                    }
                    .disabled(vm.repo.entryOr.isEmpty
                              && vm.repo.entryAnd.isEmpty
                              && vm.repo.exitAnd.isEmpty
                              && vm.repo.exitOr.isEmpty
                              && vm.repo.holdingPeriod == nil
                    )
                    
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

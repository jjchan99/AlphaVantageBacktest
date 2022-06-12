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
    @EnvironmentObject var repo: InputRepository
    @State private var isPresented: Bool = false
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    @State var section2active : Bool = false
    
    @State var section3active : Bool = false
    
    func delete2(at offsets: IndexSet){
        if let ndx = offsets.first {
            let item = vm.repo.exitOr.sorted(by: >)[ndx]
            vm.repo.exitOr.removeValue(forKey: item.key)
        }
    }
    
    func delete3(at offsets: IndexSet){
        if let ndx = offsets.first {
            let item = vm.repo.exitAnd.sorted(by: >)[ndx]
            vm.repo.exitAnd.removeValue(forKey: item.key)
        }
    }
    
    var body: some View {
       
                Form {
                   
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.exitOr.values), id: \.self) { condition in
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
                            .onDelete(perform: delete2)

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $isActive) {
                            SelectorView(rootIsActive: self.$isActive, selectedDictIndex: 0)
                                .navigationTitle("Add OR condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add OR condition")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                        List {
                            
                            ForEach(Array(vm.repo.exitAnd.values), id: \.self) { condition in
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
                            .onDelete(perform: delete3)

                    }
                       
                    
                   
                    } header: {
                        NavigationLink(isActive: $section2active) {
                            SelectorView(rootIsActive: self.$section2active, selectedDictIndex: 1)
                                .navigationTitle("Add AND condition")
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Add AND condition")
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Section {
                       
                    } header: {
                        Button {
                            vm.transitionState(key: "HP")
                            section3active.toggle()
                        } label: {
                            HStack {
                            Image(systemName: "plus")
                            Text("Set holding period")
                            }
                        }
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
            .customSheet(isPresented: $section3active, frame: vm.frame) {
                PopupView(shouldPopToRootView: $isActive, entryForm: true)
                    .environmentObject(vm)
            }
     
    }
}


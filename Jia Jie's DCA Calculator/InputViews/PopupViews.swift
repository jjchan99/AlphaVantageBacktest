//
//  PopupViews.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI
import Combine

struct PopupView: View {
    @Binding var shouldPopToRootView : Bool
    @EnvironmentObject var vm: InputViewModel
    @State var hideButton: Bool = false
   
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(shouldPopToRootView: Binding<Bool>, entryForm: Bool) {
        self._shouldPopToRootView = shouldPopToRootView
        self.entryForm = entryForm
    }
    
    
    @ViewBuilder func holdingPeriodBody() -> some View {
        Section {
        TextField("Enter number of days", text: Binding(
            get: { String(vm.inputState.stepperValue) },
            set: { vm.inputState.stepperValue = Int($0) ?? 0 }
        ))
                .textFieldStyle(.plain)
            .frame(width: 0.2 * Dimensions.width)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("Done")
                    }
                    Spacer()
                    }
                }
            }
            .keyboardType(.numberPad)
            .padding()
        } header: {
            Text("Enter number of days")
        }
    }
    
    @ViewBuilder func sectionBottomHalf() -> some View {
        Section {
            Picker("Selected", selection: $vm.inputState.selectedPositionIdx) {
        Text("Above").tag(0)
        Text("Below").tag(1)
    }.pickerStyle(SegmentedPickerStyle())
    .frame(width: 0.985 * vm.width)
        } header: {
            vm.indexPathState.sectionBottomHalfHeader()
        } footer: {
            if !vm.validationState.validationState {
                HStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                    Text(vm.validationState.validationMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    @ViewBuilder func setButton() -> some View {
        HStack {
            if !hideButton {
            Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
        Button("Set") {
            vm.actionOnSet()
            self.presentationMode.wrappedValue.dismiss()
            self.shouldPopToRootView = false
        }
        .buttonStyle(.borderedProminent)
        .disabled(!vm.validationState.validationState)
            }
        }
    }
    
    
    var entryForm: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                Slider(value: $percentB, in: 0...100)
//                Text("\(percentB, specifier: "%.1f")")
//                if vm.section == 0 && vm.index == 0 {
//                    SlidingTabView(selection: self.$vm.selectedTabIndex, tabs: ["Singular", "Crossover"])
//                }
                
                Form {
                vm.indexPathState.body()
                sectionBottomHalf()
                }
                setButton()
                Spacer()

                }
            .navigationTitle(vm.indexPathState.title)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .onAppear {
            if entryForm {
                vm.resetInputs()
            }
        }
    }
}



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
    @State private var selectedTabIndex: Int = 0

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(shouldPopToRootView: Binding<Bool>, entryForm: Bool) {
        self._shouldPopToRootView = shouldPopToRootView
        self.entryForm = entryForm
    }
    
    @ViewBuilder func rsiBody() -> some View {
        Section {
            
        Slider(value: $vm.selectedPercentage, in: 0...1)
      
        } header: {
        Text("RSI threshold: \(vm.selectedPercentage * 100, specifier: "%.0f")%")
        }
        
        Section {
            HStack {
            Stepper("", value: $vm.stepperValue, in: 2...14)
            Spacer()
            }
        } header: {
            Text("Period: \(vm.stepperValue)")
        }
    }
    
    @ViewBuilder func holdingPeriodBody() -> some View {
        Section {
        TextField("Enter number of days", text: Binding(
            get: { String(vm.stepperValue) },
            set: { vm.stepperValue = Int($0) ?? 0 }
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
    Picker("Selected", selection: $vm.selectedPositionIdx) {
        Text("Above").tag(0)
        Text("Below").tag(1)
    }.pickerStyle(SegmentedPickerStyle())
    .frame(width: 0.985 * vm.width)
        } header: {
            Text("Enter when the ticker is")
        } footer: {
            if !vm.validationState {
                HStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                    Text(vm.validationMessage)
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
        .disabled(!vm.validationState)
            }
        }
    }
    
    @ViewBuilder func movingAverageBody() -> some View {
        if selectedTabIndex == 0 {
            Section {
            Picker("Selected", selection: $vm.selectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                .frame(width: 0.985 * vm.width)
            } header: {
                Text("Select window")
            }
        } else {
            Text("Hello world!")
        }
    }
    
    @ViewBuilder func bbBody() -> some View {
        Section {
            Slider(value: $vm.selectedPercentage, in: 0...100)
        } header: {
            Text("Set threshold: \(vm.selectedPercentage, specifier: "%.0f")%")
        }
    }
    
    @ViewBuilder func plBody() -> some View {
        Section {
            Slider(value: $vm.selectedPercentage, in: 0...100)
        } header: {
            Text("Set profit target: \(vm.selectedPercentage, specifier: "%.0f")%")
        }
    }
    
    
    @ViewBuilder func section() -> some View {
        switch vm.section {
        case 0:
            switch vm.index {
            case 0:
                movingAverageBody()
            case 1:
                bbBody()
            case 2:
                rsiBody()
            default:
                fatalError()
          
            }
        case 1:
            switch vm.index {
            case 0:
                movingAverageBody()
            case 1:
                movingAverageBody()
            case 2:
                holdingPeriodBody()
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    var entryForm: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                Slider(value: $percentB, in: 0...100)
//                Text("\(percentB, specifier: "%.1f")")
                if vm.section == 0 && vm.index == 0 {
                SlidingTabView(selection: self.$selectedTabIndex, tabs: ["First", "Second"])
                }
                
                Form {
                section()
                sectionBottomHalf()
                }
                setButton()
                Spacer()

                }
            .navigationTitle(vm.entry ? vm.entryTitleFrame[vm.section][vm.index] : vm.exitTitleFrame[vm.section][vm.index])
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .onAppear {
            if entryForm {
                vm.resetInputs()
            }
        }
    }
}



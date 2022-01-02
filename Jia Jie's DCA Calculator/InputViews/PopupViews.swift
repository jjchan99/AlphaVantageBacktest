//
//  PopupViews.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct PopupView: View {
    @Binding var shouldPopToRootView : Bool
    @EnvironmentObject var vm: InputViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(shouldPopToRootView: Binding<Bool>, entryForm: Bool) {
        self._shouldPopToRootView = shouldPopToRootView
        self.entryForm = entryForm
    }
    
    @ViewBuilder func rsiBody() -> some View {
        Text("HELLO WORLD!!!!")
    }

    @ViewBuilder func formBottomHalf() -> some View {
        HStack {
        Text("Step 2. Enter when price is...")
                .padding()
        Spacer()
        }
        Picker("Selected", selection: $vm.selectedPositionIdx) {
            Text("Above").tag(0)
            Text("Below").tag(1)
        }.pickerStyle(SegmentedPickerStyle())
        .frame(width: 0.985 * vm.width)
        
        HStack {
            Button("Cancel") {
                vm.resetInputs()
                vm.resetIndexPath()
                self.presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
        Button("Set") {
            vm.actionOnSet()
            vm.resetInputs()
            vm.resetIndexPath()
            self.presentationMode.wrappedValue.dismiss()
            self.shouldPopToRootView = false
        }
        .buttonStyle(.borderedProminent)
        
        }
    }
    
    @ViewBuilder func movingAverageBody() -> some View {
        VStack {
            HStack {
            Text("Step 1. Select window")
                .padding()
                Spacer()
            }
            Picker("Selected", selection: $vm.selectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                .frame(width: 0.985 * vm.width)
           formBottomHalf()
        }
    }
    
    @ViewBuilder func bbBody() -> some View {
        VStack {
            Slider(value: $vm.selectedPercentage, in: 0...100)
            Text("\(vm.selectedPercentage, specifier: "%.1f")")
        formBottomHalf()
        }
    }
    
    @ViewBuilder func form() -> some View {
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
                movingAverageBody()
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
            VStack {
//                Slider(value: $percentB, in: 0...100)
//                Text("\(percentB, specifier: "%.1f")")
                form()
                Spacer()

                }
            .navigationTitle(vm.entry ? vm.entryTitleFrame[vm.section][vm.index] : vm.exitTitleFrame[vm.section][vm.index])
            
        }
        .onAppear {
            if entryForm {
                vm.resetInputs()
            }
            
        }
    }
}



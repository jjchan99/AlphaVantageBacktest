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
                if vm.indexPathState as? MA != nil || vm.indexPathState as? MACrossover != nil {
                    SlidingTabView(selection: self.$vm.selectedTabIndex, tabs: ["Singular", "Crossover"])
                }
                
                Form {
                vm.indexPathState.body()
                if vm.indexPathState as? PT == nil && vm.indexPathState as? LT == nil && vm.indexPathState as? HP == nil {
                sectionBottomHalf()
                }
                }
                setButton()
                Spacer()

                }
            .navigationTitle(vm.indexPathState.title)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .onDisappear {
            if entryForm {
                vm.resetInputs()
            }
        }
    }
}

extension View {
    func customSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        return self
            .overlay(
                CustomSheetVCR(isPresented: isPresented, content: content())
            )
    }
}

struct CustomSheetVCR<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: Content
    let controller: UIViewController = {
       let c = UIViewController()
       c.view.backgroundColor = .clear
       return c
    }()
    
    func makeUIViewController(context: Context) -> UIViewController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let hc = CustomSheetController(rootView: content)
            
            uiViewController.present(hc, animated: true) {
                DispatchQueue.main.async {
                    isPresented.toggle()
                }
            }
            
        }
    }
}

class CustomSheetController<Content: View>: UIHostingController<Content> {
    
    override func viewDidLoad() {
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [
                .medium(),
                .large()
            ]
            
        }
        
    }
}

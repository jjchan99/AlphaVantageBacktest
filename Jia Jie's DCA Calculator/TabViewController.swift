//
//  TabView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/11/21.
//

import Foundation
import UIKit
import SwiftUI

class TabViewController: UITabBarController {
    
    var tabView: CustomTabView = CustomTabView()
    let viewModel = TabViewModel()
    var hostingController: UIHostingController<AnyView>?
    
    
    func addCustomTab() {
        self.hostingController = UIHostingController(rootView: AnyView(tabView.environmentObject(viewModel)))
        let customTabView = hostingController!.view!
        view.addSubview(customTabView)
        hostingController!.view.activateConstraints(reference: view, constraints: [.bottom(), .leading()], identifier: "tabView")
    }
    
    override func viewDidLoad() {
        addCustomTab()
        registerForKeyboardNotifications()

        self.tabBar.isHidden = true
        viewModel.index0tapped = { [unowned self] in
            selectedViewController = viewControllers![1]
        }
        
        viewModel.index1tapped = { [unowned self] in
            selectedViewController = viewControllers![0]
        }
        
        viewModel.index2tapped = { [weak self] in
            
        }
    }
    
    func registerForKeyboardNotifications() {
       //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [unowned self] value in
            self.hostingController!.view.removeFromSuperview()
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [unowned self] value in
           addCustomTab()
        }
   }


    
}

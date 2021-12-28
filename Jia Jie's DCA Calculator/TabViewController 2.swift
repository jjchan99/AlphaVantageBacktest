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
        let controller = hostingController!
        controller.didMove(toParent: self)
        controller.setupTab(view)
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
        
        viewModel.index2tapped = { [unowned self] in
            selectedViewController = viewControllers![2]
        }
        definesPresentationContext = true
    }
    
    func registerForKeyboardNotifications() {
       //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [unowned self] value in
            self.hostingController!.view.isHidden = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [unowned self] value in
            self.hostingController!.view.isHidden = false
        }
   }


    
}

extension UIHostingController {
    func setupTab(_ view: UIView) {
        let controller = self
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                   controller.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                   controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])
    }
}

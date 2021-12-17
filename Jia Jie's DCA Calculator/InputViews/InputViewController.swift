//
//  InputViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import UIKit
import SwiftUI

class InputViewController: UIViewController {
    var hostingController: UIHostingController<AnyView>?
    var viewModel = InputViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController = UIHostingController(rootView: AnyView(InputCustomizationView().environmentObject(viewModel)))
        view.addSubview(hostingController!.view)
        hostingController!.view.activateConstraints(reference: view, constraints: [], identifier: "cloudView")
        view.backgroundColor = .white
        let controller = hostingController!
        NSLayoutConstraint.activate([
                    controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                    controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
                    controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
 
        // Do any additional setup after loading the view.
    }
}

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
        view.backgroundColor = .white
        let controller = hostingController!
        controller.didMove(toParent: self)
        controller.view.frame = UIScreen.main.bounds
        // Do any additional setup after loading the view.
    }
}

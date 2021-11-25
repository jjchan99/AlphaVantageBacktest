//
//  CalculatorViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 19/9/21.
//

import UIKit
import SwiftUI
import Combine

class CalculatorViewController: UIViewController {
    
    weak var coordinator: CalculatorCoordinator?
    
    //MARK: SWIFTUI
    let viewModel = GraphViewModel()
    var hostingController: GraphHostingController<AnyView>?
    var subscribers = Set<AnyCancellable>()

    //MARK: VIEWS
    var titleView: TitleView
    var bodyView = BodyView()
    var dateView = DateViews()
    var displayLabels = DisplaylabelsView()
    var graphView = GraphView()
    
    deinit {
        Log.queue(action: "Calculator VC deinit")
    }
    
    init(name: String, symbol: String, type: String) {
        titleView = TitleView()
        titleView.name.text = name
        titleView.symbol.text = symbol
        titleView.type.text = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController = GraphHostingController(rootView: AnyView(
           graphView
             .environmentObject(viewModel)
        )
        )
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        addSubviews()
        configureDatePickerToolbar()
        setDelegates()
        animateDateButton()
        bodyView.actionOnFirstResponder = { [unowned self] in
            viewModel.shouldDrawGraph = false
            revertToOriginalPosition()
        }
        dateView.actionOnFirstResponder = { [unowned self] in
            viewModel.shouldDrawGraph = false
            revertToOriginalPosition()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToDateDisplay()
    }
    
    private func subscribeToDateDisplay() {
        coordinator!.$selectedDate
            .filter { $0 != "" }
            .assign(to: \.text!, on: dateView.dateSelected)
            .store(in: &subscribers)
    }
    
    private func revertToOriginalPosition() {
        bodyView.initialButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(100).hScaled())], identifier: "initialButton")
        bodyView.monthlyButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(200).hScaled())], identifier: "monthlyButton")

        displayLabels.initial.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(135).hScaled())], identifier: "initial")
        displayLabels.monthly.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(235).hScaled())], identifier: "monthly")
        displayLabels.initialInvestmentLabel.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(110).hScaled())], identifier: "initialInvestmentLabel")
        displayLabels.monthlyInvestmentLabel.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(210).hScaled())], identifier: "monthlyInvestmentLabel")
        
        dateView.dateButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(100).hScaled())], identifier: "dateButton");
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .transitionCurlDown) { [self] in
            view.layoutIfNeeded()
        } completion: { _ in }
    }
    
    private func setDelegates() {
    bodyView.initialTextField.delegate = self
    bodyView.monthlyTextField.delegate = self
    }
    
    private func addSubviews() {
        bodyView.configureView(parent: view)
        titleView.configureView(parent: view)
        dateView.configureView(parent: view)
        view.addSubview(hostingController!.view)
        displayLabels.configureView(parent: view)
    }
    
    private func animateDateButton() {
        let action = UIAction { [unowned self] value in
            let view = value.sender as! UIView
            resetColors(nil)
            dateView.dateButton.backgroundColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            dateView.dateButton.layer.borderColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            dateView.dateSelected.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            dateView.dateLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            view.showAnimation {
            }
        }
        dateView.dateButton.addAction(action, for: .touchDown)
    }
    
    private func sendToCalculator() {
        guard coordinator!.monthIndex != nil else { return }
        let output = self.coordinator!.getDCAResult()
        viewModel.results = output.result
        viewModel.meta = output.meta
        if (coordinator!.initialInvestment == 0 && coordinator!.monthlyInvestment == 0) || (coordinator!.monthIndex == 0 && coordinator!.initialInvestment == 0) {
            viewModel.shouldDrawGraph = false
        } else {
            hostingController!.view.activateConstraints(reference: view.layoutMarginsGuide, constraints: [.top(constant: CGFloat(50).hScaled()), .leading(), .trailing()], identifier: "hostingController")
            viewModel.shouldDrawGraph = true
            animateConstraints()
    }
    }
    
    @objc private func dismissInputViews(_ sender: UIBarButtonItem) {
        if sender === dateView.doneButton {
            dateView.dateField.resignFirstResponder()
            dateView.dateSelected.text = coordinator?.selectedDate
            resetColors(nil)
            coordinator?.publishMonthIndex(monthIndexDidPublish: sendToCalculator())
            displayLabels.initial.text = "\(Double(bodyView.initialTextField.text!)?.roundedWithAbbreviations ?? "None")"
            displayLabels.monthly.text = "\(Double(bodyView.monthlyTextField.text!)?.roundedWithAbbreviations ?? "None")"
        } else if sender === bodyView.doneButton {
            if bodyView.initialTextField.isFirstResponder {
            bodyView.initialTextField.resignFirstResponder()
            resetColors(nil)
            sendToCalculator()
            displayLabels.initial.text = "\(Double(displayLabels.initial.text!)?.roundedWithAbbreviations ?? "None")"
                displayLabels.monthly.text = "\(Double(bodyView.monthlyTextField.text!)?.roundedWithAbbreviations ?? "None")"
            } else {
            bodyView.monthlyTextField.resignFirstResponder()
            resetColors(nil)
            sendToCalculator()
            displayLabels.initial.text = "\(Double(bodyView.initialTextField.text!)?.roundedWithAbbreviations ?? "None")"
            displayLabels.monthly.text = "\(Double(displayLabels.monthly.text!)?.roundedWithAbbreviations ?? "None")"
            }
        }
    }
    
    private func configureDatePickerToolbar() {
      
        let doneButton = dateView.doneButton
        doneButton.title = "Hide"
        doneButton.style = UIBarButtonItem.Style.done
        doneButton.target = self
        doneButton.action = #selector(dismissInputViews)
        
        let doneButton2 = bodyView.doneButton
        doneButton2.title = "Done"
        doneButton2.style = UIBarButtonItem.Style.done
        doneButton2.target = self
        doneButton2.action = #selector(dismissInputViews)
    }
    
    func animateConstraints() {
        bodyView.initialButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(540).hScaled())], identifier: "initialButton")
        bodyView.monthlyButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(640).hScaled())], identifier: "monthlyButton")

        displayLabels.initial.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(575).hScaled())], identifier: "initial")
        displayLabels.monthly.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(675).hScaled())], identifier: "monthly")
        displayLabels.initialInvestmentLabel.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(550).hScaled())], identifier: "initialInvestmentLabel")
        displayLabels.monthlyInvestmentLabel.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(650).hScaled())], identifier: "monthlyInvestmentLabel")
        
        dateView.dateButton.updateConstraints(reference: view, constraints: [.top(constant: CGFloat(540).hScaled())], identifier: "dateButton");
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .transitionCurlDown) { [self] in
            view.layoutIfNeeded()
        } completion: { _ in }
    }
}

extension CalculatorViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === bodyView.initialTextField {
            displayLabels.initial.text = "\(Int(coordinator!.initialInvestment))"
            bodyView.initialButton.backgroundColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            bodyView.initialButton.layer.borderColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            displayLabels.initial.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            displayLabels.initialInvestmentLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            resetColors(textField)
            bodyView.initialButton.showAnimation { [unowned self] in
                
            }
           
            return true
        } else if textField === bodyView.monthlyTextField {
            displayLabels.monthly.text = "\(Int(coordinator!.monthlyInvestment))"
            bodyView.monthlyButton.backgroundColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            bodyView.monthlyButton.layer.borderColor = #colorLiteral(red: 0.4630131125, green: 0.3992906511, blue: 1, alpha: 1)
            displayLabels.monthly.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            displayLabels.monthlyInvestmentLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            resetColors(textField)
            bodyView.monthlyButton.showAnimation { [unowned self] in
              
            }
            return true
        }
        return false
    }
    
    func resetColors(_ sender: UITextField?) {
        switch sender {
        case bodyView.initialTextField:
            bodyView.monthlyButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            bodyView.monthlyButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            displayLabels.monthly.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            displayLabels.monthlyInvestmentLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            dateView.dateButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dateView.dateSelected.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
        case bodyView.monthlyTextField:
            bodyView.initialButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            bodyView.initialButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            displayLabels.initial.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            displayLabels.initialInvestmentLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            dateView.dateButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dateView.dateSelected.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
        default:
            bodyView.initialButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            bodyView.initialButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            displayLabels.initial.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            displayLabels.initialInvestmentLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            bodyView.monthlyButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            bodyView.monthlyButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            displayLabels.monthly.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            displayLabels.monthlyInvestmentLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            dateView.dateButton.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateButton.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
            dateView.dateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dateView.dateSelected.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text != "" && textField.text != nil else { return }
        switch textField {
        case bodyView.initialTextField:
            guard Int(textField.text!)! <= 1000000000 else {
                textField.text = "1000000000"
                displayLabels.initial.text = "1000000000"
                return
            }
            
            displayLabels.initial.text = textField.text
            coordinator!.initialInvestment = Double(textField.text!)!
            
        case bodyView.monthlyTextField:
            guard Int(textField.text!)! <= 1000000000 else {
                textField.text = "1000000000"
                displayLabels.monthly.text = "1000000000"
                return
            }
            
            displayLabels.monthly.text = textField.text
            coordinator!.monthlyInvestment = Double(textField.text!)!
        default:
            return
        }
    }
}



//
//  InputViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 23/9/21.
//

import UIKit

class BodyView: ViewFactory {
    
    let image = UIImage(systemName: "arrow.up")
    let border = CALayer()
    let width = CGFloat(1.0)
    var actionOnFirstResponder: (() -> ())?
    
    let doneButton = UIBarButtonItem()
    
    lazy var numberToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    lazy var initialButton: UIButton = {
        let button = UIButton()
        button.widthAnchor.constraint(equalToConstant: CGFloat(193).wScaled()).isActive = true
        button.heightAnchor.constraint(equalToConstant: CGFloat(80).hScaled()).isActive = true
        
        button.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
        
        return button
    }()
    
    lazy var monthlyButton: UIButton = {
        let button = UIButton()
        button.widthAnchor.constraint(equalToConstant: CGFloat(193).wScaled()).isActive = true
        button.heightAnchor.constraint(equalToConstant: CGFloat(80).hScaled()).isActive = true
        
        button.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
       
        return button
    }()
    
   
    
    func configureView(parent: UIView) {
        addSubviews(parent: parent)
        setViewConstraints(parent: parent)
        setup()
    }
    
    internal func addSubviews(parent view: UIView) {
        view.addSubview(initialButton)
        view.addSubview(monthlyButton)
        
        //MARK: INVISIBLE VIEWS
        view.addSubview(initialTextField)
        view.addSubview(monthlyTextField)
    }
    
    internal func setup() {
        let inputForInitial = UIAction { [unowned self] action in
            initialTextField.becomeFirstResponder()
            actionOnFirstResponder?()
        }
        
        let inputForMonthly = UIAction { [unowned self] action in
            monthlyTextField.becomeFirstResponder()
            actionOnFirstResponder?()
        }
        
        initialButton.addAction(inputForInitial, for: .touchDown)
        monthlyButton.addAction(inputForMonthly, for: .touchDown)
        
        initialTextField.inputAccessoryView = numberToolbar
        monthlyTextField.inputAccessoryView = numberToolbar
    }
    
    internal func setViewConstraints(parent view: UIView) {
        let reference = view
        initialButton.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(100).hScaled()), .leading(constant: CGFloat(15).wScaled())], identifier: "initialButton")
        monthlyButton.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(200).hScaled()), .leading(constant: CGFloat(15).wScaled())], identifier: "monthlyButton")
    }
    
    //MARK: HIDDEN VIEWS
    
    lazy var initialTextField: UITextField = {
        let textfield = UITextField()
        textfield.keyboardType = .numberPad
        textfield.font = UIFont.systemFont(ofSize: 0, weight: .medium)
        let action = UIAction { action in
            wholeNumberFilter(textfield)
        }
        textfield.addAction(action, for: .editingChanged)
        textfield.backgroundColor = .clear
        textfield.textColor = .clear
        textfield.borderStyle = .none
        textfield.widthAnchor.constraint(equalToConstant: 0).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: 0).isActive = true
        textfield.isHidden = true
        return textfield
    }()
    
    lazy var monthlyTextField: UITextField = {
        let textfield = UITextField()
        textfield.keyboardType = .numberPad
        textfield.font = UIFont.systemFont(ofSize: 0, weight: .medium)
        let action = UIAction { action in
            wholeNumberFilter(textfield)
        }
        textfield.addAction(action, for: .editingChanged)
        textfield.backgroundColor = .clear
        textfield.textColor = .clear
        textfield.borderStyle = .none
        textfield.widthAnchor.constraint(equalToConstant: 0).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: 0).isActive = true
        textfield.isHidden = true
        return textfield
    }()
}

fileprivate func wholeNumberFilter(_ textField: UITextField) {
      if let text = textField.text,
        let number = Decimal(string: text.filter { $0.isWholeNumber }) {
          textField.text = "\(number)"
      } else {
        textField.text = ""
      }
    }


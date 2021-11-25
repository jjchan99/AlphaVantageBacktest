//
//  DatePickerView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/10/21.
//

import Foundation
import UIKit

class DateViews: ViewFactory {
    
    let doneButton = UIBarButtonItem()
   
    var datePicker = UIPickerView()
    var actionOnFirstResponder: (() -> ())?
    
    lazy var dateToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    func configureView(parent: UIView) {
        addSubviews(parent: parent)
        setViewConstraints(parent: parent)
        setup()
    }
    
    internal func addSubviews(parent view: UIView) {
        view.addSubview(dateLabel)
        view.addSubview(dateButton)
        view.addSubview(dateField)
        view.addSubview(dateSelected)
        dateButton.addSubview(dateLabel)
    }
    
    internal func setup() {
        dateField.inputView = datePicker
        dateField.inputAccessoryView = dateToolbar
        
        let action = UIAction { [unowned self] _ in
            dateField.becomeFirstResponder()
            actionOnFirstResponder?()
        }
        
        dateButton.addAction(action, for: .touchDown)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        dateToolbar.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    internal func setViewConstraints(parent view: UIView) {
        let reference = view
        dateButton.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(100).hScaled()), .trailing(constant: CGFloat(-15).wScaled())], identifier: "dateButton")
        dateLabel.activateConstraints(reference: dateButton, constraints: [.top(constant: CGFloat(10).hScaled()), .leading(constant: CGFloat(20).wScaled())], identifier: "dateLabel")
        dateSelected.activateConstraints(reference: dateButton, constraints: [.top(constant: CGFloat(65).hScaled()), .leading(constant: CGFloat(20).wScaled())], identifier: "dateSelected")
    }
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Select date"
        label.font = UIFont.systemFont(ofSize: CGFloat(17).hScaled(), weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: CGFloat(300).wScaled()).isActive = true
        return label
    }()
    
    lazy var dateSelected: UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.font = UIFont.systemFont(ofSize: CGFloat(25).hScaled(), weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: CGFloat(150).wScaled()).isActive = true
        label.numberOfLines = 2
        return label
    }()
    
    lazy var dateField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        return textField
    }()
    
    lazy var dateButton: UIButton = {
        let button = UIButton()
        button.widthAnchor.constraint(equalToConstant: CGFloat(193).wScaled()).isActive = true
        button.heightAnchor.constraint(equalToConstant: CGFloat(180).hScaled()).isActive = true
        
        button.backgroundColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.9356668591, green: 0.9606878161, blue: 0.9957599044, alpha: 1)
        return button
    }()
}

//
//  DisplayLabelsView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/10/21.
//

import Foundation
import UIKit

class DisplaylabelsView: ViewFactory {
    
    var initial: UILabel = {
        let label = UILabel()
        label.text = "None"
        label.font = UIFont.systemFont(ofSize: CGFloat(25).hScaled(), weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.widthAnchor.constraint(equalToConstant: CGFloat(180).wScaled()).isActive = true
        return label
    }()
    var monthly: UILabel = {
        let label = UILabel()
        label.text = "None"
        label.font = UIFont.systemFont(ofSize: CGFloat(25).hScaled(), weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.widthAnchor.constraint(equalToConstant: CGFloat(180).wScaled()).isActive = true
        return label
    }()
    
    lazy var initialInvestmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Initial investment"
        label.font = UIFont.systemFont(ofSize: CGFloat(17).hScaled(), weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: CGFloat(175).wScaled()).isActive = true
        return label
    }()
    
    lazy var monthlyInvestmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Monthly investment"
        label.font = UIFont.systemFont(ofSize: CGFloat(17).hScaled(), weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: CGFloat(175).wScaled()).isActive = true
        return label
    }()
    
    func configureView(parent: UIView) {
        addSubviews(parent: parent)
        setViewConstraints(parent: parent)
    }
    
    internal func addSubviews(parent view: UIView) {
        view.addSubview(initial)
        view.addSubview(monthly)
        view.addSubview(initialInvestmentLabel)
        view.addSubview(monthlyInvestmentLabel)
    }
    
    internal func setViewConstraints(parent view: UIView) {
        let reference = view
        initial.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(135).hScaled()), .leading(constant: CGFloat(35).wScaled())], identifier: "initial")
        monthly.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(235).hScaled()), .leading(constant: CGFloat(35).wScaled())], identifier: "monthly")
        initialInvestmentLabel.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(110).hScaled()), .leading(constant: CGFloat(35).wScaled())], identifier: "initialInvestmentLabel")
        monthlyInvestmentLabel.activateConstraints(reference: reference, constraints: [.top(constant: CGFloat(210).hScaled()), .leading(constant: CGFloat(35).wScaled())], identifier: "monthlyInvestmentLabel")
    }
    
    
}

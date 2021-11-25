//
//  TitleView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 26/9/21.
//

import UIKit

class TitleView: UIView, ViewFactory {
    
    lazy var name: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: CGFloat(17).hScaled(), weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = CGFloat(200).wScaled()
        return label
    }()
    
    lazy var symbol: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(35).hScaled(), weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.minimumScaleFactor = 0.01
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textColor = .black
        return label
    }()
    
    lazy var type: UILabel = {
        let label = UILabel()
        return label
    }()
    
    func configureView(parent: UIView) {
        addSubviews(parent: parent)
        setViewConstraints(parent: parent)
    }
    
    func addSubviews(parent view: UIView) {
        view.addSubview(name)
        view.addSubview(symbol)
        symbol.textAlignment = .center
        view.addSubview(type)
    }
    
    func setViewConstraints(parent view: UIView) {
        let reference = view.layoutMarginsGuide
        symbol.activateConstraints(reference: reference, constraints: [.top(), .leading()], identifier: "symbol")
        name.activateConstraints(reference: symbol, constraints: [.leading(constant: CGFloat(10).wScaled(), equalTo: .trailing)], identifier: "name")
    }
}


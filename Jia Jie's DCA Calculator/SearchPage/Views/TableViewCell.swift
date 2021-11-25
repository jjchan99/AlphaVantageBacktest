//
//  TableView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/9/21.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .medium)
        label.textColor = .gray
        label.preferredMaxLayoutWidth = CGFloat(175).wScaled()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .bold)
        label.widthAnchor.constraint(equalToConstant: CGFloat(190).wScaled()).isActive = true
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .medium)
        return label
    }()
    
    func setLabels(nameLabel: String, symbolLabel: String, typeLabel: String) {
        self.nameLabel.text = nameLabel
        self.symbolLabel.text = symbolLabel
        self.typeLabel.text = typeLabel
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.symbolLabel)
        self.contentView.addSubview(self.typeLabel)
        let guide = self.contentView
        
        self.symbolLabel.activateConstraints(reference: guide, constraints: [.top(constant: 10), .leading(constant: CGFloat(15).wScaled())], identifier: "symbolLabel")
        self.typeLabel.activateConstraints(reference: self.symbolLabel, constraints: [.top(equalTo: .bottom), .leading()], identifier: "typeLabel")
        self.nameLabel.activateConstraints(reference: guide, constraints: [.top(constant: 10), .trailing(constant: CGFloat(-15).wScaled())], identifier: "nameLabel")
    }
}



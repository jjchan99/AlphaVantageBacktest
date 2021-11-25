//
//  HomeViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/11/21.
//

import Foundation
import UIKit

class HomeViewController: UITableViewController {
    
    var hiddenSections = Set<Int>()
    
    override func viewDidLoad() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TableViewCell
        cell.setLabels(nameLabel: "XYZ Company", symbolLabel: "XYZ", typeLabel: "Equity")
        cell.nameLabel.textAlignment = .right
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
}

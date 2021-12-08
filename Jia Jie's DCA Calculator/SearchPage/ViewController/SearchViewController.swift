//
//  ViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 12/9/21.
//

import UIKit
import Combine

class SearchViewController: UITableViewController {
    
    weak var coordinator: NavigationCoordinator?
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search for a company"
        controller.searchBar.autocapitalizationType = .allCharacters
        return controller
    }()
    
    @Published var searchBarText: String?
    
    var searchResults: SearchResults?
    var indexPath: IndexPath?
    
    var safeArea: UILayoutGuide!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        tableView.rowHeight = CGFloat(80)
        print("The window width is: \(windowWidth())")
        print("The window height is: \(windowHeight())")
        tableView.register(TableViewCell.self, forCellReuseIdentifier:"cellId")
        windowWidth()
        windowHeight()
        view.backgroundColor = .white
        subscribeToSearchBarPublisher()
        overrideUserInterfaceStyle = .light
        
        navigationItem.title = "DCA Calculator"
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
        
   
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.bestMatches.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TableViewCell
        if let allMatches = searchResults?.bestMatches {
            let cellData = allMatches[indexPath.row]
            cellView.setLabels(nameLabel: cellData.name, symbolLabel: cellData.symbol, typeLabel: cellData.type)
        }
        cellView.nameLabel.textAlignment = .right
        return cellView
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
    }
    
    private func subscribeToSearchBarPublisher() {
        $searchBarText
            .filter {
                $0 != nil && !$0!.isEmpty
            }
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] query in
                populateTable(with: query!)
            }.store(in: &(coordinator!.subscribers))
    }
    
    private func populateTable(with query: String) {
        API.fetchSearchResultsPublisher(query)
            .sink { value in
                switch value {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                self.searchResults = value
                self.tableView.reloadData()
                self.tableView.isScrollEnabled = true
            }
            .store(in: &(coordinator!.subscribers))
    }
    
    func subscribeToDaily(query: String, completion: @escaping () -> ()) {
        CandleAPI.fetchDaily(query)
            .sink { value in
                switch value {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                if value.timeSeries == nil {
                    print(value.note)
                    tableView.deselectRow(at: indexPath!, animated: false)
                    view.isUserInteractionEnabled = true
                    spinner.removeFromSuperview()
                } else {
                coordinator!.rawDataDaily = value
                completion()
                self.searchBarText = nil
                searchController.searchBar.text = nil
                }
            }
            .store(in: &coordinator!.subscribers)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                spinner.startAnimating()
                view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
        
                spinner.frame = view.frame
        
        view.isUserInteractionEnabled = false
        let dependencies = searchResults?.bestMatches[indexPath.row]
        let name = dependencies!.name
        let symbol = dependencies!.symbol
        let type = dependencies!.type
        self.indexPath = indexPath
        self.subscribeToDaily(query: symbol) { [unowned self] in
        self.coordinator!.start(name: name, symbol: symbol, type: type)
        view.isUserInteractionEnabled = true
        spinner.removeFromSuperview()
        }
        
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text != nil else { return }
        self.searchBarText = searchController.searchBar.text
    }
}

extension SearchViewController {
    func windowHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }

    func windowWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
}





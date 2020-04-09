//
//  ViewController.swift
//  Space X
//
//  Created by Andrey on 07/04/2020.
//  Copyright © 2020 Andrey. All rights reserved.
//

import UIKit
import Alamofire
import JGProgressHUD

class MainVC: UIViewController {
    
//    var allLaunches: Launches = []
//    var selectedFlight: Launche?
//    var filteredData: [Launche]!
//    var hasSearched = false
//    // sort by launches = 0
//    // sort by name = 1
//    var howToSort = 0
    
    
    var mainScreeValues: MainViewData!
    
    // sort by launches = 0
    // sort by name = 1
    let hud = JGProgressHUD(style: .dark)
    let cellIdentifier = "launchCell"
    
    public var mainView: MainView! {
      guard isViewLoaded else { return nil }
      return (view as! MainView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainScreeValues = MainViewData(allLaunches: nil, selectedFlight: nil, filteredData: nil)
        setUP()
    }
    
    func setUP() {
        
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        mainView.tableView.register(cellNib, forCellReuseIdentifier: cellIdentifier)
        
        mainView.tableView.dataSource = self
        mainView.tableView.delegate = self
        mainView.searchBar.delegate = self
        mainView.tableView.keyboardDismissMode = .onDrag
        mainView.tableView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        navigationItem.hidesSearchBarWhenScrolling = false
        mainScreeValues.howToSort = UserDefaults.standard.integer(forKey: "Sort")
        fetchLaunches()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailVC
        {
            let vc = segue.destination as? DetailVC
            vc?.flight = mainScreeValues.selectedFlight
            print("One launch")
        }
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        fetchLaunches()
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Choose sort type", message: "Please Select an Option", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Sort by name", style: .default , handler:{ (UIAlertAction) in
            self.mainScreeValues.allLaunches = self.sort(wayToSort: 1, objectToSort: self.mainScreeValues.allLaunches!)
            self.mainView.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Sort by launch number", style: .default , handler:{ (UIAlertAction) in
            self.mainScreeValues.allLaunches = self.sort(wayToSort: 0, objectToSort: self.mainScreeValues.allLaunches!)
            self.mainView.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! launchCell
        
        if mainScreeValues.hasSearched {
            cell.flightNumberLabel.text = String(mainScreeValues.filteredData![indexPath.row].flightNumber)
            cell.missionNameLabel.text = mainScreeValues.filteredData![indexPath.row].missionName
            cell.launchDateLabel.text = mainScreeValues.filteredData![indexPath.row].launch_date_utc
        } else {
            cell.flightNumberLabel.text = String(mainScreeValues.allLaunches![indexPath.row].flightNumber)
            cell.missionNameLabel.text = mainScreeValues.allLaunches![indexPath.row].missionName
            cell.launchDateLabel.text = mainScreeValues.allLaunches![indexPath.row].launch_date_utc
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if mainScreeValues.hasSearched {
            mainScreeValues.selectedFlight = mainScreeValues.filteredData![indexPath.row]
        } else {
            mainScreeValues.selectedFlight = mainScreeValues.allLaunches![indexPath.row]
        }
      return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mainScreeValues.hasSearched {
            return mainScreeValues.filteredData!.count
        } else {
            
            if let num = mainScreeValues.allLaunches?.count {
                return num
            } else {
                return 0
            }
        }
    }
}

extension MainVC: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.mainView.searchBar.showsCancelButton = true
        mainScreeValues.hasSearched = true
        if searchText.isEmpty == false {
            mainScreeValues.filteredData = mainScreeValues.allLaunches!.filter({ $0.missionName.localizedCaseInsensitiveContains(searchText)})
        }
        mainView.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mainScreeValues.hasSearched = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        mainView.tableView.reloadData()
    }
}

extension MainVC {
    
    func errorHandler() {
        // create the alert
        let alert = UIAlertController(title: "Error :(", message: "Looks like we can't load list for you, try again or come back in few minutes!", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Try again!", style: UIAlertAction.Style.default, handler: { action in
            self.fetchLaunches()
        }))
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: {action in
            self.isHUDOn(isON: false)
        }))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func sort(wayToSort: Int, objectToSort: Launches) -> Launches {
        let objectToReturn: Launches
        print(wayToSort)
        self.mainScreeValues.howToSort = wayToSort
        if wayToSort == 1 {
            objectToReturn = objectToSort.sorted { $0.missionName < $1.missionName }
        } else {
            objectToReturn = objectToSort.sorted { $0.flightNumber < $1.flightNumber }
        }
        UserDefaults.standard.set(wayToSort, forKey: "Sort")
        return objectToReturn
    }
    
    func fetchLaunches() {
        
        isHUDOn(isON: true)
        
        let url = "https://api.spacexdata.com/v3/launches/past"
        let request = AF.request(url)
        request.responseDecodable(of: Launches.self ) { (response) in
            
            if response.error != nil {
                self.errorHandler()
            }
            
            guard let lanches = response.value else { return }
            //Saving to holder and reloading
            self.mainScreeValues.allLaunches = lanches
            self.mainScreeValues.allLaunches = self.sort(wayToSort: self.mainScreeValues.howToSort, objectToSort: self.mainScreeValues.allLaunches!)
            
            self.isHUDOn(isON: false)
            self.mainView.tableView.reloadData()
        }
    }
    
    func isHUDOn (isON: Bool) {
           if isON == true {
               hud.textLabel.text = "Loading"
               hud.show(in: self.view)
           } else {
               hud.dismiss()
           }
       }
}

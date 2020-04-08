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





class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var allLaunches: Launches = []
    let hud = JGProgressHUD(style: .dark)
    var selectedFlight: Launche?
    
    var filteredData: [Launche]!
    var hasSearched = false
    
    // sort by launches = 0
    // sort by name = 1
    var howToSort = 0
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        howToSort = 1
        
        tableview.dataSource = self
        tableview.delegate = self
        searchBar.delegate = self
        
        tableview.keyboardDismissMode = .onDrag
        tableview.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let cellNib = UINib(nibName: "launchCell", bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: "launchCell")
        
        navigationItem.hidesSearchBarWhenScrolling = false
        howToSort = UserDefaults.standard.integer(forKey: "Sort")
        fetchLaunches()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "launchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! launchCell
        
        if hasSearched {
            cell.flightNumberLabel.text = String(filteredData[indexPath.row].flightNumber)
            cell.missionNameLabel.text = filteredData[indexPath.row].missionName
            cell.launchDateLabel.text = filteredData[indexPath.row].launch_date_utc
        } else {
            cell.flightNumberLabel.text = String(allLaunches[indexPath.row].flightNumber)
            cell.missionNameLabel.text = allLaunches[indexPath.row].missionName
            cell.launchDateLabel.text = allLaunches[indexPath.row].launch_date_utc
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        
        if hasSearched == true {
            selectedFlight = filteredData[indexPath.row]
        } else {
            selectedFlight = allLaunches[indexPath.row]
        }
        
       // print("Cell tapped")
       // print(selectedFlight)
      return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSearched == true {
            return filteredData.count
        } else {
            return allLaunches.count
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailViewController
        {
            let vc = segue.destination as? DetailViewController
            vc?.flight = selectedFlight
            print("One launch")
        }
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        fetchLaunches()
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Choose sort type", message: "Please Select an Option", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Sort by name", style: .default , handler:{ (UIAlertAction) in
            self.allLaunches = self.sort(wayToSort: 1, objectToSort: self.allLaunches)
            self.tableview.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Sort by launch number", style: .default , handler:{ (UIAlertAction) in
            self.allLaunches = self.sort(wayToSort: 0, objectToSort: self.allLaunches)
            self.tableview.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.showsCancelButton = true
        //filteredData = allLaunches
        print("Text Chaning ")
        hasSearched = true
        if searchText.isEmpty == false {
            filteredData = allLaunches.filter({ $0.missionName.localizedCaseInsensitiveContains(searchText)})
        }
        print("After search")
        print(filteredData)
        tableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        tableview.reloadData()
    }
}

extension ViewController {
    
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
            //print(response)
            
            if let error = response.error {
                self.errorHandler()
            }
            
            guard let lanches = response.value else { return }
            //Saving to holder and reloading
            //print(lanches)
            self.allLaunches = lanches
            
            self.allLaunches = self.sort(wayToSort: UserDefaults.standard.integer(forKey: "Sort"), objectToSort: self.allLaunches)
            
            self.isHUDOn(isON: false)
            self.tableview.reloadData()
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

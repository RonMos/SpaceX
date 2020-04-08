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
    
    @IBOutlet weak var tableview: UITableView!
    
    var oneLaunch: Launche?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        
        tableview.keyboardDismissMode = .onDrag
        tableview.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let cellNib = UINib(nibName: "launchCell", bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: "launchCell")
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        fetchLaunches()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "launchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! launchCell
        cell.flightNumberLabel.text = String(allLaunches[indexPath.row].flightNumber)
        cell.missionNameLabel.text = allLaunches[indexPath.row].missionName
        cell.launchDateLabel.text = allLaunches[indexPath.row].launch_date_utc

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedFlight = allLaunches[indexPath.row]
        oneLaunch = selectedFlight
       // print("Cell tapped")
       // print(selectedFlight)
      return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLaunches.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("One launch")
//            guard let destinationVC = segue.description as? DetailViewController else {
//                return
//            }
//            print("One launch")
//            destinationVC.flight = selectedFlight
//            print(oneLaunch)
//
        if segue.destination is DetailViewController
        {
            let vc = segue.destination as? DetailViewController
            vc?.flight = selectedFlight
            print("One launch")
        }
        
    }
    

}

extension ViewController {
    func fetchLaunches() {
        
        isHUDOn(isON: true)
        
        let url = "https://api.spacexdata.com/v3/launches/past"
        let request = AF.request(url)
        request.responseDecodable(of: Launches.self ) { (response) in
            //print(response)
            guard let lanches = response.value else { return }
            //Saving to holder and reloading
            //print(lanches)
            self.allLaunches = lanches
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

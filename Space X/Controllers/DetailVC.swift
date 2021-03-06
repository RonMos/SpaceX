//
//  DetailViewController.swift
//  Space X
//
//  Created by Andrey on 08/04/2020.
//  Copyright © 2020 Andrey. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    /*
     Image
        Name
        FlightNumber
        details
     */
    
    var flight: Launche?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameOfFlight: UILabel!
    @IBOutlet weak var flightNumber: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var loadingInfoLabel: UILabel!
    
    
    private func commonInit() {
        guard let flight = flight else { return }
        nameOfFlight.text = flight.missionName
        flightNumber.text = "Flight number: " + String(flight.flightNumber)
        
        if let detail = flight.detail {
            detailTextView.text = detail
        } else {
            detailTextView.text = "Detail data is not avalible for current flight."
        }
        
        if let missionPatchURL = flight.links?.missionPatch {
            downloadImage(from: URL(string: missionPatchURL)!)
        } else {
            self.loadingInfoLabel.text = "Patch is not existing"
        }
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            
            if error != nil {
                self.loadingInfoLabel.text = "Failed to load image"
            }
            
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.loadingInfoLabel.isHidden = true
                self.imageView.image = UIImage(data: data)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("My flight detail ")
        print(flight)
        commonInit()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

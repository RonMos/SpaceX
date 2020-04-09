//
//  File.swift
//  Space X
//
//  Created by Andrey on 09/04/2020.
//  Copyright © 2020 Andrey. All rights reserved.
//

import Foundation

public struct MainViewData {
    
    var allLaunches: Launches?
    var selectedFlight: Launche?
    var filteredData: [Launche]?
    var hasSearched: Bool
    // sort by launches = 0
    // sort by name = 1
    var howToSort: Int
    
    init(allLaunches: Launches?, selectedFlight: Launche?, filteredData: [Launche]?) {
        self.allLaunches = allLaunches
        self.selectedFlight = selectedFlight
        self.filteredData = filteredData
        self.hasSearched = false
        self.howToSort = 0
    }
}

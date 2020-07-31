//
//  Launches.swift
//  Space X
//
//  Created by Andrey on 08/04/2020.
//  Copyright © 2020 Andrey. All rights reserved.
//

import Foundation

// MARK: - Main
struct Launche: Decodable {
    let flightNumber: Int
    let missionName: String
    let launch_date_utc: String
    let detail: String?
    let links: Links?
    
    enum CodingKeys: String, CodingKey {
        case flightNumber = "flight_number"
        case missionName = "mission_name"
        case launch_date_utc = "launch_date_utc"
        case detail = "details"
        case links
    }
}

struct Links: Decodable {
    let missionPatch: String?
    
    enum CodingKeys: String, CodingKey {
        case missionPatch = "mission_patch"
    }
}

typealias Launches = [Launche]

//
//  File.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 05/12/2024.
//

import Foundation


struct Station: Codable {
    let stationCode: String
    let stationName: String
    let city: String
    let address: String
    let latitude: Double
    let longitude: Double
}

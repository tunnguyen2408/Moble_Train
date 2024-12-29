//
//  WelcomeElement.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 16/12/2024.
//

import Foundation

// MARK: - WelcomeElement
struct WelcomeElement: Codable {
    let id, trNo, routeID: Int
    let stationCode: String
    let arrivalTime: Date?
    let departureTime: Date
    let stopTime: Int
}

typealias Welcome = [WelcomeElement]


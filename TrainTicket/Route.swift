//
//  Route.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 05/12/2024.
//

import Foundation

struct Route: Codable {
    let id: Int
    let routeName: String
    let startStation: String
    let stopStation: String
    let endStation: String
    let distance: Int
}

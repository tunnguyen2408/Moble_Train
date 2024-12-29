//
//  Price.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation


struct Price: Codable {
    let id: Int
    let trNo: Int
    let typeID: Int
    let routeID: Int
    let fare: Double
    let effectiveDate: String
}

//
//  RouteData.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation
struct RouteData: Codable {
    let id: Int
    let routeName: String
    let stopStation: String
    let startStation: String
    let endStation: String
    let distance: Int
    // Thêm các trường khác theo cấu trúc JSON
}

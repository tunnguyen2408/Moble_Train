//
//  Train.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation

struct Train: Codable {
    let id: Int
    let trName: String
    let trType: String?
    let seats: Int
    let description: String?
}


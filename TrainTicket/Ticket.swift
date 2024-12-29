//
//  Ticket.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 17/12/2024.
//

import Foundation

struct Ticket: Codable {
    let trNo: Int
    let schedule: Int
    let mailid: String
    let typeID: Int
    let seatNumber: String
    let bookingDate: Date
    let status: String
    let price: Double
}

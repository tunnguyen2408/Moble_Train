//
//  Customer.swift
//  TrainTicket
//
//  Created by Tũn Nguyễn on 02/12/2024.
//

import Foundation

struct Customer: Codable {
    let mailid: String
    let pword: String
    let fname: String
    let lname: String
    let addr: String
    let phno: Int
    let dob: String
    let gender: String
}

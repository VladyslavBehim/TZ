//
//  Player.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import Foundation

struct Player: Codable {
    var username: String
    var chips: Int
    var wins: Int
    var losses: Int
    var totalSpins: Int
    var winRate: Double
}

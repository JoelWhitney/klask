//
//  DataModels.swift
//  klask
//
//  Created by Joel Whitney on 1/9/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

// MARK: - Standing
struct Standing {
    var user: KlaskUser
    var wins: Int
    var losses: Int
    var goalsfor: Int
    var goalsagainst: Int
    var goalsdiff: Int
    var winpercentage: Double
    var rank: Int?
    
    init(user: KlaskUser, wins: Int, losses: Int, goalsfor: Int, goalsagainst: Int) {
        self.user = user
        self.wins = wins
        self.losses = losses
        self.goalsfor = goalsfor
        self.goalsagainst = goalsagainst
        self.goalsdiff = goalsfor - goalsagainst
        self.winpercentage = { () -> Double in
            let total = wins + losses
            if total == 0 {
                return 0.0
            } else {
                let percentage = (( Double(wins) / Double(total) ) * 100.0)
                print(percentage)
                return percentage
            }
        }()
    }
}

extension Standing: Equatable {
    static func == (lhs: Standing, rhs: Standing) -> Bool {
        return lhs.user == rhs.user &&
            lhs.wins == rhs.wins &&
            lhs.losses == rhs.losses &&
            lhs.goalsfor == rhs.goalsfor &&
            lhs.goalsagainst == rhs.goalsagainst &&
            lhs.goalsdiff == rhs.goalsdiff &&
            lhs.winpercentage == rhs.winpercentage
    }
}

// MARK: - KlaskGame
struct KlaskGame: Codable {
    var gid: String?
    let datetime: Double?
    let arenaid: String?
    var player1id: String?
    var player1score: Int?
    var player2id: String?
    var player2score: Int?
    
    init() {
        self.datetime = NSDate().timeIntervalSince1970
        self.arenaid = DataStore.shared.activearena?.aid
    }
}

// MARK: - KlaskUser
struct KlaskUser: Codable {
    let uid: String?
    var arenasjoined: [String]?
    let name: String?
    var email: String?
    let nickname: String?
    let photourl: String?
    
    init(uid: String, arenasjoined: [String], name: String, email: String, photourl: String, nickname: String) {
        self.uid = uid
        self.arenasjoined = arenasjoined
        self.nickname = nickname
        self.email = email
        self.name = name
        self.photourl = photourl
    }
}

extension KlaskUser: Equatable {
    static func == (lhs: KlaskUser, rhs: KlaskUser) -> Bool {
        return lhs.uid == rhs.uid
    }
}

// MARK: - KlaskArena
struct KlaskArena: Codable {
    let aid: String?
    let arenaname: String?
    var joinedusers: [String]?
}



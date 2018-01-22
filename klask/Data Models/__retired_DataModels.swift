////
////  __retired_DataModels.swift
////  klask
////
////  Created by Joel Whitney on 1/18/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import Foundation
////
////  DataModels.swift
////  klask
////
////  Created by Joel Whitney on 1/9/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import Foundation
//
////class DataStore {
////    static var shared = DataStore()
////
////    var users = [User]()
//////    var current_games = [Game]()
//////    var all_time_games = [Game]()
////    var current_standings = [Standing]()
////    var all_time_standings = [Standing]()
////
////    private init() {
////        reload() {
////            //print("Reloaded \(self.users.count) users and \(self.current_games.count) current games")
////        }
////    }
////
////    func reload(onCompletion: @escaping () -> Void) {
////        DatabaseAPI.sharedInstance.getDatabase(onCompletion: { (data: Data?) in
////            do {
////                guard let data = data else {
////                    return
////                }
////                let decoder = JSONDecoder()
////                let appData = try decoder.decode(AppData.self, from: data)
////                //self.users = appData.users.sorted(by: { $0.first_name < $1.first_name } )
//////                self.current_games = appData.current_games
//////                self.all_time_games = appData.all_time_games
////                //self.calculateCurrentStandings()
////            } catch {
////                print(error)
////            }
////            //self.calculateRankings()
////            onCompletion()
////        })
////    }
//
//
////    private func calculateCurrentStandings() {
////        self.current_standings = users.map { (user: User) in
////            var wins = 0
////            var losses = 0
////            var goals_for = 0
////            var goals_against = 0
////            let employee_games = self.current_games.filter( { ($0.player1 == user.id)  || ($0.player2 == user.id) } )
////            for game in employee_games {
////                if (game.player1 == user.id) {
////                    if (game.player1_pts! > game.player2_pts!) {
////                        wins += 1
////                    } else {
////                        losses += 1
////                    }
////                    goals_for += game.player1_pts!
////                    goals_against += game.player2_pts!
////                } else if (game.player2 == user.id) {
////                    if (game.player2_pts! > game.player1_pts!) {
////                        wins += 1
////                    } else {
////                        losses += 1
////                    }
////                    goals_for += game.player2_pts!
////                    goals_against += game.player1_pts!
////                }
////            }
////            return Standing(user: user, wins: wins, losses: losses, goals_for: goals_for, goals_against: goals_against)
////        }
////            .filter({ ($0.wins + $0.losses) > 0 })
////            .sorted { (standing1, standing2) in
////                if standing1.win_percentage != standing2.win_percentage {
////                    return standing1.win_percentage > standing2.win_percentage
////                } else if standing1.wins != standing2.wins {
////                    return standing1.wins > standing2.wins
////                } else {
////                    return (standing1.wins + standing1.losses) > (standing2.wins + standing2.losses)
////                }
////            }
////    }
////
////    private func calculateRankings() {
////        var rankedStandings = [Standing]()
////        for i in 1...current_standings.count {
////            var standing = current_standings[i - 1]
////            standing.rank = i
////            rankedStandings.append(standing)
////        }
////        self.current_standings = rankedStandings
////    }
////}
//
//
//
//struct Standing {
//    var user: KlaskUser
//    var wins: Int
//    var losses: Int
//    var goals_for: Int
//    var goals_against: Int
//    var goals_diff: Int
//    var win_percentage: Double {
//        let total = wins + losses
//        if total == 0 {
//            return 0.0
//        } else {
//            return ( Double(wins) / Double(total) ) * 100.0
//        }
//    }
//    var rank: Int?
//    
//    init(user: KlaskUser, wins: Int, losses: Int, goals_for: Int, goals_against: Int) {
//        self.user = user
//        self.wins = wins
//        self.losses = losses
//        self.goals_for = goals_for
//        self.goals_against = goals_against
//        self.goals_diff = goals_for - goals_against
//    }
//}
//
//
//struct Game: Codable {
//    let datetime: Double?
//    let arenaid: String?
//    var player1id: Int?
//    var player1score: Int?
//    var player2id: Int?
//    var player2score: Int?
//}
//
//class ActiveUser {
//    static var shared = ActiveUser()
//    
//    var activeUser: KlaskUser? {
//        didSet {
//            if let activeUser = activeUser {
//                saveActiveUser(activeUser: activeUser)
//            }
//        }
//    }
//    
//    private init() {
//        getActiveUser()
//    }
//    
//    func getActiveUser() {
//        do {
//            if let employeeData = UserDefaults.standard.value(forKey: "activeuser") as? Data {
//                let decodedUser = try JSONDecoder().decode(KlaskUser.self, from: employeeData)
//                activeUser = decodedUser
//            } else {
//                activeUser = nil
//            }
//        } catch {
//            activeUser = nil
//        }
//    }
//    
//    func saveActiveUser(activeUser: KlaskUser) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(activeUser){
//            UserDefaults.standard.set(encoded, forKey: "current_employee")
//        }
//    }
//    
//}
//
//struct KlaskUser: Codable {
//    let uid: String?
//    let arenasjoined: [String]?
//    let name: String?
//    var email: String?
//    let nickname: String?
//    let photourl: String?
//    
//    init(uid: String, arenasjoined: [String], name: String, email: String, photourl: String, nickname: String) {
//        self.uid = uid
//        self.arenasjoined = arenasjoined
//        self.nickname = nickname
//        self.email = email
//        self.name = name
//        self.photourl = photourl
//    }
//}
//
//

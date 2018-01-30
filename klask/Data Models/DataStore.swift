//
//  DataStore.swift
//  klask
//
//  Created by Joel Whitney on 1/20/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

typealias FirebaseArenaClosure = (KlaskArena?) -> Void
typealias FirebaseArenasClosure = ([KlaskArena]) -> Void
typealias FirebaseArenaUsersClosure = ([KlaskUser]) -> Void
typealias FirebaseGameClosure = ([KlaskGame]) -> Void


// MARK: - Delegates
protocol StandingsDelegate {
    func reloadStandings()
}

protocol ArenaUsersDelegate {
    func reloadArenaUsers()
}

protocol ArenasJoinedDelegate {
    func reloadArenasJoined()
}

// MARK: - Enums
enum StandingsTimeframe: String {
    case Day
    case Week
    case Month
    case Alltime
    
    mutating func cycleTimeFrame() {
        switch self {
        case .Day:
            self = .Week
        case .Week:
            self = .Month
        case .Month:
            self = .Alltime
        case .Alltime:
            self = .Day
        }
    }
}

enum StandingsType: String {
    case Goals
    case Wins
    
    mutating func cycleType() {
        switch self {
        case .Goals:
            self = .Wins
        case .Wins:
            self = .Goals
        }
    }
}

// MARK: - DataStore
class DataStore {

    static var shared = DataStore()
    
    let ref = Database.database().reference()
    
    var standingsDelegate: StandingsDelegate?
    var arenaUsersDelegate: ArenaUsersDelegate?
    var arenasJoinedDelegate: ArenasJoinedDelegate?
    
    private init() {
        getUserDefaults()
    }
    
    // MARK: - Variables
    //actives
    var activeuser: KlaskUser? {
        didSet {
            saveUserDefaults()
            getArenasJoined() { arenas in
                self.arenasjoined = arenas
            }
        }
    }
    var activearena: KlaskArena? {
        didSet {
            saveUserDefaults()
            observeArenaGames() { games in
                self.arenagames = games
            }
            observeForUserRemoved()
            observeForUserAdded()
            observeForUserChanged()
        }
    }
    //user details
    var arenasjoined = [KlaskArena]() {
        didSet {
            arenasJoinedDelegate?.reloadArenasJoined()
        }
    }
    //arena details
    var arenausers: [KlaskUser]? {
        didSet {
            arenaUsersDelegate?.reloadArenaUsers()
        }
    }
    var arenagames = [KlaskGame]() {
        didSet {
            calculateStandings()
        }
    }
    //standings
    var standingsTimeframe: StandingsTimeframe = .Week {
        didSet {
            calculateStandings()
        }
    }
    var standingsType: StandingsType = .Wins {
        didSet {
            calculateStandings()
        }
    }
    var standings: [Standing]? {
        didSet {
            standingsDelegate?.reloadStandings()
        }
    }

    // MARK: - User defaults methods
    func getUserDefaults() {
        if let encodeduser = UserDefaults.standard.value(forKey: "activeuser") as? Data, let encodedarena = UserDefaults.standard.value(forKey: "activearena") as? Data {
            self.activeuser = try? PropertyListDecoder().decode(KlaskUser.self, from: encodeduser)
            self.activearena = try? PropertyListDecoder().decode(KlaskArena.self, from: encodedarena)
        } else {
            self.activeuser = nil
            self.activearena = nil
        }
    }
    
    func saveUserDefaults() {
        if let activeuser = activeuser, let activearena = activearena {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(activeuser), forKey: "activeuser")
            UserDefaults.standard.set(try? PropertyListEncoder().encode(activearena), forKey: "activearena")
        }
    }
    
    // MARK: - GET methods
    func getActiveUser(_ user: User) {
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // need to create user in users table
            guard snapshot.exists() else {
                self.activeuser = KlaskUser(uid: user.uid, name: user.displayName!, email: user.email!, nickname: "", photourl: (user.photoURL?.absoluteString)!)
                self.postActiveUser()
                return
            }
            
            // found user in users table
            guard let value = snapshot.value  else { return }
            do {
                self.activeuser  = try FirebaseDecoder().decode(KlaskUser.self, from: value)
            } catch {
                print(error)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getArenasJoined(onComplete: @escaping FirebaseArenasClosure) {
        var arenas = [KlaskArena]()
        
        let dispatchGroup = DispatchGroup()
        
        if let arenaaids = activeuser?.arenasjoined {
            
            for aid in arenaaids {

                dispatchGroup.enter()
                ref.child("arenas").child(aid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let value = snapshot.value  else { return }
                    do {
                        arenas.append(try FirebaseDecoder().decode(KlaskArena.self, from: value))
                    } catch {
                        print(error)
                    }
                    dispatchGroup.leave()
                }) { (error) in
                    print(error.localizedDescription)
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            onComplete(arenas)
        }
    }
    
    func getArena(aid: String, onComplete: @escaping FirebaseArenaClosure) {
        var arena: KlaskArena?
        
        ref.child("arenas").child(aid).observeSingleEvent(of: .value, with: { (snapshot) in
        
            guard let value = snapshot.value  else { return }
        
            do {
                arena = try FirebaseDecoder().decode(KlaskArena.self, from: value)
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async() {
                onComplete(arena)
            }
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    func observeArenaGames(onComplete: @escaping FirebaseGameClosure) {
        var games = [KlaskGame]()
        
        if let activearena = activearena {
            ref.child("games").queryOrdered(byChild: "arenaid").queryEqual(toValue: activearena.aid).observe(.value, with: { (snapshot) in
                
                guard let value = snapshot.value  else { return }
                games = []
                
                do {
                    let arenaDict = try FirebaseDecoder().decode([String: KlaskGame].self, from: value)
                    for (_, value) in arenaDict {
                        games.append(value)
                    }
                } catch {
                    print(error)
                }
                
                // call completion handler on the main thread.
                DispatchQueue.main.async() {
                    onComplete(games)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func searchArenas(arenaname: String, onComplete: @escaping FirebaseArenasClosure) {
        var arenas = [KlaskArena]()
        ref.child("arenas").queryOrdered(byChild: "arenaname").queryEqual(toValue: arenaname).observeSingleEvent(of: .value, with: { (snapshot) in
        
            guard let value = snapshot.value  else { return }

            do {
                let arenaDict = try FirebaseDecoder().decode([String: KlaskArena].self, from: value)
                for (_, value) in arenaDict {
                    arenas.append(value)
                    print(arenas)
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async() {
                onComplete(arenas)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func observeForUserAdded() {
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            guard let value = snapshot.value  else { return }

            do {
                let user  = try FirebaseDecoder().decode(KlaskUser.self, from: value)
                
                if let arenausers = self.arenausers {
                    guard !arenausers.contains(user) else { return } // return if exists
                }
                
                self.observedUserChangesPredicateMet(user)
                
            } catch {
                print(error)
            }
        })
    }
    
    func observeForUserChanged() {
        ref.child("users").observe(.childChanged, with: { (snapshot) in
            guard let value = snapshot.value  else { return }
            
            do {
                let user  = try FirebaseDecoder().decode(KlaskUser.self, from: value)
                
                if let arenausers = self.arenausers {
                    guard let existinguser = arenausers.first(where: { existing in (existing.uid == user.uid) }), existinguser != user else { return } // don't reload if user not updated with certain properties
                }
            
                self.observedUserChangesPredicateMet(user)
                
            } catch {
                print(error)
            }
        })
    }
    
    func observeForUserRemoved() {
        ref.child("users").observe(.childRemoved, with: { (snapshot) in
            guard let value = snapshot.value  else { return }
            
            do {
                let user  = try FirebaseDecoder().decode(KlaskUser.self, from: value)
                
                if let arenausers = self.arenausers {
                    guard arenausers.contains(where: { existing in (existing.uid == user.uid) }) else { return } // return if does not exist in arena
                }
                
                self.observedUserChangesPredicateMet(user)
                
            } catch {
                print(error)
            }
        })
    }
    
    // MARK: - Private GET methods
    private func observedUserChangesPredicateMet(_ user: KlaskUser) {
        if let activearena = self.activearena, let arenasjoined = user.arenasjoined {
            
            self.getArena(aid: activearena.aid!, onComplete: { arena in
                if let arena = arena, arenasjoined.contains(arena.aid!) {
                    self.activearena = arena
                    
                    self.updatedArenaUsers(onComplete: { users in
                        DispatchQueue.main.async {
                            self.arenausers = users
                        }
                    })
                    
                }
            })
            
        }
    }

    private func updatedArenaUsers(onComplete: @escaping FirebaseArenaUsersClosure) {
        var arenausers = [KlaskUser]()
        
        let dispatchGroup = DispatchGroup()
        
        if let activearena = activearena {
            
            guard let joinedusers = activearena.joinedusers else { return }
            
            for uid in joinedusers {
                
                dispatchGroup.enter()
                ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let value = snapshot.value  else { return }
                    do {
                        let user = try FirebaseDecoder().decode(KlaskUser.self, from: value)
                        arenausers.append(user)
                    } catch {
                        print(error)
                    }
                    dispatchGroup.leave()
                }) { (error) in
                    print(error.localizedDescription)
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            onComplete(arenausers)
        }
    }
    
    // MARK: - POST methods
    func postActiveUser() {
        do {
            guard let activeuser = activeuser, let uid = activeuser.uid else { return }
            let newUser = try FirebaseEncoder().encode(activeuser)
            ref.child("users").child(uid).setValue(newUser)
        } catch {
            print(error)
        }
    }
    
    func postGame(_ game: KlaskGame) {
        var newGame = game
        do {
            let postRef = ref.child("games").childByAutoId()
            newGame.gid = postRef.key
            let game = try FirebaseEncoder().encode(newGame)
            postRef.setValue(game)
        } catch {
            print(error)
        }
    }
    
    func updateArena(_ arena: KlaskArena) {
        do {
            let updateArena = try FirebaseEncoder().encode(arena)
            ref.child("arenas").child(arena.aid!).setValue(updateArena)
        } catch {
            print(error)
        }
    }
    
    func updateUser(_ user: KlaskUser) {
        do {
            let updateUser = try FirebaseEncoder().encode(user)
            ref.child("users").child(user.uid!).setValue(updateUser)
        } catch {
            print(error)
        }
    }
    
    // MARK: - DELETE methods
    func deleteGame(_ game: KlaskGame) {
        ref.child("games").child(game.gid!).removeValue { error, ref  in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    // MARK: - Private methods
    private func calculateStandings() {
        if let arenausers = arenausers {
            var relevantgames = [KlaskGame]()
            
            switch standingsTimeframe {
            case .Day:
                relevantgames = arenagames.filter( {$0.datetime! >= (Calendar.current.date(byAdding: .day, value: -1, to: Date())?.timeIntervalSince1970)! } )
            case .Week:
                relevantgames = arenagames.filter( {$0.datetime! >= (Calendar.current.date(byAdding: .day, value: -7, to: Date())?.timeIntervalSince1970)! } )
            case .Month:
                relevantgames = arenagames.filter( {$0.datetime! >= (Calendar.current.date(byAdding: .day, value: -30, to: Date())?.timeIntervalSince1970)! } )
            case .Alltime:
                relevantgames = arenagames
            }

            self.standings = arenausers.map{ (klaskuser: KlaskUser) in
                var wins = 0
                var losses = 0
                var goalsfor = 0
                var goalsagainst = 0
                let usergames = relevantgames.filter( { ($0.player1id == klaskuser.uid)  || ($0.player2id == klaskuser.uid) } )
                for game in usergames {
                    if (game.player1id == klaskuser.uid) {
                        if (game.player1score! > game.player2score!) {
                            wins += 1
                        } else {
                            losses += 1
                        }
                        goalsfor += game.player1score!
                        goalsagainst += game.player2score!
                    } else if (game.player2id == klaskuser.uid) {
                        if (game.player2score! > game.player1score!) {
                            wins += 1
                        } else {
                            losses += 1
                        }
                        goalsfor += game.player2score!
                        goalsagainst += game.player1score!
                    }
                }
                return Standing(user: klaskuser, wins: wins, losses: losses, goalsfor: goalsfor, goalsagainst: goalsagainst)
                }
                // .filter({ ($0.wins + $0.losses) > 0 })
                .sorted { (standing1, standing2) in
                    switch standingsType {
                    case .Wins:
                        if standing1.winpercentage != standing2.winpercentage {
                            return standing1.winpercentage > standing2.winpercentage
                        } else if standing1.wins != standing2.wins {
                            return standing1.wins > standing2.wins
                        } else {
                            return (standing1.wins + standing1.losses) > (standing2.wins + standing2.losses)
                        }
                    case .Goals:
                        return standing1.goalsdiff > standing2.goalsdiff
                    }
            }
        }
    }
}

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

typealias FirebaseArenaClosure = ([KlaskArena]?) -> Void
typealias FirebaseArenaUsersClosure = ([KlaskUser]?) -> Void
typealias FirebaseGameClosure = ([KlaskGame]?) -> Void

protocol StandingsDelegate {
    func reloadStandings()
}

protocol ArenaUsersDelegate {
    func reloadArenaUsers()
}

protocol ArenasJoinedDelegate {
    func reloadArenasJoined()
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
                if let arenas = arenas {
                    self.arenasjoined = []
                    self.arenasjoined = arenas
                }
            }
        }
    }
    var activearena: KlaskArena? {
        didSet {
            saveUserDefaults()
            observeArenaGames() { games in
                if let games = games {
                    self.arenagames = []
                    self.arenagames = games
                }
            }
            getArenaUsers() { arenausers in
                if let arenausers = arenausers {
                    self.arenausers = []
                    self.arenausers = arenausers
                }
            }
//            observeArenaUsers() { arenausers in
//                if let arenausers = arenausers {
//                    self.arenausers = []
//                    self.arenausers = arenausers
//                }
//            }
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
    var standings: [Standing]? {
        didSet {
            standingsDelegate?.reloadStandings()
        }
    }
    
    // MARK: - Local cache methods
    func getUserDefaults() {
        do {
            if let userData = UserDefaults.standard.value(forKey: "activeuser") as? Data, let arenaData =  UserDefaults.standard.value(forKey: "activearena") as? Data{
                let decodedUser = try JSONDecoder().decode(KlaskUser.self, from: userData)
                let decodedArena = try JSONDecoder().decode(KlaskArena.self, from: arenaData)
                self.activeuser = decodedUser
                self.activearena = decodedArena
            } else {
                self.activeuser = nil
                self.activearena = nil
            }
        } catch {
            print(error)
        }
    }
    
    func saveUserDefaults() {
        let encoder = JSONEncoder()
        if let encodeduser = try? encoder.encode(activeuser), let encodedarena = try? encoder.encode(activearena) {
            UserDefaults.standard.set(encodeduser, forKey: "activeuser")
            UserDefaults.standard.set(encodedarena, forKey: "activearena")
        }
    }
    
    // MARK: - GET methods
    func getActiveUser(_ user: User) {
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // need to create user in users table
            guard snapshot.exists() else {
                self.activeuser = KlaskUser(uid: user.uid, name: user.displayName!, email: user.email!, photourl: (user.photoURL?.absoluteString)!, nickname: "")
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
    
    func getArenasJoined(onComplete: @escaping FirebaseArenaClosure) {
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
            if arenas.isEmpty {
                onComplete(nil)
            }else {
                onComplete(arenas)
            }
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
                    if games.isEmpty {
                        onComplete(nil)
                    }else {
                        onComplete(games)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func searchArenas(arenaname: String, onComplete: @escaping FirebaseArenaClosure) {
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
                if arenas.isEmpty {
                    onComplete(nil)
                }else {
                    onComplete(arenas)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func observeArenaUsers(onComplete: @escaping FirebaseArenaUsersClosure) {
        
        if let activearena = activearena {
            for uid in activearena.joinedusers {
                
                ref.child("users").child(uid).observe(.value, with: { (snapshot) in
                    
                    guard let value = snapshot.value, var arenausers = self.arenausers else { return }
                    print(value)
                    do {
                        let user = try FirebaseDecoder().decode(KlaskUser.self, from: value)
                        guard let userIndex = arenausers.index(where: {$0.uid == user.uid} ) else { return }
                        arenausers[userIndex] = user
                    } catch {
                        print(error)
                    }

                    // call completion handler on the main thread.
                    DispatchQueue.main.async() {
                        if arenausers.isEmpty {
                            onComplete(nil)
                        } else {
                            onComplete(arenausers)
                        }
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func getArenaUsers(onComplete: @escaping FirebaseArenaUsersClosure) {
        var arenausers = [KlaskUser]()
        
        let dispatchGroup = DispatchGroup()
        
        if let activearena = activearena {
            for uid in activearena.joinedusers {
                
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
            if arenausers.isEmpty {
                onComplete(nil)
            }else {
                onComplete(arenausers)
            }
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
        // ran into permission denied issue trying to use updateArena flow (maybe rules?) had to remove and then add
        ref.child("users").child(user.uid!).removeValue { error, ref1  in
            if error != nil {
                print("error \(String(describing: error))")
            }
            do {
                let updateUser = try FirebaseEncoder().encode(user)
                ref1.setValue(updateUser)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Delete methods
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
            self.standings = arenausers.map{ (klaskuser: KlaskUser) in
                var wins = 0
                var losses = 0
                var goalsfor = 0
                var goalsagainst = 0
                let usergames = self.arenagames.filter( { ($0.player1id == klaskuser.uid)  || ($0.player2id == klaskuser.uid) } )
                print("arena games fitlered to \(usergames.count)")
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
                    if standing1.winpercentage != standing2.winpercentage {
                        return standing1.winpercentage > standing2.winpercentage
                    } else if standing1.wins != standing2.wins {
                        return standing1.wins > standing2.wins
                    } else {
                        return (standing1.wins + standing1.losses) > (standing2.wins + standing2.losses)
                    }
            }
        }
    }
}

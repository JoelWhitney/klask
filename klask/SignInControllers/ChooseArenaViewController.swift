//
//  ChooseArenaViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/20/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CodableFirebase

class ChooseArenaViewController: UIViewController, ArenasJoinedDelegate {
    
    // MARK: - Variables
    var arenas = [[KlaskArena]]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedArena: KlaskArena!
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var signOut: UIBarButtonItem!
    
    
    // MARK: - IBActions
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.shared.arenasJoinedDelegate = self
        
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            print("Already signed in as \(String(describing: currentUser.displayName)) (\(String(describing: currentUser.email)))")
            DataStore.shared.getUserDefaults()
        } else {
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
        }
        tableView.tableFooterView = UIView()
        
        arenas.append(DataStore.shared.arenasjoined)
    }
    
    // MARK: - Methods
    func reloadArenasJoined() {
        print("reload arenas")
        var arenas = self.arenas
        if arenas.count == 1{
            arenas[0] = DataStore.shared.arenasjoined
        }
        self.arenas = arenas
    }
}

// MARK: - search bar delegate
extension ChooseArenaViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            DataStore.shared.searchArenas(arenaname: searchText) { matchingarenas in
                if let matchingarenas = matchingarenas  {
                    if self.arenas.count == 1 {
                        self.arenas.insert(matchingarenas, at: 0)
                    } else {
                        self.arenas[0] = matchingarenas
                    }
                } else {
                    if self.arenas.count == 2 {
                        self.arenas[0] = []
                    } else {
                        self.arenas.insert([], at: 0)
                    }
                }
            }
        }
        else {
            arenas = [DataStore.shared.arenasjoined]
        }
    }
}

// MARK: - tableView data source
extension ChooseArenaViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arenas.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if arenas.count == 2 {
            if section == 0 {
                return "Matching Arenas"
            } else {
                return "Arenas Joined"
            }
        } else {
            return "Arenas Joined"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arenas.count == 2 {
            return arenas[section].count
        } else {
            return arenas[0].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arenaCell = self.tableView!.dequeueReusableCell(withIdentifier: "ArenaCell", for: indexPath) as! ArenaCell
        var arena: KlaskArena!
        if arenas.count == 2 {
            if indexPath.section == 0 {
                arena = arenas[indexPath.section][indexPath.row]
            } else {
                arena = arenas[indexPath.section][indexPath.row]
            }
        } else {
            arena = arenas[indexPath.section][indexPath.row]
        }
        // cell details
        arenaCell.arenaNameLabel.text = arena.arenaname ?? ""
        arenaCell.numberJoinedLabel.text = "\(String(describing: arena.joinedusers.count)) playing"
        return arenaCell
    }
}


// MARK: - tableView delegate
extension ChooseArenaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var arena = arenas[indexPath.section][indexPath.row]
        guard var activeuser = DataStore.shared.activeuser else { return }
        if let arenasjoined = activeuser.arenasjoined, !arenasjoined.contains(arena.aid!) {
            if arenas.count == 2, indexPath.section == 0 {
                // joining new arena
                
                // update arena
                if arena.joinedusers == nil {
                    arena.joinedusers = []
                }
                arena.joinedusers.append(activeuser.uid!)
                DataStore.shared.updateArena(arena)
                
                // update user
                if activeuser.arenasjoined == nil {
                    activeuser.arenasjoined = []
                }
                activeuser.arenasjoined?.append(arena.aid!)
                DataStore.shared.updateUser(activeuser)
                
            }
        }
        DataStore.shared.activearena = arena
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - tableView cell
class ArenaCell: UITableViewCell {
    @IBOutlet var arenaNameLabel: UILabel!
    @IBOutlet var numberJoinedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

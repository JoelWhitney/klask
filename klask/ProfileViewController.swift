//
//  ProfileViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/9/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import UIKit
import Foundation
import GoogleSignIn
import Firebase

class ProfileViewController: UIViewController, StandingsDelegate {
    // MARK: - Variables
    var selectedUser: Standing?
    var userstanding: Standing? {
        return DataStore.shared.standings?.filter( { $0.user.uid == self.selectedUser?.user.uid } ).first
    }
    var usergames: [KlaskGame]? {
        return DataStore.shared.arenagames.filter( { $0.player1id == (self.selectedUser?.user.uid) || $0.player2id == (self.selectedUser?.user.uid) } )
            .sorted(by: { $0.datetime! > $1.datetime! } )
    }
    weak var addUpdateAction: UIAlertAction?

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var signOut: UIBarButtonItem!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popViewController(animated: true)
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.shared.delegate = self
        tableView.tableFooterView = UIView()
        updateUserInfo()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func updateUserInfo() {
        if let userstanding = self.userstanding, let standings = DataStore.shared.standings {
            if let image = UIImage(named: userstanding.user.name!) {
                profileImage.image = image
            } else if let photourl = userstanding.user.photourl, photourl != "" {
                profileImage.downloadedFrom(url: URL(string: photourl)!)
            } else {
                profileImage.image = #imageLiteral(resourceName: "Default")
            }
            if userstanding.user.nickname != "" {
                nameLabel.text = "\(String(describing: userstanding.user.nickname!))"
                nickNameLabel.text = "\(String(describing: userstanding.user.name!))"
            } else {
                nameLabel.text = "\(String(describing: userstanding.user.name!))"
                nickNameLabel.text = ""
            }
            rankLabel.text = "# \(String(describing: standings.index(of: userstanding)! + 1))"
        }
    }
    
    func reloadStandings() {
        print("profile reloading")
        DispatchQueue.main.async {
            self.updateUserInfo()
            self.tableView.reloadData()
        }
    }
}

// MARK: - tableView data source
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Komika Slim", size: 15)
        header.textLabel?.textColor = #colorLiteral(red: 0.6729776263, green: 0.6734990478, blue: 0.6730583906, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
        view.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.contentView.backgroundColor = #colorLiteral(red: 0.1865964234, green: 0.1867694855, blue: 0.1866232157, alpha: 1)
        if section == 0 {
            view.textLabel?.text = "Stats"
        } else {
            view.textLabel?.text = "Games"
        }
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return usergames?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "ProfileSummaryCell", for: indexPath) as! ProfileSummaryCell
            if indexPath.row == 0 {
                // cell details
                if let userstanding = userstanding {
                    cell.primaryLabel.text = "Record"
                    cell.secondaryLabel.text = "\(userstanding.wins) win, \(userstanding.losses) losses · \(String(format: "%.0f", userstanding.winpercentage))%"
                }
                return cell
            } else {
                // cell details
                if let userstanding = userstanding {
                    cell.primaryLabel.text = "Total Goals"
                    cell.secondaryLabel.text = "\(userstanding.goalsfor) for · \(userstanding.goalsagainst) against"
                }
                return cell
            }
        } else {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "ProfileGameCell", for: indexPath) as! ProfileGameCell
            if let usergames = usergames, let userstanding = userstanding, let arenausers = DataStore.shared.arenausers {
                let game = usergames[indexPath.row]
                let userscore = (game.player1id == userstanding.user.uid) ? game.player1score : game.player2score
                let opponentscore = (game.player1id != userstanding.user.uid) ? game.player1score : game.player2score
                let opponentid = ((game.player1id != userstanding.user.uid) ? game.player1id : game.player2id)
                guard let opponent = arenausers.filter( {$0.uid == opponentid!} ).first else { return cell }
                // cell details
                if let image = UIImage(named: opponent.name!) {
                    cell.profileImage.image = image
                } else if let photourl = opponent.photourl, photourl != "" {
                    cell.profileImage.downloadedFrom(url: URL(string: photourl)!)
                } else {
                    cell.profileImage.image = #imageLiteral(resourceName: "Default")
                }
                if opponent.nickname != "" {
                    cell.nameLabel.text = "\(String(describing: opponent.nickname!))"
                    cell.nickNameLabel.text = "\(String(describing: opponent.name!))"
                } else {
                    cell.nameLabel.text = "\(String(describing: opponent.name!))"
                    cell.nickNameLabel.text = ""
                }
                cell.scoreLabel.text = "\(String(describing: userscore!)) - \(String(describing: opponentscore!))"
                if (userscore! > opponentscore!) {
                    cell.scoreLabel.backgroundColor = #colorLiteral(red: 0.6241136193, green: 0.8704479337, blue: 0.3534047008, alpha: 1)
                } else {
                    cell.scoreLabel.backgroundColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
                }
            }
            return cell
        }
    }
    

    @objc
    func addGame(_ sender: UIBarButtonItem) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SubmitGame", bundle: nil)
        let selectWinnerViewController = storyBoard.instantiateViewController(withIdentifier: "SelectWinnerViewController") as! SelectWinnerViewController
        selectWinnerViewController.challenger = userstanding?.user
        self.navigationController?.pushViewController(selectWinnerViewController, animated: true)
    }
    
    
    @objc
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        // Enforce a minimum length of >= 1 for secure text alerts.
        addUpdateAction!.isEnabled = !(textField.text?.isEmpty)!
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            if let usergames = self.usergames {
                let game = usergames[indexPath.row]
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this game?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alert) -> Void in
                    print("deleting")
                    print(game.gid!)
                    DataStore.shared.deleteGame(game)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        action.image = UIImage(named: "Trash")
        action.backgroundColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
        return action
    }
    
}


// MARK: - tableView delegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let usergames = usergames, let activeuser = DataStore.shared.activeuser {
            if indexPath.section == 1, usergames.count >= indexPath.row {
                let game = usergames[indexPath.row]
                if (activeuser.uid == game.player1id!) || (activeuser.uid == game.player2id!) {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
}

// MARK: - tableView cell
class ProfileSummaryCell: UITableViewCell {
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class ProfileGameCell: UITableViewCell {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


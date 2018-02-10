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
import UserNotifications

class ProfileViewController: UIViewController, StandingsDelegate, ArenaUsersDelegate {
    // MARK: - Variables
    var selectedUser: Standing?
    var userstandinguid: String?
    var userstanding: Standing? {
        return DataStore.shared.standings?.filter( { $0.user.uid == userstandinguid } ).first
    }
    var usergames: [KlaskGame]? {
        switch DataStore.shared.standingsTimeframe {
        case .Today:
            return DataStore.shared.arenagames.filter({ ($0.player1id == (userstandinguid) || $0.player2id == (userstandinguid)) && ($0.datetime! >= Date().startTime().timeIntervalSince1970) } ).sorted(by: { $0.datetime! > $1.datetime! })
        case .Week:
            return DataStore.shared.arenagames.filter({ ($0.player1id == (userstandinguid) || $0.player2id == (userstandinguid)) && ($0.datetime! >= (Calendar.current.date(byAdding: .day, value: -7, to: Date())?.timeIntervalSince1970)!) } ).sorted(by: { $0.datetime! > $1.datetime! })
        case .Month:
            return DataStore.shared.arenagames.filter({ ($0.player1id == (userstandinguid) || $0.player2id == (userstandinguid)) && ($0.datetime! >= (Calendar.current.date(byAdding: .day, value: -30, to: Date())?.timeIntervalSince1970)!) } ).sorted(by: { $0.datetime! > $1.datetime! })
        case .Alltime:
            return DataStore.shared.arenagames.filter({ $0.player1id == (userstandinguid) || $0.player2id == (userstandinguid) }).sorted(by: { $0.datetime! > $1.datetime! })
        }
    }
    weak var addUpdateAction: UIAlertAction?

    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var actionFAB: UIButton!
    
    // MARK: - IBAction
    @IBAction func presentActionPickerController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ActionPicker", bundle: nil)
        let actionPickerViewController = storyBoard.instantiateViewController(withIdentifier: "ActionPickerViewController") as! ActionPickerViewController
        actionPickerViewController.userstanding = self.userstanding
        self.present(actionPickerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.shared.standingsDelegate = self
        DataStore.shared.arenaUsersDelegate = self
        tableView.tableFooterView = UIView()
        buttonUI()
        updateUserInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        setBottomGradientView()
        CATransaction.commit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userstanding?.user.uid == DataStore.shared.activeuser?.uid {
            let overflowButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Overflow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(overflowMenu))
            self.navigationItem.rightBarButtonItem = overflowButton
        } else {
//            let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Add"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addGame))
//            self.navigationItem.rightBarButtonItem = addButton
        }
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
    
    func buttonUI() {
        actionFAB.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        actionFAB.layer.borderWidth = 1.5
        if userstanding?.user.uid == DataStore.shared.activeuser?.uid {
            actionFAB.isEnabled = false
            actionFAB.alpha = 0.0
        } else {
            actionFAB.isEnabled = true
            actionFAB.alpha = 1.0
        }
    }
    
    func reloadStandings() {
        DispatchQueue.main.async {
            self.updateUserInfo()
            self.tableView.reloadData()
        }
    }
    
    func reloadArenaUsers() {
        DispatchQueue.main.async {
            self.updateUserInfo()
            self.tableView.reloadData()
        }
    }
    
    func setBottomGradientView() {
        var gradientLayer: CAGradientLayer!
        
        let colorTop = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomGradientView.bounds
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        bottomGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func overflowMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit Nickname", style: .default , handler:{ (UIAlertAction) in
            self.editNickname()
        }))
        alert.addAction(UIAlertAction(title: "Switch Arena", style: .default , handler:{ (UIAlertAction) in
            DataStore.shared.activearena = nil
            DataStore.shared.saveUserDefaults()
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChooseArena", bundle: nil)
            let chooseArenaViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseArenaViewController") as! ChooseArenaViewController
            self.present(chooseArenaViewController, animated: true, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive , handler:{ (UIAlertAction) in
            self.signOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        self.present(alert, animated: true, completion: nil)
    }

    
    @objc func addGame(_ sender: UIBarButtonItem) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SubmitGame", bundle: nil)
        let selectWinnerViewController = storyBoard.instantiateViewController(withIdentifier: "SelectWinnerViewController") as! SelectWinnerViewController
        selectWinnerViewController.challenger = userstanding?.user
        self.navigationController?.pushViewController(selectWinnerViewController, animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        addUpdateAction!.isEnabled = !(textField.text?.isEmpty)!
    }
    
    private func editNickname() {
        let nickname = self.userstanding?.user.nickname ?? ""
        
        let alert = UIAlertController(title: "Edit Nickname", message: "Enter a creative nickname", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = nickname
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            
        }
        addUpdateAction = UIAlertAction(title: "Update", style: .default, handler: { [weak alert] (_) in
            let newNickname = alert?.textFields![0].text ?? ""
            guard var user = self.userstanding?.user else { return }
            user.nickname = newNickname
            DataStore.shared.updateUser(user)
        })
        addUpdateAction?.isEnabled = !(nickname.isEmpty)
        alert.addAction(addUpdateAction!)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: {
            DispatchQueue.main.async {
                self.updateUserInfo()
            }
        })
    }

    private func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
            DataStore.shared.deleteUserDefaults()
            navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
                    cell.secondaryLabel.text = "\(Int(userstanding.wins)) won, \(Int(userstanding.losses)) lost"
                    cell.tertiaryLabel.text = "\(String(format: "%.0f", userstanding.winpercentage))%"
                }
                return cell
            } else {
                // cell details
                if let userstanding = userstanding {
                    cell.primaryLabel.text = "Goals"
                    cell.secondaryLabel.text = "\(userstanding.goalsfor) for, \(userstanding.goalsagainst) against"
                    cell.tertiaryLabel.text = "\(userstanding.goalsdiff)"
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
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            if let usergames = self.usergames {
                let game = usergames[indexPath.row]
                DataStore.shared.deleteGame(game)
            }
            completionHandler(true)
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
        let swipeDeleteAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeDeleteAction.performsFirstActionWithFullSwipe = false
        return swipeDeleteAction
    }
    
}

// MARK: - tableView cell
class ProfileSummaryCell: UITableViewCell {
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var tertiaryLabel: UILabel!
    
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


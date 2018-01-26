//
//  StandingsViewController
//  klask
//
//  Created by Joel Whitney on 1/9/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import UIKit
import Foundation
import GoogleSignIn
import Firebase
import CodableFirebase

class StandingsViewController: UIViewController, StandingsDelegate, ArenaUsersDelegate {
    
    // MARK: - Variables
    var selectedStanding: Standing?
    var standings = [Standing]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileButton: UIBarButtonItem!
    @IBOutlet var submitButton: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func profile(_ sender: UIBarButtonItem) {
        selectedStanding = DataStore.shared.standings?.filter( { $0.user.uid == DataStore.shared.activeuser?.uid } ).first
        performSegue(withIdentifier: "ProfileViewController", sender: nil)
    }
    
    @IBAction func submitGame(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "SubmitScoreViewController", sender: nil)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DataStore.shared.standingsDelegate = self
        DataStore.shared.arenaUsersDelegate = self

        // auth
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            print("Already signed in as \(String(describing: currentUser.displayName)) (\(String(describing: currentUser.email)))")
            DataStore.shared.getUserDefaults()
        } else {
            presentSignInController()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
        }
  
        // ui
        tableView.tableFooterView = UIView()
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        navigationItem.backBarButtonItem = backButton
        
        reloadStandings()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            print("Already signed in as \(String(describing: currentUser.displayName)) (\(String(describing: currentUser.email)))")
            DataStore.shared.getUserDefaults()
        } else {
            presentSignInController()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
        }
        reloadStandings()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func reloadStandings() {
        print("new user standings")
        guard let newStandings = DataStore.shared.standings else { return }
        print(newStandings)
        standings = newStandings
    }
    
    func reloadArenaUsers() {
        print("new user data")
        reloadStandings()
    }
    
    private func presentSignInController() {
        print("present sign in")
        let storyBoard: UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(signInViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = (segue.destination as? ProfileViewController) {
            destVC.selectedUser = selectedStanding
        }
    }
}

// MARK: - tableView data source
extension StandingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let standings = DataStore.shared.standings {
            print(standings.count)
            return standings.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let standingCell = self.tableView!.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath) as! StandingsCell
        let standing = standings[indexPath.row]
        // cell details
        standingCell.rankLabel.text = String(describing: (standings.index(of: standing)! + 1))
        if let image = UIImage(named: (standing.user.name)!) {
            standingCell.profileImage.image = image
        } else if let photourl = standing.user.photourl, photourl != "" {
            standingCell.profileImage.downloadedFrom(url: URL(string: photourl)!)
        } else {
            standingCell.profileImage.image = #imageLiteral(resourceName: "Default")
        }
        if standing.user.nickname != "" {
            standingCell.nameLabel.text = "\(String(describing: standing.user.nickname!))"
            standingCell.nickNameLabel.text = "\(String(describing: standing.user.name!))"
        } else {
            standingCell.nameLabel.text = "\(String(describing: standing.user.name!))"
            standingCell.nickNameLabel.text = ""
        }
        
        standingCell.winPercentageLabel.text = "\(String(format: "%.00f", standing.winpercentage))%"
        if let currentId = DataStore.shared.activeuser?.uid, let name = DataStore.shared.activeuser?.name, standing.user.uid == currentId, standing.user.name == name {
            standingCell.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        } else {
            standingCell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return standingCell
    }
}


// MARK: - tableView delegate
extension StandingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStanding = standings[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ProfileViewController", sender: nil)
    }
    
}

// MARK: - tableView cell
class StandingsCell: UITableViewCell {
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var winPercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

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
import FirebaseMessaging
import UserNotifications

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
    @IBOutlet weak var standingsTimeframeButton: UIButton!
    @IBOutlet weak var standingsTypeButton: UIButton!
    
    
    // MARK: - IBActions
    @IBAction func profile(_ sender: UIBarButtonItem) {
        selectedStanding = standings.filter( { $0.user.uid == DataStore.shared.activeuser?.uid } ).first
        performSegue(withIdentifier: "ProfileViewController", sender: nil)
    }
    
    @IBAction func submitGame(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "SubmitScoreViewController", sender: nil)
    }
    
    @IBAction func changeStandingsTimeframe(_ sender: UIButton) {
        DataStore.shared.standingsTimeframe.cycleTimeFrame()
        standingsOptionsUIConfig()
    }
    
    @IBAction func changeStandingsType(_ sender: UIButton) {
        DataStore.shared.standingsType.cycleType()
        standingsOptionsUIConfig()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // auth
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            print("Already signed in as \(String(describing: currentUser.displayName)) (\(String(describing: currentUser.email)))")
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // was not updating 
        DataStore.shared.standingsDelegate = self
        DataStore.shared.arenaUsersDelegate = self
        
        standingsOptionsUIConfig()
        
        guard (Auth.auth().currentUser != nil) else {
            presentSignInController()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
            return
        }
        
        reloadStandings()
        
        getUserChallenges()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func reloadStandings() {
        guard let newStandings = DataStore.shared.standings else { return }
        self.standings = newStandings
    }
    
    func reloadArenaUsers() {
        reloadStandings()
    }
    
    func getUserChallenges() {
        DataStore.shared.getUserChallenges(onComplete: { (challenges: [KlaskChallenge]?) in
            if let challenges = challenges {
                for challenge in challenges {
                    let content = UNMutableNotificationContent()
                    content.title = "Challenge"
                    content.categoryIdentifier = "challenge"
                    let challenger = (challenge.challengername == "") ? "someone" : challenge.challengername!
                    content.body = "You've been challenged by \(challenger)"
                    content.userInfo = ["datetime": String(describing: challenge.datetime ?? 0), "arenaid": String(describing: challenge.arenaid ?? ""), "challengeruid": String(describing: challenge.challengeruid ?? ""), "challengername": String(describing: challenge.challengername ?? "")]
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error == nil {
                            print("deleting notification")
                            DataStore.shared.deleteChallenge(challenge)
                        }
                    })
                }
            }
        })
    }
    
    private func presentSignInController() {
        print("present sign in")
        let storyBoard: UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(signInViewController, animated: true, completion: nil)
    }
    
    private func standingsOptionsUIConfig() {
        let timeframeTitle: String?
        
        switch DataStore.shared.standingsTimeframe {
        case .Today:
            timeframeTitle = "Today"
        case .Week:
            timeframeTitle = "Last 7 Days"
        case .Month:
            timeframeTitle = "Last 30 Days"
        case .Alltime:
            timeframeTitle = "All Time"
        }

        standingsTimeframeButton.setTitle(timeframeTitle, for: .normal)
        let typeTitle = DataStore.shared.standingsType.rawValue
        standingsTypeButton.setTitle(typeTitle, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = (segue.destination as? ProfileViewController) {
            destVC.userstandinguid = selectedStanding?.user.uid
        }
    }
}

// MARK: - tableView data source
extension StandingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return standings.count
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
        
        standingCell.winPercentageLabel.text = (DataStore.shared.standingsType == .Wins) ? "\(String(format: "%.00f", standing.winpercentage))%" : "\(standing.goalsdiff)"
        if let currentId = DataStore.shared.activeuser?.uid, let name = DataStore.shared.activeuser?.name, standing.user.uid == currentId, standing.user.name == name {
            standingCell.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        } else {
            standingCell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return standingCell
    }
    
    func contextualLossAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Loss") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            //
        }
        //action.image = UIImage(named: "Trash")
        action.title = "Win"
        action.backgroundColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
        return action
    }

    func contextualWinAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Loss") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            //
        }
        action.image = UIImage(named: "Trash")
        action.backgroundColor = #colorLiteral(red: 0.4695706824, green: 0.7674402595, blue: 0.2090922746, alpha: 1)
        return action
    }
    
    func contextualChallengeAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Challenge") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            let user = self.standings[indexPath.row].user
            print(user)
            guard let challengeduid = user.uid, let challengedname = user.nickname ?? user.name else { return }
            let challenge = KlaskChallenge(challengeduid: challengeduid)
            DataStore.shared.postChallenge(challenge, onComplete: { error in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: "Hmm, try going to ask \(challengedname) instead of challenging again.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            completionHandler(true)
        }
        //action.image = UIImage(named: "Trash")
        action.title = "Challenge"
        action.backgroundColor = #colorLiteral(red: 0.9646865726, green: 0.7849650979, blue: 0.0104486309, alpha: 1)
        return action
    }
    
}


// MARK: - tableView delegate
extension StandingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStanding = standings[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ProfileViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let lossAction = self.contextualLossAction(forRowAtIndexPath: indexPath)
        let winAction = self.contextualWinAction(forRowAtIndexPath: indexPath)
        //let trailingActions = UISwipeActionsConfiguration(actions: [winAction, lossAction])
        let trailingActions = UISwipeActionsConfiguration(actions: [])
        return trailingActions
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = self.standings[indexPath.row].user
        guard user.uid != DataStore.shared.activeuser?.uid! else { return nil }
        let challengeAction = self.contextualChallengeAction(forRowAtIndexPath: indexPath)
        let leadingActions = UISwipeActionsConfiguration(actions: [challengeAction])
        return leadingActions
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

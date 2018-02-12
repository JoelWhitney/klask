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
    var signedIn: Bool {
        return Auth.auth().currentUser != nil && DataStore.shared.activeuser != nil
    }
    var arenaChosen: Bool {
        return DataStore.shared.activearena != nil
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
        setupToolbarUI()
    }
    
    @IBAction func changeStandingsType(_ sender: UIButton) {
        DataStore.shared.standingsType.cycleType()
        setupToolbarUI()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // ui
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // was not updating after viewing profile
        DataStore.shared.standingsDelegate = self
        DataStore.shared.arenaUsersDelegate = self
        // ui
        setupToolbarUI()
        setupTableView()
        // auth
        verifySignedIn()
        verifyArenaChosen()
        // data source
        reloadStandings()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Protocol methods
    func reloadStandings() {
        guard let newStandings = DataStore.shared.standings else { return }
        self.standings = newStandings
    }
    
    func reloadArenaUsers() {
        // don't need to do anything here except reload standings
        reloadStandings()
    }
    
    // MARK: - Methods    
    private func verifySignedIn() {
        guard signedIn else {
            presentSignInController()
            DataStore.shared.activeuser = nil
            DataStore.shared.activearena = nil
            return
        }
        profileButton.isEnabled = (signedIn) ? true : false
    }
    
    private func verifyArenaChosen() {
        guard signedIn else {
            return
        }
        guard arenaChosen else {
            presentChooseArenaController()
            DataStore.shared.activearena = nil
            return
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.alpha = (signedIn && arenaChosen) ? 1.0 : 0.0

    }
    
    private func setupNavBar() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        navigationItem.backBarButtonItem = backButton
    }
    
    private func setupToolbarUI() {
        let buttonAlpha = (signedIn && arenaChosen) ? 1.0 : 0.0
        standingsTimeframeButton.alpha = CGFloat(buttonAlpha)
        standingsTypeButton.alpha = CGFloat(buttonAlpha)
        let timeframeTitle: String = {
            switch DataStore.shared.standingsTimeframe {
            case .Today:
                return "Today"
            case .Week:
                return "Last 7 Days"
            case .Month:
                return "Last 30 Days"
            case .Alltime:
                return "All Time"
            }
        }()
        standingsTimeframeButton.setTitle(timeframeTitle, for: .normal)
        let typeTitle: String = {
            switch DataStore.shared.standingsType {
            case .Wins:
                return "Win %"
            case .Goals:
                return "Goals +/-"
            case .Points:
                return "Points earned"
            }
        }()
        standingsTypeButton.setTitle(typeTitle, for: .normal)
    }
    
    private func presentSignInController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(signInViewController, animated: true, completion: nil)
    }
    
    private func presentChooseArenaController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChooseArena", bundle: nil)
        let chooseArenaViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseArenaViewController") as! ChooseArenaViewController
        self.present(chooseArenaViewController, animated: true, completion: nil)
    }
    
    private func presentEnterScoreController(opponent: KlaskUser, actionType: ContextualActionType) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "EnterScore", bundle: nil)
        let enterScoreViewController = storyBoard.instantiateViewController(withIdentifier: "EnterScoreViewController") as! EnterScoreViewController
        enterScoreViewController.actionType = actionType
        enterScoreViewController.opponent = opponent
        self.present(enterScoreViewController, animated: true, completion: nil)
    }
    
    private func animateCellByAction(indexPath: IndexPath, actionType: ContextualActionType){
        let animationColor: UIColor = {
            switch actionType {
            case .Loss:
                return #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 0.2)
            case .Won:
                return #colorLiteral(red: 0.4695706824, green: 0.7674402595, blue: 0.2090922746, alpha: 0.2)
            case .Challenge:
                return #colorLiteral(red: 0.9646865726, green: 0.7849650979, blue: 0.0104486309, alpha: 0.2)
            }
        }()
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 3, animations: {
            cell?.backgroundColor = animationColor
            cell?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        })
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
        standingCell.winPercentageLabel.text = {
            switch DataStore.shared.standingsType {
            case .Wins:
                return "\(String(format: "%.00f", standing.winpercentage))%"
            case .Goals:
                return "\(standing.goalsdiff)"
            case .Points:
                return "\(String(format: "%.01f", standing.modifiedrank!))"
            }
        }()
        

        if let currentId = DataStore.shared.activeuser?.uid, let name = DataStore.shared.activeuser?.name, standing.user.uid == currentId, standing.user.name == name {
            standingCell.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        } else {
            standingCell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return standingCell
    }
    
    func contextualLossAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Loss") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            self.animateCellByAction(indexPath: indexPath, actionType: ContextualActionType.Loss)
            let opponent = self.standings[indexPath.row].user
            self.presentEnterScoreController(opponent: opponent, actionType: ContextualActionType.Loss)
            completionHandler(true)
        }
        action.image = #imageLiteral(resourceName: "Loser")
        action.title = "Loss"
        action.backgroundColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
        return action
    }

    func contextualWinAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Loss") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            self.animateCellByAction(indexPath: indexPath, actionType: ContextualActionType.Won)
            let opponent = self.standings[indexPath.row].user
            self.presentEnterScoreController(opponent: opponent, actionType: ContextualActionType.Won)
            completionHandler(true)
        }
        action.image = #imageLiteral(resourceName: "Won")
        action.title = "Won"
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
            self.animateCellByAction(indexPath: indexPath, actionType: ContextualActionType.Challenge)
            completionHandler(true)
        }
        action.image = #imageLiteral(resourceName: "Challenge")
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
        let user = self.standings[indexPath.row].user
        guard user.uid != DataStore.shared.activeuser?.uid! else { return UISwipeActionsConfiguration(actions: []) }
        let lossAction = self.contextualLossAction(forRowAtIndexPath: indexPath)
        let winAction = self.contextualWinAction(forRowAtIndexPath: indexPath)
        let trailingActions = UISwipeActionsConfiguration(actions: [winAction, lossAction])
        //let trailingActions = UISwipeActionsConfiguration(actions: [])
        return trailingActions
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = self.standings[indexPath.row].user
        guard user.uid != DataStore.shared.activeuser?.uid! else { return nil }
        let challengeAction = self.contextualChallengeAction(forRowAtIndexPath: indexPath)
        let leadingActions = UISwipeActionsConfiguration(actions: [challengeAction])
        leadingActions.performsFirstActionWithFullSwipe = false
        return leadingActions
    }
    
}

enum ContextualActionType {
    case Challenge
    case Won
    case Loss
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

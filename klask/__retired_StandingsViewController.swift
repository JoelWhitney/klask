////
////  __retired_StandingsViewController.swift
////  klask
////
////  Created by Joel Whitney on 1/18/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import Foundation
////
////  StandingsViewController
////  klask
////
////  Created by Joel Whitney on 1/9/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import UIKit
//import Foundation
//import Firebase
//import GoogleSignIn
//import Firebase
//
//class StandingsViewController: UIViewController {
//    var current_standings = [Standing]() {
//        didSet {
//            //            print("didSet \(DataStore.shared.current_standings.count) current standings")
//            //            DispatchQueue.main.async {
//            //                self.tableView.reloadData()
//            //            }
//        }
//    }
//    var selectedStanding: Standing!
//    var ref: DatabaseReference!
//    
//    
//    // MARK: - IBOutlets
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet var profileButton: UIBarButtonItem!
//    @IBOutlet var submitButton: UIBarButtonItem!
//    @IBOutlet var signOut: UIBarButtonItem!
//    
//    // MARK: - IBActions
//    @IBAction func profile(_ sender: UIBarButtonItem) {
//        //selectedStanding = current_standings.filter( { $0.employee.id == ActiveEmployee.shared.current?.id } ).first
//        performSegue(withIdentifier: "ProfileViewController", sender: nil)
//    }
//    
//    @IBAction func submitGame(_ sender: UIBarButtonItem) {
//        self.performSegue(withIdentifier: "SubmitScoreViewController", sender: nil)
//    }
//    
//    @IBAction func signOut(_ sender: UIBarButtonItem) {
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//            ActiveUser.shared.activeUser = nil
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let firebaseAuth = Auth.auth()
//        if let currentUser = firebaseAuth.currentUser {
//            print("Signed in as \(String(describing: currentUser.displayName)) (\(String(describing: currentUser.email)))")
//            print(currentUser.debugDescription)
//            print(currentUser.displayName)
//            print(currentUser.email)
//            print(currentUser.photoURL)
//            print(currentUser.uid)
//        } else {
//            presentSignInController()
//        }
//        ref = Database.database().reference()
//        print(ref.database)
//        
//        //        checkInternalNetwork()
//        //        refreshDatabase()
//        tableView.tableFooterView = UIView()
//        
//        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
//        backButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
//        navigationItem.backBarButtonItem = backButton
//        
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        //refreshDatabase()
//        //        //if ActiveEmployee.shared.current == nil {
//        //            presentSignInController()
//        //        }
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    // MARK: - Methods
//    func presentSignInController() {
//        print("present sign in")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
//        let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//        self.present(signInViewController, animated: true, completion: nil)
//    }
//    //
//    //    func presentNoConnectionController() {
//    //        print("present sign in")
//    //        let storyBoard: UIStoryboard = UIStoryboard(name: "NoConnection", bundle: nil)
//    //        let noConnectionViewController = storyBoard.instantiateViewController(withIdentifier: "NoConnectionViewController") as! NoConnectionViewController
//    //        self.present(noConnectionViewController, animated: true, completion: nil)
//    //    }
//    
//    func refreshDatabase() {
//        //        DataStore.shared.reload() {
//        //            self.current_standings = DataStore.shared.current_standings
//        //        }
//    }
//    
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //        if let destVC = (segue.destination as? ProfileViewController) {
//        //            destVC.selectedUser = selectedStanding
//        //        }
//    }
//    
//    //    func checkInternalNetwork() {
//    //        let serverName:String = "fryesleap.esri.com"
//    //        var numAddress:String = ""
//    //
//    //        let host = CFHostCreateWithName(nil, serverName as CFString).takeRetainedValue()
//    //        CFHostStartInfoResolution(host, .addresses, nil)
//    //        var success: DarwinBoolean = false
//    //        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
//    //            let theAddress = addresses.firstObject as? NSData {
//    //            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//    //            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
//    //                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
//    //                numAddress = String(cString: hostname)
//    //                print(numAddress)
//    //            }
//    //        }
//    //        numAddress != "" ? print("connected"): presentNoConnectionController()
//    //    }
//}
//
//// MARK: - tableView data source
//extension StandingsViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return current_standings.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let standingCell = self.tableView!.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath) as! StandingsCell
//        let standing = current_standings[indexPath.row]
//        //        // cell details
//        //        if let rank = standing.rank {
//        //            standingCell.rankLabel.text = String(describing: rank)
//        //        }
//        //        if let image = UIImage(named: standing.employee.first_name) {
//        //           standingCell.profileImage.image = image
//        //        } else {
//        //            standingCell.profileImage.image = #imageLiteral(resourceName: "Default")
//        //        }
//        //
//        //        if standing.employee.nick_name != "" {
//        //            standingCell.nameLabel.text = "\(standing.employee.nick_name)"
//        //            standingCell.nickNameLabel.text = "\(standing.employee.first_name)"
//        //        } else {
//        //            standingCell.nameLabel.text = "\(standing.employee.first_name)"
//        //            standingCell.nickNameLabel.text = ""
//        //        }
//        //
//        //        standingCell.winPercentageLabel.text = "\(String(format: "%.01f", standing.win_percentage))%"
//        //        if let currentId = ActiveEmployee.shared.current?.id, let name = ActiveEmployee.shared.current?.first_name, standing.employee.id == currentId, standing.employee.first_name == name {
//        //            standingCell.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
//        //        } else {
//        //            standingCell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        //        }
//        return standingCell
//    }
//}
//
//
//// MARK: - tableView delegate
//extension StandingsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedStanding = current_standings[indexPath.row]
//        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "ProfileViewController", sender: nil)
//    }
//    
//}
//
//// MARK: - tableView cell
//class StandingsCell: UITableViewCell {
//    @IBOutlet var rankLabel: UILabel!
//    @IBOutlet var nameLabel: UILabel!
//    @IBOutlet var nickNameLabel: UILabel!
//    @IBOutlet var profileImage: UIImageView!
//    @IBOutlet var winPercentageLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//    
//}


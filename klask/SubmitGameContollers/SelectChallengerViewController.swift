//
//  SelectChallengerViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/13/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import UIKit

class SelectChallengerViewController: UIViewController {
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var sectioneduserkeys = [String]()
    var sectionedusers: [String: [KlaskUser]] = [:]
    var arenausers = [KlaskUser]() {
        didSet {
            for letter in alphabet {
                let users = arenausers.filter( { String(($0.name?.lowercased()[($0.name?.startIndex)!])!) == letter.lowercased() } )
                if !(users.isEmpty) {
                    sectionedusers[letter] = users
                    sectioneduserkeys.append(letter)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancel: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func cancelSubmit () {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        navigationItem.backBarButtonItem = backButton
        
        guard let users = DataStore.shared.arenausers else { return }
        arenausers = users.filter( {$0.uid != DataStore.shared.activeuser?.uid } )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods

}

// MARK: - tableView data source
extension SelectChallengerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectioneduserkeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectioneduserkeys[section]
        return sectionedusers[key]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let employeeCell = self.tableView!.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let key = sectioneduserkeys[indexPath.section]
        let user = sectionedusers[key]![indexPath.row]
        // cell details
        if let image = UIImage(named: user.name!) {
            employeeCell.profileImage.image = image
        } else if let photourl = user.photourl, photourl != "" {
            employeeCell.profileImage.downloadedFrom(url: URL(string: photourl)!)
        } else {
            employeeCell.profileImage.image = #imageLiteral(resourceName: "Default")
        }
        employeeCell.nameLabel.text = user.name
        if user.nickname != "" {
            employeeCell.nickNameLabel.text = "\(String(describing: user.nickname!))"
        } else {
            employeeCell.nickNameLabel.text = ""
        }
        return employeeCell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return alphabet
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let sectionforKey = sectioneduserkeys.index(of: title) {
            return sectionforKey
        } else {
            let alphIndex = Int(alphabet.index(of: title)!)
            for letter in alphabet[0...alphIndex].reversed()  {
                if let sectionforKey = sectioneduserkeys.index(of: letter) {
                    return sectionforKey
                }
            }
        }
        return 0
    }
}

// MARK: - tableView delegate
extension SelectChallengerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "SubmitGame", bundle: nil)
        let selectWinnerViewController = storyBoard.instantiateViewController(withIdentifier: "SelectWinnerViewController") as! SelectWinnerViewController
        let key = sectioneduserkeys[indexPath.section]

        selectWinnerViewController.challenger = sectionedusers[key]![indexPath.row]
        selectWinnerViewController.modalView = true
        self.navigationController?.pushViewController(selectWinnerViewController, animated: true)
    }
}

// MARK: - tableView cell
class UserCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}


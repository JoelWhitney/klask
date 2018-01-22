////
////  SignInViewController.swift
////  klask
////
////  Created by Joel Whitney on 1/13/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class SignInViewController: UIViewController {
//    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
//    var sectioned_employees_keys = [String]()
//    var sectioned_employees: [String: [Employee]] = [:]
//    var current_employees = [Employee]() {
//        didSet {
//            for letter in alphabet {
//                let employees = current_employees.filter({ String($0.first_name.lowercased()[$0.first_name.startIndex]) == letter.lowercased() })
//                if !(employees.isEmpty) {
//                    sectioned_employees[letter] = employees
//                    sectioned_employees_keys.append(letter)
//                }
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    // MARK: - IBOutlets
//    @IBOutlet var tableView: UITableView!
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        refreshDatabase()
//        tableView.tableFooterView = UIView()
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    // MARK: - Methods
//    func refreshDatabase() {
//        DataStore.shared.reload() {
//            self.current_employees = DataStore.shared.employees
//        }
//    }
//}
//
//// MARK: - tableView data source
//extension SignInViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sectioned_employees_keys.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let key = sectioned_employees_keys[section]
//        return sectioned_employees[key]!.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let employeeCell = self.tableView!.dequeueReusableCell(withIdentifier: "SignInEmployeeCell", for: indexPath) as! SignInEmployeeCell
//        let key = sectioned_employees_keys[indexPath.section]
//        let employee = sectioned_employees[key]![indexPath.row]
//        // cell details
//        if let image = UIImage(named: employee.first_name) {
//            employeeCell.profileImage.image = image
//        } else {
//            employeeCell.profileImage.image = #imageLiteral(resourceName: "Default")
//        }
//        employeeCell.nameLabel.text = employee.first_name
//        if employee.nick_name != "" {
//            employeeCell.nickNameLabel.text = "\(employee.nick_name)"
//        } else {
//            employeeCell.nickNameLabel.text = ""
//        }
//        return employeeCell
//    }
//
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return alphabet
//    }
//
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        if let sectionforKey = sectioned_employees_keys.index(of: title) {
//            return sectionforKey
//        } else {
//            let alphIndex = Int(alphabet.index(of: title)!)
//            for letter in alphabet[0...alphIndex].reversed()  {
//                if let sectionforKey = sectioned_employees_keys.index(of: letter) {
//                    return sectionforKey
//                }
//            }
//        }
//        return 0
//    }
//}
//
//// MARK: - tableView delegate
//extension SignInViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let key = sectioned_employees_keys[indexPath.section]
//        ActiveEmployee.shared.current = sectioned_employees[key]![indexPath.row]
//        tableView.deselectRow(at: indexPath, animated: true)
//        self.dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: - tableView cell
//class SignInEmployeeCell: UITableViewCell {
//    @IBOutlet var nameLabel: UILabel!
//    @IBOutlet var nickNameLabel: UILabel!
//    @IBOutlet var profileImage: UIImageView!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//}


//
//  SelectWinnerViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/13/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import UIKit

class SelectWinnerViewController: UIViewController {
    var winner: Int!
    var challenger: KlaskUser!
    var game = KlaskGame()
    var modalView = false

    // MARK: - IBOutlets
    @IBOutlet weak var angleUIView: AngleView!
    @IBOutlet var gameResultLabel: UILabel!
    @IBOutlet var player1_profileImage: UIImageView!
    @IBOutlet var player1_nameLabel: UILabel!
    @IBOutlet var player1_nickNameLabel: UILabel!
    @IBOutlet var player2_profileImage: UIImageView!
    @IBOutlet var player2_nameLabel: UILabel!
    @IBOutlet var player2_nickNameLabel: UILabel!
    @IBOutlet var player1_winnerView: UIView!
    @IBOutlet var player2_winnerView: UIView!
    @IBOutlet var player1_scoreView: UIView!
    @IBOutlet var player2_scoreView: UIView!
    @IBOutlet weak var player1_view: UIView!
    @IBOutlet weak var player2_view: UIView!

    @IBOutlet weak var p1_0: UIButton!
    @IBOutlet weak var p1_1: UIButton!
    @IBOutlet weak var p1_2: UIButton!
    @IBOutlet weak var p1_3: UIButton!
    @IBOutlet weak var p1_4: UIButton!
    @IBOutlet weak var p1_5: UIButton!
    @IBOutlet weak var p2_0: UIButton!
    @IBOutlet weak var p2_1: UIButton!
    @IBOutlet weak var p2_2: UIButton!
    @IBOutlet weak var p2_3: UIButton!
    @IBOutlet weak var p2_4: UIButton!
    @IBOutlet weak var p2_5: UIButton!

    // MARK: - IBAction
    @IBAction func selectScore(_ sender: UIButton) {
        print("score selected")
        resetButtons()
        if winner == 1 {
            game.player1score = 6
            game.player2score = sender.tag
            sender.backgroundColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
            sender.tintColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        } else if winner == 2 {
            game.player2score = 6
            game.player1score = sender.tag
            sender.backgroundColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
            sender.tintColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        }
        requirementsMet()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        angleUIView.addGestureRecognizer(tapGesture)

        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)


        // game setup
        game.player1id = DataStore.shared.activeuser?.uid
        game.player2id = challenger.uid

        setupPlayerUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        self.navigationItem.backBarButtonItem = backButton
    }

    // MARK: - Methods
    func setupPlayerUI() {
        // player 1 ui stuff
        if let player1 = DataStore.shared.activeuser {
            if let image = UIImage(named: player1.name!) {
                player1_profileImage.image = image
            } else if let photourl = player1.photourl, photourl != "" {
                player1_profileImage.downloadedFrom(url: URL(string: photourl)!)
            } else {
                player1_profileImage.image = #imageLiteral(resourceName: "Default")
            }
            if player1.nickname != "" {
                player1_nameLabel.text = "\(String(describing: player1.nickname!))"
                player1_nickNameLabel.text = "\(String(describing: player1.name!))"
            } else {
                player1_nameLabel.text = "\(String(describing: player1.name!))"
                player1_nickNameLabel.text = ""
            }
        }
        // player 2 ui stuff
        if let player2 = challenger {
            if let image = UIImage(named: player2.name!) {
                player2_profileImage.image = image
            } else if let photourl = player2.photourl, photourl != "" {
                player2_profileImage.downloadedFrom(url: URL(string: photourl)!)
            } else {
                player2_profileImage.image = #imageLiteral(resourceName: "Default")
            }
            if player2.nickname != "" {
                player2_nameLabel.text = "\(String(describing: player2.nickname!))"
                player2_nickNameLabel.text = "\(String(describing: player2.name!))"
            } else {
                player2_nameLabel.text = "\(String(describing: player2.name!))"
                player2_nickNameLabel.text = ""
            }
        }
    }

    func player1Won() {
        if winner != 1 {
            winner = 1
            resetButtons()
            gameResultLabel.backgroundColor = #colorLiteral(red: 0.6241136193, green: 0.8704479337, blue: 0.3534047008, alpha: 1)
            gameResultLabel.text = "  Won vs  "
            game.player2score = nil

            //angleUIView.angleSelected = true
            angleUIView.fillColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
            angleUIView.setColor(color: #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1), onComplete: {
                angleUIView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                player1_scoreView.backgroundColor =  #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
                player1_winnerView.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)

                player1_view.sendSubview(toBack: player1_scoreView)
                player1_view.bringSubview(toFront: player1_winnerView)
                player2_view.sendSubview(toBack: player2_winnerView)
                player2_view.bringSubview(toFront: player2_scoreView)

            })
            requirementsMet()
        }
    }

    func player2Won() {
        if winner != 2 {
            winner = 2
            resetButtons()
            gameResultLabel.backgroundColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
            gameResultLabel.text = "  Loss vs  "
            game.player1score = nil
             angleUIView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            angleUIView.setColor(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), onComplete: {
                angleUIView.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
                player1_scoreView.backgroundColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                player2_winnerView.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
                player2_view.sendSubview(toBack: player2_scoreView)
                player2_view.bringSubview(toFront: player2_winnerView)
                player1_view.sendSubview(toBack: player1_winnerView)
                player1_view.bringSubview(toFront: player1_scoreView)
            })
            requirementsMet()
        }
    }

    func resetButtons() {
        for case let stackView as UIStackView in player2_scoreView.subviews {
            for case let button as UIButton in stackView.subviews {
                button.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
                button.tintColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
            }
        }
        for case let stackView as UIStackView in player1_scoreView.subviews {
            for case let button as UIButton in stackView.subviews {
                button.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
                button.tintColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
            }
        }
    }

    func requirementsMet() -> Bool {
        let requirementsMet = (game.player1id != nil && game.player1score != nil && game.player2id != nil && game.player2score != nil)
        if requirementsMet {
            let submit = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(submitScore))
            navigationItem.setRightBarButton(submit, animated: true)
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Komika Slim", size: 17)!], for: UIControlState.normal)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
        return requirementsMet
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("tap")
        if sender.state == .ended {
            let touchLocation = sender.location(in: angleUIView)
            for view in self.angleUIView.subviews {
                if view.tag == 1, view.frame.contains(touchLocation) {
                    print("touched player 1 view")
                    player1Won()
                } else if view.tag == 2, view.frame.contains(touchLocation) {
                    print("touched player 2 view")
                    player2Won()
                }
            }
            print("touch ended")
        }
    }

    @objc func submitScore () {
        // verify required info is filled out
        if requirementsMet(), game.player1id != game.player2id, (game.player1score! == 6 || game.player2score! == 6) {
            //add score call
            DataStore.shared.postGame(game)
            DispatchQueue.main.async {
                if self.modalView {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //self.navigationController?.popToRootViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else if requirementsMet(), game.player1id == game.player2id {
            let alertController = UIAlertController(title: "Error", message: "Find a coworker instead of playing by yourself.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else if requirementsMet(),  (game.player1score! == 6 || game.player2score! == 6) {
            let alertController = UIAlertController(title: "Error", message: "Doesn't look like anyone won, try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            //
        }
    }

}






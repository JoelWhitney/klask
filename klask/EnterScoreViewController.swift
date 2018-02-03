//
//  EnterScoreViewController.swift
//  klask
//
//  Created by Joel Whitney on 2/3/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import UIKit

class EnterScoreViewController: UIViewController {
    var game = KlaskGame()
    var opponent: KlaskUser?
    var actionType: ContextualActionType?
    var scoreButtons: [UIButton]?
    
    // MARK: - IBActions
    @IBAction func dismissView () {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectScore(_ sender: UIButton) {
        print("score selected")
        resetButtons()
        switch actionType! {
        case .Won:
            game.player2score = sender.tag
        case .Loss:
            game.player1score = sender.tag
        default:
           print("?")
        }
        sender.backgroundColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
        sender.tintColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
        requirementsMet()
    }
    @IBAction func submitScore () {
        // verify required info is filled out
        if requirementsMet(), game.player1id != game.player2id, (game.player1score! == 6 || game.player2score! == 6) {
            //add score call
            DataStore.shared.postGame(game)
            self.dismiss(animated: true, completion: nil)
            
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
    
    // MARK: - IBOutlets
    @IBOutlet weak var dismiss: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nickNameLabel: UILabel!
    @IBOutlet weak var s0: UIButton!
    @IBOutlet weak var s1: UIButton!
    @IBOutlet weak var s2: UIButton!
    @IBOutlet weak var s3: UIButton!
    @IBOutlet weak var s4: UIButton!
    @IBOutlet weak var s5: UIButton!
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        requirementsMet()
        dismiss.layer.borderWidth = 0.75
        dismiss.layer.borderColor = #colorLiteral(red: 0.6241136193, green: 0.8704479337, blue: 0.3534047008, alpha: 1)
        backgroundView.layer.borderWidth = 0.25
        backgroundView.layer.borderColor = #colorLiteral(red: 0.6241136193, green: 0.8704479337, blue: 0.3534047008, alpha: 1)
        scoreButtons = [s0, s1, s2, s3, s4, s5]
        gameSetup()
    }
    
    // MARK: - Methods
    func requirementsMet() -> Bool {
        print(game)
        let requirementsMet = (game.player1id != nil && game.player1score != nil && game.player2id != nil && game.player2score != nil)
        if requirementsMet {
            submit.isEnabled = true
            submit.alpha = 1.0
        } else {
            submit.isEnabled = false
            submit.alpha = 0.5
        }
        return requirementsMet
    }
    
    func gameSetup() {
        // loser stuff
        game.player1id = DataStore.shared.activeuser?.uid
        game.player2id = opponent?.uid
        let gameloser: KlaskUser? = {
            switch actionType! {
            case .Won:
                game.player1score = 6
                return opponent
            case .Loss:
                game.player2score = 6
                return DataStore.shared.activeuser!
            default:
                return nil
            }
        }()
        guard let loser = gameloser else { return }
        if let image = UIImage(named: loser.name!) {
            profileImage.image = image
        } else if let photourl = loser.photourl, photourl != "" {
            profileImage.downloadedFrom(url: URL(string: photourl)!)
        } else {
            profileImage.image = #imageLiteral(resourceName: "Default")
        }
        if loser.nickname != "" {
            nickNameLabel.text = "\(String(describing: loser.nickname!))"
            nameLabel.text = "\(String(describing: loser.name!))"
        } else {
            nickNameLabel.text = "\(String(describing: loser.name!))"
            nameLabel.text = ""
        }
    }
    
    func resetButtons() {
        for button in scoreButtons! {
            button.backgroundColor = #colorLiteral(red: 0.1484079361, green: 0.108229287, blue: 0.1866647303, alpha: 1)
            button.tintColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
        }
    }

}


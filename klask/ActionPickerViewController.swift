//
//  ActionPickerViewController.swift
//  klask
//
//  Created by Joel Whitney on 2/9/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import UIKit
import Foundation
import GoogleSignIn
import Firebase
import UserNotifications

class ActionPickerViewController: UIViewController {
    // MARK: - Variables
    var userstanding: Standing?

    // MARK: - IBOutlets
    @IBOutlet weak var challengeFAB: UIButton!
    @IBOutlet weak var wonFAB: UIButton!
    @IBOutlet weak var lossFAB: UIButton!
    @IBOutlet weak var cancelFAB: UIButton!
    
    // MARK: - IBAction
    @IBAction func challenge(_ sender: UIButton) {
        let opponent = userstanding?.user
        guard let challengeduid = opponent?.uid, let challengedname = opponent?.nickname ?? opponent?.name else { return }
        let challenge = KlaskChallenge(challengeduid: challengeduid)
        DataStore.shared.postChallenge(challenge, onComplete: { error in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "Hmm, try going to ask \(challengedname) instead of challenging again.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    @IBAction func won(_ sender: UIButton) {
        let opponent = userstanding?.user
        let actionType = ContextualActionType.Won
        weak var presentingViewController = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let storyBoard: UIStoryboard = UIStoryboard(name: "EnterScore", bundle: nil)
            let enterScoreViewController = storyBoard.instantiateViewController(withIdentifier: "EnterScoreViewController") as! EnterScoreViewController
            enterScoreViewController.actionType = actionType
            enterScoreViewController.opponent = opponent
            presentingViewController?.present(enterScoreViewController, animated: true, completion: nil)
        })
    }
    @IBAction func loss(_ sender: UIButton) {
        let opponent = userstanding?.user
        let actionType = ContextualActionType.Loss
        weak var presentingViewController = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let storyBoard: UIStoryboard = UIStoryboard(name: "EnterScore", bundle: nil)
            let enterScoreViewController = storyBoard.instantiateViewController(withIdentifier: "EnterScoreViewController") as! EnterScoreViewController
            enterScoreViewController.actionType = actionType
            enterScoreViewController.opponent = opponent
            presentingViewController?.present(enterScoreViewController, animated: true, completion: nil)
        })
    }
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fabSetup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func fabSetup() {
        wonFAB.layer.borderColor = #colorLiteral(red: 0.6241136193, green: 0.8704479337, blue: 0.3534047008, alpha: 1)
        wonFAB.layer.borderWidth = 1.5
        lossFAB.layer.borderColor = #colorLiteral(red: 0.9994900823, green: 0.2319722176, blue: 0.1904809773, alpha: 1)
        lossFAB.layer.borderWidth = 1.5
        challengeFAB.layer.borderColor = #colorLiteral(red: 0.9646865726, green: 0.7849650979, blue: 0.0104486309, alpha: 1)
        challengeFAB.layer.borderWidth = 1.5
        cancelFAB.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cancelFAB.layer.borderWidth = 1.5
    }

}


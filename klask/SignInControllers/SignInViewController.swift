//
//  SignInViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/16/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    // MARK: - IBActions
    @IBAction func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientLayer()
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = .iconOnly
        googleSignInButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double(40.0) * M_PI/Double(180)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let activearena = DataStore.shared.activearena {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    func addGradientLayer() {
        var gradientLayer: CAGradientLayer!
        
        let colorTop = UIColor(red: 188.0 / 255.0, green: 72.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 97.0 / 255.0, green: 23.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}


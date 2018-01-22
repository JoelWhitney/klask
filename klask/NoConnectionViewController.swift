//
//  NoConnectionViewController.swift
//  klask
//
//  Created by Joel Whitney on 1/15/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import Foundation
import UIKit

class NoConnectionViewController: UIViewController {
    
    // MARK: - IBActions
    @IBAction func retry() {
        let serverName:String = "fryesleap.esri.com"
        var numAddress:String = ""
        
        let host = CFHostCreateWithName(nil, serverName as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                numAddress = String(cString: hostname)
                print(numAddress)
            }
        }
        numAddress != "" ? self.dismiss(animated: true, completion: nil): print("still nothing")
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        var gradientLayer: CAGradientLayer!
        
        let colorTop = UIColor(red: 188.0 / 255.0, green: 72.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 97.0 / 255.0, green: 23.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    // MARK: - Methods
    
}


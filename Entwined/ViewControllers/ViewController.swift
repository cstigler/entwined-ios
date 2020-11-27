//
//  ViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/25/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

let bonjourServiceName = "_entwined._tcp."

class ViewController: UIViewController, NetServiceBrowserDelegate {
    
    var serviceBrowser = NetServiceBrowser()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configure Service Browser
        self.serviceBrowser.delegate = self
        self.serviceBrowser.searchForServices(ofType: bonjourServiceName, inDomain: "local.")
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        if aNetService.type == bonjourServiceName,
            let addresses = aNetService.addresses {
            print("got \(addresses)")
        }
    }

}


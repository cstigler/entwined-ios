//
//  BreakViewController.swift
//  Entwined-iOS
//
//  Created by Charlie Stigler on 12/11/20.
//  Copyright © 2020 Charles Gadeken. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class BreakViewController: UIViewController {
    let disposables = CompositeDisposable.init()
    var labelUpdateTimer: Timer? = nil
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var stopBreakButton: UIButton!

    deinit {
        disposables.dispose()

        self.labelUpdateTimer?.invalidate()
        self.labelUpdateTimer = nil
    }
    
    override func viewDidLoad() {
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.state)).startWithValues { [unowned self] (_) in
            if (Model.sharedInstance.state == "run") {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(BreakViewController.updateTimeRemaining), userInfo: nil, repeats: true)

        updateTimeRemaining()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.labelUpdateTimer?.invalidate()
        self.labelUpdateTimer = nil
    }
    
    @objc func updateTimeRemaining() {
        let secondsRemaining = Model.sharedInstance.secondsToNextStateChange
        
        timeRemainingLabel.text = "\(formatCountdown(Float(secondsRemaining)))"
    }
    
    @IBAction func stopBreak(_ sender: AnyObject) {
        Model.sharedInstance.autoplay = true
        ServerController.sharedInstance.resetTimerToRun()
    }
}

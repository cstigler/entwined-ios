//
//  StartViewController.swift
//  Entwined-iOS
//
//  Created by Charlie Stigler on 12/9/20.
//  Copyright © 2020 Charles Gadeken. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class StartViewController: UIViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    let disposables = CompositeDisposable.init()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startControllingButton: UIButton!
    @IBOutlet weak var connectingLabel: UIView!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var resetToPauseButton: UIButton!
    @IBOutlet weak var resetToRunButton: UIButton!
    @IBOutlet var startBreakAboveResetRunConstraint: NSLayoutConstraint!
    @IBOutlet var stopBreakAboveResetBreakConstraint: NSLayoutConstraint!

    var imagesArr = [UIImage(named: "entwined1"),
                     UIImage(named: "entwined2"),
                     UIImage(named: "entwined3")]
    
    var imageGalleryTimer:Timer? = nil
    var labelUpdateTimer: Timer? = nil
    
    //var secondsCounter = 0
    
    deinit {
        disposables.dispose()
        self.imageGalleryTimer?.invalidate()
        self.labelUpdateTimer?.invalidate()
        self.imageGalleryTimer = nil
        self.labelUpdateTimer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        reloadCollectionView()
        ServerController.sharedInstance.connect()
        
        // make connecting label tappable so users can change hostname
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(connectingLabelTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        connectingLabel.addGestureRecognizer(tapGestureRecognizer)
        connectingLabel.isUserInteractionEnabled = true
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.loaded)).startWithValues { [unowned self] (_) in
            // all UI stuff should happen on main thread
            DispatchQueue.main.async {
                self.connectingLabel.isHidden = Model.sharedInstance.loaded
                self.resetToPauseButton.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
                self.resetToRunButton.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
                self.timerLabel.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)

                if (Model.sharedInstance.loaded) {
                    if (!self.startControllingButton.isEnabled && !Model.sharedInstance.autoplay) {
                        // when we connect, immediately turn on autoplay if it was off
                        Model.sharedInstance.autoplay = true
                    }

                    self.startControllingButton.setTitle("START CONTROLLING", for: UIControl.State.normal)
                    self.startControllingButton.backgroundColor = UIColor(red: 0.656078, green: 0.382225, blue: 0.606485, alpha: 1)
                    self.startControllingButton.isEnabled = true
                } else {
                    self.startControllingButton.setTitle("CONNECTING", for: UIControl.State.normal)
                    self.startControllingButton.backgroundColor = UIColor.lightGray
                    self.startControllingButton.isEnabled = false
                }
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.breakTimerEnabled)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.resetToPauseButton.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
                self.resetToRunButton.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
                self.timerLabel.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
            }
        })

        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.state)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                if (Model.sharedInstance.state == "run") {
                    self.resetToPauseButton.setTitle("Start Break Immediately", for: .normal)
                    self.resetToRunButton.setTitle("Reset Run Timer", for: .normal)

                    self.stopBreakAboveResetBreakConstraint.isActive = false
                    self.startBreakAboveResetRunConstraint.isActive = true
                } else {
                    self.resetToRunButton.setTitle("End Break Immediately", for: .normal)
                    self.resetToPauseButton.setTitle("Reset Break Timer", for: .normal)
        
                    self.startBreakAboveResetRunConstraint.isActive = false
                    self.stopBreakAboveResetBreakConstraint.isActive = true
                }
            }
        })
        
        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StartViewController.updateTimerLabel), userInfo: nil, repeats: true)
        updateTimerLabel()

        //Set autoplay mode enable by default
        Model.sharedInstance.autoplay = true;
    }
    
    @objc func updateTimerLabel() {
        updateBreakTimerLabel(
            label: self.timerLabel,
            compactFormatting: (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact),
            useLineBreaks: true
        )
    }
    
    @objc func connectingLabelTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Change Hostname", message: "What hostname is the Entwined server at?", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField : UITextField!) in
            textField.placeholder = "\(ServerController.sharedInstance.serverHostname)"
            textField.delegate = self
        }
        
        let save = UIAlertAction(title: "Connect", style: UIAlertAction.Style.default, handler: { saveAction -> Void in
            var newHostname = (alert.textFields![0] as UITextField).text
            newHostname = newHostname?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (newHostname != nil && newHostname!.isEmpty) {
                return;
            }
            
            if let unwrappedHostname = newHostname {
                ServerController.sharedInstance.serverHostname = unwrappedHostname
                print("Connecting to new hostname \(unwrappedHostname)")
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        alert.addAction(save)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetToPause(_ sender: AnyObject) {
        let breakLengthMins = Int(round(Model.sharedInstance.pauseSeconds / 60.0))
        
        var confirmationTitle: String
        var confirmationMessage: String
        var actionTitle: String
        if (Model.sharedInstance.state == "run") {
            confirmationTitle = "Confirm Break"
            confirmationMessage = "Are you sure you want to start a \(breakLengthMins)-minute lighting break? All patterns will stop, the sculpture will go dark, and the break timer will reset."
            actionTitle = "Start Break"
        } else {
            confirmationTitle = "Confirm Timer Reset"
            confirmationMessage = "Are you sure you want to reset the break timer? This will extend the current break period, and the break will end in \(breakLengthMins) minutes."
            actionTitle = "Reset Timer"
        }
        
        let confirmationAlert = UIAlertController(title: confirmationTitle, message: confirmationMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: actionTitle, style: .default, handler: { (action) -> Void in
            ServerController.sharedInstance.resetTimerToPause()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        confirmationAlert.addAction(ok)
        confirmationAlert.addAction(cancel)
        
        // Present dialog message to user
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    @IBAction func resetToRun(_ sender: AnyObject) {
        let runLengthMins = Int(round(Model.sharedInstance.runSeconds / 60.0))

        var confirmationTitle: String
        var confirmationMessage: String
        var actionTitle: String
        if (Model.sharedInstance.state == "pause") {
            confirmationTitle = "Confirm End Break"
            confirmationMessage = "Are you sure you want to end the lighting break? The sculpture will light up again, and the timer will reset for another \(runLengthMins)-minute light show."
            actionTitle = "End Break"
        } else {
            confirmationTitle = "Confirm Timer Reset"
            confirmationMessage = "Are you sure you want to reset the run timer? This will extend the current run period, and the next break will occur in \(runLengthMins) minutes."
            actionTitle = "Reset Timer"
        }
        
        let confirmationAlert = UIAlertController(title: confirmationTitle, message: confirmationMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: actionTitle, style: .default, handler: { (action) -> Void in
            ServerController.sharedInstance.resetTimerToRun()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        confirmationAlert.addAction(ok)
        confirmationAlert.addAction(cancel)
        
        // Present dialog message to user
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    
    @IBAction func startControllingButtonPressed(_ sender: Any) {
        if Model.sharedInstance.loaded {
            if (Model.sharedInstance.state == "pause") {
                // warn the user before they interrupt the break!
                let confirmationAlert = UIAlertController(title: "Confirm End Break", message: "A scheduled lighting break is currently ongoing. Are you sure you want to override that break and take control anyway?", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "Start Controlling", style: .default, handler: { (action) -> Void in
                    self.startControlPanel()
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                    (action : UIAlertAction!) -> Void in })

                confirmationAlert.addAction(ok)
                confirmationAlert.addAction(cancel)
                
                // Present dialog message to user
                self.present(confirmationAlert, animated: true, completion: nil)
            } else {
                startControlPanel()
            }
        }
    }
    
    func startControlPanel() {
        Model.sharedInstance.autoplay = false;

        // UI stuff on main thread, always!
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "show-controls-segue", sender: self)
        }
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
        
        // Invalidating timer for safety reasons
        self.imageGalleryTimer?.invalidate()
        
        // Below, for each 3.5 seconds MyViewController's 'autoScrollImageSlider' would be fired
        self.imageGalleryTimer = Timer.scheduledTimer(timeInterval: 7.5, target: self, selector: #selector(StartViewController.autoScrollImageSlider), userInfo: nil, repeats: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width:collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension StartViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArr.count
    }
    
    @objc func autoScrollImageSlider() {
        DispatchQueue.main.async {
            let firstIndex = 0
            let lastIndex = (self.imagesArr.count) - 1
            
            let visibleIndices = self.collectionView.indexPathsForVisibleItems
            let nextIndex = visibleIndices[0].row + 1
            
            let nextIndexPath: IndexPath = IndexPath.init(item: nextIndex, section: 0)
            let firstIndexPath: IndexPath = IndexPath.init(item: firstIndex, section: 0)
            
            if nextIndex > lastIndex {
                self.collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
            } else {
                self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.autoPilotImageView.image = imagesArr[indexPath.row]
        return cell
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        self.imageGalleryTimer?.invalidate()
    }
}

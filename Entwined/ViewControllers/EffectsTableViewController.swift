//
//  EffectsTableViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/5/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class EffectsTableViewController: UITableViewController {
    let disposables = CompositeDisposable.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.colorEffects)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    deinit {
        disposables.dispose()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.colorEffects.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EffectTableViewCell

        if indexPath.row == 0 {
            cell.effect = nil
        } else {
            cell.effect = Model.sharedInstance.colorEffects[indexPath.row - 1]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || Model.sharedInstance.activeColorEffectIndex == indexPath.row - 1 {
            Model.sharedInstance.activeColorEffectIndex = -1
        } else {
            Model.sharedInstance.activeColorEffectIndex = indexPath.row - 1
        }
    }

}

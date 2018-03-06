//
//  EffectsTableViewController.swift
//  Minitrees
//
//  Created by Kyle Fleming on 11/5/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class EffectsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.colorEffects)).startWithValues { [unowned self] (_) in
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return Model.sharedInstance.colorEffects.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EffectTableViewCell

        // Configure the cell...
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

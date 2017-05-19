//
//  PatternsCollectionViewController.swift
//  Minitrees
//
//  Created by Kyle Fleming on 10/28/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class PatternsCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Model.sharedInstance.rac_values(forKeyPath: "patterns", observer: self).subscribeNext { [unowned self] (_) in
            self.collectionView!.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return Model.sharedInstance.patterns.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PatternCollectionViewCell
        
        // Configure the cell
        cell.pattern = Model.sharedInstance.patterns[indexPath.item]
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pattern = Model.sharedInstance.patterns[indexPath.item]
        if let channelSelectedOn = pattern.channelSelectedOn {
            channelSelectedOn.currentPattern = nil
        } else {
            DisplayState.sharedInstance.selectedChannel?.currentPattern = pattern
        }
    }

}

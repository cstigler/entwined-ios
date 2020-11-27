//
//  PatternsCollectionViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/28/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class PatternsCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.patterns)).startWithValues { [unowned self] (_) in
            self.collectionView!.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   Model.sharedInstance.patterns.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PatternCollectionViewCell
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

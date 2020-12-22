//
//  PatternsCollectionViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/28/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class PatternsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let disposables = CompositeDisposable.init()
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.patterns)).startWithValues { [unowned self] (_) in
            self.collectionView!.reloadData()
        })
    }
    
    deinit {
        disposables.dispose()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sideLength = min(view.frame.size.width / 4, 140)
        
        print("sideLength \(sideLength)")
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: sideLength, height: sideLength)
    }

}

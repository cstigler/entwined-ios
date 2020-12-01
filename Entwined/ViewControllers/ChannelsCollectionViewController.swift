//
//  ChannelsCollectionViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/4/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class ChannelsCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.channels)).startWithValues { [unowned self] (_) in
            self.collectionView!.reloadData()
            if self.collectionView!.indexPathsForSelectedItems?.first == nil {
                self.setSelectedItem()
            }
        }
    }
   
    func setSelectedItem() {
        let selectedItemIndex = DisplayState.sharedInstance.selectedChannelIndex
        if selectedItemIndex >= 0 && selectedItemIndex < self.collectionView!.numberOfItems(inSection: 0) {
            self.collectionView!.selectItem(at: IndexPath(item: selectedItemIndex, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // for UI simplicity's sake, we'll never show more than 3 sliders
        // even if the server tells us there are more channels than that
        return min(Model.sharedInstance.channels.count, 3)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChannelCollectionViewCell
        cell.channel = Model.sharedInstance.channels[indexPath.item]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DisplayState.sharedInstance.selectedChannelIndex = indexPath.item
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = self.view.frame.width/3
        return CGSize(width: width, height: height)
    }
}

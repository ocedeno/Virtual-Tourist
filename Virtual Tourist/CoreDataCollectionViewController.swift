//
//  CoreDataCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "flickrCell"

class CoreDataCollectionViewController: UICollectionViewController
{
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet
        {
//            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : uicollectionview = .plain) {
        fetchedResultsController = fc
        super.init
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}

extension CoreDataCollectionViewController
{
    func executeSearch()
    {
        if let fc = fetchedResultsController
        {
            do
            {
                try fc.performFetch()
            } catch let e as NSError
            {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/24/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate
{

    //IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flickrCollectionView: UICollectionView!
    
    //Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
}

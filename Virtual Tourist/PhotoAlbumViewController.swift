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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    
    //IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flickrCollectionView: UICollectionView!

    let delegate = UIApplication.shared.delegate as! AppDelegate
    var photosArray: [Photo]?
    var sentAnnotation: Annotations!
    var currentMV: CurrentMapView?
    var stack: CoreDataStack!
    
    //Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        stack = delegate.stack
        self.navigationController?.navigationBar.isHidden = false
        
        flickrCollectionView.delegate = self
        flickrCollectionView.dataSource = self
        
        let fr = NSFetchRequest<CurrentMapView>(entityName: "CurrentMapView")
        currentMV = try! stack.context.fetch(fr)[0]
        
        setPhotoAlbumMV()
        print("Sent annotation is : \(sentAnnotation.description)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = flickrCollectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    func setPhotoAlbumMV()
    {
        let fr = currentMV!
        
        let latitude: CLLocationDegrees = fr.latitude
        let longitude: CLLocationDegrees = fr.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        var span = MKCoordinateSpan()
        span.latitudeDelta = fr.latitudeDelta
        span.longitudeDelta = fr.longitudeDelta
        
        var region = MKCoordinateRegion()
        region.span = span
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.setCenter(coordinate, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

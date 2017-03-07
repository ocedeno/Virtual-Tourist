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
    //MARK: IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flickrCollectionView: UICollectionView!
    @IBOutlet weak var flickrPhotoView: UIImageView!

    //Variables/Constants
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var photosArray: [Photo]?
    var sentAnnotation: Annotations!
    var currentMV: CurrentMapView?
    var stack: CoreDataStack!
    
    //MARK: Life Cycle:
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
        mapView.isUserInteractionEnabled = false
    }
    
    //MARK: Setting MapView Coordinates
    func setPhotoAlbumMV()
    {
        let fr = currentMV!
        
        let latitude: CLLocationDegrees = sentAnnotation.latitude
        let longitude: CLLocationDegrees = sentAnnotation.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        var span = MKCoordinateSpan()
        span.latitudeDelta = fr.latitudeDelta
        span.longitudeDelta = fr.longitudeDelta
        
        var region = MKCoordinateRegion()
        region.span = span
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.setCenter(coordinate, animated: true)
        
        let annotation = MyPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return Int((sentAnnotation.photo?.count)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let availableWidth = view.frame.width + 1
        let widthPerItem = availableWidth / 4
        collectionViewLayout?.sectionInset.left = 10.0
        collectionViewLayout?.sectionInset.right = 10.0
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell",for: indexPath) as! FlickrPhotoCell
        
        let photo = sentAnnotation.photo?.allObjects[indexPath.row] as! Photo
        let imageString = photo.imageData!
        let imageURL = URL(string: imageString)
        let imageData = try? Data(contentsOf: imageURL!)
        cell.flickrImageView.image = UIImage(data: imageData!)
        cell.backgroundColor = UIColor.black

        return cell
    }
}

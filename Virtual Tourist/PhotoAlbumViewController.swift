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
    var sentAnnotation: MyPointAnnotation!
    var annotationEntity: Annotations!

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
        annotationEntity = sentAnnotation.annotations!
        mapView.isUserInteractionEnabled = false
    }
    
    //MARK: IBActions:
    @IBAction func newCollectionButton(_ sender: UIBarButtonItem)
    {
        removeOldData()
        addNewData()
    }
    
    func removeOldData()
    {
        let annotationEntity = sentAnnotation.annotations!
        annotationEntity.removeFromPhoto(annotationEntity.photo!)
        print("Removed Old Data")
    }
    
    func addNewData()
    {
        let flickrClient = FlickrClient()
        flickrClient.getImages(flickrClient.getMethodParameters(latitude: annotationEntity.latitude, longitude: annotationEntity.longitude) as [String : AnyObject], withPageNumber: 51, annotation: annotationEntity)
        flickrCollectionView.reloadData()
        print("Added new Data")
    }
    
    //MARK: Setting MapView Coordinates
    func setPhotoAlbumMV()
    {
        let fr = currentMV!
        
        let latitude: CLLocationDegrees = (sentAnnotation.annotations?.latitude)!
        let longitude: CLLocationDegrees = (sentAnnotation.annotations?.longitude)!
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
        return Int((sentAnnotation.annotations?.photo?.count)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell",for: indexPath) as! FlickrPhotoCell
        
        let photo = annotationEntity.photo?.allObjects[indexPath.row] as! Photo
        let imageString = photo.imageData!
        let imageURL = URL(string: imageString)
        let imageData = try? Data(contentsOf: imageURL!)
        cell.flickrImageView.image = UIImage(data: imageData!)
        cell.backgroundColor = UIColor.black

        return cell
    }
}

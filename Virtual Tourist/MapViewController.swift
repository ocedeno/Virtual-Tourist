//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/24/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import SpriteKit

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate
{
    //IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsLabel: UILabel!
    
    //Variables/Constants
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var fetchedAnnotationsResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var annotations = [MKAnnotation]()
    var newAnnotation: Annotations!
    var currentMV: CurrentMapView?
    var stack: CoreDataStack!
    var selectedPinLatitude: CLLocationDegrees?
    var selectedPinLongitude: CLLocationDegrees?
    var photosArray: [[String: AnyObject]]?
    
    //MARK: Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Get the stack
        stack = delegate.stack
        initializeAnnotationFetchedResultsController()
        
        //Check for Initial MapView Coordinates
        let fr = NSFetchRequest<CurrentMapView>(entityName: "CurrentMapView")
        
        if delegate.checkIfFirstLaunch()
        {
            currentMV = try? stack.context.fetch(fr)[0]
            setMapView(mapView: mapView)
            getAnnotationsArray()
        }else
        {
            currentMV = CurrentMapView(latDelta: self.mapView.region.span.latitudeDelta, lonDelta: self.mapView.region.span.longitudeDelta, lat: self.mapView.centerCoordinate.latitude, lon: self.mapView.centerCoordinate.longitude, context: self.stack.context)
        }
        
        //MapView Setup
        mapView.delegate = self
        mapView.addAnnotations(annotations)
        hideDirectionsLabel()
        
        //Gesture Setup
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        //Hide Nav Bar
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:Annotation Methods
    
    //Initialize Annotations Fetched Results Controller
    func initializeAnnotationFetchedResultsController()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
        let latSort = NSSortDescriptor(key: "latitude", ascending: true)
        request.sortDescriptors = [latSort]
        
        let moc = stack.context
        fetchedAnnotationsResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedAnnotationsResultsController.delegate = self
        
        do {
            try fetchedAnnotationsResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getAnnotationsArray()
    {
        let far = fetchedAnnotationsResultsController
        
        for object in far?.fetchedObjects as! [Annotations]
        {
            let annotation = MyPointAnnotation()
            annotation.annotations = object
            let latitude = object.latitude
            let longitude = object.longitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinates
            annotation.title = "Select to see Photos!"
            annotations.append(annotation)
        }
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            newAnnotation = Annotations(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: stack.context)
            let annotation = MyPointAnnotation()
            annotation.title = "Select to see Photos!"
            annotation.coordinate = newCoordinates
            annotations.append(annotation)
            annotation.annotations = newAnnotation
            createPhotosArray(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, annotation: newAnnotation)
        }
        
        self.stack.save()
        mapView.addAnnotations(annotations)
    }
    
    //MARK: Helper Functions
    
    //Get current location of view.
    func getCurrentMapView()
    {
        stack.context.delete(currentMV!)
        currentMV = CurrentMapView(latDelta: self.mapView.region.span.latitudeDelta, lonDelta: self.mapView.region.span.longitudeDelta, lat: self.mapView.centerCoordinate.latitude, lon: self.mapView.centerCoordinate.longitude, context: self.stack.context)
        
        self.stack.save()
    }

    func setMapView(mapView: MKMapView)
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
        
        mapView.setRegion(region, animated: true)
        mapView.setCenter(coordinate, animated: true)
    }
    
    func createPhotosArray(latitude: Double, longitude: Double, annotation: Annotations)
    {
        let flickrClient = FlickrClient()
        flickrClient.getImages(flickrClient.getMethodParameters(latitude: latitude, longitude: longitude) as [String : AnyObject], withPageNumber: 51, annotation: annotation)
    }
    
    func hideDirectionsLabel()
    {
        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when)
        {
            self.directionsLabel.isHidden = true
        }
    }
    
    //MARK: Segue
    
    //Passing Annotation to Photo Album VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let photoAlbumVC = segue.destination as! PhotoAlbumViewController
        photoAlbumVC.sentAnnotation = sender as! Annotations
    }
    
    //MARK: Map Class Methods
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        selectedPinLatitude = view.annotation?.coordinate.latitude
        selectedPinLongitude = view.annotation?.coordinate.longitude
        getCurrentMapView()
        let sentAnnotation = view.annotation as! MyPointAnnotation
        performSegue(withIdentifier: "photoAlbumSegue", sender: sentAnnotation.annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView")
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
    }
    
    //Flickr Helper Function
    func bboxString(latitude: Double, longitude: Double) -> String
    {
        if longitude != 0.0 {
            
            let minimumLon = max(longitude - FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0, 0, 0, 0"
        }
    }
    
    //MARK: Shared Instance
    class func sharedInstance() -> MapViewController
    {
        struct Singleton
        {
            static var sharedInstance = MapViewController()
        }
        return Singleton.sharedInstance
    }
}

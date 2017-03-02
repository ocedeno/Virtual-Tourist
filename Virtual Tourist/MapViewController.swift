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

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate
{
    //IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables/Constants
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var fetchedAnnotationsResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var annotations = [MKPointAnnotation]()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack: CoreDataStack!
    
    //MARK: Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Get the stack
        stack = delegate.stack
        
        initializeFetchedResultsController()
        initializeAnnotationFetchedResultsController()
        
        //Hide Nav Bar
        self.navigationController?.navigationBar.isHidden = true
        
        //MapView Setup
        mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if fetchedResultsController.fetchedObjects?.count != 0
        {
            setMapView()
        }
    }
    
    //MARK:Core Data
    func initializeFetchedResultsController()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentMapView")
        let latDeltaSort = NSSortDescriptor(key: "latitudeDelta", ascending: false)
        let lonDeltaSort = NSSortDescriptor(key: "longitudeDelta", ascending: false)
        let latSort = NSSortDescriptor(key: "latitude", ascending: false)
        let lonSort = NSSortDescriptor(key: "longitude", ascending: false)
        request.sortDescriptors = [latDeltaSort, lonDeltaSort, latSort, lonSort]
        
        let moc = stack.context
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("Successful initialized CurrentMapView FetchedResultsController")
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func initializeAnnotationFetchedResultsController()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
        let latSort = NSSortDescriptor(key: "latitude", ascending: false)
        let lonSort = NSSortDescriptor(key: "longitude", ascending: false)
        request.sortDescriptors = [latSort, lonSort]
        
        let moc = stack.context
        fetchedAnnotationsResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedAnnotationsResultsController.delegate = self
        
        do {
            try fetchedAnnotationsResultsController.performFetch()
            print("Successful initialized Annotation FetchedResultsController")
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getCurrentMapView()
    {
        DispatchQueue.main.async
        {
            let x = CurrentMapView(latDelta: self.mapView.region.span.latitudeDelta, lonDelta: self.mapView.region.span.longitudeDelta, lat: self.mapView.centerCoordinate.latitude, lon: self.mapView.centerCoordinate.longitude, context: self.stack.context)
            
            print(x.latitude, x.longitude)
            
            self.stack.save()
        }
    }
    
    func setMapView()
    {
        DispatchQueue.main.async
            {
                
                let fr = self.fetchedResultsController.fetchedObjects?[(self.fetchedResultsController.fetchedObjects?.count)! - 1] as! CurrentMapView
                print(Int((self.fetchedResultsController.fetchedObjects?.count)!))
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
                print(fr.latitude, fr.longitude)
        }
    }
    
    //MARK: Helper Functions
    func addAnnotation(gestureRecognizer:UIGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.title = "Select to see Photos!"
            annotation.coordinate = newCoordinates
            annotations.append(annotation)
            
            let _ = Annotations(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, context: stack.context)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    //MARK: Map Class Methods
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        initializeFetchedResultsController()
        getCurrentMapView()
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumViewController
        self.navigationController?.pushViewController(photoAlbumVC!, animated: true)
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
}

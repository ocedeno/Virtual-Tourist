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
    var fetchedAnnotationsResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var annotations = [MKAnnotation]()
    var currentMV: CurrentMapView?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack: CoreDataStack!
    
    //MARK: Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Get the stack
        stack = delegate.stack
        initializeAnnotationFetchedResultsController()
        
        //Hide Nav Bar
        self.navigationController?.navigationBar.isHidden = true
        
        //Check for Initial MapView Coordinates
        let fr = NSFetchRequest<CurrentMapView>(entityName: "CurrentMapView")
        
        if delegate.checkIfFirstLaunch()
        {
            currentMV = try! stack.context.fetch(fr)[0]
            setMapView()
            getAnnotationsArray()
        }else
        {
            currentMV = CurrentMapView(latDelta: self.mapView.region.span.latitudeDelta, lonDelta: self.mapView.region.span.longitudeDelta, lat: self.mapView.centerCoordinate.latitude, lon: self.mapView.centerCoordinate.longitude, context: self.stack.context)
        }
        
        //MapView Setup
        mapView.delegate = self
        mapView.addAnnotations(annotations)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    func initializeAnnotationFetchedResultsController()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
        let latSort = NSSortDescriptor(key: "latitude", ascending: true)
        let lonSort = NSSortDescriptor(key: "longitude", ascending: false)
        request.sortDescriptors = [latSort, lonSort]
        
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
            let annotation = MKPointAnnotation()
            let latitude = object.latitude
            let longitude = object.longitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinates
            annotation.title = "Select to see Photos!"
            annotations.append(annotation)
        }
    }
    
    func getCurrentMapView()
    {
        stack.context.delete(currentMV!)
        currentMV = CurrentMapView(latDelta: self.mapView.region.span.latitudeDelta, lonDelta: self.mapView.region.span.longitudeDelta, lat: self.mapView.centerCoordinate.latitude, lon: self.mapView.centerCoordinate.longitude, context: self.stack.context)
        
        self.stack.save()
    }
    
    func setMapView()
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
    }
    
    //MARK: Helper Functions
    func addAnnotation(gestureRecognizer:UIGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            _ = Annotations(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: stack.context)
            let annotation = MKPointAnnotation()
            annotation.title = "Select to see Photos!"
            annotation.coordinate = newCoordinates
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    //MARK: Map Class Methods
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
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

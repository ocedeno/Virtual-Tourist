//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/24/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController
{
    //IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables/Constants
    var pinArray: [MKAnnotation]?
    
    //Life Cycle:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            var touchPoint = gestureRecognizer.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            print(newCoordinates)
        }
    }
}

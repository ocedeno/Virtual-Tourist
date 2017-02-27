//
//  MapClient.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import MapKit


class MapClient
{
    let MERCATOR_RADIUS =  85445659.44705395
    
    func getZoomLevel(mapView: MKMapView)
    {
        let longitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        let latitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapWidthInPixels: CGFloat = mapView.bounds.size.width
        
    }
}

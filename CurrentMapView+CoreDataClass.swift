//
//  CurrentMapView+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(CurrentMapView)
public class CurrentMapView: NSManagedObject
{
    convenience init(latDelta:Double = 0.0,lonDelta: Double = 0.0, lat: Double, lon: Double, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "CurrentMapView", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.latitudeDelta = latDelta
            self.longitudeDelta = lonDelta
            self.latitude = lat
            self.longitude = lon
        }else
        {
            fatalError("Unable to find Entity name!")
        }
    }
}

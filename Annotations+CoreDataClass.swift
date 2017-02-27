//
//  Annotations+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Annotations)
public class Annotations: NSManagedObject
{
    convenience init(latitude: Double = 0.0, longitude: Double = 0.0, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "Annotations", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        }else
        {
            fatalError("Unable to find Entity name!")
        }
    }
}

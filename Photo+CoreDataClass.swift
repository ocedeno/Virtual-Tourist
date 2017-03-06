//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject
{
    convenience init(imageData: String?, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData
        }else
        {
            fatalError("Unable to find Entity name!")
        }
    }
}

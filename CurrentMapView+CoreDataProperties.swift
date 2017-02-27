//
//  CurrentMapView+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreData


extension CurrentMapView {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentMapView> {
        return NSFetchRequest<CurrentMapView>(entityName: "CurrentMapView");
    }

    @NSManaged public var latitudeDelta: Double
    @NSManaged public var longitudeDelta: Double

}

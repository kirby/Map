//
//  Reminder.swift
//  Map
//
//  Created by Kirby Shabaga on 8/19/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var message: String

}

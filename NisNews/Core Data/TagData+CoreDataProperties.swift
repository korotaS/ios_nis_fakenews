//
//  TagData+CoreDataProperties.swift
//  NisNews
//
//  Created by K&K on 29.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//
//

import Foundation
import CoreData


extension TagData {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TagData> {
        return NSFetchRequest<TagData>(entityName: "TagData")
    }

    @NSManaged public var title: String
    @NSManaged public var tag: String

}

//
//  ArticleData+CoreDataProperties.swift
//  NisNews
//
//  Created by K&K on 29.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//
//

import Foundation
import CoreData


extension ArticleData {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ArticleData> {
        return NSFetchRequest<ArticleData>(entityName: "ArticleData")
    }

    @NSManaged public var date: String
    @NSManaged public var descriptionNews: String
    @NSManaged public var id: Int64
    @NSManaged public var image: String
    @NSManaged public var link: String
    @NSManaged public var title: String
    @NSManaged public var tag: String

}

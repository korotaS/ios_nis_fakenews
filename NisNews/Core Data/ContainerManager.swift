//
//  ContainerManager.swift
//  NisNews
//
//  Created by K&K on 29.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import Foundation
import CoreData

class ContainerManager {
    
    static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores { storeDescription, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        return container
    }()
    
    func loadSavedArticlesByTag(_ tag: String) -> [Article] {
        let request = ArticleData.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "tag == '\(tag)'")
        
        do {
            let articles = try Self.container.viewContext.fetch(request)
            print("Got \(articles.count) articles")
            
            return articles.map { a in
                NewsMapper.articleData2Article(a)
            }
        } catch {
            print("Fetch failed")
            return []
        }
    }
    
    func loadSavedTags() -> [Tag] {
        let request = TagData.createFetchRequest()
        let sort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sort]
        do {
            let tags = try Self.container.viewContext.fetch(request)
            print("Got \(tags.count) tags")
            
            return tags.map { t in
                NewsMapper.tagData2Tag(t)
            }
        } catch {
            print("Fetch failed")
            return []
        }
    }
    
    func saveTags(_ tags: [Tag]) {
        for tag in tags {
            let tagData = TagData(context: Self.container.viewContext)
            NewsMapper.tag2TagData(tagData, tag: tag)
        }
        
        saveContext()
    }
    
    func saveArticles(_ articles: [Article], byTag tag: String) {
        for article in articles {
            let articleData = ArticleData(context: Self.container.viewContext)
            NewsMapper.article2ArticleData(articleData, article: article, withTag: tag)
        }
        
        saveContext()
    }
    
    func getArticleById(_ id: Int64) -> ArticleData? {
        let request = ArticleData.createFetchRequest()
        request.predicate = NSPredicate(format: "id == '\(id)'")
        
        return (try? Self.container.viewContext.fetch(request))?.first
    }
    
    func changeArticleById(_ id: Int64, handler: @escaping (ArticleData?) -> Void) {
        handler(getArticleById(id))
        saveContext()
    }
    
    private func saveContext() {
        if Self.container.viewContext.hasChanges {
            do {
                try Self.container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}

//
//  NewsMapper.swift
//  NisNews
//
//  Created by Артём Кулаков on 28.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import Foundation

class NewsMapper {
    
    private init() {}
    
    static func articleData2Article(_ articleData: ArticleData) -> Article {
        return Article(title: articleData.title, description: articleData.descriptionNews, image: articleData.image, date: articleData.date, link: articleData.link)
    }
    
    static func article2ArticleData(_  articleData: ArticleData, article: Article, withTag tag: String = "") {
        articleData.id = Int64(article.title.hashValue)
        articleData.date = article.date
        articleData.title = article.title
        articleData.descriptionNews = article.description
        articleData.image = article.image
        articleData.link = article.link
        articleData.tag = tag
    }
    
    static func tagData2Tag(_ tagData: TagData) -> Tag {
        return Tag(title: tagData.title, tag: tagData.tag)
    }
    
    static func tag2TagData(_ tagData: TagData, tag: Tag) {
        tagData.title = tag.title
        tagData.tag = tag.tag
    }
}

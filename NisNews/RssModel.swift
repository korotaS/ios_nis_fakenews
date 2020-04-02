//
//  RssModel.swift
//  NisNews
//
//  Created by К&К on 07.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import Foundation

struct FullRss: Decodable {
    
    let rss: Rss

    struct Rss: Decodable {
        
        let channel: Channel
        
        struct Channel: Decodable {
            
            let item: [Item]
            
            struct Item: Decodable {
                let title: String
                let link: String
                let guid: String
                let description: String
                let pubDate: String
            }
        }
    }
}

struct Tag: Decodable {
    let title: String
    let tag: String
}

struct Images: Decodable {
    let cat1: String
    let cat2: String
}

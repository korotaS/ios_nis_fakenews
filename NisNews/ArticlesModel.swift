//
//  ArticlesModel.swift
//  NisNews
//
//  Created by K&K on 17.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import Foundation

struct NewsResponse: Decodable {
    var articles: [Article]
}

struct Article: Decodable {
    var title: String
    var description: String
    var image: String
    var date: String
    var link: String
}

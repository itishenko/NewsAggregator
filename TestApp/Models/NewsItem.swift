//
//  NewsItem.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class NewsItem: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var itemDescription: String
    @Persisted var link: String
    @Persisted var imageURL: String?
    @Persisted var pubDate: Date
    @Persisted var sourceID: String
    @Persisted var sourceName: String
    @Persisted var isRead: Bool = false
    
    convenience init(id: String, title: String, description: String, link: String, imageURL: String?, pubDate: Date, sourceID: String, sourceName: String) {
        self.init()
        self.id = id
        self.title = title
        self.itemDescription = description
        self.link = link
        self.imageURL = imageURL
        self.pubDate = pubDate
        self.sourceID = sourceID
        self.sourceName = sourceName
    }
}

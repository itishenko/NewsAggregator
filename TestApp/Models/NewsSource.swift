//
//  NewsSource.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class NewsSource: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var rssURL: String
    @Persisted var isEnabled: Bool = true
    
    convenience init(id: String, name: String, rssURL: String, isEnabled: Bool = true) {
        self.init()
        self.id = id
        self.name = name
        self.rssURL = rssURL
        self.isEnabled = isEnabled
    }
}

// Default sources
extension NewsSource {
    static func defaultSources() -> [NewsSource] {
        return [
            NewsSource(id: "vedomosti", name: "Ведомости", rssURL: "https://www.vedomosti.ru/rss/news.xml"),
            NewsSource(id: "rbc", name: "РБК", rssURL: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss")
        ]
    }
}

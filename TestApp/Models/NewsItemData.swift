//
//  NewsItemData.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation

struct NewsItemData {
    let id: String
    let title: String
    let itemDescription: String
    let link: String
    let imageURL: String?
    let pubDate: Date
    let sourceID: String
    let sourceName: String
    let isRead: Bool
    
    init(from item: NewsItem) {
        self.id = item.id
        self.title = item.title
        self.itemDescription = item.itemDescription
        self.link = item.link
        self.imageURL = item.imageURL
        self.pubDate = item.pubDate
        self.sourceID = item.sourceID
        self.sourceName = item.sourceName
        self.isRead = item.isRead
    }
}

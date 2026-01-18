//
//  NewsSourceData.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation

struct NewsSourceData {
    let id: String
    let name: String
    let rssURL: String
    let isEnabled: Bool
    
    init(from source: NewsSource) {
        self.id = source.id
        self.name = source.name
        self.rssURL = source.rssURL
        self.isEnabled = source.isEnabled
    }
}

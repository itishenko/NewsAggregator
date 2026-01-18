//
//  NewsRepository.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class NewsRepository: NewsRepositoryProtocol {
    
    private let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func save(_ items: [NewsItem]) {
        if Thread.isMainThread {
            try? realm.write {
                items.forEach { realm.add($0, update: .modified) }
            }
        } else {
            DispatchQueue.main.sync {
                try? realm.write {
                    items.forEach { realm.add($0, update: .modified) }
                }
            }
        }
    }
    
    func getAll() -> Results<NewsItem> {
        return realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
    }
    
    func markAsRead(_ item: NewsItem) {
        try? realm.write {
            item.isRead = true
        }
    }
    
    func deleteAll() {
        try? realm.write {
            let allNews = realm.objects(NewsItem.self)
            realm.delete(allNews)
        }
    }
}

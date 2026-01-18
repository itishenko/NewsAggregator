//
//  SourceRepository.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class SourceRepository: SourceRepositoryProtocol {
    
    private let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func getAll() -> Results<NewsSource> {
        return realm.objects(NewsSource.self)
    }
    
    func update(_ source: NewsSource, isEnabled: Bool) {
        try? realm.write {
            source.isEnabled = isEnabled
        }
    }
    
    func add(id: String, name: String, rssURL: String) {
        let source = NewsSource(id: id, name: name, rssURL: rssURL)
        try? realm.write {
            realm.add(source, update: .modified)
        }
    }
    
    func setupDefaultSources() {
        let sources = realm.objects(NewsSource.self)
        
        if sources.isEmpty {
            try? realm.write {
                NewsSource.defaultSources().forEach { realm.add($0) }
            }
        }
    }
}

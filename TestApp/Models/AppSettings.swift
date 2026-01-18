//
//  AppSettings.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class AppSettings: Object {
    @Persisted(primaryKey: true) var id: String = "app_settings"
    @Persisted var refreshIntervalMinutes: Int = 15
    @Persisted var lastUpdated: Date?
    
    static func shared(realm: Realm) -> AppSettings {
        if let settings = realm.object(ofType: AppSettings.self, forPrimaryKey: "app_settings") {
            return settings
        }
        
        let settings = AppSettings()
        try? realm.write {
            realm.add(settings)
        }
        return settings
    }
}

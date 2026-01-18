//
//  SettingsRepository.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class SettingsRepository: SettingsRepositoryProtocol {
    
    private let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
        initializeSettings()
    }
    
    private func initializeSettings() {
        _ = AppSettings.shared(realm: realm)
    }
    
    func get() -> AppSettings {
        return AppSettings.shared(realm: realm)
    }
    
    func updateRefreshInterval(minutes: Int) {
        let settings = AppSettings.shared(realm: realm)
        try? realm.write {
            settings.refreshIntervalMinutes = minutes
        }
    }
    
    func updateLastUpdated() {
        let settings = AppSettings.shared(realm: realm)
        try? realm.write {
            settings.lastUpdated = Date()
        }
    }
}

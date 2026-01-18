//
//  DatabaseService.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class DatabaseService: DatabaseServiceProtocol {
    
    // MARK: - Repositories
    
    let newsRepository: NewsRepositoryProtocol
    let sourceRepository: SourceRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    
    // MARK: - Private Properties
    
    private let realm: Realm
    
    // MARK: - Init
    
    init(
        newsRepository: NewsRepositoryProtocol? = nil,
        sourceRepository: SourceRepositoryProtocol? = nil,
        settingsRepository: SettingsRepositoryProtocol? = nil
    ) {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                        // Migration logic if needed
                    }
                }
            )
            self.realm = try Realm(configuration: config)
        } catch {
#if DEBUG
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                let inMemoryConfig = Realm.Configuration(inMemoryIdentifier: "TestRealm")
                self.realm = try! Realm(configuration: inMemoryConfig)
            } else {
                fatalError("Failed to initialize Realm: \(error)")
            }
#else
            fatalError("Failed to initialize Realm: \(error)")
#endif
        }
        
        
        
        self.newsRepository = newsRepository ?? NewsRepository(realm: self.realm)
        self.sourceRepository = sourceRepository ?? SourceRepository(realm: self.realm)
        self.settingsRepository = settingsRepository ?? SettingsRepository(realm: self.realm)
        
        self.sourceRepository.setupDefaultSources()
    }
}

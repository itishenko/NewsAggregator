//
//  DependencyContainer.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation

class DependencyContainer {
    
    // MARK: - Services
    
    let databaseService: DatabaseServiceProtocol
    let newsService: NewsServiceProtocol
    let imageCacheService: ImageCacheServiceProtocol
    
    // MARK: - Repositories (computed from databaseService)
    
    var newsRepository: NewsRepositoryProtocol {
        return databaseService.newsRepository
    }
    
    var sourceRepository: SourceRepositoryProtocol {
        return databaseService.sourceRepository
    }
    
    var settingsRepository: SettingsRepositoryProtocol {
        return databaseService.settingsRepository
    }
    
    // MARK: - Init
    
    init(
        databaseService: DatabaseServiceProtocol? = nil,
        newsService: NewsServiceProtocol? = nil,
        imageCacheService: ImageCacheServiceProtocol? = nil
    ) {
        self.databaseService = databaseService ?? DatabaseService()
        self.newsService = newsService ?? NewsService(rssParser: RSSParser())
        self.imageCacheService = imageCacheService ?? ImageCacheService()
    }
}

//
//  SettingsViewModel.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift
import Realm

class SettingsViewModel {
    
    // MARK: - Properties
    
    private let sourceRepository: SourceRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let imageCacheService: ImageCacheServiceProtocol
    private var sourcesNotificationToken: NotificationToken?
    
    var sources: Results<NewsSource>? {
        didSet {
            setupSourcesNotifications()
        }
    }
    
    var settings: AppSettings {
        return settingsRepository.get()
    }
    
    // MARK: - Callbacks
    
    var onSourcesUpdated: (() -> Void)?
    var onSettingsUpdated: (() -> Void)?
    var onCacheCleared: (() -> Void)?
    
    // MARK: - Init
    
    init(
        sourceRepository: SourceRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        imageCacheService: ImageCacheServiceProtocol
    ) {
        self.sourceRepository = sourceRepository
        self.settingsRepository = settingsRepository
        self.imageCacheService = imageCacheService
        loadSources()
    }
    
    deinit {
        sourcesNotificationToken?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func loadSources() {
        sources = sourceRepository.getAll()
    }
    
    func toggleSource(at index: Int) {
        guard let source = sources?[index] else { return }
        sourceRepository.update(source, isEnabled: !source.isEnabled)
    }
    
    func updateRefreshInterval(minutes: Int) {
        settingsRepository.updateRefreshInterval(minutes: minutes)
        onSettingsUpdated?()
    }
    
    func numberOfSources() -> Int {
        return sources?.count ?? 0
    }
    
    func getSource(at index: Int) -> NewsSource? {
        return sources?[index]
    }
    
    func clearCache() {
        imageCacheService.clearCache()
        onCacheCleared?()
    }
    
    func getCacheSize() -> String {
        let bytes = imageCacheService.getCacheSize()
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    func getLastUpdatedString() -> String {
        if let lastUpdated = settings.lastUpdated {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: lastUpdated)
        }
        return "Никогда"
    }
    
    func addNewSource(name: String, url: String) -> Bool {
        guard !name.isEmpty, !url.isEmpty,
              let _ = URL(string: url) else {
            return false
        }
        
        let id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        sourceRepository.add(id: id, name: name, rssURL: url)
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupSourcesNotifications() {
        sourcesNotificationToken?.invalidate()
        
        sourcesNotificationToken = sources?.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial, .update:
                self.onSourcesUpdated?()
            case .error:
                break
            }
        }
    }
}

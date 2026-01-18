//
//  NewsListViewModel.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift
import Realm

enum DisplayMode {
    case normal
    case expanded
}

class NewsListViewModel {
    
    // MARK: - Properties
    
    private let newsRepository: NewsRepositoryProtocol
    private let sourceRepository: SourceRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let newsService: NewsServiceProtocol
    private var notificationToken: NotificationToken?
    private var refreshTimer: Timer?
    
    var displayMode: DisplayMode = .normal {
        didSet {
            onDisplayModeChanged?()
        }
    }
    
    var newsItems: Results<NewsItem>? {
        didSet {
            setupNotifications()
        }
    }
    
    var filteredNews: [NewsItem] {
        guard let items = newsItems else { return [] }
        return Array(items)
    }
    
    // MARK: - Callbacks
    
    var onNewsUpdated: (() -> Void)?
    var onDisplayModeChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var onRefreshStarted: (() -> Void)?
    var onRefreshCompleted: (() -> Void)?
    
    // MARK: - Init
    
    init(
        newsRepository: NewsRepositoryProtocol,
        sourceRepository: SourceRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        newsService: NewsServiceProtocol
    ) {
        self.newsRepository = newsRepository
        self.sourceRepository = sourceRepository
        self.settingsRepository = settingsRepository
        self.newsService = newsService
        loadNews()
        setupRefreshTimer()
    }
    
    deinit {
        notificationToken?.invalidate()
        refreshTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func loadNews() {
        newsItems = newsRepository.getAll()
    }
    
    func refreshNews() {
        onRefreshStarted?()
        
        let sources = Array(sourceRepository.getAll())
        
        newsService.fetchNews(from: sources) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.newsRepository.save(items)
                    self.settingsRepository.updateLastUpdated()
                    self.loadNews()
                    self.onRefreshCompleted?()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                    self.onRefreshCompleted?()
                }
            }
        }
    }
    
    func toggleDisplayMode() {
        displayMode = displayMode == .normal ? .expanded : .normal
    }
    
    func markAsRead(at index: Int) {
        guard let item = newsItems?[index] else { return }
        newsRepository.markAsRead(item)
    }
    
    func getNewsItem(at index: Int) -> NewsItem? {
        return newsItems?[index]
    }
    
    func numberOfItems() -> Int {
        return newsItems?.count ?? 0
    }
    
    func shouldAutoRefresh() -> Bool {
        let settings = settingsRepository.get()
        
        guard let lastUpdated = settings.lastUpdated else {
            return true
        }
        
        let interval = TimeInterval(settings.refreshIntervalMinutes * 60)
        let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdated)
        
        return timeSinceLastUpdate >= interval
    }
    
    func clearAllData() {
        newsRepository.deleteAll()
        loadNews()
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        notificationToken?.invalidate()
        
        notificationToken = newsItems?.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.onNewsUpdated?()
            case .update:
                self.onNewsUpdated?()
            case .error(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    private func setupRefreshTimer() {
        let settings = settingsRepository.get()
        let interval = TimeInterval(settings.refreshIntervalMinutes * 60)
        
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshNews()
        }
    }
    
    func updateRefreshInterval() {
        setupRefreshTimer()
    }
}

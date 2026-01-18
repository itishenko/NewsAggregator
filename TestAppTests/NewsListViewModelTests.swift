import XCTest
import RealmSwift
@testable import TestApp

// MARK: - Mock Repositories

class MockNewsRepository: NewsRepositoryProtocol {
    var savedItems: [NewsItem] = []
    var allItems: Results<NewsItem>?
    var markedAsReadItem: NewsItem?
    var deleteAllCalled = false
    
    private let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func save(_ items: [NewsItem]) {
        savedItems = items
        try? realm.write {
            items.forEach { realm.add($0, update: .modified) }
        }
        allItems = realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
    }
    
    func getAll() -> Results<NewsItem> {
        return realm.objects(NewsItem.self).sorted(byKeyPath: "pubDate", ascending: false)
    }
    
    func markAsRead(_ item: NewsItem) {
        markedAsReadItem = item
        try? realm.write {
            item.isRead = true
        }
    }
    
    func deleteAll() {
        deleteAllCalled = true
        try? realm.write {
            realm.delete(realm.objects(NewsItem.self))
        }
    }
}

class MockSourceRepository: SourceRepositoryProtocol {
    var sources: [NewsSource] = []
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
        let defaultSources = NewsSource.defaultSources()
        try? realm.write {
            defaultSources.forEach { realm.add($0, update: .modified) }
        }
    }
}

class MockSettingsRepository: SettingsRepositoryProtocol {
    var settings = AppSettings()
    
    func get() -> AppSettings {
        return settings
    }
    
    func updateRefreshInterval(minutes: Int) {
        settings.refreshIntervalMinutes = minutes
    }
    
    func updateLastUpdated() {
        settings.lastUpdated = Date()
    }
}

class MockNewsService: NewsServiceProtocol {
    var fetchNewsCalled = false
    var sourcesPassed: [NewsSource] = []
    var mockResult: Result<[NewsItem], Error> = .success([])
    
    func fetchNews(from sources: [NewsSource], completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        fetchNewsCalled = true
        sourcesPassed = sources
        completion(mockResult)
    }
}

final class NewsListViewModelTests: XCTestCase {
    
    var testRealm: Realm!
    var mockNewsRepository: MockNewsRepository!
    var mockSourceRepository: MockSourceRepository!
    var mockSettingsRepository: MockSettingsRepository!
    var mockNewsService: MockNewsService!
    var viewModel: NewsListViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = Realm.Configuration(inMemoryIdentifier: "test-realm-\(UUID().uuidString)")
        testRealm = try Realm(configuration: config)
        
        mockNewsRepository = MockNewsRepository(realm: testRealm)
        mockSourceRepository = MockSourceRepository(realm: testRealm)
        mockSettingsRepository = MockSettingsRepository()
        mockNewsService = MockNewsService()
        
        viewModel = NewsListViewModel(
            newsRepository: mockNewsRepository,
            sourceRepository: mockSourceRepository,
            settingsRepository: mockSettingsRepository,
            newsService: mockNewsService
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNewsService = nil
        mockSettingsRepository = nil
        mockSourceRepository = nil
        mockNewsRepository = nil
        try testRealm.write {
            testRealm.deleteAll()
        }
        testRealm = nil
        try super.tearDownWithError()
    }
    
    func testLoadNews() throws {
        // Given
        let item = NewsItem(
            id: "1",
            title: "Test News",
            description: "Description",
            link: "https://example.com",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        mockNewsRepository.save([item])
        
        // When
        viewModel.loadNews()
        
        // Then
        XCTAssertEqual(viewModel.numberOfItems(), 1)
        XCTAssertNotNil(viewModel.newsItems)
    }
    
    func testRefreshNews() throws {
        // Given
        let expectation = XCTestExpectation(description: "Refresh completes")
        let items = [
            NewsItem(
                id: "1",
                title: "News 1",
                description: "Desc 1",
                link: "https://example.com/1",
                imageURL: nil,
                pubDate: Date(),
                sourceID: "source-1",
                sourceName: "Source 1"
            )
        ]
        
        mockNewsService.mockResult = .success(items)
        mockSourceRepository.sources = [
            NewsSource(id: "source-1", name: "Source 1", rssURL: "https://example.com/rss", isEnabled: true)
        ]
        
        viewModel.onRefreshCompleted = {
            expectation.fulfill()
        }
        
        // When
        viewModel.refreshNews()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNewsService.fetchNewsCalled)
        XCTAssertEqual(mockNewsRepository.savedItems.count, 1)
    }
    
    func testToggleDisplayMode() throws {
        // Given
        XCTAssertEqual(viewModel.displayMode, .normal)
        
        // When
        viewModel.toggleDisplayMode()
        
        // Then
        XCTAssertEqual(viewModel.displayMode, .expanded)
        
        // When
        viewModel.toggleDisplayMode()
        
        // Then
        XCTAssertEqual(viewModel.displayMode, .normal)
    }
    
    func testMarkAsRead() throws {
        // Given
        let item = NewsItem(
            id: "1",
            title: "Test News",
            description: "Description",
            link: "https://example.com",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        mockNewsRepository.save([item])
        viewModel.loadNews()
        
        // When
        viewModel.markAsRead(at: 0)
        
        // Then
        XCTAssertNotNil(mockNewsRepository.markedAsReadItem)
        XCTAssertEqual(mockNewsRepository.markedAsReadItem?.id, "1")
    }
    
    func testGetNewsItem() throws {
        // Given
        let item = NewsItem(
            id: "1",
            title: "Test News",
            description: "Description",
            link: "https://example.com",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        mockNewsRepository.save([item])
        viewModel.loadNews()
        
        // When
        let retrievedItem = viewModel.getNewsItem(at: 0)
        
        // Then
        XCTAssertNotNil(retrievedItem)
        XCTAssertEqual(retrievedItem?.id, "1")
        XCTAssertEqual(retrievedItem?.title, "Test News")
    }
    
    func testNumberOfItems() throws {
        // Given
        let items = [
            NewsItem(
                id: "1",
                title: "News 1",
                description: "Desc 1",
                link: "https://example.com/1",
                imageURL: nil,
                pubDate: Date(),
                sourceID: "source-1",
                sourceName: "Source 1"
            ),
            NewsItem(
                id: "2",
                title: "News 2",
                description: "Desc 2",
                link: "https://example.com/2",
                imageURL: nil,
                pubDate: Date(),
                sourceID: "source-2",
                sourceName: "Source 2"
            )
        ]
        mockNewsRepository.save(items)
        viewModel.loadNews()
        
        // When
        let count = viewModel.numberOfItems()
        
        // Then
        XCTAssertEqual(count, 2)
    }
    
    func testClearAllData() throws {
        // Given
        let items = [
            NewsItem(
                id: "1",
                title: "News 1",
                description: "Desc 1",
                link: "https://example.com/1",
                imageURL: nil,
                pubDate: Date(),
                sourceID: "source-1",
                sourceName: "Source 1"
            )
        ]
        mockNewsRepository.save(items)
        viewModel.loadNews()
        XCTAssertEqual(viewModel.numberOfItems(), 1)
        
        // When
        viewModel.clearAllData()
        
        // Then
        XCTAssertTrue(mockNewsRepository.deleteAllCalled)
        XCTAssertEqual(viewModel.numberOfItems(), 0)
    }
    
    func testShouldAutoRefresh() throws {
        // Given - настройки без lastUpdated
        mockSettingsRepository.settings.lastUpdated = nil
        
        // When
        let shouldRefresh = viewModel.shouldAutoRefresh()
        
        // Then
        XCTAssertTrue(shouldRefresh)
    }
    
    func testShouldNotAutoRefresh() throws {
        // Given 
        mockSettingsRepository.settings.lastUpdated = Date()
        mockSettingsRepository.settings.refreshIntervalMinutes = 60
        
        // When
        let shouldRefresh = viewModel.shouldAutoRefresh()
        
        // Then
        XCTAssertFalse(shouldRefresh)
    }
}

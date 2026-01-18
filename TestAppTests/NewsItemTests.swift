import XCTest
import RealmSwift
@testable import TestApp

final class NewsItemTests: XCTestCase {
    
    var testRealm: Realm!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let config = Realm.Configuration(inMemoryIdentifier: "test-realm")
        testRealm = try Realm(configuration: config)
    }
    
    override func tearDownWithError() throws {
        try testRealm.write {
            testRealm.deleteAll()
        }
        testRealm = nil
        try super.tearDownWithError()
    }
    
    func testNewsItemInitialization() throws {
        // Given
        let id = "test-id-1"
        let title = "Test News Title"
        let description = "Test Description"
        let link = "https://example.com/news"
        let imageURL = "https://example.com/image.jpg"
        let pubDate = Date()
        let sourceID = "source-1"
        let sourceName = "Test Source"
        
        // When
        let newsItem = NewsItem(
            id: id,
            title: title,
            description: description,
            link: link,
            imageURL: imageURL,
            pubDate: pubDate,
            sourceID: sourceID,
            sourceName: sourceName
        )
        
        // Then
        XCTAssertEqual(newsItem.id, id)
        XCTAssertEqual(newsItem.title, title)
        XCTAssertEqual(newsItem.itemDescription, description)
        XCTAssertEqual(newsItem.link, link)
        XCTAssertEqual(newsItem.imageURL, imageURL)
        XCTAssertEqual(newsItem.pubDate, pubDate)
        XCTAssertEqual(newsItem.sourceID, sourceID)
        XCTAssertEqual(newsItem.sourceName, sourceName)
        XCTAssertFalse(newsItem.isRead)
    }
    
    func testNewsItemWithNilImageURL() throws {
        // Given
        let newsItem = NewsItem(
            id: "test-id",
            title: "Test",
            description: "Description",
            link: "https://example.com",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        
        // Then
        XCTAssertNil(newsItem.imageURL)
    }
    
    func testNewsItemIsReadDefaultValue() throws {
        // Given
        let newsItem = NewsItem(
            id: "test-id",
            title: "Test",
            description: "Description",
            link: "https://example.com",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        
        // Then
        XCTAssertFalse(newsItem.isRead)
    }
    
    func testNewsItemPrimaryKey() throws {
        // Given
        let id = "unique-id"
        let newsItem1 = NewsItem(
            id: id,
            title: "Title 1",
            description: "Desc 1",
            link: "https://example.com/1",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-1",
            sourceName: "Source"
        )
        
        let newsItem2 = NewsItem(
            id: id,
            title: "Title 2",
            description: "Desc 2",
            link: "https://example.com/2",
            imageURL: nil,
            pubDate: Date(),
            sourceID: "source-2",
            sourceName: "Source 2"
        )
        
        // When
        try testRealm.write {
            testRealm.add(newsItem1)
            testRealm.add(newsItem2, update: .modified)
        }
        
        // Then - должна быть только одна запись с таким id
        let savedItems = testRealm.objects(NewsItem.self)
        XCTAssertEqual(savedItems.count, 1)
        XCTAssertEqual(savedItems.first?.title, "Title 2") // Обновленная версия
    }
}

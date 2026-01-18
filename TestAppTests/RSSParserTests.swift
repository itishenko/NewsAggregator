import XCTest
@testable import TestApp

final class RSSParserTests: XCTestCase {
    
    var parser: RSSParser!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        parser = RSSParser()
    }
    
    override func tearDownWithError() throws {
        parser = nil
        try super.tearDownWithError()
    }
    
    func testParseValidRSS() throws {
        // Given
        let rssXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>Test News Title</title>
                    <description>Test Description</description>
                    <link>https://example.com/news</link>
                    <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
                </item>
            </channel>
        </rss>
        """
        
        let data = rssXML.data(using: .utf8)!
        
        // When
        let items = parser.parse(data: data)
        
        // Then
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Test News Title")
        XCTAssertEqual(items.first?.description, "Test Description")
        XCTAssertEqual(items.first?.link, "https://example.com/news")
    }
    
    func testParseMultipleItems() throws {
        // Given
        let rssXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>News 1</title>
                    <description>Description 1</description>
                    <link>https://example.com/1</link>
                    <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
                </item>
                <item>
                    <title>News 2</title>
                    <description>Description 2</description>
                    <link>https://example.com/2</link>
                    <pubDate>Mon, 01 Jan 2024 13:00:00 +0000</pubDate>
                </item>
            </channel>
        </rss>
        """
        
        let data = rssXML.data(using: .utf8)!
        
        // When
        let items = parser.parse(data: data)
        
        // Then
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].title, "News 1")
        XCTAssertEqual(items[1].title, "News 2")
    }
    
    func testParseWithImageURL() throws {
        // Given
        let rssXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>News with Image</title>
                    <description>Description</description>
                    <link>https://example.com/news</link>
                    <enclosure url="https://example.com/image.jpg" type="image/jpeg"/>
                    <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
                </item>
            </channel>
        </rss>
        """
        
        let data = rssXML.data(using: .utf8)!
        
        // When
        let items = parser.parse(data: data)
        
        // Then
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.imageURL, "https://example.com/image.jpg")
    }
    
    func testParseWithHTMLInDescription() throws {
        // Given
        let rssXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <item>
                    <title>News</title>
                    <description>&lt;p&gt;This is a &lt;b&gt;test&lt;/b&gt; description&lt;/p&gt;</description>
                    <link>https://example.com/news</link>
                    <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
                </item>
            </channel>
        </rss>
        """
        
        let data = rssXML.data(using: .utf8)!
        
        // When
        let items = parser.parse(data: data)
        
        // Then
        XCTAssertEqual(items.count, 1)
        let description = items.first?.description ?? ""
        XCTAssertFalse(description.contains("<p>"))
        XCTAssertFalse(description.contains("<b>"))
        XCTAssertFalse(description.contains("</b>"))
        XCTAssertFalse(description.contains("</p>"))
    }
    
    func testParseEmptyRSS() throws {
        // Given
        let rssXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
            </channel>
        </rss>
        """
        
        let data = rssXML.data(using: .utf8)!
        
        // When
        let items = parser.parse(data: data)
        
        // Then
        XCTAssertEqual(items.count, 0)
    }
    
    func testParseInvalidData() throws {
        // Given
        let invalidData = "Not XML data".data(using: .utf8)!
        
        // When
        let items = parser.parse(data: invalidData)
        
        // Then
        XCTAssertNotNil(items)
    }
}

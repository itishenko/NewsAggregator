//
//  RSSParser.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation

struct ParsedNewsItem {
    let title: String
    let description: String
    let link: String
    let imageURL: String?
    let pubDate: Date
}

class RSSParser: NSObject {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImageURL: String?
    private var items: [ParsedNewsItem] = []
    
    private let dateFormatters: [DateFormatter] = {
        let formatters = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, dd MMM yyyy HH:mm:ss zzz",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd"
        ].map { format -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }
        return formatters
    }()
    
    func parse(data: Data) -> [ParsedNewsItem] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }
    
    private func parseDate(from string: String) -> Date {
        for formatter in dateFormatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return Date()
    }
}

extension RSSParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
            currentImageURL = nil
        }
        
        // Handle enclosure tag for images
        if elementName == "enclosure" {
            if let url = attributeDict["url"], url.lowercased().contains("jpg") || url.lowercased().contains("png") || url.lowercased().contains("jpeg") {
                currentImageURL = url
            }
        }
        
        // Handle media:content for images
        if elementName == "media:content" || elementName == "content" {
            if let url = attributeDict["url"] {
                currentImageURL = url
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmedString
        case "description":
            currentDescription += trimmedString
        case "link":
            currentLink += trimmedString
        case "pubDate":
            currentPubDate += trimmedString
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            // Extract image URL from description if not found in enclosure
            if currentImageURL == nil {
                currentImageURL = extractImageURL(from: currentDescription)
            }
            
            // Clean HTML from description
            let cleanDescription = stripHTML(from: currentDescription)
            
            let item = ParsedNewsItem(
                title: currentTitle,
                description: cleanDescription,
                link: currentLink,
                imageURL: currentImageURL,
                pubDate: parseDate(from: currentPubDate)
            )
            items.append(item)
        }
    }
    
    private func extractImageURL(from html: String) -> String? {
        // Try to extract image URL from img tag
        if let regex = try? NSRegularExpression(pattern: "<img[^>]+src=\"([^\"]+)\"", options: []) {
            let nsString = html as NSString
            let results = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let match = results.first {
                let range = match.range(at: 1)
                return nsString.substring(with: range)
            }
        }
        return nil
    }
    
    private func stripHTML(from string: String) -> String {
        var result = string
        
        // Remove HTML tags
        if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) {
            let range = NSRange(location: 0, length: result.utf16.count)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
        }
        
        // Decode HTML entities
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&apos;", with: "'")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

//
//  NewsService.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

class NewsService: NewsServiceProtocol {
    private let rssParser: RSSParser
    
    init(rssParser: RSSParser = RSSParser()) {
        self.rssParser = rssParser
    }
    
    func fetchNews(from sources: [NewsSource], completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        let enabledSources = sources.filter { $0.isEnabled }
        
        guard !enabledSources.isEmpty else {
            completion(.success([]))
            return
        }
        
        let sourcesData = enabledSources.map { NewsSourceData(from: $0) }
        
        let group = DispatchGroup()
        var allNews: [NewsItem] = []
        var errors: [Error] = []
        let queue = DispatchQueue(label: "com.newsaggregator.fetch", attributes: .concurrent)
        
        for sourceData in sourcesData {
            print("Loading from: \(sourceData.name) (\(sourceData.rssURL))")
            group.enter()
            fetchNews(from: sourceData) { result in
                queue.async(flags: .barrier) {
                    switch result {
                    case .success(let news):
                        allNews.append(contentsOf: news)
                    case .failure(let error):
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("Total news items loaded: \(allNews.count), errors: \(errors.count)")
            if !allNews.isEmpty {
                completion(.success(allNews))
            } else if let error = errors.first {
                completion(.failure(error))
            } else {
                completion(.success([]))
            }
        }
    }
    
    private func fetchNews(from sourceData: NewsSourceData, completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        guard let url = URL(string: sourceData.rssURL) else {
            completion(.failure(NSError(domain: "NewsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NewsService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            let parsedItems = self.rssParser.parse(data: data)
            let newsItems = parsedItems.map { item -> NewsItem in
                let cleanLink = item.link.components(separatedBy: "?").first ?? item.link
                let id = "\(sourceData.id)_\(cleanLink)"
                
                return NewsItem(
                    id: id,
                    title: item.title,
                    description: item.description,
                    link: item.link,
                    imageURL: item.imageURL,
                    pubDate: item.pubDate,
                    sourceID: sourceData.id,
                    sourceName: sourceData.name
                )
            }
            
            completion(.success(newsItems))
        }
        
        task.resume()
    }
}

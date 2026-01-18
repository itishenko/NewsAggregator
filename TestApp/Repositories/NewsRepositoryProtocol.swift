//
//  NewsRepositoryProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

protocol NewsRepositoryProtocol {
    func save(_ items: [NewsItem])
    func getAll() -> Results<NewsItem>
    func markAsRead(_ item: NewsItem)
    func deleteAll()
}

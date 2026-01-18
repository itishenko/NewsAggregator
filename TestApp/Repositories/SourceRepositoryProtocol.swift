//
//  SourceRepositoryProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

protocol SourceRepositoryProtocol {
    func getAll() -> Results<NewsSource>
    func update(_ source: NewsSource, isEnabled: Bool)
    func add(id: String, name: String, rssURL: String)
    func setupDefaultSources()
}

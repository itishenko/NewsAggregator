//
//  NewsServiceProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

protocol NewsServiceProtocol {
    func fetchNews(from sources: [NewsSource], completion: @escaping (Result<[NewsItem], Error>) -> Void)
}

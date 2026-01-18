//
//  DatabaseServiceProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

protocol DatabaseServiceProtocol {
    var newsRepository: NewsRepositoryProtocol { get }
    var sourceRepository: SourceRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }
}

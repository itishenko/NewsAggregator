//
//  SettingsRepositoryProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import Foundation
import RealmSwift

protocol SettingsRepositoryProtocol {
    func get() -> AppSettings
    func updateRefreshInterval(minutes: Int)
    func updateLastUpdated()
}

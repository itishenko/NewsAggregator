//
//  ImageCacheServiceProtocol.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import UIKit

protocol ImageCacheServiceProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
    func clearCache()
    func getCacheSize() -> Int64
}

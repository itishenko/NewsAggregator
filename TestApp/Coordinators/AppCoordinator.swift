//
//  AppCoordinator.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    let dependencyContainer: DependencyContainer
    
    init(window: UIWindow, dependencyContainer: DependencyContainer? = nil) {
        self.window = window
        self.dependencyContainer = dependencyContainer ?? DependencyContainer()
        self.navigationController = UINavigationController()
        self.navigationController.navigationBar.prefersLargeTitles = true
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        showNewsList()
    }
    
    private func showNewsList() {
        let coordinator = NewsListCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        coordinator.parentCoordinator = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}

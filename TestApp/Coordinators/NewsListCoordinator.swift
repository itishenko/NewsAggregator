//
//  NewsListCoordinator.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import UIKit
import SafariServices

class NewsListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var parentCoordinator: AppCoordinator?
    
    private let dependencyContainer: DependencyContainer
    private var newsListViewController: NewsListViewController?
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewModel = NewsListViewModel(
            newsRepository: dependencyContainer.newsRepository,
            sourceRepository: dependencyContainer.sourceRepository,
            settingsRepository: dependencyContainer.settingsRepository,
            newsService: dependencyContainer.newsService
        )
        viewModel.coordinator = self
        
        let viewController = NewsListViewController(
            viewModel: viewModel,
            imageCacheService: dependencyContainer.imageCacheService
        )
        newsListViewController = viewController
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    // MARK: - Navigation Methods
    
    func showSettings(onSettingsChanged: @escaping () -> Void) {
        let coordinator = SettingsCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        coordinator.parentCoordinator = self
        coordinator.onSettingsChanged = onSettingsChanged
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showNewsDetail(url: URL, newsItemIndex: Int, onMarkAsRead: @escaping (Int) -> Void) {
        onMarkAsRead(newsItemIndex)
        
        let safariVC = SFSafariViewController(url: url)
        navigationController.present(safariVC, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func showFirstLaunchMessage() {
        let alert = UIAlertController(
            title: "Добро пожаловать!",
            message: "Потяните список вниз для загрузки новостей",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.navigationController.present(alert, animated: true)
        }
    }
}

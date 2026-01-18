//
//  SettingsCoordinator.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import UIKit

class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var parentCoordinator: NewsListCoordinator?
    
    private let dependencyContainer: DependencyContainer
    var onSettingsChanged: (() -> Void)?
    
    private var settingsViewController: SettingsViewController?
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func start() {
        let viewModel = SettingsViewModel(
            sourceRepository: dependencyContainer.sourceRepository,
            settingsRepository: dependencyContainer.settingsRepository,
            imageCacheService: dependencyContainer.imageCacheService
        )
        let viewController = SettingsViewController(viewModel: viewModel)
        viewController.coordinator = self
        settingsViewController = viewController
        
        let navController = UINavigationController(rootViewController: viewController)
        navigationController.present(navController, animated: true)
    }
    
    // MARK: - Navigation Methods
    
    func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.removeChildCoordinator(self)
        }
    }
    
    func showRefreshIntervalPicker(currentInterval: Int, onIntervalSelected: @escaping (Int) -> Void) {
        let alert = UIAlertController(
            title: "Частота обновления",
            message: "Выберите интервал автообновления",
            preferredStyle: .actionSheet
        )
        
        let intervals = [5, 15, 30, 60]
        for interval in intervals {
            alert.addAction(UIAlertAction(title: "\(interval) минут", style: .default) { _ in
                onIntervalSelected(interval)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigationController.presentedViewController?.present(alert, animated: true)
    }
    
    func showAddSourceDialog(onSourceAdded: @escaping (String, String) -> Bool) {
        let alert = UIAlertController(
            title: "Добавить источник",
            message: "Введите данные нового источника новостей",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Название"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "RSS URL"
            textField.keyboardType = .URL
        }
        
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let url = alert.textFields?[1].text else {
                return
            }
            
            if onSourceAdded(name, url) {
                self.showAlert(title: "Успешно", message: "Источник добавлен")
            } else {
                self.showAlert(title: "Ошибка", message: "Проверьте введённые данные")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigationController.presentedViewController?.present(alert, animated: true)
    }
    
    func showClearCacheConfirmation(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Очистить кэш?",
            message: "Это действие удалит все кэшированные изображения",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Очистить", style: .destructive) { _ in
            onConfirm()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigationController.presentedViewController?.present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.presentedViewController?.present(alert, animated: true)
    }
}

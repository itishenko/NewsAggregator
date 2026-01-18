//
//  NewsListViewController.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import AsyncDisplayKit

class NewsListViewController: ASDKViewController<ASTableNode> {
    
    // MARK: - Properties
    
    weak var coordinator: NewsListCoordinator?
    
    private let viewModel: NewsListViewModel
    private let imageCacheService: ImageCacheServiceProtocol
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Init
    
    init(viewModel: NewsListViewModel, imageCacheService: ImageCacheServiceProtocol) {
        self.viewModel = viewModel
        self.imageCacheService = imageCacheService
        
        let tableNode = ASTableNode()
        super.init(node: tableNode)
        
        setupTableNode()
        setupViewModel()
        setupNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = .systemBackground
        
        viewModel.loadNews()
        
        let shouldRefresh = viewModel.shouldAutoRefresh()
        
        if viewModel.numberOfItems() == 0 {
            showFirstLaunchMessage()
            viewModel.refreshNews()
        } else if shouldRefresh {
            viewModel.refreshNews()
        }
    }
    
    private func showFirstLaunchMessage() {
        coordinator?.showFirstLaunchMessage()
    }
    
    // MARK: - Setup
    
    private func setupTableNode() {
        node.dataSource = self
        node.delegate = self
        node.backgroundColor = .systemBackground
        node.view.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        node.view.refreshControl = refreshControl
    }
    
    private func setupViewModel() {
        viewModel.onNewsUpdated = { [weak self] in
            DispatchQueue.main.async {
                print("onNewsUpdated called - reloading table")
                print("Current number of news items: \(self?.viewModel.numberOfItems() ?? 0)")
                self?.node.reloadData()
            }
        }
        
        viewModel.onDisplayModeChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.node.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.coordinator?.showError(message: error)
            }
        }
        
        viewModel.onRefreshStarted = {
            print("Starting news loading...")
        }
        
        viewModel.onRefreshCompleted = { [weak self] in
            DispatchQueue.main.async {
                print("Loading completed. News items in DB: \(self?.viewModel.numberOfItems() ?? 0)")
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "Новости"
        
        let toggleButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(toggleDisplayMode)
        )
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        
        navigationItem.leftBarButtonItem = toggleButton
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    // MARK: - Actions
    
    @objc private func handleRefresh() {
        viewModel.refreshNews()
    }
    
    @objc private func toggleDisplayMode() {
        viewModel.toggleDisplayMode()
        
        let iconName = viewModel.displayMode == .normal ? "list.bullet" : "list.bullet.rectangle"
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: iconName)
    }
    
    @objc private func openSettings() {
        coordinator?.showSettings { [weak self] in
            self?.viewModel.updateRefreshInterval()
        }
    }
    
    private func openNewsDetail(for newsItem: NewsItem, at index: Int) {
        guard let url = URL(string: newsItem.link) else { return }
        
        coordinator?.showNewsDetail(
            url: url,
            newsItemIndex: index,
            onMarkAsRead: { [weak self] index in
                self?.viewModel.markAsRead(at: index)
            }
        )
    }
}

// MARK: - ASTableDataSource

extension NewsListViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.numberOfItems()
        print("numberOfRowsInSection returned: \(count)")
        return count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        guard let newsItem = viewModel.getNewsItem(at: indexPath.row) else {
            print("Failed to get newsItem for row: \(indexPath.row)")
            return {
                ASCellNode()
            }
        }
        
        let newsItemData = NewsItemData(from: newsItem)
        let displayMode = viewModel.displayMode
        
        return {
            let cellNode = NewsItemCellNode()
            cellNode.configure(
                with: newsItemData,
                displayMode: displayMode,
                imageCacheService: self.imageCacheService
            )
            return cellNode
        }
    }
}

// MARK: - ASTableDelegate

extension NewsListViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        if let newsItem = viewModel.getNewsItem(at: indexPath.row) {
            openNewsDetail(for: newsItem, at: indexPath.row)
        }
    }
}

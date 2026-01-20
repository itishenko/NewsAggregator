//
//  SettingsViewController.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import AsyncDisplayKit

class SettingsViewController: ASDKViewController<ASTableNode> {
    
    // MARK: - Properties
    
    private let viewModel: SettingsViewModel
    
    private enum Section: Int, CaseIterable {
        case refresh
        case sources
        case cache
        case about
    }
    
    // MARK: - Init
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        
        let tableNode = ASTableNode(style: .grouped)
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
        
        node.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Setup
    
    private func setupTableNode() {
        node.dataSource = self
        node.delegate = self
        node.backgroundColor = .systemGroupedBackground
    }
    
    private func setupViewModel() {
        viewModel.onSourcesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.node.reloadData()
                self?.viewModel.notifySettingsChanged()
            }
        }
        
        viewModel.onSettingsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.node.reloadData()
                self?.viewModel.notifySettingsChanged()
            }
        }
        
        viewModel.onCacheCleared = { [weak self] in
            DispatchQueue.main.async {
                self?.node.reloadData()
                self?.viewModel.showAlert(title: "", message: "Кэш успешно очищен")
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "Настройки"
        
        let closeButton = UIBarButtonItem(
            title: "Закрыть",
            style: .done,
            target: self,
            action: #selector(closeSettings)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - Actions
    
    @objc private func closeSettings() {
        viewModel.dismiss()
    }
}

// MARK: - ASTableDataSource

extension SettingsViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return Section.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .refresh:
            return 1
        case .sources:
            return viewModel.numberOfSources() + 1 // +1 for Add button
        case .cache:
            return 2
        case .about:
            return 1
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return { ASCellNode() }
        }
        
        let sourcesCount = sectionType == .sources ? viewModel.numberOfSources() : 0
        let sourceData: NewsSourceData? = {
            if sectionType == .sources && indexPath.row < sourcesCount {
                if let source = viewModel.getSource(at: indexPath.row) {
                    return NewsSourceData(from: source)
                }
            }
            return nil
        }()
        
        let refreshInterval = viewModel.settings.refreshIntervalMinutes
        let cacheSize = viewModel.getCacheSize()
        let lastUpdated = viewModel.getLastUpdatedString()
        
        return {
            let cellNode = ASCellNode()
            cellNode.automaticallyManagesSubnodes = true
            cellNode.backgroundColor = .secondarySystemGroupedBackground
            
            switch sectionType {
            case .refresh:
                return self.createRefreshCell(interval: refreshInterval)
            case .sources:
                if let sourceData = sourceData {
                    return self.createSourceCell(with: sourceData, at: indexPath.row)
                } else {
                    return self.createAddSourceCell()
                }
            case .cache:
                if indexPath.row == 0 {
                    return self.createCacheSizeCell(size: cacheSize)
                } else {
                    return self.createClearCacheCell()
                }
            case .about:
                return self.createAboutCell(lastUpdated: lastUpdated)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        
        switch sectionType {
        case .refresh:
            return "Обновление"
        case .sources:
            return "Источники новостей"
        case .cache:
            return "Кэш"
        case .about:
            return "О приложении"
        }
    }
    
    // MARK: - Cell Creation
    
    private func createRefreshCell(interval: Int) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = .secondarySystemGroupedBackground
        
        let textNode = ASTextNode()
        let detailNode = ASTextNode()
        
        textNode.attributedText = NSAttributedString(
            string: "Частота обновления",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label]
        )
        
        detailNode.attributedText = NSAttributedString(
            string: "\(interval) мин",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.secondaryLabel]
        )
        
        cellNode.automaticallyManagesSubnodes = true
        cellNode.layoutSpecBlock = { _, _ in
            let stack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 8,
                justifyContent: .spaceBetween,
                alignItems: .center,
                children: [textNode, detailNode]
            )
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), child: stack)
        }
        
        return cellNode
    }
    
    private func createSourceCell(with sourceData: NewsSourceData, at index: Int) -> ASCellNode {
        let cellNode = SourceSwitchCellNode(
            sourceName: sourceData.name,
            isEnabled: sourceData.isEnabled,
            index: index,
            onToggle: { [weak self] index in
                self?.viewModel.toggleSource(at: index)
            }
        )
        return cellNode
    }
    
    private func createAddSourceCell() -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = .secondarySystemGroupedBackground
        
        let textNode = ASTextNode()
        textNode.attributedText = NSAttributedString(
            string: "Добавить источник",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.systemBlue]
        )
        
        cellNode.automaticallyManagesSubnodes = true
        cellNode.layoutSpecBlock = { _, _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), child: textNode)
        }
        
        return cellNode
    }
    
    private func createCacheSizeCell(size: String) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = .secondarySystemGroupedBackground
        
        let textNode = ASTextNode()
        let detailNode = ASTextNode()
        
        textNode.attributedText = NSAttributedString(
            string: "Размер кэша",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label]
        )
        
        detailNode.attributedText = NSAttributedString(
            string: size,
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.secondaryLabel]
        )
        
        cellNode.automaticallyManagesSubnodes = true
        cellNode.layoutSpecBlock = { _, _ in
            let stack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 8,
                justifyContent: .spaceBetween,
                alignItems: .center,
                children: [textNode, detailNode]
            )
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), child: stack)
        }
        
        return cellNode
    }
    
    private func createClearCacheCell() -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = .secondarySystemGroupedBackground
        
        let textNode = ASTextNode()
        textNode.attributedText = NSAttributedString(
            string: "Очистить кэш",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.systemRed]
        )
        
        cellNode.automaticallyManagesSubnodes = true
        cellNode.layoutSpecBlock = { _, _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), child: textNode)
        }
        
        return cellNode
    }
    
    private func createAboutCell(lastUpdated: String) -> ASCellNode {
        let cellNode = ASCellNode()
        cellNode.backgroundColor = .secondarySystemGroupedBackground
        
        let textNode = ASTextNode()
        let detailNode = ASTextNode()
        
        textNode.attributedText = NSAttributedString(
            string: "Последнее обновление",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label]
        )
        
        detailNode.attributedText = NSAttributedString(
            string: lastUpdated,
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.secondaryLabel]
        )
        
        cellNode.automaticallyManagesSubnodes = true
        cellNode.layoutSpecBlock = { _, _ in
            let stack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 8,
                justifyContent: .spaceBetween,
                alignItems: .center,
                children: [textNode, detailNode]
            )
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16), child: stack)
        }
        
        return cellNode
    }
}

// MARK: - ASTableDelegate

extension SettingsViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .refresh:
            viewModel.showRefreshIntervalPicker()
        case .sources:
            if indexPath.row == viewModel.numberOfSources() {
                viewModel.showAddSourceDialog()
            }
        case .cache:
            if indexPath.row == 1 {
                viewModel.showClearCacheConfirmation()
            }
        case .about:
            break
        }
    }
}

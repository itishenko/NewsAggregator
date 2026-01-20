//
//  NewsItemCellNode.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import AsyncDisplayKit

class NewsItemCellNode: ASCellNode {
    
    // MARK: - Properties
    
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    private let descriptionNode = ASTextNode()
    private let sourceNode = ASTextNode()
    private let dateNode = ASTextNode()
    private let readIndicatorNode = ASDisplayNode()
    private let containerNode = ASDisplayNode()
    
    private var newsItemData: NewsItemData?
    private var displayMode: DisplayMode = .normal
    
    // MARK: - Init
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    // MARK: - Setup
    
    private func setupNodes() {
        imageNode.contentMode = .scaleAspectFill
        imageNode.cornerRadius = 8
        imageNode.clipsToBounds = true
        imageNode.placeholderColor = UIColor.systemGray5
        imageNode.style.preferredSize = CGSize(width: 80, height: 80)
        
        imageNode.image = createDefaultPlaceholder()
        imageNode.defaultImage = createDefaultPlaceholder()
        
        containerNode.backgroundColor = .systemBackground
        containerNode.cornerRadius = 12
        containerNode.borderColor = UIColor.systemGray5.cgColor
        containerNode.borderWidth = 1
        
        readIndicatorNode.style.preferredSize = CGSize(width: 8, height: 8)
        readIndicatorNode.backgroundColor = .systemBlue
        readIndicatorNode.cornerRadius = 4
    }
    
    private func createDefaultPlaceholder() -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        let image = UIImage(systemName: "newspaper", withConfiguration: config)?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        return image ?? UIImage(systemName: "photo")!
    }
    
    // MARK: - Configuration
    
    func configure(with newsItemData: NewsItemData, displayMode: DisplayMode, imageCacheService: ImageCacheServiceProtocol?) {
        self.newsItemData = newsItemData
        self.displayMode = displayMode
        
        let placeholder = createDefaultPlaceholder()
        imageNode.image = placeholder
        
        if let imageURLString = newsItemData.imageURL, let imageURL = URL(string: imageURLString) {
            if let cacheService = imageCacheService {
                cacheService.loadImage(from: imageURLString) { [weak self] image in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if let loadedImage = image {
                            self.imageNode.image = loadedImage
                        } else {
                            self.imageNode.image = placeholder
                        }
                    }
                }
            } else {
                // Use ASNetworkImageNode's built-in loading
                imageNode.url = imageURL
                imageNode.defaultImage = placeholder
            }
        }
        
        // Configure title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        titleNode.attributedText = NSAttributedString(string: newsItemData.title, attributes: titleAttributes)
        titleNode.maximumNumberOfLines = 2
        
        // Configure description 
        if displayMode == .expanded {
            let descriptionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
            descriptionNode.attributedText = NSAttributedString(string: newsItemData.itemDescription, attributes: descriptionAttributes)
            descriptionNode.maximumNumberOfLines = 3
        }
        
        // Configure source
        let sourceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.systemBlue
        ]
        sourceNode.attributedText = NSAttributedString(string: newsItemData.sourceName, attributes: sourceAttributes)
        
        // Configure date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: newsItemData.pubDate)
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        dateNode.attributedText = NSAttributedString(string: dateString, attributes: dateAttributes)
        
        // Configure read indicator
        readIndicatorNode.isHidden = newsItemData.isRead
        
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // Image
        imageNode.style.preferredSize = CGSize(width: 80, height: 80)
        
        // Title and source
        let titleSourceStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .stretch,
            children: [titleNode, sourceNode]
        )
        
        // Add description in expanded mode
        var rightContentChildren: [ASLayoutElement] = [titleSourceStack]
        if displayMode == .expanded {
            rightContentChildren.append(descriptionNode)
        }
        rightContentChildren.append(dateNode)
        
        let rightContentStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 6,
            justifyContent: .start,
            alignItems: .stretch,
            children: rightContentChildren
        )
        rightContentStack.style.flexShrink = 1.0
        rightContentStack.style.flexGrow = 1.0
        
        // Horizontal stack with image and content
        let contentStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .start,
            alignItems: .start,
            children: [imageNode, rightContentStack]
        )
        
        // Add read indicator
        let overlaySpec = ASOverlayLayoutSpec(child: contentStack, overlay: ASAbsoluteLayoutSpec(children: [readIndicatorNode]))
        
        // Insets
        let insetSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            child: overlaySpec
        )
        
        // Background
        let backgroundSpec = ASBackgroundLayoutSpec(child: insetSpec, background: containerNode)
        
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
            child: backgroundSpec
        )
    }
}

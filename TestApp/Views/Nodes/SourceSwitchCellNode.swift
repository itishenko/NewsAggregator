//
//  SourceSwitchCellNode.swift
//  NewsAggregator
//
//  Created on 13.01.2026
//

import AsyncDisplayKit

class SourceSwitchCellNode: ASCellNode {
    
    // MARK: - Properties
    
    private let textNode = ASTextNode()
    private let switchNode: ASDisplayNode
    private let onToggle: ((Int) -> Void)?
    private let index: Int
    
    // MARK: - Init
    
    init(sourceName: String, isEnabled: Bool, index: Int, onToggle: ((Int) -> Void)?) {
        self.index = index
        self.onToggle = onToggle
        
        self.switchNode = ASDisplayNode { () -> UIView in
            let switchView = UISwitch()
            return switchView
        }
        
        super.init()
        
        backgroundColor = .secondarySystemGroupedBackground
        automaticallyManagesSubnodes = true
        
        textNode.attributedText = NSAttributedString(
            string: sourceName,
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label]
        )
        
        switchNode.style.preferredSize = CGSize(width: 51, height: 31)
        
        switchNode.onDidLoad { [weak self] node in
            guard let self = self,
                  let switchView = node.view as? UISwitch else { return }
            
            DispatchQueue.main.async {
                switchView.isOn = isEnabled
                switchView.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func switchToggled(_ sender: UISwitch) {
        onToggle?(index)
    }
    
    // MARK: - Layout
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [textNode, switchNode]
        )
        
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16),
            child: stack
        )
    }
}

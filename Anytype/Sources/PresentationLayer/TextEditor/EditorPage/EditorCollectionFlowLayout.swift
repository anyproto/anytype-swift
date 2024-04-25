import UIKit
import Combine
import Services

struct RowInformation: Equatable, Hashable {
    let hashable: AnyHashable // There is a cache hash table inside FlowLayout,
    
    let allChilds: [AnyHashable]
    let indentations: [BlockIndentationStyle]
    let ownStyle: BlockIndentationStyle
}


private struct LayoutItem {
    var x: CGFloat
    var y: CGFloat
    var ownPreferedHeight: CGFloat
    var height: CGFloat
    var zIndex: Int
    var indexPath: IndexPath
    
    /// Creates layout attributes for item at given indexPath
    func attributes(collectionViewWidth: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(
            x: x,
            y: y,
            width: collectionViewWidth - x,
            height: height
        )
        // If you don't set zIndex you can ocassionally end up with incorrect initial layout size
        attributes.zIndex = zIndex
        return attributes
    }
}

private enum LayoutConstants {
    enum Paddings {
        static let `default`: CGFloat = 20
        static let quote: CGFloat = 48
    }
    
    static let estimatedItemHeight: CGFloat = 32
}

final class CustomInvalidation: UICollectionViewLayoutInvalidationContext {
    override var invalidatedItemIndexPaths: [IndexPath]? {
        indexPaths
    }
    
    private let indexPaths: [IndexPath]
    
    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }
}

final class EditorCollectionFlowLayout: UICollectionViewLayout {
    weak var dataSource: UICollectionViewDiffableDataSource<EditorSection, EditorItem>?
    var layoutDetailsPublisher: AnyPublisher<[AnyHashable: RowInformation], Never>? {
        didSet {
            blocksLayoutSubscription = layoutDetailsPublisher?
                .sink { [weak self] layoutDetails in
                    var invalidationIndexPaths = [IndexPath]()
                    
                    let newLayoutDetails = Dictionary(uniqueKeysWithValues: layoutDetails.map { ($0.value.hashable, $0.value) })
                    
                    
                    self?.blockLayoutDetails.forEach { key, value in
                        if let info = newLayoutDetails[value.hashable] {
                            if info != value,
                                let layoutItem = self?.cachedAttributes[value.hashable] {
                                invalidationIndexPaths.append(layoutItem.indexPath)
                                
                                if info.ownStyle != value.ownStyle {
                                    let allChilds = info.allChilds.compactMap { childHash -> IndexPath? in
                                        guard let childAttr = self?.cachedAttributes[childHash] else {
                                            return nil
                                        }
                                        
                                        return childAttr.indexPath
                                    }
                                    
                                    invalidationIndexPaths.append(contentsOf: allChilds)
                                }
                            }
                        }
                    }
                    self?.blockLayoutDetails = newLayoutDetails
                    
                    if invalidationIndexPaths.isNotEmpty {
                        self?.invalidateLayout(with: CustomInvalidation(indexPaths: invalidationIndexPaths))
                    }
                }
        }
    }
    
    private var cachedAttributes = [AnyHashable: LayoutItem]() // Actual
    private var _nonInvalidatedAttributed = [AnyHashable: LayoutItem]()
    
    private var blockLayoutDetails = [AnyHashable: RowInformation]()
    

    private var maxHeight = LayoutConstants.estimatedItemHeight
    override var collectionViewContentSize: CGSize { CGSize(width: collectionViewWidth, height: collectionViewHeight) }
    
    private var blocksLayoutSubscription: AnyCancellable?
    
    private var collectionViewWidth: CGFloat = 0
    private var collectionViewHeight: CGFloat = 0
    
    override func prepare() {
        super.prepare()

        let numberOfSections = collectionView?.numberOfSections ?? 0
        var offset: CGFloat = 0
        var zIndex = 1
        var lastBlockPadding = [AnyHashable: CGFloat]()
        
        for section in 0..<numberOfSections {
            let numberOfRows = collectionView?.numberOfItems(inSection: section) ?? 0
            
            for row in 0..<numberOfRows {
                let indexPath = IndexPath(item: row, section: section)
                
                guard let item = itemIdentifier(for: indexPath) else {
                    continue
                }
                        
                switch item {
                case let .header(hashable as HashableProvier), let .system(hashable as HashableProvier):
                    if var cachedLayoutItem = cachedAttributes[hashable.hashable] {
                        cachedLayoutItem.y = offset
                        cachedLayoutItem.zIndex = zIndex
                        cachedLayoutItem.indexPath = indexPath
                        cachedAttributes[hashable.hashable] = cachedLayoutItem
                        
                        offset += cachedLayoutItem.height
                    } else {
                        let layoutItem = LayoutItem(
                            x: 0,
                            y: offset,
                            ownPreferedHeight: LayoutConstants.estimatedItemHeight,
                            height: LayoutConstants.estimatedItemHeight,
                            zIndex: zIndex, 
                            indexPath: indexPath
                        )
                        cachedAttributes[hashable.hashable] = layoutItem
                        
                        offset += layoutItem.height
                    }
                case .block(let blockViewModel):
                    let blockLayoutDetails = blockLayoutDetails[blockViewModel.hashable]
                    
                    if var cachedLayoutItem = cachedAttributes[blockViewModel.hashable] {
                        cachedLayoutItem.x = blockLayoutDetails?.indentations.totalIndentation ?? 0
                        cachedLayoutItem.y = offset
                        cachedLayoutItem.height = cachedLayoutItem.ownPreferedHeight + additionalHeight(for: blockViewModel)
                        cachedLayoutItem.zIndex = zIndex
                        cachedLayoutItem.indexPath = indexPath
                        cachedAttributes[blockViewModel.hashable] = cachedLayoutItem
                        
                        offset += cachedLayoutItem.ownPreferedHeight
                    } else {
                        let layoutItem = LayoutItem(
                            x: blockLayoutDetails?.indentations.totalIndentation ?? 0,
                            y: offset,
                            ownPreferedHeight: _nonInvalidatedAttributed[blockViewModel.hashable]?.ownPreferedHeight ?? LayoutConstants.estimatedItemHeight,
                            height: (_nonInvalidatedAttributed[blockViewModel.hashable]?.ownPreferedHeight ?? LayoutConstants.estimatedItemHeight) + additionalEstimatedHeight(for: blockViewModel),
                            zIndex: zIndex,
                            indexPath: indexPath
                        )
                        cachedAttributes[blockViewModel.hashable] = layoutItem
                        
                        offset += layoutItem.ownPreferedHeight
                    }
                    
                    if let ownStyle = blockLayoutDetails?.ownStyle,
                        let lastChild = blockLayoutDetails?.allChilds.last {
                        lastBlockPadding[lastChild] = (lastBlockPadding[lastChild] ?? 0) + ownStyle.extraHeight
                    }
                    
                    if let padding = lastBlockPadding[blockViewModel.hashable] {
                        offset += padding
                    }
                }
                
                zIndex += 1
            }
        }
        
        collectionViewWidth = collectionView.map { $0.bounds.width - .leastNonzeroMagnitude } ?? 0
        collectionViewHeight = offset
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var rect = rect
        
        rect.origin = .init(x: rect.origin.x, y: rect.origin.y - 500)
        rect.size = .init(width: rect.width, height: rect.height + 500)
        
        let cached = cachedAttributes.reduce(into: [UICollectionViewLayoutAttributes]()) { acc, item in
            let itemAttrs = item.value.attributes(collectionViewWidth: collectionViewWidth)
            
            
            if rect.intersects(itemAttrs.frame) {
                acc.append(itemAttrs)
            }
        }
                
        return cached
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let item = itemIdentifier(for: indexPath),
               let layoutDetails = cachedAttributes[item.hashable] else {
            return nil //
        }
        
        return layoutDetails.attributes(collectionViewWidth: collectionViewWidth)
    }
    
    override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        guard let item = itemIdentifier(for: originalAttributes.indexPath) else {
            return false
        }
        
        switch item {
        case .header, .system:
            return originalAttributes.frame.height != preferredAttributes.frame.height
        case .block(let blockViewModel):
            return originalAttributes.frame.height != preferredAttributes.frame.height + additionalHeight(
                for: blockViewModel)
        }
    }
    
    override func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(
            forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes
        )
        let heightDiff = originalAttributes.frame.height - preferredAttributes.frame.height
        context.contentSizeAdjustment.height -= heightDiff
        
        maxHeight = max(maxHeight, preferredAttributes.frame.height)
        
        if let item = itemIdentifier(for: preferredAttributes.indexPath),
           var cachedItem = cachedAttributes[item.hashable] {
            
            switch item {
            case .header, .system:
                cachedItem.height = preferredAttributes.frame.height
            case .block(let blockViewModel):
                cachedItem.height = preferredAttributes.frame.height + additionalHeight(for: blockViewModel)
            }
        
            cachedItem.ownPreferedHeight = preferredAttributes.frame.height
            cachedAttributes[item.hashable] = cachedItem
        }
        
        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        _nonInvalidatedAttributed = cachedAttributes
        
        super.invalidateLayout(with: context)

        // Removing cache layout items for removed blocks
        if let dataSource {
            let dataSourceItems = dataSource.snapshot().itemIdentifiers.map { $0.hashable }
            var allCachedKeys = Set(cachedAttributes.keys)
            allCachedKeys.subtract(dataSourceItems)
            
            allCachedKeys.forEach {
                cachedAttributes[$0] = nil
            }
        }
        
        if context.invalidateEverything {
            cachedAttributes.removeAll()
        }
        
        if let indexPaths = context.invalidatedItemIndexPaths, let dataSource {
            indexPaths.forEach {
                let hash = dataSource.itemIdentifier(for: $0)?.hashable
                hash.map { cachedAttributes[$0] = nil }
            }
        }
    }
    
    private func itemIdentifier(for indexPath: IndexPath) -> EditorItem? {
        dataSource?.itemIdentifier(for: indexPath)
    }
    
    private func additionalHeight(for blockViewModel: BlockViewModelProtocol) -> CGFloat {
        additionalHeight(for: blockViewModel, using: cachedAttributes)
    }
    
    private func additionalEstimatedHeight(for blockViewModel: BlockViewModelProtocol) -> CGFloat {
        additionalHeight(for: blockViewModel, using: _nonInvalidatedAttributed)
    }
    
    private func additionalHeight(
        for blockViewModel: BlockViewModelProtocol,
        using cache: [AnyHashable: LayoutItem]
    ) -> CGFloat {
        var additionalSize: CGFloat = 0
        
        if let layoutDetails = blockLayoutDetails[blockViewModel.hashable] {
            for childHash in layoutDetails.allChilds {
                var height: CGFloat = 0
                
                if let childLayoutItem = cache[childHash] {
                    height = childLayoutItem.ownPreferedHeight
                }
                
                additionalSize = additionalSize + height
                
                guard blockLayoutDetails[childHash]?.ownStyle != nil else { continue }
            }
            
            if layoutDetails.allChilds.count > 0 {
                additionalSize += layoutDetails.ownStyle.extraHeight
            }
        }
        
        return additionalSize
    }
}


func layoutDetails(for blockModels: [BlockInformation]) -> [AnyHashable: RowInformation] {
    var output = [AnyHashable: RowInformation]()
    
    func traverseBlock(_ block: BlockInformation) -> [AnyHashable] {
        block.childrenIds.map { childId -> [AnyHashable] in
            
            var childIndentifiers = [AnyHashable]()
            if let childInformation = blockModels.first(where: { info in info.id == childId }) {
                childIndentifiers.append(childInformation.hashable)
                childIndentifiers.append(contentsOf: traverseBlock(childInformation))
            }
            
            return childIndentifiers
        }.flatMap { $0 }
    }
    
    let dictionary = Dictionary(uniqueKeysWithValues: blockModels.map { ($0.hashable, $0) })
    
    func findIdentation(
        currentIdentations: [BlockIndentationStyle],
        block: BlockInformation
    ) -> [BlockIndentationStyle] {
        guard let parentId = block.configurationData.parentId,
              let parent = dictionary[parentId]  else {
            return currentIdentations
        }
        var indentations = currentIdentations
        indentations.append(parent.content.indentationStyle)
        
        return findIdentation(
            currentIdentations: indentations,
            block: parent
        )
    }
    
    for rootBlockInfo in blockModels.enumerated() {
        output[rootBlockInfo.element.hashable] = RowInformation(
            hashable: rootBlockInfo.element.hashable,
            allChilds: traverseBlock(rootBlockInfo.element),
            indentations: findIdentation(currentIdentations: [], block: rootBlockInfo.element),
            ownStyle: rootBlockInfo.element.content.indentationStyle
        )
    }
    
    return output
}

extension BlockContent {
    var indentationStyle: BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .quote
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}

public enum BlockIndentationStyle: Hashable, Equatable {
    case `none`
    case quote
    case callout
    
    var padding: CGFloat {
        switch self {
        case .none:
            return LayoutConstants.Paddings.default
        case .quote:
            return LayoutConstants.Paddings.quote
        case .callout:
            return LayoutConstants.Paddings.quote
        }
    }
    
    var extraHeight: CGFloat {
        switch self {
        case .none:
            return 0
        case .quote, .callout:
            return LayoutConstants.Paddings.default
        }
    }
}

extension Array where Element == BlockIndentationStyle {
    var totalIndentation: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.padding
        }
    }
    
    var totalExtraHeight: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.extraHeight
        }
    }
}

extension UICollectionView {
    var allIndexPaths: [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        for s in 0..<numberOfSections {
            for i in 0..<numberOfItems(inSection: s) {
                indexPaths.append(IndexPath(row: i, section: s))
            }
        }
        
        return indexPaths
    }
}


extension BlockInformation: HashableProvier {
    var hashable: AnyHashable { id }
}

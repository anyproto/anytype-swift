import UIKit
import Combine
import Services


final class EditorCollectionFlowLayout: UICollectionViewLayout {
    weak var dataSource: UICollectionViewDiffableDataSource<EditorSection, EditorItem>?
    var blockLayoutDetailsPublisher: AnyPublisher<[String: BlockLayoutDetails], Never>? {
        didSet {
            blocksLayoutSubscription = blockLayoutDetailsPublisher?
                .sink { [weak self] newLayoutDetailsDict in
                    self?.invalidateLayout(newLayoutDetailsDict)
                }
        }
    }
    
    private var cachedAttributes = [AnyHashable: LayoutItem]() // Actual
    private var _nonInvalidatedAttributed = [AnyHashable: LayoutItem]()
    private var blockLayoutDetails = [String: BlockLayoutDetails]()

    override var collectionViewContentSize: CGSize { CGSize(width: collectionViewWidth, height: collectionViewHeight) }
    
    private var blocksLayoutSubscription: AnyCancellable?
    
    private var collectionViewWidth: CGFloat = 0
    private var collectionViewHeight: CGFloat = 0
    
    override func prepare() {
        super.prepare()

        let numberOfSections = collectionView?.numberOfSections ?? 0
        var offset: CGFloat = 0
        var zIndex = 1
        var lastBlockPadding = [String: CGFloat]()
        
        for section in 0..<numberOfSections {
            let numberOfRows = collectionView?.numberOfItems(inSection: section) ?? 0
            
            for row in 0..<numberOfRows {
                let indexPath = IndexPath(item: row, section: section)
                
                guard let item = itemIdentifier(for: indexPath) else {
                    continue
                }
                        
                switch item {
                case let .header(hashable as any HashableProvier), let .system(hashable as any HashableProvier):
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
                    let blockLayout = blockLayoutDetails[blockViewModel.blockId]
                    
                    if var cachedLayoutItem = cachedAttributes[blockViewModel.hashable] {
                        cachedLayoutItem.x = blockLayout?.indentations.totalIndentation ?? 0
                        cachedLayoutItem.y = offset
                        cachedLayoutItem.height = cachedLayoutItem.ownPreferedHeight + additionalHeight(for: blockViewModel)
                        cachedLayoutItem.zIndex = zIndex
                        cachedLayoutItem.indexPath = indexPath
                        cachedAttributes[blockViewModel.hashable] = cachedLayoutItem
                        
                        offset += cachedLayoutItem.ownPreferedHeight
                    } else {
                        let layoutItem = LayoutItem(
                            x: blockLayout?.indentations.totalIndentation ?? 0,
                            y: offset,
                            ownPreferedHeight: _nonInvalidatedAttributed[blockViewModel.hashable]?.ownPreferedHeight ?? LayoutConstants.estimatedItemHeight,
                            height: (_nonInvalidatedAttributed[blockViewModel.hashable]?.ownPreferedHeight ?? LayoutConstants.estimatedItemHeight) + additionalEstimatedHeight(for: blockViewModel),
                            zIndex: zIndex,
                            indexPath: indexPath
                        )
                        cachedAttributes[blockViewModel.hashable] = layoutItem
                        
                        offset += layoutItem.ownPreferedHeight
                    }
                    
                    if let ownStyle = blockLayout?.ownStyle,
                        let lastChildId = blockLayout?.allChildIds.last {
                        lastBlockPadding[lastChildId] = (lastBlockPadding[lastChildId] ?? 0) + ownStyle.extraHeight
                    }
                    
                    if let padding = lastBlockPadding[blockViewModel.blockId] {
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
    
    // MARK: - Private
    
    private func itemIdentifier(for indexPath: IndexPath) -> EditorItem? {
        dataSource?.itemIdentifier(for: indexPath)
    }
    
    private func additionalHeight(for blockViewModel: some BlockViewModelProtocol) -> CGFloat {
        additionalHeight(for: blockViewModel, using: cachedAttributes)
    }
    
    private func additionalEstimatedHeight(for blockViewModel: some BlockViewModelProtocol) -> CGFloat {
        additionalHeight(for: blockViewModel, using: _nonInvalidatedAttributed)
    }
    
    private func additionalHeight(
        for blockViewModel: some BlockViewModelProtocol,
        using cache: [AnyHashable: LayoutItem]
    ) -> CGFloat {
        var additionalSize: CGFloat = 0
        
        if let layoutDetails = blockLayoutDetails[blockViewModel.blockId] {
            for childId in layoutDetails.allChildIds {
                var height: CGFloat = 0
                
                if let childLayoutItem = cache[childId] {
                    height = childLayoutItem.ownPreferedHeight
                }
                
                additionalSize = additionalSize + height
                
                guard blockLayoutDetails[childId]?.ownStyle != nil else { continue }
            }
            
            if layoutDetails.allChildIds.count > 0 {
                additionalSize += layoutDetails.ownStyle.extraHeight
            }
        }
        
        return additionalSize
    }
    
    private func invalidateLayout(_ newLayoutDetailsDict: [String: BlockLayoutDetails]) {
        var invalidationIndexPaths = [IndexPath]()
        
        for oldLayoutDetails in blockLayoutDetails.values {
            guard let newLayoutDetails = newLayoutDetailsDict[oldLayoutDetails.id],
                  newLayoutDetails != oldLayoutDetails,
                  let layoutItem = cachedAttributes[oldLayoutDetails.id] else { continue }
            
            invalidationIndexPaths.append(layoutItem.indexPath)
            
            if newLayoutDetails.ownStyle != oldLayoutDetails.ownStyle {
                let childIndexPaths = newLayoutDetails.allChildIds
                    .compactMap { cachedAttributes[$0]?.indexPath }
                
                invalidationIndexPaths.append(contentsOf: childIndexPaths)
            }
        }
        
        blockLayoutDetails = newLayoutDetailsDict
        
        if invalidationIndexPaths.isNotEmpty {
            invalidateLayout(with: CustomInvalidation(indexPaths: invalidationIndexPaths))
        }
    }
}

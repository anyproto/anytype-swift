import Services
import Foundation
import AnytypeCore
import SwiftProtobuf

protocol SetContentViewDataBuilderProtocol: AnyObject {
    func sortedRelations(dataview: BlockDataview, view: DataviewView, spaceId: String) -> [SetRelation]
    func activeViewRelations(
        dataViewRelationsDetails: [RelationDetails],
        view: DataviewView,
        excludeRelations: [RelationDetails],
        spaceId: String
    ) -> [RelationDetails]
    func itemData(
        _ details: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        viewRelationValueIsLocked: Bool,
        canEditIcon: Bool,
        storage: ObjectDetailsStorage,
        spaceId: String,
        onItemTap: @escaping @Sendable @MainActor (ObjectDetails) -> Void
    ) -> [SetContentViewItemConfiguration]
}

final class SetContentViewDataBuilder: SetContentViewDataBuilderProtocol {
    
    @Injected(\.relationsBuilder)
    private var relationsBuilder: any RelationsBuilderProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    func sortedRelations(dataview: BlockDataview, view: DataviewView, spaceId: String) -> [SetRelation] {
        let storageRelationsDetails = relationDetailsStorage.relationsDetails(keys: dataview.relationLinks.map(\.key), spaceId: spaceId)
            .filter {
                (!$0.isHidden && !$0.isDeleted) ||
                (view.canSwitchItemName && $0.key == BundledRelationKey.name.rawValue)
            }
        
        let relationsPresentInView: [SetRelation] = view.options
            .compactMap { option in
                let relationsDetails = storageRelationsDetails
                    .first { $0.key == option.key }
                guard let relationsDetails = relationsDetails else { return nil }
                
                return SetRelation(relationDetails: relationsDetails, option: option)
            }
        
        let relationsNotPresentInView: [SetRelation] = storageRelationsDetails
            .filter { !view.options.map(\.key).contains($0.key) }
            .map { SetRelation(relationDetails: $0, option: DataviewRelationOption(key: $0.key, isVisible: false)) }

        
        return NSOrderedSet(array: relationsPresentInView + relationsNotPresentInView).array as! [SetRelation]
    }
    
    func activeViewRelations(
        dataViewRelationsDetails: [RelationDetails],
        view: DataviewView,
        excludeRelations: [RelationDetails],
        spaceId: String
    ) -> [RelationDetails] {
        var relationDetails: [RelationDetails] = view.options.compactMap { option in
            let relationDetails = dataViewRelationsDetails.first { relation in
                option.key == relation.key
            }
            
            guard let relationDetails = relationDetails,
                  shouldAddRelationDetails(relationDetails, excludeRelations: excludeRelations) else { return nil }
            
            return relationDetails
        }
        // force insert Done relation after the Name for all Sets/Collections if needed
        let doneRelationIsExcluded = excludeRelations.first { $0.key == BundledRelationKey.done.rawValue }.isNotNil
        let doneRelationDetails = try? relationDetailsStorage.relationsDetails(bundledKey: BundledRelationKey.done, spaceId: spaceId)
        if !doneRelationIsExcluded, let doneRelationDetails {
            if let index = relationDetails.firstIndex(where: { $0.key == BundledRelationKey.name.rawValue }),
                index < relationDetails.count
            {
                relationDetails.insert(doneRelationDetails, at: index + 1)
            } else {
                relationDetails.insert(doneRelationDetails, at: 0)
            }
        }
        return relationDetails
    }
    
    func itemData(
        _ details: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        viewRelationValueIsLocked: Bool,
        canEditIcon: Bool,
        storage: ObjectDetailsStorage,
        spaceId: String,
        onItemTap: @escaping @Sendable @MainActor (ObjectDetails) -> Void
    ) -> [SetContentViewItemConfiguration] {
        
        let visibleRelationsDetails = sortedRelations(
            dataview: dataView,
            view: activeView,
            spaceId: spaceId
        ).filter { $0.option.isVisible }.map(\.relationDetails)

        let items = items(
            details: details,
            relationsDetails: visibleRelationsDetails,
            dataView: dataView,
            activeView: activeView,
            viewRelationValueIsLocked: viewRelationValueIsLocked,
            spaceId: spaceId,
            storage: storage
        )
        var showTitle = true
        if activeView.canSwitchItemName {
            showTitle = visibleRelationsDetails.contains { $0.key == BundledRelationKey.name.rawValue }
        }
        let showIcon = !activeView.hideIcon
        
        let minHeight = calculateMinHeight(activeView: activeView, items: items, showTitle: showTitle, showIcon: showIcon)
        let hasCover = activeView.coverRelationKey.isNotEmpty && activeView.type != .kanban
        
        return items.map { item in
            return SetContentViewItemConfiguration(
                id: item.details.id,
                title: item.details.title,
                showTitle: showTitle,
                description: item.details.description,
                icon: item.details.objectIconImage, 
                canEditIcon: canEditIcon,
                relations: item.relations,
                showIcon: showIcon,
                isSmallCardSize: activeView.isSmallCardSize,
                hasCover: hasCover,
                coverFit: activeView.coverFit,
                coverType: coverType(item.details, dataView: dataView, activeView: activeView, spaceId: spaceId, detailsStorage: storage),
                minHeight: minHeight,
                onItemTap: { [details = item.details] in
                    onItemTap(details)
                }
            )
        }
    }
    
    private func items(
        details: [ObjectDetails],
        relationsDetails: [RelationDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        viewRelationValueIsLocked: Bool,
        spaceId: String,
        storage: ObjectDetailsStorage
    ) -> [SetContentViewItem] {
        details.map { details in
            let parsedRelations = relationsBuilder
                .parsedRelations(
                    objectRelations: relationsDetails,
                    objectFeaturedRelations: [],
                    recommendedRelations: [],
                    recommendedFeaturedRelations: [],
                    recommendedHiddenRelations: [],
                    objectId: details.id,
                    relationValuesIsLocked: viewRelationValueIsLocked,
                    storage: storage
                )
                .installed
            let sortedRelations = relationsDetails.compactMap { colum in
                parsedRelations.first { $0.key == colum.key }
            }
            
            let relations: [Relation] = relationsDetails.map { colum in
                let relation = sortedRelations.first { $0.key == colum.key }
                guard let relation = relation else {
                    return .unknown(.empty(id: colum.id, key: colum.key, name: colum.name))
                }
                
                return relation
            }
            let coverType = coverType(details, dataView: dataView, activeView: activeView, spaceId: spaceId, detailsStorage: storage)
            return SetContentViewItem(
                details: details,
                relations: relations,
                coverType: coverType
            )
        }
    }
    
    private func coverType(
        _ details: ObjectDetails,
        dataView: BlockDataview,
        activeView: DataviewView,
        spaceId: String,
        detailsStorage: ObjectDetailsStorage
    ) -> ObjectHeaderCoverType? {
        guard activeView.type == .gallery else {
            return nil
        }
        let showPageCover = activeView.coverRelationKey == SetViewSettingsImagePreviewCover.pageCover.rawValue
        if showPageCover, let documentCover = details.documentCover {
            return .cover(documentCover)
        } else if showPageCover, details.objectType.isImageLayout {
            return .cover(DocumentCover.imageId(details.id))
        } else {
            return relationCoverType(details, dataView: dataView, activeView: activeView, spaceId: spaceId, detailsStorage: detailsStorage)
        }
    }
    
    private func relationCoverType(
        _ details: ObjectDetails,
        dataView: BlockDataview,
        activeView: DataviewView,
        spaceId: String,
        detailsStorage: ObjectDetailsStorage
    ) -> ObjectHeaderCoverType?
    {
        let relationDetails = relationDetailsStorage.relationsDetails(keys: dataView.relationLinks.map(\.key), spaceId: spaceId)
            .first { $0.format == .file && $0.key == activeView.coverRelationKey }
        
        guard let relationDetails = relationDetails else {
            return nil
        }

        let values = details.stringValueOrArray(for: relationDetails)
        return findCover(at: values, details, detailsStorage: detailsStorage)
    }

    private func findCover(at values: [String], _ details: ObjectDetails, detailsStorage: ObjectDetailsStorage) -> ObjectHeaderCoverType? {
        for value in values {
            let details = detailsStorage.get(id: value)
            if let details = details, details.resolvedLayoutValue.isImage {
                return .cover(.imageId(details.id))
            }
        }
        return nil
    }
    
    private func shouldAddRelationDetails(_ relationDetails: RelationDetails, excludeRelations: [RelationDetails]) -> Bool {
        guard excludeRelations.first(where: { $0.key == relationDetails.key }) == nil else {
            return false
        }
        guard relationDetails.key != BundledRelationKey.name.rawValue else {
            return true
        }
        return !relationDetails.isHidden &&
        relationDetails.format != .unrecognized
    }
    
    private func calculateMinHeight(activeView: DataviewView, items: [SetContentViewItem], showTitle: Bool, showIcon: Bool) -> CGFloat? {
        guard activeView.type == .gallery, activeView.cardSize == .small else {
            return nil
        }

        var maxHeight: CGFloat = .zero
        items.forEach { item in
            let relationsWithValueCount = CGFloat(item.relations.filter { $0.hasValue }.count)
            let hasCover = activeView.coverRelationKey.isNotEmpty && item.coverType.isNotNil
            
            let titleHeight = showTitle || showIcon ? SetGalleryViewCell.Constants.maxTitleHeight : 0
            let titleSpacerCount: CGFloat = hasCover && titleHeight == 0 ? 0 : (hasCover ? 1 : 2)
            let verticalPaddings = SetGalleryViewCell.Constants.contentPadding * titleSpacerCount
            
            let totalCoverHeight = hasCover ? SetGalleryViewCell.Constants.smallItemHeight : 0
            let bottomCoverSpace = relationsWithValueCount > 0 ? SetGalleryViewCell.Constants.bottomCoverSpacing : 0
            
            let relationsHeight = (SetGalleryViewCell.Constants.relationHeight + SetGalleryViewCell.Constants.relationSpacing) * relationsWithValueCount
            
            let total = titleHeight + verticalPaddings + totalCoverHeight + bottomCoverSpace + relationsHeight
            maxHeight = max(maxHeight, total)
        }
        
        return maxHeight
    }
}

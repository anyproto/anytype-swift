import Services
import Foundation
import AnytypeCore
import SwiftProtobuf

final class SetContentViewDataBuilder {
    
    private let relationsBuilder: RelationsBuilder
    private let detailsStorage: ObjectDetailsStorage
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    init(relationsBuilder: RelationsBuilder, detailsStorage: ObjectDetailsStorage, relationDetailsStorage: RelationDetailsStorageProtocol) {
        self.relationsBuilder = relationsBuilder
        self.detailsStorage = detailsStorage
        self.relationDetailsStorage = relationDetailsStorage
    }
    
    func sortedRelations(dataview: BlockDataview, view: DataviewView, spaceId: String) -> [SetRelation] {
        let storageRelationsDetails = relationDetailsStorage.relationsDetails(for: dataview.relationLinks, spaceId: spaceId)
            .filter { !$0.isHidden && !$0.isDeleted }
        let relations: [SetRelation] = view.options
            .compactMap { option in
                let relationsDetails = storageRelationsDetails
                    .first { $0.key == option.key }
                guard let relationsDetails = relationsDetails else { return nil }
                
                return SetRelation(relationDetails: relationsDetails, option: option)
            }

        return NSOrderedSet(array: relations).array as! [SetRelation]
    }
    
    func activeViewRelations(
        dataViewRelationsDetails: [RelationDetails],
        view: DataviewView,
        excludeRelations: [RelationDetails],
        spaceId: String
    ) -> [RelationDetails] {
        view.options.compactMap { option in
            let relationDetails = dataViewRelationsDetails.first { relation in
                option.key == relation.key
            }
            
            guard let relationDetails = relationDetails,
                  shouldAddRelationDetails(relationDetails, excludeRelations: excludeRelations) else { return nil }
            
            return relationDetails
        }
    }
    
    func itemData(
        _ details: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        viewRelationValueIsLocked: Bool,
        storage: ObjectDetailsStorage,
        spaceId: String,
        onIconTap: @escaping (ObjectDetails) -> Void,
        onItemTap: @escaping @MainActor (ObjectDetails) -> Void
    ) -> [SetContentViewItemConfiguration] {
        
        let relationsDetails = sortedRelations(
            dataview: dataView,
            view: activeView,
            spaceId: spaceId
        ).filter { $0.option.isVisible }.map(\.relationDetails)

        let items = items(
            details: details,
            relationsDetails: relationsDetails,
            dataView: dataView,
            activeView: activeView,
            viewRelationValueIsLocked: viewRelationValueIsLocked,
            spaceId: spaceId,
            storage: storage
        )
        let minHeight = calculateMinHeight(activeView: activeView, items: items)
        let hasCover = activeView.coverRelationKey.isNotEmpty && activeView.type != .kanban
        
        return items.map { item in
            return SetContentViewItemConfiguration(
                id: item.details.id,
                title: item.details.title,
                description: item.details.description,
                icon: item.details.objectIconImage,
                relations: item.relations,
                showIcon: !activeView.hideIcon,
                smallItemSize: activeView.cardSize == .small,
                hasCover: hasCover,
                coverFit: activeView.coverFit,
                coverType: coverType(item.details, dataView: dataView, activeView: activeView, spaceId: spaceId),
                minHeight: minHeight,
                onIconTap: {
                    onIconTap(item.details)
                },
                onItemTap: {
                    onItemTap(item.details)
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
                    relationsDetails: relationsDetails,
                    typeRelationsDetails: [],
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
            let coverType = coverType(details, dataView: dataView, activeView: activeView, spaceId: spaceId)
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
        spaceId: String) -> ObjectHeaderCoverType?
    {
        guard activeView.type == .gallery else {
            return nil
        }
        if activeView.coverRelationKey == SetViewSettingsImagePreviewCover.pageCover.rawValue,
           let documentCover = details.documentCover {
            return .cover(documentCover)
        } else {
            return relationCoverType(details, dataView: dataView, activeView: activeView, spaceId: spaceId)
        }
    }
    
    private func relationCoverType(
        _ details: ObjectDetails,
        dataView: BlockDataview,
        activeView: DataviewView,
        spaceId: String
    ) -> ObjectHeaderCoverType?
    {
        let relationDetails = relationDetailsStorage.relationsDetails(for: dataView.relationLinks, spaceId: spaceId)
            .first { $0.format == .file && $0.key == activeView.coverRelationKey }
        
        guard let relationDetails = relationDetails else {
            return nil
        }

        let values = details.stringValueOrArray(for: relationDetails)
        return findCover(at: values, details)
    }

    private func findCover(at values: [String], _ details: ObjectDetails) -> ObjectHeaderCoverType? {
        for value in values {
            let details = detailsStorage.get(id: value)
            if let details = details, details.type == Constants.imageType {
                return .cover(.imageId(details.id))
            }
        }
        return nil
    }
    
    private func shouldAddRelationDetails(_ relationDetails: RelationDetails, excludeRelations: [RelationDetails]) -> Bool {
        guard excludeRelations.first(where: { $0.key == relationDetails.key }) == nil else {
            return false
        }
        guard relationDetails.key != ExceptionalSetSort.name.rawValue,
              relationDetails.key != ExceptionalSetSort.done.rawValue else {
            return true
        }
        return !relationDetails.isHidden &&
        relationDetails.format != .file &&
        relationDetails.format != .unrecognized
    }
    
    private func calculateMinHeight(activeView: DataviewView, items: [SetContentViewItem]) -> CGFloat? {
        guard activeView.type == .gallery, activeView.cardSize == .small else {
            return nil
        }

        var maxHeight: CGFloat = .zero
        items.forEach { item in
            let relationsWithValueCount = CGFloat(item.relations.filter { $0.hasValue }.count)
            let hasCoverOnce = activeView.coverRelationKey.isNotEmpty && item.coverType.isNotNil
            
            let titleHeight = SetGalleryViewCell.Constants.maxTitleHeight
            let verticalPaddings = SetGalleryViewCell.Constants.contentPadding * (hasCoverOnce ? 1 : 2)
            
            let totalCoverHeight = hasCoverOnce ? SetGalleryViewCell.Constants.smallItemHeight + SetGalleryViewCell.Constants.bottomCoverSpacing : 0
            
            let relationsHeight = (SetGalleryViewCell.Constants.relationHeight + SetGalleryViewCell.Constants.relationSpacing) * relationsWithValueCount
            
            let total = titleHeight + verticalPaddings + totalCoverHeight + relationsHeight
            maxHeight = max(maxHeight, total)
        }
        
        return maxHeight
    }
}

extension SetContentViewDataBuilder {
    enum Constants {
        static let imageType = "_otimage"
    }
}

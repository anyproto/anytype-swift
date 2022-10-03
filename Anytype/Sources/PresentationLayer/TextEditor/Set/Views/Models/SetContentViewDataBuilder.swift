import BlocksModels
import Foundation
import AnytypeCore
import SwiftProtobuf

final class SetContentViewDataBuilder {
    private let relationsBuilder = RelationsBuilder()
    private let storage = ObjectDetailsStorage.shared
    private let isGalleryViewEnabled = FeatureFlags.setGalleryView
    
    func sortedRelations(dataview: BlockDataview, view: DataviewView) -> [SetRelation] {
        let relations: [SetRelation] = view.options
            .compactMap { option in
                let metadata = dataview.relations
                    .filter { !$0.isHidden }
                    .first { $0.key == option.key }
                guard let metadata = metadata else { return nil }
                
                return SetRelation(metadata: metadata, option: option)
            }

        return NSOrderedSet(array: relations).array as! [SetRelation]
    }
    
    func activeViewRelations(
        dataview: BlockDataview,
        view: DataviewView,
        excludeRelations: [RelationMetadata]
    ) -> [RelationMetadata] {
        view.options.compactMap { option in
            let metadata = dataview.relations.first { relation in
                option.key == relation.key
            }
            
            guard let metadata = metadata,
                  shouldAddRelationMetadata(metadata, excludeRelations: excludeRelations) else { return nil }
            
            return metadata
        }
    }
    
    func itemData(
        _ details: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        colums: [RelationMetadata],
        isObjectLocked: Bool,
        onIconTap: @escaping (ObjectDetails) -> Void,
        onItemTap: @escaping (ObjectDetails) -> Void
    ) -> [SetContentViewItemConfiguration] {
        
        let metadata = sortedRelations(dataview: dataView, view: activeView)
            .filter { $0.option.isVisible == true }
            .map { $0.metadata }
        return details.compactMap { details in
            let parsedRelations = relationsBuilder
                .parsedRelations(
                    relationMetadatas: metadata,
                    objectId: details.id,
                    isObjectLocked: isObjectLocked
                )
                .all
            
            let sortedRelations = colums.compactMap { colum in
                parsedRelations.first { $0.id == colum.key }
            }
            
            let relations: [Relation] = colums.map { colum in
                let relation = sortedRelations.first { $0.id == colum.key }
                guard let relation = relation else {
                    return .unknown(.empty(id: colum.id, name: colum.name))
                }
                
                return relation
            }
            
            return SetContentViewItemConfiguration(
                id: details.id,
                title: details.title,
                description: details.description,
                icon: details.objectIconImage,
                relations: relations,
                showIcon: !activeView.hideIcon,
                smallItemSize: activeView.cardSize == .small,
                hasCover: activeView.coverRelationKey.isNotEmpty,
                coverFit: activeView.coverFit,
                coverType: coverType(details, dataView: dataView, activeView: activeView),
                onIconTap: {
                    onIconTap(details)
                },
                onItemTap: {
                    onItemTap(details)
                }
            )
        }
    }
    
    private func coverType(
        _ details: ObjectDetails,
        dataView: BlockDataview,
        activeView: DataviewView) -> ObjectHeaderCoverType?
    {
        guard isGalleryViewEnabled, activeView.type == .gallery else {
            return nil
        }
        if activeView.coverRelationKey == SetViewSettingsImagePreviewCover.pageCover.rawValue,
           let documentCover = details.documentCover {
            return .cover(documentCover)
        } else {
            return relationCoverType(details, dataView: dataView, activeView: activeView)
        }
    }
    
    private func relationCoverType(
        _ details: ObjectDetails,
        dataView: BlockDataview,
        activeView: DataviewView) -> ObjectHeaderCoverType?
    {
        let relation = dataView.relations.first { $0.format == .file && $0.key == activeView.coverRelationKey }
        
        guard let relation = relation,
              let value = details.values[relation.key] else {
            return nil
        }
        if case let .listValue(listValue) = value.kind {
            return findCover(at: listValue.values, details)
        } else if value.stringValue.isNotEmpty {
            return findCover(at: [value], details)
        } else {
            return nil
        }
    }
    
    private func findCover(at values: [Google_Protobuf_Value], _ details: ObjectDetails) -> ObjectHeaderCoverType? {
        for value in values {
            let details = storage.get(id: value.stringValue)
            if let details = details, details.type == Constants.imageType {
                return .cover(.imageId(details.id))
            }
        }
        return nil
    }
    
    private func shouldAddRelationMetadata(_ relationMetadata: RelationMetadata, excludeRelations: [RelationMetadata]) -> Bool {
        guard excludeRelations.first(where: { $0.key == relationMetadata.key }) == nil else {
            return false
        }
        guard relationMetadata.key != ExceptionalSetSort.name.rawValue,
              relationMetadata.key != ExceptionalSetSort.done.rawValue else {
            return true
        }
        return !relationMetadata.isHidden &&
        relationMetadata.format != .file &&
        relationMetadata.format != .unrecognized
    }
}

extension SetContentViewDataBuilder {
    enum Constants {
        static let imageType = "_otimage"
    }
}

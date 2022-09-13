import BlocksModels
import Foundation
import AnytypeCore
import SwiftProtobuf

final class SetContentViewDataBuilder {
    private let relationsBuilder = RelationsBuilder()
    private let storage = ObjectDetailsStorage.shared
    private let relationStorage = ServiceLocator.shared.relationStorage()
    private let isGalleryViewEnabled = FeatureFlags.setGalleryView

    func sortedRelations(dataview: BlockDataview, view: DataviewView) -> [SetRelation] {
        let relations: [SetRelation] = view.options
            .compactMap { option in
                let relation = relationStorage.relations(for: dataview.relationLinks)
                    .filter { !$0.isHidden }
                    .first { $0.key == option.key }
                guard let relation = relation else { return nil }
                
                return SetRelation(relation: relation, option: option)
            }

        return NSOrderedSet(array: relations).array as! [SetRelation]
    }
    
    func itemData(
        _ details: [ObjectDetails],
        dataView: BlockDataview,
        activeView: DataviewView,
        colums: [Relation],
        isObjectLocked: Bool,
        onIconTap: @escaping (ObjectDetails) -> Void,
        onItemTap: @escaping (ObjectDetails) -> Void
    ) -> [SetContentViewItemConfiguration] {
        
        let relation = sortedRelations(dataview: dataView, view: activeView)
            .filter { $0.option.isVisible == true }
            .map { $0.relation }
        return details.compactMap { details in
            let parsedRelations = relationsBuilder
                .parsedRelations(
                    relations: relation,
                    objectId: details.id,
                    isObjectLocked: isObjectLocked
                )
                .all
            
            let sortedRelations = colums.compactMap { colum in
                parsedRelations.first { $0.key == colum.key }
            }
            
            let relationValues: [RelationValue] = colums.map { colum in
                let relation = sortedRelations.first { $0.key == colum.key }
                guard let relation = relation else {
                    return .unknown(.empty(id: colum.id, key: colum.key, name: colum.name))
                }
                
                return relation
            }
            
            return SetContentViewItemConfiguration(
                id: details.id,
                title: details.title,
                description: details.description,
                icon: details.objectIconImage,
                relationValues: relationValues,
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
        let relation = relationStorage.relations(for: dataView.relationLinks)
            .first { $0.format == .file && $0.key == activeView.coverRelationKey }
        
        guard let relation = relation else {
            return nil
        }

        let values = details.stringArrayValue(for: relation.key)
        let value = details.stringValue(for: relation.key)

        if values.isNotEmpty {
            return findCover(at: values, details)
        } else if value.isNotEmpty {
            return findCover(at: [value], details)
        } else {
            return nil
        }
    }

    private func findCover(at values: [String], _ details: ObjectDetails) -> ObjectHeaderCoverType? {
        for value in values {
            let details = storage.get(id: value)
            if let details = details, details.type == Constants.imageType {
                return .cover(.imageId(details.id))
            }
        }
        return nil
    }
}

extension SetContentViewDataBuilder {
    enum Constants {
        static let imageType = "_otimage"
    }
}

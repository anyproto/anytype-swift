import BlocksModels
import Foundation
import AnytypeCore
import SwiftProtobuf

final class SetContentViewDataBuilder {
    private let relationsBuilder = RelationsBuilder(scope: [.object, .type])
    private let storage = ObjectDetailsStorage.shared
    
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
        guard FeatureFlags.setGalleryView, activeView.type == .gallery else {
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
              let list = details.values[relation.key],
              case let .listValue(listValue) = list.kind else {
            return nil
        }
        for value in listValue.values {
            let details = storage.get(id: value.stringValue)
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

import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class ObjectRelationsSectionBuilder {
    
    // MARK: - Private variables
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    // MARK: - Internal functions
    
    func buildViewModels(
        using relations: [Relation],
        objectId: BlockId,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> [ObjectRelationsSection] {
        guard let objectDetails = detailsStorage.get(id: objectId) else { return [] }
        
        var featuredRelations: [ObjectRelationRowData] = []
        var otherRelations: [ObjectRelationRowData] = []
        
        let featuredRelationIds = objectDetails.featuredRelations
        relations.forEach { relation in
            let value = relationRowValue(
                relation: relation,
                details: objectDetails,
                detailsStorage: detailsStorage
            )
            
            let rowData = ObjectRelationRowData(
                id: relation.id,
                name: relation.name,
                value: value,
                hint: relation.format.hint
            )
            
            if featuredRelationIds.contains(relation.id) {
                featuredRelations.append(rowData)
            } else {
                otherRelations.append(rowData)
            }
        }
        
        var sections: [ObjectRelationsSection] = []
        
        if featuredRelations.isNotEmpty {
            sections.append(
                ObjectRelationsSection(
                    id: Constants.featuredRelationsSectionId,
                    title: "Featured relations".localized,
                    relations: featuredRelations
                )
            )
        }
        
        let otherRelationsSectionTitle = featuredRelations.isNotEmpty ?
        "Other relations".localized :
        "In this object".localized
        
        sections.append(
            ObjectRelationsSection(
                id: Constants.otherRelationsSectionId,
                title: otherRelationsSectionTitle,
                relations: otherRelations
            )
        )
        
        return sections
    }
    
}

// MARK: - Private extension

private extension ObjectRelationsSectionBuilder {
    
    func relationRowValue(
        relation: Relation,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> ObjectRelationRowValue {
        switch relation.format {
        case .longText:
            return textRelationRowValue(relation: relation, details: details)
        case .shortText:
            return textRelationRowValue(relation: relation, details: details)
        case .number:
            return numberRelationRowValue(relation: relation, details: details)
        case .status:
            return statusRelationRowValue(relation: relation, details: details)
        case .date:
            return dateRelationRowValue(relation: relation, details: details)
        case .file:
            return fileRelationRowValue(relation: relation, details: details, detailsStorage: detailsStorage)
        case .checkbox:
            return checkboxRelationRowValue(relation: relation, details: details)
        case .url:
            return textRelationRowValue(relation: relation, details: details)
        case .email:
            return textRelationRowValue(relation: relation, details: details)
        case .phone:
            return textRelationRowValue(relation: relation, details: details)
        case .tag:
            return tagRelationRowValue(relation: relation, details: details)
        case .object:
            return objectRelationRowValue(relation: relation, details: details, detailsStorage: detailsStorage)
        case .unrecognized:
            return .text("Unsupported value".localized)
        }
    }
    
    func textRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        let text: String? = value?.stringValue
        
        return .text(text)
    }
    
    func numberRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        
        let number = value?.safeIntValue
        let text: String? = number.flatMap { String($0) }
        
        return .text(text)
    }
    
    func statusRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        
        guard
            let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
        else { return .status(nil) }
        
        let option: Relation.Option? = relation.selections.first { $0.id == optionId }

        guard let option = option else { return .status(nil) }
        
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        let anytypeColor: AnytypeColor = middlewareColor?.asDarkColor ?? .grayscale90
        
        return .status(
            StatusRelation(
                text: option.text,
                color: anytypeColor
            )
        )
    }
    
    func dateRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        
        guard let number = value?.safeDoubleValue else { return .text(nil) }
        
        let date = Date(timeIntervalSince1970: number)
        
        return .text(dateFormatter.string(from: date))
    }
    
    func checkboxRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        
        return .checkbox(value?.boolValue ?? false)
    }
    
    func tagRelationRowValue(relation: Relation, details: ObjectDetails) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        guard let value = value else { return .tag([]) }

        let selectedTagIds: [String] = value.listValue.values.compactMap {
            let tagId = $0.stringValue
            return tagId.isEmpty ? nil : tagId
        }
        
        let options: [Relation.Option] = relation.selections.filter {
            selectedTagIds.contains($0.id)
        }
        
        let tags: [TagRelation] = options.map {
            TagRelation(
                text: $0.text,
                textColor: MiddlewareColor(rawValue: $0.color)?.asDarkColor ?? .grayscale90,
                backgroundColor: MiddlewareColor(rawValue: $0.color)?.asLightColor ?? .grayscaleWhite
            )
        }
        
        return .tag(tags)
    }
    
    func objectRelationRowValue(
        relation: Relation,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        guard let value = value else { return .object([]) }
        
        let values: [Google_Protobuf_Value] = {
            if case let .listValue(listValue) = value.kind {
                return listValue.values
            }
            
            return [value]
        }()
        
        let objectDetails: [ObjectDetails] = values.compactMap {
            let objectId = $0.stringValue
            guard objectId.isNotEmpty else { return nil }
            let objectDetails = detailsStorage.get(id: objectId)
            return objectDetails
        }

        let objectRelations: [ObjectRelation] = objectDetails.map { objectDetail in
            let name = objectDetail.name
            let icon: ObjectIconImage = {
                if let objectIcon = objectDetail.objectIconImage {
                    return objectIcon
                }
                
                return .placeholder(name.first)
            }()
            
            return ObjectRelation(icon: icon, text: name)
        }
        
        
        return .object(objectRelations)
    }
    
    func fileRelationRowValue(
        relation: Relation,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> ObjectRelationRowValue {
        let value = details.values[relation.key]
        guard let value = value else { return .object([]) }
        
        let objectDetails: [ObjectDetails] = value.listValue.values.compactMap {
            let objectId = $0.stringValue
            guard objectId.isNotEmpty else { return nil }
            
            let objectDetails = detailsStorage.get(id: objectId)
            return objectDetails
        }

        let objectRelations: [ObjectRelation] = objectDetails.map { objectDetail in
            let fileName: String = {
                let name = objectDetail.name
                let fileExt = objectDetail.values[RelationKey.fileExt.rawValue]
                let fileExtString = fileExt?.stringValue
                
                guard
                    let fileExtString = fileExtString, fileExtString.isNotEmpty
                else { return name }
                
                return "\(name).\(fileExtString)"
            }()
            
            let icon: ObjectIconImage = {
                if let objectIconType = objectDetail.icon {
                    return .icon(objectIconType)
                }
                
                let fileMimeType = objectDetail.values[RelationKey.fileMimeType.rawValue]?.stringValue
                guard let fileMimeType = fileMimeType else {
                    return .image(UIImage.blockFile.content.other)
                }
                
                return .image(BlockFileIconBuilder.convert(mime: fileMimeType))
            }()
            
            return ObjectRelation(icon: icon, text: fileName)
        }
        
        return .object(objectRelations)
    }
    
}

extension Relation.Format {
    
    var hint: String {
        switch self {
        case .longText:
            return "Enter text".localized
        case .shortText:
            return "Enter text".localized
        case .number:
            return "Enter number".localized
        case .date:
            return "Enter date".localized
        case .url:
            return "Enter URL".localized
        case .email:
            return "Enter e-mail".localized
        case .phone:
            return "Enter phone".localized
        case .status:
            return "Select status".localized
        case .tag:
            return "Select tags".localized
        case .file:
            return "Select files".localized
        case .object:
            return "Select objects".localized
        case .checkbox:
            return ""
        case .unrecognized:
            return "Enter value".localized
        }
    }
    
}

private extension ObjectRelationsSectionBuilder {
    
    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let otherRelationsSectionId = "otherRelationsSectionId"
    }
    
}

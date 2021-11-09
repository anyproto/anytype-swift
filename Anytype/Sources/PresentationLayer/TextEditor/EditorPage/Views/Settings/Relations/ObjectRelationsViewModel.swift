import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class ObjectRelationsViewModel: ObservableObject {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    @Published private(set) var rowViewModels: [ObjectRelationRowViewModel]
    
    init(rowViewModels: [ObjectRelationRowViewModel] = []) {
        self.rowViewModels = rowViewModels
    }
    
    func update(
        with relations: [Relation],
        objectId: String,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        guard let objectDetails = detailsStorage.get(id: objectId) else { return }
        
        let visibleRelations = relations.filter { !$0.isHidden }
        
        let viewModels: [ObjectRelationRowViewModel] = visibleRelations.map { relation in
            let value = relationRowValue(
                relation: relation,
                details: objectDetails,
                detailsStorage: detailsStorage
            )
            
            return ObjectRelationRowViewModel(
                name: relation.name,
                value: value,
                hint: relation.format.hint
            )
        }
        
        self.rowViewModels = viewModels
    }
    
}

// MARK: - Private extension

private extension ObjectRelationsViewModel {
    
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
            return textRelationRowValue(relation: relation, details: details)
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

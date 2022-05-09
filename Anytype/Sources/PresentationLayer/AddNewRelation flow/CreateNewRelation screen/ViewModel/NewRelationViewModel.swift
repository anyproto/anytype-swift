import Foundation
import SwiftUI
import BlocksModels
import Combine

final class NewRelationViewModel: ObservableObject {
    
    var formatModel: NewRelationFormatSectionView.Model {
        format.asViewModel
    }
    
    var objectTypesRestrictionModel: [NewRelationRestrictionsSectionView.ObjectTypeModel]? {
        objectTypes.flatMap { $0.asViewModel }
    }
    
    var isCreateButtonActive: Bool {
        name.isNotEmpty
    }
    
    @Published var name: String
    @Published private var format: SupportedRelationFormat
    @Published private var objectTypes: [ObjectType]?
    
    private let service: RelationsServiceProtocol
    private weak var output: NewRelationModuleOutput?
    
    init(name: String, service: RelationsServiceProtocol, output: NewRelationModuleOutput?) {
        self.service = service
        self.output = output
        
        self.name = name
        self.format = SupportedRelationFormat.object
        handleFormatUpdate()
    }
    
}

// MARK: - Internal functions

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        output?.didAskToShowRelationFormats()
    }
    
    func didTapTypesRestrictionSection() {
        output?.didAskToShowObjectTypesSearch(selectedObjectTypesIds: objectTypeIds)
    }
    
    func didTapAddButton() {
        let relationMetatdata = RelationMetadata(
            key: "",
            name: name,
            format: format.asRelationMetadataFormat,
            isHidden: false,
            isReadOnly: false,
            isMulti: format.isMulti,
            selections: [],
            objectTypes: objectTypeIds,
            scope: .object,
            isBundled: false
        )

        if let relation = service.createRelation(relation: relationMetatdata) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            output?.didCreateRelation(relation)
        }
    }
    
}

// MARK: - NewRelationModuleInput

extension NewRelationViewModel: NewRelationModuleInput {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat) {
        format = newFormat
        handleFormatUpdate()
    }
    
    func updateTypesRestriction(objectTypeIds: [String]) {
        objectTypes = objectTypeIds.compactMap {
            ObjectTypeProvider.objectType(url: $0)
        }
    }
    
}

// MARK: - Private extension

private extension NewRelationViewModel {
    
    func handleFormatUpdate() {
        objectTypes = format == .object ? [] : nil
    }
    
    var objectTypeIds: [String] {
        objectTypes?.map { $0.url } ?? []
    }
    
}

// MARK: - SupportedRelationFormat private extension

private extension SupportedRelationFormat {
    
    var asViewModel: NewRelationFormatSectionView.Model {
        NewRelationFormatSectionView.Model(icon: self.icon, title: self.title)
    }
    
    var asRelationMetadataFormat: RelationMetadata.Format {
        switch self {
        case .text: return .longText
        case .tag: return .tag
        case .status: return .status
        case .number: return .number
        case .date: return .date
        case .file: return .file
        case .object: return .object
        case .checkbox: return .checkbox
        case .url: return .url
        case .email: return .email
        case .phone: return .phone
        }
    }
    
    var isMulti: Bool {
        switch self {
        case .text: return false
        case .tag: return true
        case .status: return true
        case .number: return false
        case .date: return false
        case .file: return true
        case .object: return true
        case .checkbox: return false
        case .url: return false
        case .email: return false
        case .phone: return false
        }
    }
    
}

// MARK: - Array private extension

private extension Array where Element == ObjectType {
    
    var asViewModel: [NewRelationRestrictionsSectionView.ObjectTypeModel] {
        map {
            NewRelationRestrictionsSectionView.ObjectTypeModel(
                id: $0.url,
                emoji: $0.iconEmoji,
                title: $0.name
            )
        }
    }
    
}

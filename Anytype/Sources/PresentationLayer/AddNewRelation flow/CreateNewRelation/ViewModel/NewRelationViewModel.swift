import Foundation
import SwiftUI
import Services
import Combine

@MainActor
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
    @Published var toastData: ToastBarData = .empty
    
    private let document: BaseDocumentProtocol
    private let target: RelationsModuleTarget
    
    @Injected(\.relationsService)
    private var relationsService: RelationsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    private let relationsInteractor: RelationsInteractorProtocol
    private weak var output: NewRelationModuleOutput?
    
    init(
        name: String,
        document: BaseDocumentProtocol,
        target: RelationsModuleTarget,
        relationsInteractor: RelationsInteractorProtocol,
        output: NewRelationModuleOutput?
    ) {
        self.document = document
        self.target = target
        self.relationsInteractor = relationsInteractor
        self.output = output
        
        self.name = name
        self.format = SupportedRelationFormat.object
        handleFormatUpdate()
    }
    
}

// MARK: - Internal functions

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        output?.didAskToShowRelationFormats(selectedFormat: format, onSelect: { [weak self] format in
            self?.updateRelationFormat(format)
        })
    }
    
    func didTapTypesRestrictionSection() {
        output?.didAskToShowObjectTypesSearch(selectedObjectTypesIds: objectTypeIds)
    }
    
    func didTapAddButton() {
        let relationDetails = RelationDetails(
            id: "",
            key: "",
            name: name,
            format: format.asRelationFormat,
            isHidden: false,
            isReadOnly: false,
            isReadOnlyValue: false,
            objectTypes: objectTypeIds,
            maxCount: 0,
            sourceObject: "",
            isDeleted: false,
            spaceId: ""
        )
        
        createRelation(relationDetails: relationDetails)
    }
    
    private func createRelation(relationDetails: RelationDetails) {
        Task {
            let createdRelation = try await relationsInteractor.createRelation(spaceId: document.spaceId, relation: relationDetails)
            
            switch target {
            case .object:
                try await relationsInteractor.addRelationToObject(relation: createdRelation)
            case .dataview(let activeViewId):
                try await relationsInteractor.addRelationToDataview(objectId: document.objectId, relation: createdRelation, activeViewId: activeViewId)
            }
            
            relationDetailsAdded(relationDetails: createdRelation)
        }
    }
    
    private func relationDetailsAdded(relationDetails: RelationDetails) {
        toastData = ToastBarData(text: Loc.Relation.addedToLibrary(relationDetails.name), showSnackBar: true)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        output?.didCreateRelation(relationDetails)
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
            try? objectTypeProvider.objectType(id: $0)
        }
    }
    
}

// MARK: - Private extension

private extension NewRelationViewModel {
    
    func handleFormatUpdate() {
        objectTypes = format == .object ? [] : nil
    }
    
    var objectTypeIds: [String] {
        objectTypes?.map { $0.id } ?? []
    }
    
}

// MARK: - SupportedRelationFormat private extension

private extension SupportedRelationFormat {
    
    var asViewModel: NewRelationFormatSectionView.Model {
        NewRelationFormatSectionView.Model(icon: self.iconAsset, title: self.title)
    }
    
    var asRelationFormat: RelationFormat {
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
}

// MARK: - Array private extension

private extension Array where Element == ObjectType {
    
    var asViewModel: [NewRelationRestrictionsSectionView.ObjectTypeModel] {
        map {
            NewRelationRestrictionsSectionView.ObjectTypeModel(
                id: $0.id,
                emoji: $0.iconEmoji,
                title: $0.name
            )
        }
    }
    
}

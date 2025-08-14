import FloatingPanel
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore
import Combine

@MainActor
final class SetPropertiesViewModel: ObservableObject {
    @Published var view: DataviewView = .empty
    @Published var relations = [SetViewSettingsProperty]()
    
    private let setDocument: any SetDocumentProtocol
    private let viewId: String
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    
    private weak var output: (any SetPropertiesCoordinatorOutput)?
    
    private var cancellable: (any Cancellable)?
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String,
        output: (any SetPropertiesCoordinatorOutput)?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.output = output
        self.setup()
    }
    
    func deleteProperties(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setDocument.sortedRelations(for: viewId)[safe: index] else {
                anytypeAssertionFailure("No relation to delete", info: ["index": "\(index)"])
                return
            }
            Task {
                let key = relation.relationDetails.key
                guard let details = setDocument.details else { return }
                
                if details.isObjectType {
                    try await propertiesService.removeTypeProperty(
                        details: details,
                        propertyId: relation.relationDetails.id
                    )
                } else {
                    try await dataviewService.deleteRelation(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        relationKey: key
                    )
                }
                
                if let details = setDocument.details, details.isObjectType {
                    try await propertiesService.removeTypeProperty(details: details, propertyId: relation.relationDetails.id)
                } else {
                    try await dataviewService.removeViewRelations(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        keys: [key],
                        viewId: viewId
                    )
                }
            }
        }
    }
    
    func moveProperty(from: IndexSet, to: Int) {
        from.forEach { [weak self] sortedRelationsFromIndex in
            guard let self, sortedRelationsFromIndex != to else { return }
            
            let sortedRelations = setDocument.sortedRelations(for: viewId)
            let relationFrom = sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = sortedRelations[sortedRelationsToIndex]
            let options = view.options
            
            // index in all options array (includes hidden options)
            guard let indexFrom = options.index(of: relationFrom) else {
                anytypeAssertionFailure("No from relation for move", info: ["key": relationFrom.relationDetails.key])
                return
            }
            guard let indexTo = options.index(of: relationTo) else {
                anytypeAssertionFailure("No to relation for move", info: ["key": relationTo.relationDetails.key])
                return
            }
            
            var newOptions = options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let keys = newOptions.map { $0.key }
            Task { [weak self] in
                guard let self else { return }
                try await dataviewService.sortViewRelations(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    keys: keys,
                    viewId: viewId
                )
            }
        }
    }
    
    func showAddPropertyInfoView() {
        output?.onAddButtonTap { [spaceId = setDocument.spaceId] relation, isNew in
            AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                format: relation.format,
                isNew: isNew,
                type: .dataview,
                key: relation.analyticsKey,
                spaceId: spaceId
            )
        }
    }
    
    private func setup() {
        cancellable = setDocument.syncPublisher.receiveOnMain().sink {  [weak self] in
            guard let self else { return }
            view = setDocument.view(by: viewId)
            
            let isObjectType = setDocument.details?.isObjectType ?? false
            
            relations = setDocument.sortedRelations(for: viewId).map { relation in
                let canBeRemoved = isObjectType ? relation.relationDetails.canBeRemovedFromType : relation.relationDetails.canBeRemovedFromObject
                
                return SetViewSettingsProperty(
                    id: relation.id,
                    image: relation.relationDetails.format.iconAsset,
                    title: relation.relationDetails.name,
                    isOn: relation.option.isVisible,
                    canBeRemoved: canBeRemoved,
                    onChange: { [weak self] isVisible in
                        self?.onRelationVisibleChange(relation, isVisible: isVisible)
                    }
                )
            }
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetProperty, isVisible: Bool) {
        Task {
            let newOption = relation.option.updated(isVisible: isVisible).asMiddleware
            try await dataviewService.replaceViewRelation(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                key: relation.option.key,
                with: newOption,
                viewId: viewId
            )
        }
    }
}

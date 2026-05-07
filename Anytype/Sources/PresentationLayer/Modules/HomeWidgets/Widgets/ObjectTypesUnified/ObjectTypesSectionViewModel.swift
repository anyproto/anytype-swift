import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class ObjectTypesSectionViewModel {

    // MARK: - DI

    @ObservationIgnored
    let spaceId: String

    @ObservationIgnored
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol
    @ObservationIgnored
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored
    @Injected(\.objectTypesWithObjectsCreatedService)
    private var objectTypesWithObjectsCreatedService: any ObjectTypesWithObjectsCreatedServiceProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol

    // MARK: - State

    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var objectTypesDataLoaded: Bool = false
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false

    private static let expandedStorageId = "HomeObjectTypeSection"

    init(spaceId: String) {
        self.spaceId = spaceId
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Self.expandedStorageId, defaultValue: true)
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let typesSub: () = startObjectTypesTask()
        async let canEditSub: () = startCanEditSubscription()
        _ = await (typesSub, canEditSub)
    }

    func onTapObjectTypeHeader() {
        withAnimation {
            objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        }
        expandedService.setState(id: Self.expandedStorageId, isExpanded: objectTypeSectionIsExpanded)
    }

    private func startObjectTypesTask() async {
        let spaceId = spaceId
        let spaceType = workspaceStorage.spaceView(spaceId: spaceId)?.spaceType
        let allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceType: spaceType)
        await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceType: spaceType)

        let typesPublisher = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
        let objectsCreatedPublisher = objectTypesWithObjectsCreatedService.typeIdsWithObjectsCreatedPublisher
        let alwaysVisibleKeys: Set<ObjectTypeUniqueKey> = [.page, .task, .collection]

        let stream = typesPublisher.combineLatest(objectsCreatedPublisher)
            .map { (types, typeIdsWithObjectsCreated) in
                types
                    .filter { ($0.recommendedLayout.map { allowedLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                    .filter { typeIdsWithObjectsCreated.contains($0.id) || alwaysVisibleKeys.contains($0.uniqueKey) }
                    .map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
            .values

        for await objectTypes in stream {
            if !objectTypesDataLoaded { objectTypesDataLoaded = true }
            objectTypeWidgets = objectTypes
        }
    }

    private func startCanEditSubscription() async {
        for await canEdit in participantsStorage.canEditSequence(spaceId: spaceId) {
            canCreateObjectType = canEdit
        }
    }
}

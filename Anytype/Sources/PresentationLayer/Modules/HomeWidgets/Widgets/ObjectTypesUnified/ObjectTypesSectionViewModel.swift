import Foundation
import SwiftUI
import Services
import AnytypeCore
import AsyncAlgorithms

@MainActor
@Observable
final class ObjectTypesSectionViewModel {

    // MARK: - DI

    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    weak var output: (any CommonWidgetModuleOutput)?

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
    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    // MARK: - State

    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var objectTypesDataLoaded: Bool = false
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false

    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(section: .objects, defaultValue: true)
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        await startObjectTypesTask()
    }

    func onTapObjectTypeHeader() {
        objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        expandedService.setState(section: .objects, isExpanded: objectTypeSectionIsExpanded)
    }

    func onTypeTap(info: ObjectTypeWidgetInfo) {
        output?.onObjectSelected(
            screenData: .editor(.type(EditorTypeObject(objectId: info.objectTypeId, spaceId: info.spaceId)))
        )
    }

    func onCreateObject(info: ObjectTypeWidgetInfo) async throws {
        let type = try objectTypeProvider.objectType(id: info.objectTypeId)

        if type.isChatType {
            output?.onObjectSelected(screenData: .alert(.chatCreate(ChatCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .widget
            ))))
            return
        }

        if type.isBookmarkType {
            output?.onObjectSelected(screenData: .alert(.bookmarkCreate(BookmarkCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .widget
            ))))
            return
        }

        let details = try await objectActionsService.createObject(
            name: "",
            typeUniqueKey: type.uniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: false,
            shouldSelectTemplate: true,
            spaceId: type.spaceId,
            origin: .none,
            templateId: type.defaultTemplateId
        )

        AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .widget)
        output?.onObjectSelected(screenData: details.screenData())
    }

    // MARK: - Private

    private func startObjectTypesTask() async {
        let spaceId = spaceId
        let spaceType = workspaceStorage.spaceView(spaceId: spaceId)?.spaceType
        let allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceType: spaceType)
        await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceType: spaceType)

        let typesSequence = objectTypeProvider.objectTypesPublisher(spaceId: spaceId).values
        let objectsCreatedSequence = objectTypesWithObjectsCreatedService.typeIdsWithObjectsCreatedPublisher.values
        let canEditSequence = participantsStorage.canEditSequence(spaceId: spaceId)
        let alwaysVisibleKeys: Set<ObjectTypeUniqueKey> = [.page, .task, .collection]

        for await (types, typeIdsWithObjectsCreated, canEdit) in combineLatest(typesSequence, objectsCreatedSequence, canEditSequence) {
            canCreateObjectType = canEdit

            let widgets: [ObjectTypeWidgetInfo] = types
                .filter { ($0.recommendedLayout.map { allowedLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                .filter { typeIdsWithObjectsCreated.contains($0.id) || alwaysVisibleKeys.contains($0.uniqueKey) }
                .map { type in
                    let typeCanBeCreated = type.recommendedLayout?.isSupportedForCreation(spaceType: spaceType) ?? false
                    return ObjectTypeWidgetInfo(
                        objectTypeId: type.id,
                        spaceId: spaceId,
                        name: type.pluralDisplayName,
                        icon: .object(type.icon),
                        canCreateObject: typeCanBeCreated && canEdit
                    )
                }

            if !objectTypesDataLoaded { objectTypesDataLoaded = true }
            guard objectTypeWidgets != widgets else { continue }
            objectTypeWidgets = widgets
        }
    }
}

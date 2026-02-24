import SwiftUI
import Services

@MainActor
@Observable
final class ObjectTypesUnifiedRowViewModel {

    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantsStorage: any ParticipantsStorageProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    private let info: ObjectTypeWidgetInfo
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?

    var typeIcon: Icon?
    var typeName: String = ""
    var canCreateObject: Bool = false

    private var canEdit: Bool = false
    private var typeCanBeCreated: Bool = false

    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self.info = info
        self.output = output
    }

    func startSubscriptions() async {
        async let typeSub: () = startTypeSubscription()
        async let participantSub: () = startParticipantSubscription()
        _ = await (typeSub, participantSub)
    }

    func onTapType() {
        output?.onObjectSelected(screenData: .editor(.type(EditorTypeObject(objectId: info.objectTypeId, spaceId: info.spaceId))))
    }

    func onCreateObject() async throws {
        let type = try objectTypeProvider.objectType(id: info.objectTypeId)

        if type.isChatType {
            let screenData = ScreenData.alert(.chatCreate(ChatCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .widget
            )))
            output?.onObjectSelected(screenData: screenData)
            return
        }

        if type.isBookmarkType {
            let screenData = ScreenData.alert(.bookmarkCreate(BookmarkCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .widget
            )))
            output?.onObjectSelected(screenData: screenData)
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

    private func startTypeSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            typeIcon = .object(type.icon)
            typeName = type.pluralDisplayName
            let spaceUxType = spaceViewsStorage.spaceView(spaceId: info.spaceId)?.uxType
            typeCanBeCreated = type.recommendedLayout?.isSupportedForCreation(spaceUxType: spaceUxType) ?? false
            updateCanCreateObject()
        }
    }

    private func startParticipantSubscription() async {
        for await canEdit in accountParticipantsStorage.canEditSequence(spaceId: info.spaceId) {
            self.canEdit = canEdit
            updateCanCreateObject()
        }
    }

    private func updateCanCreateObject() {
        canCreateObject = typeCanBeCreated && canEdit
    }
}

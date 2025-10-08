import SwiftUI
import Services

@MainActor
@Observable
final class ObjectTypeWidgetViewModel {
    
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private let expandedService: any ExpandedServiceProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.accountParticipantsStorage) @ObservationIgnored
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    private let rowsBuilder: any ObjectTypeRowsBuilderProtocol
    
    private let info: ObjectTypeWidgetInfo
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?
    
    var typeId: String { info.objectTypeId }
    var canCreateObject: Bool { typeCanBeCreated && canEdit}
    var canDeleteType: Bool { typeIsDeletable && canEdit }
    
    var typeIcon: Icon?
    var typeName: String = ""
    var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    var rows: ObjectTypeWidgetRowType?
    var deleteAlert: ObjectTypeDeleteConfirmationAlertData?
    var canEdit: Bool = false
    
    var typeIsDeletable: Bool = false
    var typeCanBeCreated: Bool = false
    
    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self.info = info
        self.output = output
        expandedService = Container.shared.expandedService()
        isExpanded = expandedService.isExpanded(id: info.objectTypeId, defaultValue: false)
        rowsBuilder = Container.shared.objectTypeRowBuilder(info)
    }
    
    func startMainSubscriptions() async {
        async let typeSub: () = startTypeSubscription()
        async let participantSub: () = startParticipantSubscription()
        async let rowsSub: () = startRowsSubscription()
        
        _ = await (typeSub, participantSub, rowsSub)
    }
    
    func startSubscriptionsForExpandedState() async {
        guard isExpanded else { return }
        await rowsBuilder.startSubscriptions()
    }
    
    func onCreateObject() {
        Task {
            let type = try objectTypeProvider.objectType(id: info.objectTypeId)
            
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
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .homeScreen)
            output?.onObjectSelected(screenData: details.screenData())
        }
    }
    
    func onHeaderTap() {
        output?.onObjectSelected(screenData: .editor(.type(EditorTypeObject(objectId: info.objectTypeId, spaceId: info.spaceId))))
    }
    
    func onShowAllTap() {
        output?.onObjectSelected(screenData: .editor(.type(EditorTypeObject(objectId: info.objectTypeId, spaceId: info.spaceId))))
    }
    
    func onDelete() {
        deleteAlert = ObjectTypeDeleteConfirmationAlertData(typeId: info.objectTypeId)
    }
    
    // MARK: - Private
    
    private func expandedDidChange() {
        UISelectionFeedbackGenerator().selectionChanged()
        expandedService.setState(id: info.objectTypeId, isExpanded: isExpanded)
    }
    
    private func startTypeSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            typeIcon = .object(type.icon)
            typeName = type.pluralDisplayName
            typeCanBeCreated = type.recommendedLayout?.isSupportedForCreation ?? false
            typeIsDeletable = type.isDeletable
        }
    }
    
    private func startParticipantSubscription() async {
        for await canEdit in accountParticipantsStorage.canEditPublisher(spaceId: info.spaceId).values {
            self.canEdit = canEdit
        }
    }
    
    private func handleTapOnObject(details: ObjectDetails) {
        output?.onObjectSelected(screenData: details.screenData())
    }
    
    private func startRowsSubscription() async {
        await rowsBuilder.setTapHandle { [weak self] details in
            self?.handleTapOnObject(details: details)
        }
        
        for await newRows in rowsBuilder.rowsSequence {
            rows = newRows
        }
    }
}

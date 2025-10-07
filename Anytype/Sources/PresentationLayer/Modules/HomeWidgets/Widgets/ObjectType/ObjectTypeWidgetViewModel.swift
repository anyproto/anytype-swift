import SwiftUI
import Services

@MainActor
final class ObjectTypeWidgetViewModel: ObservableObject {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private let expandedService: any ExpandedServiceProtocol
    private let subscriptionStorage: any SubscriptionStorageProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @Injected(\.setObjectWidgetOrderHelper)
    private var setObjectWidgetOrderHelper: any SetObjectWidgetOrderHelperProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    private let info: ObjectTypeWidgetInfo
    private weak var output: (any CommonWidgetModuleOutput)?
    private let setDocument: any SetDocumentProtocol
    private let subscriptionId = "ObjectTypeWidget-\(UUID().uuidString)"
    private var isImageType: Bool = false
    
    var typeId: String { info.objectTypeId }
    var canCreateObject: Bool { typeCanBeCreated && canEdit}
    var canDeleteType: Bool { typeIsDeletable && canEdit }
    
    @Published var typeIcon: Icon?
    @Published var typeName: String = ""
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var rows: ObjectTypeWidgetRowType?
    @Published var deleteAlert: ObjectTypeDeleteConfirmationAlertData?
    @Published var canEdit: Bool = false
    
    @Published private var typeIsDeletable: Bool = false
    @Published private var typeCanBeCreated: Bool = false
    
    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self.info = info
        self.output = output
        expandedService = Container.shared.expandedService()
        isExpanded = expandedService.isExpanded(id: info.objectTypeId, defaultValue: false)
        setDocument = Container.shared.openedDocumentProvider().setDocument(
            objectId: info.objectTypeId,
            spaceId: info.spaceId,
            mode: .preview
        )
        let storageProvider = Container.shared.subscriptionStorageProvider()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: subscriptionId)
    }
    
    func startSubscriptions() async {
        async let typeSub: () = startTypeSubscription()
        async let objectsSub: () = startObjectsSubscription()
        async let participantSub: () = startParticipantSubscription()
        
        (_, _, _) = await (typeSub, objectsSub, participantSub)
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
            isImageType = type.isImageLayout
            typeCanBeCreated = type.recommendedLayout?.isSupportedForCreation ?? false
            typeIsDeletable = type.isDeletable
        }
    }
    
    private func startObjectsSubscription() async {
        do {
            try await setDocument.open()
            
            let subscriptionData = setSubscriptionDataBuilder.set(
                SetSubscriptionData(
                    identifier: subscriptionId,
                    document: setDocument,
                    groupFilter: nil,
                    currentPage: 0,
                    numberOfRowsPerPage: 6,
                    collectionId: nil,
                    objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId)
                )
            )
            
            try await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData)
            
            for await state in subscriptionStorage.statePublisher.values {
                let rowDetails = setObjectWidgetOrderHelper.reorder(
                    setDocument: setDocument,
                    subscriptionStorage: subscriptionStorage,
                    details: state.items,
                    onItemTap: { [weak self] details, _ in
                        self?.handleTapOnObject(details: details)
                    }
                )
                updateRows(rowDetails: rowDetails)
            }
            
        } catch {}
    }
    
    private func startParticipantSubscription() async {
        for await canEdit in accountParticipantsStorage.canEditPublisher(spaceId: info.spaceId).values {
            self.canEdit = canEdit
        }
    }
    
    private func handleTapOnObject(details: ObjectDetails) {
        output?.onObjectSelected(screenData: details.screenData())
    }
    
    private func updateRows(rowDetails: [SetContentViewItemConfiguration]) {
        if isImageType {
            let galleryRows = rowDetails.map { details in
                GalleryWidgetRowModel(
                    objectId: details.id,
                    title: nil,
                    icon: nil,
                    cover: .cover(.imageId(details.id)),
                    onTap: details.onItemTap
                )
            }
            rows = .gallery(rows: galleryRows)
        } else {
            switch setDocument.activeView.type {
            case .table, .list, .kanban, .calendar, .graph:
                let listRows = rowDetails.map { ListWidgetRowModel(details: $0) }
                rows = .compactList(rows: listRows)
            case .gallery:
                let galleryRows = rowDetails.map { GalleryWidgetRowModel(details: $0) }
                rows = .gallery(rows: galleryRows)
            }
        }
    }
}

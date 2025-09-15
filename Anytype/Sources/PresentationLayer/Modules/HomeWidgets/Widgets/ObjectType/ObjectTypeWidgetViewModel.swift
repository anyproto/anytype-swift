import SwiftUI
import Services

@MainActor
final class ObjectTypeWidgetViewModel: ObservableObject {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private let blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol
    private let subscriptionStorage: any SubscriptionStorageProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @Injected(\.setObjectWidgetOrderHelper)
    private var setObjectWidgetOrderHelper: any SetObjectWidgetOrderHelperProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let info: ObjectTypeWidgetInfo
    private weak var output: (any CommonWidgetModuleOutput)?
    private let setDocument: any SetDocumentProtocol
    private let subscriptionId = "ObjectTypeWidget-\(UUID().uuidString)"
    private var isImageType: Bool = false
    
    var typeId: String { info.objectTypeId }
    @Published var typeIcon: Icon?
    @Published var typeName: String = ""
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var canCreateObject: Bool = false
    @Published var rows: ObjectTypeWidgetRowType?
    
    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self.info = info
        self.output = output
        blockWidgetExpandedService = Container.shared.blockWidgetExpandedService.resolve()
        isExpanded = blockWidgetExpandedService.isExpanded(id: info.objectTypeId)
        setDocument = Container.shared.openedDocumentProvider().setDocument(
            objectId: info.objectTypeId,
            spaceId: info.spaceId,
            mode: .preview
        )
        let storageProvider = Container.shared.subscriptionStorageProvider.resolve()
        self.subscriptionStorage = storageProvider.createSubscriptionStorage(subId: subscriptionId)
    }
    
    func startSubscriptions() async {
        async let typeSub: () = startTypeSubscription()
        async let objectsSub: () = startObjectsSubscription()
        
        (_, _) = await (typeSub, objectsSub)
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
    
    // MARK: - Private
    
    private func expandedDidChange() {
        UISelectionFeedbackGenerator().selectionChanged()
        blockWidgetExpandedService.setState(id: info.objectTypeId, isExpanded: isExpanded)
    }
    
    private func startTypeSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            typeIcon = .object(type.icon)
            typeName = type.name
            isImageType = type.isImageLayout
            canCreateObject = type.recommendedLayout?.isSupportedForCreation ?? false
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

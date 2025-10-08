import Foundation
import AsyncAlgorithms
import AsyncTools
import Factory
import Services

protocol ObjectTypeRowsBuilderProtocol: AnyObject, Sendable {
    func startSubscriptions() async
    func setTapHandle(onTap: @escaping @MainActor (_ details: ObjectDetails) -> Void) async
    var rowsSequence: AnyAsyncSequence<ObjectTypeWidgetRowType> { get }
}

actor ObjectTypeRowsBuilder: ObjectTypeRowsBuilderProtocol {
    
    private let info: ObjectTypeWidgetInfo
    
    @LazyInjected(\.openedDocumentProvider)
    private var openedDocumentProvider: any OpenedDocumentsProviderProtocol
    @LazyInjected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @LazyInjected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @LazyInjected(\.setObjectWidgetOrderHelper)
    private var setObjectWidgetOrderHelper: any SetObjectWidgetOrderHelperProtocol
    @LazyInjected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionId = "ObjectTypeWidget-\(UUID().uuidString)"
    private var isImageType: Bool = false
    
    private let rowsChannel = AsyncChannel<ObjectTypeWidgetRowType>()
    private var onTap: (@MainActor (_ details: ObjectDetails) -> Void)?
    
    nonisolated var rowsSequence: AnyAsyncSequence<ObjectTypeWidgetRowType> {
        rowsChannel.eraseToAnyAsyncSequence()
    }
    
    private lazy var setDocument = openedDocumentProvider.setDocument(
        objectId: info.objectTypeId,
        spaceId: info.spaceId,
        mode: .preview
    )
    
    init(info: ObjectTypeWidgetInfo) {
        self.info = info
    }
    
    func setTapHandle(onTap: @escaping @MainActor (_ details: ObjectDetails) -> Void) {
        self.onTap = onTap
    }
    
    func startSubscriptions() async {
        async let typeSub: () = startTypeSubscription()
        async let objectSub: () = startObjectsSubscription()
        
        _ = await (typeSub, objectSub)
    }
    
    private func startTypeSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            isImageType = type.isImageLayout
        }
    }
    
    // MARK: - Private
    
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
                        Task {
                            let onTap = await self?.onTap
                            onTap?(details)
                        }
                    }
                )
                await updateRows(rowDetails: rowDetails)
            }
            
        } catch {}
    }
    
    private func updateRows(rowDetails: [SetContentViewItemConfiguration]) async {
        let rows: ObjectTypeWidgetRowType
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
        
        await rowsChannel.send(rows)
    }
}

extension Container {
    var objectTypeRowBuilder:  ParameterFactory<ObjectTypeWidgetInfo, any ObjectTypeRowsBuilderProtocol> {
        self { ObjectTypeRowsBuilder(info: $0) }
    }
}

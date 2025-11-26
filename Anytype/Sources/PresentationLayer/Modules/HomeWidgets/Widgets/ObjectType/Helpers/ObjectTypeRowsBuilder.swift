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
    @LazyInjected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @LazyInjected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @LazyInjected(\.widgetRowModelBuilder)
    private var widgetRowModelBuilder: any WidgetRowModelBuilderProtocol

    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()

    private let subscriptionId = "ObjectTypeWidget-\(UUID().uuidString)"
    private var isImageType: Bool = false
    private var chatPreviews: [ChatMessagePreview] = []

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
        async let chatPreviewsSub: () = startChatPreviewsSubscription()

        _ = await (typeSub, objectSub, chatPreviewsSub)
    }
    
    private func startTypeSubscription() async {
        for await type in objectTypeProvider.objectTypePublisher(typeId: info.objectTypeId).values {
            isImageType = type.isImageLayout
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequenceWithEmpty {
            chatPreviews = previews
        }
    }

    // MARK: - Private
    
    private func startObjectsSubscription() async {
        do {
            try await setDocument.open()

            let spaceUxType = await spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)?.uxType
            let subscriptionData = setSubscriptionDataBuilder.set(
                SetSubscriptionData(
                    identifier: subscriptionId,
                    document: setDocument,
                    groupFilter: nil,
                    currentPage: 0,
                    numberOfRowsPerPage: 6,
                    collectionId: nil,
                    objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId),
                    spaceUxType: spaceUxType
                )
            )
            
            try await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData)
            
            for await state in subscriptionStorage.statePublisher.values {
                let spaceView = await spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)
                let rowDetails = setObjectWidgetOrderHelper.reorder(
                    setDocument: setDocument,
                    subscriptionStorage: subscriptionStorage,
                    details: state.items,
                    chatPreviews: chatPreviews,
                    spaceView: spaceView,
                    onItemTap: { [weak self] details, _ in
                        Task {
                            let onTap = await self?.onTap
                            onTap?(details)
                        }
                    }
                )
                await updateRows(rowDetails: rowDetails, spaceView: spaceView, availableMoreObjects: state.total > state.items.count)
            }
            
        } catch {}
    }
    
    private func updateRows(rowDetails: [SetContentViewItemConfiguration], spaceView: SpaceView?, availableMoreObjects: Bool) async {
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
            rows = .gallery(rows: galleryRows, availableMoreObjects: availableMoreObjects)
        } else {
            switch setDocument.activeView.type {
            case .table, .list, .kanban, .calendar, .graph:
                let listRows = await widgetRowModelBuilder.buildListRows(
                    from: rowDetails,
                    spaceView: spaceView,
                    chatPreviews: chatPreviews
                )
                rows = .compactList(rows: listRows, availableMoreObjects: availableMoreObjects)
            case .gallery:
                let galleryRows = rowDetails.map { GalleryWidgetRowModel(details: $0) }
                rows = .gallery(rows: galleryRows, availableMoreObjects: availableMoreObjects)
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

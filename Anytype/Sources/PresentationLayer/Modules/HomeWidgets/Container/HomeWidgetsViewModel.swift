import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
@Observable
final class HomeWidgetsViewModel {

    private enum Constants {
        static let pinnedSectionId = "HomePinnedSection"
        static let objectTypeSectionId = "HomeObjectTypeSection"
    }
    
    // MARK: - DI
    
    let info: AccountInfo
    let widgetObject: any BaseDocumentProtocol
    
    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionService: any ObjectActionsServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    @Injected(\.accountParticipantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.homeWidgetsRecentStateManager) @ObservationIgnored
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectTypeService) @ObservationIgnored
    private var objectTypeService: any ObjectTypeServiceProtocol
    @Injected(\.expandedService) @ObservationIgnored
    private var expandedService: any ExpandedServiceProtocol
    
    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?
    @ObservationIgnored
    private var typesDropTask: Task<Void, any Error>?
    
    // MARK: - State
    
    var widgetBlocks: [BlockWidgetInfo] = []
    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var homeState: HomeWidgetsState = .readonly
    var widgetsDataLoaded: Bool = false
    var objectTypesDataLoaded: Bool = false
    var wallpaper: SpaceWallpaperType = .default
    var pinnedSectionIsExpanded: Bool = false
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false
    var chatWidgetData: SpaceChatWidgetData?
    
    var spaceId: String { info.accountSpaceId }
    
    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        self.widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.pinnedSectionIsExpanded = expandedService.isExpanded(id: Constants.pinnedSectionId, defaultValue: true)
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
    }
    
    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let participantTask: () = startParticipantTask()
        async let objectTypesTask: () = startObjectTypesTask()
        async let spaceViewTask: () = startSpaceViewTask()
        
        _ = await (widgetObjectSub, participantTask, objectTypesTask, spaceViewTask)
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }
    
    func widgetsDropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func widgetsDropFinish(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        AnytypeAnalytics.instance().logReorderWidget(source: from.data.source.analyticsSource)
        Task {
            try? await objectActionService.move(
                dashboadId: widgetObject.objectId,
                blockId: from.data.id,
                dropPositionblockId: to.data.id,
                position: to.index > from.index ? .bottom : .top
            )
        }
    }
    
    func typesDropUpdate(from: DropDataElement<ObjectTypeWidgetInfo>, to: DropDataElement<ObjectTypeWidgetInfo>) {
        objectTypeWidgets.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func typesDropFinish(from: DropDataElement<ObjectTypeWidgetInfo>, to: DropDataElement<ObjectTypeWidgetInfo>) {
        typesDropTask?.cancel()
        typesDropTask = Task {
            // Middleware notify state with delay and we ome time show old state. Making fewer requests
            try await Task.sleep(seconds: 2)
            let typeIds = objectTypeWidgets.map { $0.objectTypeId }
            try await objectTypeService.setOrder(spaceId: spaceId, typeIds: typeIds)
        }
    }
    
    func onSpaceSelected() {
        output?.onSpaceSelected()
    }
    
    func onCreateObjectType() {
        output?.onCreateObjectType()
    }
    
    func onTapPinnedHeader() {
        withAnimation {
            pinnedSectionIsExpanded = !pinnedSectionIsExpanded
        }
        expandedService.setState(id: Constants.pinnedSectionId, isExpanded: pinnedSectionIsExpanded)
    }
    
    func onTapObjectTypeHeader() {
        withAnimation {
            objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        }
        expandedService.setState(id: Constants.objectTypeSectionId, isExpanded: objectTypeSectionIsExpanded)
    }
    
    // MARK: - Private
    
    private func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            widgetsDataLoaded = true
            
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            
            var newWidgetBlocks = blocks
                .compactMap { widgetObject.widgetInfo(block: $0) }
            
            newWidgetBlocks.removeAll { $0.source == .library(.chat) }
            
            if FeatureFlags.homeObjectTypeWidgets {
                newWidgetBlocks.removeAll { $0.source == .library(.allObjects) || $0.source == .library(.bin) }
            }
            
            guard widgetBlocks != newWidgetBlocks else { continue }
            
            widgetBlocks = newWidgetBlocks
        }
    }
    
    private func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            homeState = canEdit ? .readwrite : .readonly
            canCreateObjectType = canEdit
        }
    }
    
    private func startObjectTypesTask() async {
        guard FeatureFlags.homeObjectTypeWidgets else { return }
        let spaceId = spaceId
        
        let stream = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
            .values
            .map { objects in
                let objects = objects
                    .filter { ($0.recommendedLayout.map { DetailsLayout.widgetTypeLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                return objects.map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
        
        for await objectTypes in stream {
            objectTypesDataLoaded = true
            objectTypeWidgets = objectTypes
        }
    }
    
    private func startSpaceViewTask() async {
        for await showChat in workspaceStorage.spaceViewPublisher(spaceId: spaceId).map(\.canShowChatWidget).removeDuplicates().values {
            chatWidgetData = showChat ? SpaceChatWidgetData(spaceId: spaceId, output: output) : nil
        }
    }
}

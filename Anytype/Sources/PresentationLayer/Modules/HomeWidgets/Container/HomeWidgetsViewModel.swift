import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    // MARK: - DI
    
    let info: AccountInfo
    let widgetObject: any BaseDocumentProtocol
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.homeWidgetsRecentStateManager)
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State
    
    private let showSpaceChat: Bool
    
    @Published var widgetBlocks: [BlockWidgetInfo] = []
    @Published var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var dataLoaded: Bool = false
    @Published var wallpaper: SpaceWallpaperType = .default
    
    var spaceId: String { info.accountSpaceId }
    
    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        self.widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.showSpaceChat = workspaceStorage.spaceView(spaceId: info.accountSpaceId).map { !$0.initialScreenIsChat } ?? false
    }
    
    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let participantTask: () = startParticipantTask()
        async let objectTypesTask: () = startObjectTypesTask()
        
        (_, _, _) = await (widgetObjectSub, participantTask, objectTypesTask)
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }
    
    func onEditButtonTap() {
        AnytypeAnalytics.instance().logEditWidget()
        homeState = .editWidgets
    }
    
    func dropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func dropFinish(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
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
    
    func onSpaceSelected() {
        output?.onSpaceSelected()
    }
    
    func onCreateWidgetFromEditMode() {
        AnytypeAnalytics.instance().logClickAddWidget(context: .editor)
        output?.onCreateWidgetSelected(context: .editor)
    }
    
    func onCreateWidgetFromMainMode() {
        AnytypeAnalytics.instance().logClickAddWidget(context: .main)
        output?.onCreateWidgetSelected(context: .main)
    }
    
    func onCreateObjectType() {
        output?.onCreateObjectType()
    }
    
    // MARK: - Private
    
    private func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            dataLoaded = true
            
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            
            var newWidgetBlocks = blocks
                .compactMap { widgetObject.widgetInfo(block: $0) }
            
            let chatWidgets = newWidgetBlocks.filter { $0.source == .library(.chat) }
            
            newWidgetBlocks.removeAll { $0.source == .library(.chat) }
            
            if showSpaceChat && FeatureFlags.chatInDataSpace {
                newWidgetBlocks.insert(contentsOf: chatWidgets, at: 0)
            }
            
            if FeatureFlags.homeObjectTypeWidgets {
                newWidgetBlocks.removeAll { $0.source == .library(.allObjects) }
            }
            
            guard widgetBlocks != newWidgetBlocks else { continue }
            
            widgetBlocks = newWidgetBlocks
            
            // Reset panel for empty state
            if newWidgetBlocks.isEmpty && homeState == .editWidgets {
                homeState = .readwrite
            }
        }
    }
    
    private func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            homeState = canEdit ? .readwrite : .readonly
        }
    }
    
    private func startObjectTypesTask() async {
        guard FeatureFlags.homeObjectTypeWidgets else { return }
        let spaceId = spaceId
        
        let stream = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
            .values
            .map { objects in
                let objects = objects.filter { $0.recommendedLayout.map { DetailsLayout.widgetTypeLayouts.contains($0) } ?? false }
                return objects.map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
        
        for await objectTypes in stream {
            objectTypeWidgets = objectTypes
        }
    }
}

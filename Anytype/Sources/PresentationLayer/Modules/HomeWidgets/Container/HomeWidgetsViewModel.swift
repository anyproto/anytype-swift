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
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.homeWidgetsRecentStateManager)
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State
    
    @Published var widgetBlocks: [BlockWidgetInfo] = []
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
    }
    
    func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            dataLoaded = true
            
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            
            let newWidgetBlocks = blocks.compactMap { widgetObject.widgetInfo(block: $0) }
            
            guard widgetBlocks != newWidgetBlocks else { continue }
            
            widgetBlocks = newWidgetBlocks
            
            // Reset panel for empty state
            if newWidgetBlocks.isEmpty && homeState == .editWidgets {
                homeState = .readwrite
            }
        }
    }
    
    func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            homeState = canEdit ? .readwrite : .readonly
        }
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
    
    func submoduleOutput() -> (any CommonWidgetModuleOutput)? {
        output
    }
    
    func onCreateWidgetFromEditMode() {
        AnytypeAnalytics.instance().logClickAddWidget(context: .editor)
        output?.onCreateWidgetSelected(context: .editor)
    }
    
    func onCreateWidgetFromMainMode() {
        AnytypeAnalytics.instance().logClickAddWidget(context: .main)
        output?.onCreateWidgetSelected(context: .main)
    }
}

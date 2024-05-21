import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    // MARK: - DI
    
    private let info: AccountInfo
    
    let widgetObject: BaseDocumentProtocol
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: ObjectActionsServiceProtocol
    private let documentService: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: AccountParticipantsStorageProtocol
    
    private let recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol
    
    weak var output: HomeWidgetsModuleOutput?
    
    // MARK: - State
    
    @Published var widgetBlocks: [BlockWidgetInfo] = []
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var dataLoaded: Bool = false
    @Published var wallpaper: BackgroundType = .default
    
    var spaceId: String { info.accountSpaceId }
    
    init(
        info: AccountInfo,
        recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.info = info
        self.recentStateManagerProtocol = recentStateManagerProtocol
        self.output = output
        self.widgetObject = documentService.document(objectId: info.widgetsId)
        subscribeOnWallpaper()
    }
    
    func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManagerProtocol.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            
            let newWidgetBlocks = blocks.compactMap { widgetObject.widgetInfo(block: $0) }
            
            guard widgetBlocks != newWidgetBlocks else { continue }
            
            widgetBlocks = newWidgetBlocks
            dataLoaded = true
        }
    }
    
    func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            homeState = canEdit ? .readwrite : .readonly
        }
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
    
    func submoduleOutput() -> CommonWidgetModuleOutput? {
        output
    }
    
    func onCreateWidgetSelected() {
        output?.onCreateWidgetSelected(context: .editor)
    }
    
    // MARK: - Private
    
    private func subscribeOnWallpaper() {
        UserDefaultsConfig.wallpaperPublisher(spaceId: info.accountSpaceId)
            .receiveOnMain()
            .assign(to: &$wallpaper)
    }
}

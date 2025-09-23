import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private enum Constants {
        static let pinnedSectionId = "HomePinnedSection"
        static let objectTypeSectionId = "HomeObjectTypeSection"
    }
    
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
    @Injected(\.objectTypeService)
    private var objectTypeService: any ObjectTypeServiceProtocol
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol
    
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State
    
    private let showSpaceChat: Bool
    
    @Published var widgetBlocks: [BlockWidgetInfo] = []
    @Published var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var widgetsDataLoaded: Bool = false
    @Published var objectTypesDataLoaded: Bool = false
    @Published var wallpaper: SpaceWallpaperType = .default
    @Published var pinnedSectionIsExpanded: Bool = false
    @Published var objectTypeSectionIsExpanded: Bool = false
    @Published var canCreateObjectType: Bool = false
    
    var spaceId: String { info.accountSpaceId }
    
    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        self.widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.showSpaceChat = workspaceStorage.spaceView(spaceId: info.accountSpaceId).map { !$0.initialScreenIsChat } ?? false
        self.pinnedSectionIsExpanded = expandedService.isExpanded(id: Constants.pinnedSectionId, defaultValue: true)
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
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
        Task {
            let typeIds = objectTypeWidgets.map { $0.objectTypeId }
            try await objectTypeService.setOrder(spaceId: spaceId, typeIds: typeIds)
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
            
            let chatWidgets = newWidgetBlocks.filter { $0.source == .library(.chat) }
            
            newWidgetBlocks.removeAll { $0.source == .library(.chat) }
            
            if showSpaceChat && FeatureFlags.chatInDataSpace {
                newWidgetBlocks.insert(contentsOf: chatWidgets, at: 0)
            }
            
            if FeatureFlags.homeObjectTypeWidgets {
                newWidgetBlocks.removeAll { $0.source == .library(.allObjects) || $0.source == .library(.bin) }
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
}

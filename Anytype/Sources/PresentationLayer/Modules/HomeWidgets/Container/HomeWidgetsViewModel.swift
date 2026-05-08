import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI
import AsyncAlgorithms

@MainActor
@Observable
final class HomeWidgetsViewModel {

    private enum Constants {
        static let objectTypeSectionId = "HomeObjectTypeSection"
        static let myFavoritesSectionId = "HomeMyFavoritesSection"
        static let recentlyEditedSectionId = "HomeRecentlyEditedSection"
    }
    
    // MARK: - DI

    let info: AccountInfo
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol

    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.expandedService) @ObservationIgnored
    private var expandedService: any ExpandedServiceProtocol
    @Injected(\.objectTypesWithObjectsCreatedService) @ObservationIgnored
    private var objectTypesWithObjectsCreatedService: any ObjectTypesWithObjectsCreatedServiceProtocol
    @Injected(\.homeSectionsStorage) @ObservationIgnored
    private var homeSectionsStorage: any HomeSectionsStorageProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State

    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var homeState: HomeWidgetsState = .readonly
    var objectTypesDataLoaded: Bool = false
    var wallpaper: SpaceWallpaperType = .default
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false
    var homeWidgetData: HomepageWidgetViewData?
    var myFavoritesSectionIsExpanded: Bool = false
    var myFavoritesListViewModel: MyFavoritesListViewModel
    var recentlyEditedSectionIsExpanded: Bool = false
    var recentlyEditedListViewModel: RecentlyEditedListViewModel
    var sectionsConfiguration: HomeSectionsConfiguration = .default

    var spaceId: String { info.accountSpaceId }

    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        let channelWidgetsObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.channelWidgetsObject = channelWidgetsObject
        let personalWidgetsObject = documentService.document(
            objectId: info.personalWidgetsId,
            spaceId: info.accountSpaceId
        )
        self.personalWidgetsObject = personalWidgetsObject
        self.myFavoritesListViewModel = MyFavoritesListViewModel(
            spaceId: info.accountSpaceId,
            personalWidgetsObject: personalWidgetsObject,
            channelWidgetsObject: channelWidgetsObject,
            onObjectSelected: { [weak output] details in
                output?.onObjectSelected(screenData: details.screenData())
            }
        )
        self.recentlyEditedListViewModel = RecentlyEditedListViewModel(
            spaceId: info.accountSpaceId,
            onObjectSelected: { [weak output] details in
                output?.onObjectSelected(screenData: details.screenData())
            }
        )
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
        self.myFavoritesSectionIsExpanded = expandedService.isExpanded(id: Constants.myFavoritesSectionId, defaultValue: true)
        self.recentlyEditedSectionIsExpanded = expandedService.isExpanded(id: Constants.recentlyEditedSectionId, defaultValue: true)
    }

    func startSubscriptions() async {
        async let myFavoritesSub: () = startMyFavoritesTask()
        async let recentlyEditedSub: () = startRecentlyEditedTask()
        async let canEditSub: () = startCanEditSubscription()
        async let objectTypesTask: () = startObjectTypesTask()
        async let spaceViewTask: () = startSpaceViewTask()
        async let sectionsConfigurationTask: () = startSectionsConfigurationTask()

        _ = await (myFavoritesSub, recentlyEditedSub, canEditSub, objectTypesTask, spaceViewTask, sectionsConfigurationTask)
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }

    func onSpaceSelected() {
        output?.onSpaceSelected()
    }

    func onMembersSelected(spaceId: String, route: SettingsSpaceShareRoute) {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: route)
    }

    func onQrCodeSelected(url: URL) {
        output?.onSpaceChatShowQrCodeSelected(url: url)
    }

    func onManageSectionsSelected() {
        output?.onManageSectionsSelected()
    }

    func onCreateObjectType() {
        output?.onCreateObjectType()
    }
    
    func onTapObjectTypeHeader() {
        withAnimation {
            objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        }
        expandedService.setState(id: Constants.objectTypeSectionId, isExpanded: objectTypeSectionIsExpanded)
    }

    func onTapMyFavoritesHeader() {
        withAnimation {
            myFavoritesSectionIsExpanded = !myFavoritesSectionIsExpanded
        }
        expandedService.setState(id: Constants.myFavoritesSectionId, isExpanded: myFavoritesSectionIsExpanded)
    }

    func onTapRecentlyEditedHeader() {
        withAnimation {
            recentlyEditedSectionIsExpanded = !recentlyEditedSectionIsExpanded
        }
        expandedService.setState(id: Constants.recentlyEditedSectionId, isExpanded: recentlyEditedSectionIsExpanded)
    }

    // MARK: - Private

    private func startMyFavoritesTask() async {
        await myFavoritesListViewModel.startSubscriptions()
    }

    private func startRecentlyEditedTask() async {
        await recentlyEditedListViewModel.startSubscriptions()
    }

    private func startSectionsConfigurationTask() async {
        for await configuration in homeSectionsStorage.configurationPublisher(spaceId: info.accountSpaceId).values {
            sectionsConfiguration = configuration
        }
    }

    private func startCanEditSubscription() async {
        for await canEdit in accountParticipantStorage.canEditSequence(spaceId: info.accountSpaceId) {
            homeState = canEdit ? .readwrite : .readonly
            canCreateObjectType = canEdit
        }
    }
    
    private func startObjectTypesTask() async {
        let spaceId = spaceId
        let spaceType = workspaceStorage.spaceView(spaceId: spaceId)?.spaceType
        let allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceType: spaceType)
        await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceType: spaceType)

        let typesPublisher = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
        let objectsCreatedPublisher = objectTypesWithObjectsCreatedService.typeIdsWithObjectsCreatedPublisher
        let alwaysVisibleKeys: Set<ObjectTypeUniqueKey> = [.page, .task, .collection]

        let stream = typesPublisher.combineLatest(objectsCreatedPublisher)
            .map { (types, typeIdsWithObjectsCreated) in
                types
                    .filter { ($0.recommendedLayout.map { allowedLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                    .filter { typeIdsWithObjectsCreated.contains($0.id) || alwaysVisibleKeys.contains($0.uniqueKey) }
                    .map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
            .values

        for await objectTypes in stream {
            objectTypesDataLoaded = true
            objectTypeWidgets = objectTypes
        }
    }

    private struct ObservedHomepage: Equatable {
        let objectId: String
        let canSetHomepage: Bool
    }

    private func startSpaceViewTask() async {
        var homepageTask: Task<Void, Never>?
        var lastObserved: ObservedHomepage?
        defer { homepageTask?.cancel() }

        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView

            // Home widget renders whichever object is set as homepage (Chat / Page / Collection).
            // 1-on-1 channels always home on Chat; `SpaceView.homepage` is unreliable there
            // (middleware may not populate it), so fall back to `info.spaceChatId`.
            let effectiveHomepage: SpaceHomepage = spaceView.isOneToOne && !info.spaceChatId.isEmpty
                ? .object(objectId: info.spaceChatId)
                : spaceView.homepage
            guard case let .object(objectId) = effectiveHomepage else {
                if lastObserved != nil {
                    homepageTask?.cancel()
                    homepageTask = nil
                    homeWidgetData = nil
                    lastObserved = nil
                }
                continue
            }

            // Only rebuild the observer when the observed tuple actually changes. Unrelated
            // SpaceView emissions (rename, member added, etc.) must not cancel the task or
            // clear homeWidgetData — doing so causes flicker/disappearance of the widget.
            let next = ObservedHomepage(objectId: objectId, canSetHomepage: participantSpaceView.canSetHomepage)
            guard lastObserved != next else { continue }

            // Subscribe to the homepage object's details so the widget hides upstream when the
            // object is archived, deleted, or fails to open. When details change (e.g. ownership
            // via canSetHomepage), re-emitting HomepageWidgetViewData propagates to the child.
            homepageTask?.cancel()
            // Clear stale data synchronously so a slow/failed `document.open()` for the new object
            // doesn't leave the previous homepage's widget visible and tappable.
            homeWidgetData = nil
            lastObserved = next
            homepageTask = Task { [weak self] in
                await self?.observeHomepageObject(objectId: next.objectId, canSetHomepage: next.canSetHomepage)
            }
        }
    }

    private func observeHomepageObject(objectId: String, canSetHomepage: Bool) async {
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await document.open()
        for await _ in document.syncPublisher.values {
            guard !Task.isCancelled else { return }
            let details = document.details
            if let details, !details.isArchivedOrDeleted {
                homeWidgetData = HomepageWidgetViewData(
                    spaceId: spaceId,
                    objectId: objectId,
                    canSetHomepage: canSetHomepage,
                    document: document,
                    output: output,
                    onChangeHome: { [weak self] in
                        self?.output?.onChangeHome()
                    },
                    onHomeTap: { [weak self] screenData in
                        self?.output?.onHomeObjectSelected(screenData: screenData)
                    }
                )
            } else {
                homeWidgetData = nil
            }
        }
    }

}

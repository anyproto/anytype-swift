import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

@MainActor
final class ListWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let internalModel: any WidgetInternalViewModelProtocol
    private let internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    
    // MARK: - State
    
    private var rowDetails: [ObjectDetails]?
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    var dragId: String? { widgetBlockId }
    
    @Published private(set) var headerItems: [ViewWidgetTabsItemModel]?
    @Published private(set) var rows: [ListWidgetRowModel]?
    let style: ListWidgetStyle
    var allowCreateObject: Bool { internalModel.allowCreateObject }
    
    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        style: ListWidgetStyle,
        internalModel: any WidgetInternalViewModelProtocol,
        internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.style = style
        self.internalModel = internalModel
        self.internalHeaderModel = internalHeaderModel
        self.output = output
        startHeaderSubscription()
        startContentSubscription()
    }
    
    func onHeaderTap() {
        guard let screenData = internalModel.screenData() else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: internalModel.analyticsSource())
        output?.onObjectSelected(screenData: screenData)
    }
    
    func onCreateObjectTap() {
        internalModel.onCreateObjectTap()
    }
    
    // MARK: - Private

    private func startHeaderSubscription() {
        setupAllSubscriptions()
        internalModel.startHeaderSubscription()
    }
    
    private func startContentSubscription() {
        Task {
            await internalModel.startContentSubscription()
        }
    }
    
    private func setupAllSubscriptions() {
        
        internalModel.namePublisher
            .receiveOnMain()
            .assign(to: &$name)
        
        internalModel.detailsPublisher
            .receiveOnMain()
            .sink { [weak self] details in
                self?.rowDetails = details
                self?.updateViewState()
            }
            .store(in: &subscriptions)
        
        internalHeaderModel?.dataviewPublisher
            .receiveOnMain()
            .sink { [weak self] dataview in
                self?.updateHeader(dataviewState: dataview)
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewState() {
        withAnimation(rows.isNil ? nil : .default) {
            rows = rowDetails?.map { details in
                ListWidgetRowModel(
                    details: details,
                    onTap: { [weak self] _ in
                        self?.handleTapOnObject(details: details)
                    }
                )
            }
        }
    }
    
    private func updateHeader(dataviewState: WidgetDataviewState?) {
        withAnimation(headerItems.isNil ? nil : .default) {
            headerItems = dataviewState?.dataview.map { dataView in
                ViewWidgetTabsItemModel(
                    dataviewId: dataView.id,
                    title: dataView.nameWithPlaceholder,
                    isSelected: dataView.id == dataviewState?.activeViewId,
                    onTap: { [weak self] in
                        self?.internalHeaderModel?.onActiveViewTap(dataView.id)
                    }
                )
            }
        }
    }
    
    private func handleTapOnObject(details: ObjectDetails) {
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logOpenSidebarObject(createType: info.widgetCreateType)
        output?.onObjectSelected(screenData: details.screenData())
    }
}

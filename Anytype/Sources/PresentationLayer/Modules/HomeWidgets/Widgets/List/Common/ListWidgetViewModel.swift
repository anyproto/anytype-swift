import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

@MainActor
final class ListWidgetViewModel: WidgetContainerContentViewModelProtocol, ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let internalModel: any WidgetInternalViewModelProtocol
    private let internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var rowDetails: [ObjectDetails]?
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    var dragId: String? { widgetBlockId }
    
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model]?
    @Published private(set) var rows: [ListWidgetRowModel]?
    let emptyTitle = Loc.Widgets.Empty.title
    let style: ListWidgetStyle
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        internalModel: any WidgetInternalViewModelProtocol,
        internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?,
        objectActionsService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.style = style
        self.internalModel = internalModel
        self.internalHeaderModel = internalHeaderModel
        self.objectActionsService = objectActionsService
        self.output = output
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    func startHeaderSubscription() {
        setupAllSubscriptions()
        internalModel.startHeaderSubscription()
    }
    
    func stopHeaderSubscription() {
        subscriptions.removeAll()
        internalModel.stopHeaderSubscription()
    }
    
    func startContentSubscription() {
        internalModel.startContentSubscription()
    }

    func stopContentSubscription() {
        internalModel.stopContentSubscription()
    }
    
    func onHeaderTap() {
        guard let screenData = internalModel.screenData() else { return }
        AnytypeAnalytics.instance().logSelectHomeTab(source: internalModel.analyticsSource())
        output?.onObjectSelected(screenData: screenData)
    }
    
    // MARK: - Private
    
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
        withAnimation {
            rows = rowDetails?.map { details in
                ListWidgetRowModel(
                    details: details,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: $0)
                    },
                    onIconTap: { [weak self] in
                        self?.updateDone(details: details)
                    }
                )
            }
        }
    }
    
    private func updateHeader(dataviewState: WidgetDataviewState?) {
        withAnimation {
            headerItems = dataviewState?.dataview.map { dataView in
                ListWidgetHeaderItem.Model(
                    dataviewId: dataView.id,
                    title: dataView.name,
                    isSelected: dataView.id == dataviewState?.activeViewId,
                    onTap: { [weak self] in
                        self?.internalHeaderModel?.onActiveViewTap(dataView.id)
                    }
                )
            }
        }
    }
    
    private func updateDone(details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        
        Task {
            try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.done(!details.done)])
        }
    }
}

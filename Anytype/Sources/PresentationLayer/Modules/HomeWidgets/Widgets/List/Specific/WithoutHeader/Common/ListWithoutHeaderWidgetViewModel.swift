import Foundation
import BlocksModels
import Combine
import SwiftUI

@MainActor
final class ListWithoutHeaderWidgetViewModel: ListWidgetViewModelProtocol, WidgetContainerContentViewModelProtocol, ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let internalModel: any WidgetInternalViewModelProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var rowDetails: [ObjectDetails] = []
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    @Published private(set) var name: String = ""
    var dragId: String? { widgetBlockId }
    
    // MARK: - ListWidgetViewModelProtocol
    
    let headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model]?
    let emptyTitle = Loc.Widgets.Empty.title
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        internalModel: any WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.internalModel = internalModel
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
            .assign(to: &$name)
        
        internalModel.detailsPublisher
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] details in
                self?.rowDetails = details
                self?.updateViewState()
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewState() {
        withAnimation {
            rows = rowDetails.map { details in
                ListWidgetRow.Model(
                    details: details,
                    onTap: { [weak self] in
                        self?.output?.onObjectSelected(screenData: $0)
                    }
                )
            }
        }
    }
}

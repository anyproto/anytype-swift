
import BlocksModels
import Combine
import Foundation
import ProtobufMessages

extension HomeViewModel {
    struct NewPageData {
        let pageId: String
        var showingNewPage: Bool
    }
}

final class HomeViewModel: ObservableObject {
    @Published var cellData: [PageCellData] = []
    @Published var newPageData = NewPageData(pageId: "", showingNewPage: false)
    let coordinator: HomeCoordinator = ServiceLocator.shared.homeCoordinator()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = [AnyCancellable]()
    private var newPageSubscription: AnyCancellable?
            
    let document: BaseDocumentProtocol = BaseDocument()
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    
    init() {
        fetchDashboardData()
    }
    
    // MARK: - Public
    private func fetchDashboardData() {        
        dashboardService.openDashboard()
            .sinkWithDefaultCompletion("Subscribe dashboard events") { [weak self] serviceSuccess in
                self?.onOpenDashboard(serviceSuccess)
            }.store(in: &self.subscriptions)
    }
    
    func createNewPage() {
        guard let rootId = document.documentId else { return }
        
        newPageSubscription = dashboardService.createNewPage(contextId: rootId).receiveOnMain()
            .sinkWithDefaultCompletion("Create page") { [weak self] success in
            guard let self = self else {
                return
            }
            
            self.document.handle(events: .init(contextId: success.contextID, events: success.messages))
            
            guard let newBlockId = self.extractNewBlockId(serviceSuccess: success) else {
                assertionFailure("No new block id in create new page response")
                return
            }
            
            self.newPageData = NewPageData(pageId: newBlockId, showingNewPage: true)
        }
    }
    
    private func extractNewBlockId(serviceSuccess: ServiceSuccess) -> String? {
        let blockAdd = serviceSuccess.messages.compactMap { message -> Anytype_Event.Block.Add?  in
            if case let .blockAdd(value)? = message.value {
                return value
            }
            
            return nil
        }.first
        
        return blockAdd?.blocks.first?.link.targetBlockID
    }
    
    private func onOpenDashboard(_ serviceSuccess: ServiceSuccess) {
        document.updateBlockModelPublisher.receiveOnMain().sink { [weak self] updateResult in
            self?.onDashboardChange(updateResult: updateResult)
        }.store(in: &self.subscriptions)
        
        document.open(serviceSuccess)
    }
    
    private func onDashboardChange(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            self.cellData = self.cellDataBuilder.buldCellData(updateResult)
        case .update(let payload):
            payload.updatedIds.forEach { updateCellWithTargetId($0) }
        }
    }
    
    private func updateCellWithTargetId(_ blockId: BlockId) {
        guard let newDetails = document.getDetails(by: blockId)?.currentDetails else {
            assertionFailure("Could not find object with id: \(blockId)")
            return
        }

        cellData.enumerated()
            .first { $0.element.destinationId == blockId }
            .flatMap { offset, data in
                cellData[offset] = cellDataBuilder.updatedCellData(newDetails: newDetails, oldData: data)
            }
    }
}


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
    @Published fileprivate var cellData: [PageCellData] = []
    
    var favoritesCellData: [PageCellData] {
        cellData.filter{ $0.isArchived == false}
    }
    var archiveCellData: [PageCellData] {
        cellData.filter{ $0.isArchived == true}
    }
    
    @Published var newPageData = NewPageData(pageId: "", showingNewPage: false)
    let coordinator: HomeCoordinator = ServiceLocator.shared.homeCoordinator()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    private let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    
    private var subscriptions = [AnyCancellable]()
    private var newPageSubscription: AnyCancellable?
            
    let document: BaseDocumentProtocol = BaseDocument()
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    
    init() {
        fetchDashboardData()
    }
    
    private func fetchDashboardData() {        
        dashboardService.openDashboard()
            .sinkWithDefaultCompletion("Subscribe dashboard events") { [weak self] serviceSuccess in
                self?.onOpenDashboard(serviceSuccess)
            }.store(in: &self.subscriptions)
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
            cellData = cellDataBuilder.buldCellData(updateResult)
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

// MARK: - New page
extension HomeViewModel {
    func createNewPage() {
        guard let rootId = document.documentId else { return }
        
        newPageSubscription = dashboardService.createNewPage(contextId: rootId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("Create page") { [weak self] success in
                guard let self = self else {
                    return
                }

                self.document.handle(
                    events: PackOfEvents(contextId: success.contextID, events: success.messages)
                )

                guard let newBlockId = success.newBlockId else {
                    assertionFailure("No new block id in create new page response")
                    return
                }

                self.newPageData = NewPageData(pageId: newBlockId, showingNewPage: true)
        }
    }
}


// MARK: - CellDataManager
protocol PageCellDataManager {
    func onDrag(from: PageCellData, to: PageCellData) -> DropData.Direction?
    func onDrop(from: PageCellData, to: PageCellData, direction: DropData.Direction) -> Bool
}

extension HomeViewModel: PageCellDataManager {
    func onDrag(from: PageCellData, to: PageCellData) -> DropData.Direction? {
        guard from.id != to.id else {
            return nil
        }
        
        guard let fromIndex = cellData.index(id: from.id),
              let toIndex = cellData.index(id: to.id) else {
            return nil
        }
        
        let dropAfter = toIndex > fromIndex
        
        cellData.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: dropAfter ? toIndex + 1 : toIndex
        )
        
        return dropAfter ? .after : .before
    }
    
    func onDrop(from: PageCellData, to: PageCellData, direction: DropData.Direction) -> Bool {
        guard let homeBlockId = MiddlewareConfiguration.shared?.homeBlockID else {
            assertionFailure("Shared configuration is nil")
            return false
        }
        
        objectActionsService.move(
            dashboadId: homeBlockId,
            blockId: from.id,
            dropPositionblockId: to.id,
            position: direction.toBlockModel()
        )
        
        return true
    }
}

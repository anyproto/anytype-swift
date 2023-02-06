import Foundation
import Combine
import BlocksModels

final class WidgetObjectListViewModel<InternalModel: WidgetObjectListInternalViewModelProtocol>: ObservableObject {
    
    private let internalModel: InternalModel
    private weak var output: WidgetObjectListCommonModuleOutput?
    
    var title: String { internalModel.title }
    var editorViewType: EditorViewType { internalModel.editorViewType }
    @Published private(set) var rows: [ListRowConfiguration] = []
    
    private var rowDetails: [ObjectDetails] = []
    private var searchText: String?
    private var subscriptions = [AnyCancellable]()
    
    init(internalModel: InternalModel, output: WidgetObjectListCommonModuleOutput?) {
        self.internalModel = internalModel
        self.output = output
        internalModel.rowDetailsPublisher.sink { [weak self] data in
            self?.rowDetails = data
            self?.updateRows()
        }
        .store(in: &subscriptions)
    }
    
    func onAppear() {
        internalModel.onAppear()
    }
    
    func onDisappear() {
        internalModel.onDisappear()
    }
    
    func didAskToSearch(text: String) {
        searchText = text
        updateRows()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        
        var filteredDetails: [ObjectDetails]
        if let searchText = searchText?.lowercased(), searchText.isNotEmpty {
            filteredDetails = rowDetails.filter { $0.title.lowercased().contains(searchText) }
        } else {
            filteredDetails = rowDetails
        }
        
        rows = filteredDetails.map { details in
            ListRowConfiguration.widgetSearchConfiguration(
                objectDetails: details,
                onTap: { [weak self] screenData in
                    self?.output?.onObjectSelected(screenData: screenData)
                }
            )
        }
    }
}

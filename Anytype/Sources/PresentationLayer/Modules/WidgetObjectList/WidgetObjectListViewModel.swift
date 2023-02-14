import Foundation
import Combine
import BlocksModels

final class WidgetObjectListViewModel: ObservableObject {
    
    private let internalModel: WidgetObjectListInternalViewModelProtocol
    private weak var output: WidgetObjectListCommonModuleOutput?
    
    var title: String { internalModel.title }
    var editorViewType: EditorViewType { internalModel.editorViewType }
    @Published private(set) var rows: [ListRowConfiguration] = []
    
    private var rowDetails: [ObjectDetails] = []
    private var searchText: String?
    private var subscriptions = [AnyCancellable]()
    
    init(internalModel: WidgetObjectListInternalViewModelProtocol, output: WidgetObjectListCommonModuleOutput?) {
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
            filteredDetails = rowDetails.filter { $0.title.range(of: searchText, options: .caseInsensitive) != nil }
        } else {
            filteredDetails = rowDetails
        }
        
        rows = filteredDetails.map { details in
            ListRowConfiguration.widgetSearchConfiguration(
                objectDetails: details,
                showType: internalModel.showType,
                onTap: { [weak self] screenData in
                    self?.output?.onObjectSelected(screenData: screenData)
                }
            )
        }
    }
}

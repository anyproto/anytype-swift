import Foundation
import Combine
import BlocksModels
import UIKit

enum WidgetObjectListData {
    case list([ListSectionData<String?, WidgetObjectListRow>])
    case error(NewSearchError)
}

final class WidgetObjectListViewModel: ObservableObject, OptionsItemProvider, WidgetObjectListMenuOutput {
    
    // MARK: - DI
    
    private let internalModel: WidgetObjectListInternalViewModelProtocol
    private let bottomPanelManager: BrowserBottomPanelManagerProtocol?
    private let objectActionService: ObjectActionsServiceProtocol
    private let menuBuilder: WidgetObjectListMenuBuilderProtocol
    private weak var output: WidgetObjectListCommonModuleOutput?
    
    // MARK: - State
    
    var title: String { internalModel.title }
    var editorViewType: EditorViewType { internalModel.editorViewType }
    @Published private(set) var data: WidgetObjectListData = .list([])
    var editModel: WidgetObjectListEditMode { internalModel.editMode }
    @Published private(set) var selectButtonText: String = ""
    @Published private(set) var showActionPanel: Bool = false
    var contentIsNotEmpty: Bool { rowDetails.contains { $0.details.isNotEmpty } }
    var isSheet: Bool
    
    private var rowDetails: [WidgetObjectListDetailsData] = []
    private var searchText: String?
    private var subscriptions = [AnyCancellable]()
    private var selectedRowIds: Set<String> = [] {
        didSet { updateView() }
    }
    
    // MARK: - OptionsItemProvider
    
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $options.eraseToAnyPublisher() }
    @Published var options = [SelectionOptionsItemViewModel]()
    
    init(
        internalModel: WidgetObjectListInternalViewModelProtocol,
        bottomPanelManager: BrowserBottomPanelManagerProtocol?,
        objectActionService: ObjectActionsServiceProtocol,
        menuBuilder: WidgetObjectListMenuBuilderProtocol,
        output: WidgetObjectListCommonModuleOutput?,
        isSheet: Bool = false
    ) {
        self.internalModel = internalModel
        self.bottomPanelManager = bottomPanelManager
        self.objectActionService = objectActionService
        self.menuBuilder = menuBuilder
        self.output = output
        self.isSheet = isSheet
        internalModel.rowDetailsPublisher.sink { [weak self] data in
            self?.rowDetails = data
            self?.validateSelectedIds()
            self?.updateView()
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
    
    func onSwitchEditMode() {
        selectedRowIds.removeAll()
    }
    
    func onSelectAll() {
        let allIds = makeAllSelectedIds()
        selectedRowIds = (selectedRowIds == allIds) ? [] : allIds
    }
    
    func onMove(from: IndexSet, to: Int) {
        internalModel.onMove(from: from, to: to)
    }
    
    // MARK: - WidgetObjectListMenuOutput
    
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) {
        Task { try? await objectActionService.setFavorite(objectIds: objectIds, isFavorite) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) {
        Task { try? await objectActionService.setArchive(objectIds: objectIds, isArchived) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func delete(objectIds: [BlockId]) {
        Task { try? await objectActionService.delete(objectIds: objectIds) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        
        var filteredDetails: [WidgetObjectListDetailsData]
        
        if let searchText = searchText?.lowercased(), searchText.isNotEmpty {
            filteredDetails = rowDetails.map { section in
                var section = section
                section.details = section.details.filter { $0.title.range(of: searchText, options: .caseInsensitive) != nil }
                return section
            }
            .filter { $0.details.isNotEmpty }
        } else {
            filteredDetails = rowDetails
        }
        
        let rows = filteredDetails.map { section in
            ListSectionData(
                id: section.id ?? "\(section.details.hashValue)",
                data: section.title,
                rows: section.details.map { details in
                    WidgetObjectListRow(
                        data: ListWidgetRow.Model(
                            details: details,
                            subtitle: internalModel.subtitle(for: details),
                            isChecked: selectedRowIds.contains(details.id),
                            onTap: { [weak self] screenData in
                                self?.output?.onObjectSelected(screenData: screenData)
                            },
                            onCheckboxTap: { [weak self] in
                                self?.switchCheckbox(details: details)
                            }
                        ),
                        menu: menuBuilder.buildMenuItems(details: details, allowOptions: internalModel.availableMenuItems, output: self)
                    )
                }
            )
        }
        
        if let searchText, rows.isEmpty {
            data = .error(.noObjectError(searchText: searchText))
        } else {
            data = .list(rows)
        }
    }
    
    private func switchCheckbox(details: ObjectDetails) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        if selectedRowIds.contains(details.id) {
            selectedRowIds.remove(details.id)
        } else {
            selectedRowIds.insert(details.id)
        }
    }
    
    private func makeAllSelectedIds() -> Set<String> {
        return Set(rowDetails.flatMap { $0.details.map(\.id) })
    }
    
    private func updateSelectButtonTitle() {
        selectButtonText = (selectedRowIds == makeAllSelectedIds()) ? Loc.unselectAll : Loc.selectAll
    }
    
    private func updateActions() {
        let selectedDetails = rowDetails.flatMap { $0.details }.filter { selectedRowIds.contains($0.id) }
        options = menuBuilder.buildOptionsMenu(details: selectedDetails, allowOptions: internalModel.availableMenuItems, output: self)
    }
    
    private func validateSelectedIds() {
        let selectedDetails = rowDetails.flatMap { $0.details }.map { $0.id }
        selectedRowIds = selectedRowIds.filter { selectedDetails.contains($0) }
    }
    
    private func updateView() {
        updateRows()
        updateSelectButtonTitle()
        updateActions()
        showActionPanel = selectedRowIds.isNotEmpty
        bottomPanelManager?.setNavigationViewHidden(selectedRowIds.isNotEmpty, animated: false)
    }
}

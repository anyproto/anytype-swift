import Foundation
import Combine
import Services
import UIKit
import AnytypeCore
import SwiftUI

enum WidgetObjectListData {
    case list([ListSectionData<String?, WidgetObjectListRowModel>])
    case error(NewSearchError)
}

@MainActor
final class WidgetObjectListViewModel: ObservableObject, OptionsItemProvider, WidgetObjectListMenuOutput {
    
    // MARK: - DI
    
    private let internalModel: WidgetObjectListInternalViewModelProtocol
    private let objectActionService: ObjectActionsServiceProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let accountParticipantStorage: AccountParticipantsStorageProtocol
    private let menuBuilder: WidgetObjectListMenuBuilderProtocol
    private weak var output: WidgetObjectListCommonModuleOutput?
    
    // MARK: - State
    
    var title: String { internalModel.title }
    var editorScreenData: EditorScreenData { internalModel.editorScreenData }
    @Published private(set) var data: WidgetObjectListData = .list([])
    @Published private(set) var editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    @Published private(set) var selectButtonText: String = ""
    @Published private(set) var showActionPanel: Bool = false
    @Published private(set) var homeBottomPanelHiddel: Bool = false
    var contentIsNotEmpty: Bool { rowDetails.contains { $0.details.isNotEmpty } }
    var isSheet: Bool
    @Published var viewEditMode: EditMode = .inactive
    @Published private(set) var canEdit = false
    @Published var binAlertData: BinConfirmationAlertData? = nil
    @Published var forceDeleteAlertData: ForceDeleteAlertData?
    
    private var rowDetails: [WidgetObjectListDetailsData] = []
    private var searchText: String?
    private var subscriptions = [AnyCancellable]()
    private var participant: Participant?
    private var selectedRowIds: Set<String> = [] {
        didSet { updateView() }
    }
    
    // MARK: - OptionsItemProvider
    
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $options.eraseToAnyPublisher() }
    @Published var options = [SelectionOptionsItemViewModel]()
    
    init(
        internalModel: WidgetObjectListInternalViewModelProtocol,
        objectActionService: ObjectActionsServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        accountParticipantStorage: AccountParticipantsStorageProtocol,
        menuBuilder: WidgetObjectListMenuBuilderProtocol,
        output: WidgetObjectListCommonModuleOutput?,
        isSheet: Bool = false
    ) {
        self.internalModel = internalModel
        self.objectActionService = objectActionService
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.accountParticipantStorage = accountParticipantStorage
        self.menuBuilder = menuBuilder
        self.output = output
        self.isSheet = isSheet
        internalModel.rowDetailsPublisher
            .receiveOnMain()
            .sink { [weak self] data in
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
    
    func startParticipantTask() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId).values {
            self.participant = participant
            canEdit = participant.canEdit
            editMode = canEdit ? internalModel.editMode : .normal(allowDnd: false)
            viewEditMode = (editMode == .editOnly) ? .active : .inactive
            updateView()
        }
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
    
    func setFavorite(objectIds: [String], _ isFavorite: Bool) {
        AnytypeAnalytics.instance().logAddToFavorites(isFavorite)
        Task { try? await objectActionService.setFavorite(objectIds: objectIds, isFavorite) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func setArchive(objectIds: [String], _ isArchived: Bool) {
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
        Task { try? await objectActionService.setArchive(objectIds: objectIds, isArchived) }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func delete(objectIds: [String]) {
        binAlertData = BinConfirmationAlertData(ids: objectIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func forceDelete(objectIds: [String]) {
        forceDeleteAlertData = ForceDeleteAlertData(objectIds: objectIds)
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
                    WidgetObjectListRowModel(
                        objectId: details.id,
                        icon: details.objectIconImage,
                        title: details.title,
                        description: details.subtitle,
                        subtitle: internalModel.subtitle(for: details),
                        isChecked: selectedRowIds.contains(details.id),
                        menu: menuBuilder.buildMenuItems(
                            details: details,
                            allowOptions: internalModel.availableMenuItems,
                            participant: participant,
                            output: self
                        ),
                        onTap: { [weak self] in
                            self?.output?.onObjectSelected(screenData: details.editorScreenData())
                        },
                        onCheckboxTap: { [weak self] in
                            self?.switchCheckbox(details: details)
                        }
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
        options = menuBuilder.buildOptionsMenu(details: selectedDetails, allowOptions: internalModel.availableMenuItems, participant: participant, output: self)
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
        homeBottomPanelHiddel = selectedRowIds.isNotEmpty
    }
}

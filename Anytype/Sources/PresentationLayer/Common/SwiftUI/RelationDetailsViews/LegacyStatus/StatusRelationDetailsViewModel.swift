import Foundation
import SwiftUI
import Services
import FloatingPanel

@MainActor
final class StatusRelationDetailsViewModel: ObservableObject {
    
    @Published private(set) var currentStatusModel: StatusSearchRowView.Model?
    @Published var isSearchPresented: Bool = false
    var title: String { relation.name }
    
    let popupLayout = AnytypePopupLayoutType.constantHeight(height: 116, floatingPanelStyle: false)

    private var selectedStatus: Relation.Status.Option? {
        didSet {
            updateSelectedStatusViewModel()
        }
    }
    var isEditable: Bool {
        return relation.isEditable
    }
    private let details: ObjectDetails
    private let relation: Relation
    private let service: RelationsServiceProtocol
    private let searchService: SearchServiceProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let analyticsType: AnalyticsEventsRelationType
    private weak var popup: AnytypePopupProxy?
    
    init(
        details: ObjectDetails,
        selectedStatus: Relation.Status.Option?,
        relation: Relation,
        service: RelationsServiceProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        searchService: SearchServiceProtocol,
        analyticsType: AnalyticsEventsRelationType
    ) {
        self.details = details
        self.selectedStatus = selectedStatus
        
        self.relation = relation
        self.service = service
        self.searchService = searchService
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.analyticsType = analyticsType
        
        updateSelectedStatusViewModel()
    }
    
}

extension StatusRelationDetailsViewModel {
    
    func didTapAddButton() {
        isSearchPresented = true
    }
    
    func didTapClearButton() {
        Task {
            selectedStatus = nil
            try await service.updateRelation(objectId: details.id, relationKey: relation.key, value: nil)
            logChanges()
        }
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        newSearchModuleAssembly.statusSearchModule(
            spaceId: details.spaceId,
            relationKey: relation.key,
            selectedStatusesIds: selectedStatus.flatMap { [$0.id] } ?? []
        ) { [weak self] ids in
            Task { @MainActor [weak self] in
                try? await self?.handleSelectedOptionIds(ids)
            }
        } onCreate: { [weak self] title in
            self?.handleCreateOption(title: title)
        }
    }
    
}

private extension StatusRelationDetailsViewModel {
    
    func updateSelectedStatusViewModel() {
        currentStatusModel = selectedStatus.flatMap {
            StatusSearchRowView.Model(text: $0.text, color: $0.color)
        }
    }
    
    func handleSelectedOptionIds(_ ids: [String]) async throws {
        defer {
            isSearchPresented = false
        }
        
        guard let newStatusId = ids.first else { return }
        
        Task {
            try await service.updateRelation(objectId: details.id, relationKey: relation.key, value: newStatusId.protobufValue)
            
            let newStatus = try await searchService.searchRelationOptions(optionIds: [newStatusId], spaceId: details.spaceId).first
                .map { Relation.Status.Option(option: $0) }
            
            guard let newStatus = newStatus else {
                popup?.close()
                return
            }
            
            selectedStatus = newStatus
            logChanges()
        }
    }
    
    func handleCreateOption(title: String) {
        Task {
            let optionId = try await service.addRelationOption(spaceId: details.spaceId, relationKey: relation.key, optionText: title, color: nil)
            guard let optionId = optionId else { return }
            
            try? await handleSelectedOptionIds([optionId])
        }
    }
    
    func logChanges() {
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedStatus.isNil, type: analyticsType)
    }
}

extension StatusRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView:
                StatusRelationDetailsView(viewModel: self)
                .highPriorityGesture(
                    DragGesture()
                )
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}

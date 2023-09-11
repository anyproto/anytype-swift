import SwiftUI
import Combine
import Services

@MainActor
final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    @Published var focused = false
    @Published var defaultObjectValue = SetViewSettings.defaultObject.placeholder
    @Published var defaultTemplateValue = SetViewSettings.defaultTemplate.placeholder
    @Published var layoutValue = SetViewSettings.layout.placeholder
    @Published var relationsValue = SetViewSettings.relations.placeholder
    @Published var filtersValue = SetViewSettings.filters.placeholder
    @Published var sortsValue = SetViewSettings.sorts.placeholder
    @Published var settings: [SetViewSettings] = []
    
    let canBeDeleted: Bool
    
    private let setDocument: SetDocumentProtocol
    private let activeViewId: String
    private let dataviewService: DataviewServiceProtocol
    private let templatesInteractor: SetTemplatesInteractorProtocol
    private let templateInteractorProvider: TemplateSelectionInteractorProvider?
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    private var cancellables = [AnyCancellable]()
    
    private var activeView: DataviewView {
        setDocument.dataView.views.first { [weak self] view in
            guard let self else { return false }
            return view.id == activeViewId
        } ?? .empty
    }
    
    init(
        setDocument: SetDocumentProtocol,
        activeViewId: String,
        dataviewService: DataviewServiceProtocol,
        templatesInteractor: SetTemplatesInteractorProtocol,
        templateInteractorProvider: TemplateSelectionInteractorProvider?,
        output: SetViewSettingsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.activeViewId = activeViewId
        self.dataviewService = dataviewService
        self.templatesInteractor = templatesInteractor
        self.templateInteractorProvider = templateInteractorProvider
        self.output = output
        self.canBeDeleted = setDocument.dataView.views.count > 1
        self.debounceNameChanges()
        self.setupSubscriptions()
        self.setupTemplatesSubscriptions()
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        switch setting {
        case .defaultObject:
            output?.onDefaultObjectTap()
        case .defaultTemplate:
            output?.onDefaultObjectTap()
        case .layout:
            output?.onLayoutTap()
        case .relations:
            output?.onRelationsTap()
        case .filters:
            output?.onFiltersTap()
        case .sorts:
            output?.onSortsTap()
        }
    }
    
    func valueForSetting(_ setting: SetViewSettings) -> String {
        switch setting {
        case .defaultObject:
            return defaultObjectValue
        case .defaultTemplate:
            return defaultTemplateValue
        case .layout:
            return layoutValue
        case .relations:
            return relationsValue
        case .filters:
            return filtersValue
        case .sorts:
            return sortsValue
        }
    }
    
    func deleteView() {
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.deleteView(activeViewId)
            AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
        }
    }
    
    func duplicateView() {
        let source = setDocument.details?.setOf ?? []
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.createView(activeView, source: source)
            AnytypeAnalytics.instance().logDuplicateView(
                type: activeView.type.stringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
    
    private func setupSubscriptions() {
//        setDocument.dataviewPublisher.sink { [weak self] dataview in
//            let activeView = dataview.views.first { [weak self] view in
//                guard let self else { return false }
//                return view.id == activeViewId
//            } ?? .empty
//            self?.name = activeView.name
//            self?.layoutValue = activeView.type.name
//            self?.updateRelationsValue(with: activeView)
//            self?.updateDefaultObjectValue(with: activeView)
//        }.store(in: &cancellables)
        
        setDocument.syncPublisher.sink { [weak self] in
            self?.updateState()
        }.store(in: &cancellables)
        
        setDocument.detailsPublisher.sink { [weak self] details in
            guard let self else { return }
            if setDocument.isTypeSet() {
                checkTemplatesAvailablility(details: details)
            } else {
                settings = SetViewSettings.allCases.filter { $0 != .defaultTemplate }
            }
        }.store(in: &cancellables)
    }
    
    private func updateState() {
        let activeView = activeView
        name = activeView.name
        layoutValue = activeView.type.name
        updateRelationsValue(with: activeView)
        updateDefaultObjectValue(with: activeView)
        
        let sorts = setDocument.sorts(for: activeViewId)
        updateSortsValue(sorts)
        
        let filters = setDocument.filters(for: activeViewId)
        updateFiltersValue(filters)
        
    }
    
    private func setupTemplatesSubscriptions() {
        templateInteractorProvider?.userTemplates.sink { [weak self] templates in
            let defaultTemplate = templates.first(where: { $0.isDefault })
            
            let title: String
            
            if let defaultTemplate {
                switch defaultTemplate.mode {
                case .blank:
                    title = Loc.TemplateSelection.blankTemplate
                case let .installed(model):
                    title = model.title
                case .addTemplate:
                    title = ""
                }
            } else {
                title = Loc.TemplateSelection.blankTemplate
            }
            
            self?.updateDefaultTemplateValue(with: title)
        }.store(in: &cancellables)
        
    }
    
    private func updateDefaultTemplateValue(with title: String) {
        if defaultTemplateValue != title {
            defaultTemplateValue = title
        }
    }
    
    private func debounceNameChanges() {
        $name
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { [weak self] name in
                self?.activeView.name != name
            }
            .sink { [weak self] name in
                self?.updateView(with: name)
            }
            .store(in: &cancellables)
    }
    
    private func updateView(with name: String) {
        let newView = activeView.updated(name: name)
        Task {
            try await dataviewService.updateView(newView)
        }
    }
    
    private func updateDefaultObjectValue(with activeView: DataviewView) {
        guard !setDocument.isTypeSet(),
            defaultObjectValue == SetViewSettings.defaultObject.placeholder ||
                activeView.defaultObjectTypeID != activeView.defaultObjectTypeID else { return }
        let objectTypeId = activeView.defaultObjectTypeIDWithFallback
        Task { @MainActor in
            let objectDetails = try await templatesInteractor.objectDetails(for: objectTypeId)
            defaultObjectValue = objectDetails.name
        }
    }
    
    private func updateRelationsValue(with activeView: DataviewView) {
        let visibleRelations = setDocument.sortedRelations(for: activeView).filter { $0.option.isVisible }
        let value = updatedValue(count: visibleRelations.count, firstName: visibleRelations.first?.relationDetails.name)
        relationsValue = value ?? SetViewSettings.relations.placeholder
    }
    
    private func updateFiltersValue(_ filters: [SetFilter]) {
        let value = updatedValue(count: filters.count, firstName: filters.first?.relationDetails.name)
        filtersValue = value ?? SetViewSettings.filters.placeholder
    }
    
    private func updateSortsValue(_ sorts: [SetSort]) {
        let value = updatedValue(count: sorts.count, firstName: sorts.first?.relationDetails.name)
        sortsValue = value ?? SetViewSettings.sorts.placeholder
    }
    
    private func updatedValue(count: Int, firstName: String?) -> String? {
        if count == 1, let firstName {
            return firstName
        } else if count > 1 {
            return Loc.Set.View.Settings.Objects.Applied.title(count)
        } else {
            return nil
        }
    }
    
    func checkTemplatesAvailablility(details: ObjectDetails) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let isTemplatesAvailable = try await templatesInteractor.isTemplatesAvailableFor(
                setObject: details
            )
            settings = isTemplatesAvailable ?
            SetViewSettings.allCases.filter { $0 != .defaultObject } :
            SetViewSettings.allCases.filter { $0 != .defaultObject &&  $0 != .defaultTemplate}
        }
    }
}

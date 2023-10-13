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
    let mode: SetViewSettingsMode
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let dataviewService: DataviewServiceProtocol
    private let templatesInteractor: SetTemplatesInteractorProtocol
    private let setObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol?
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    private var cancellables = [AnyCancellable]()
    
    private var view: DataviewView = .empty
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        dataviewService: DataviewServiceProtocol,
        templatesInteractor: SetTemplatesInteractorProtocol,
        setObjectCreationSettingsInteractor: SetObjectCreationSettingsInteractorProtocol?,
        output: SetViewSettingsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.mode = mode
        self.dataviewService = dataviewService
        self.templatesInteractor = templatesInteractor
        self.setObjectCreationSettingsInteractor = setObjectCreationSettingsInteractor
        self.output = output
        self.canBeDeleted = setDocument.dataView.views.count > 1
        self.setupFocus()
        self.debounceNameChanges()
        self.setupSubscriptions()
        self.setupTemplatesSubscriptions()
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        switch setting {
        case .defaultObject, .defaultTemplate:
            output?.onDefaultSettingsTap()
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
            try await dataviewService.deleteView(viewId)
            AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
        }
    }
    
    func duplicateView() {
        let source = setDocument.details?.setOf ?? []
        Task { [weak self] in
            guard let self else { return }
            try await dataviewService.createView(view, source: source)
            AnytypeAnalytics.instance().logDuplicateView(
                type: view.type.stringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
    
    private func setupSubscriptions() {
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
        let prevObjectTypeId = view.defaultObjectTypeID ?? ""
        view = setDocument.view(by: viewId)
        
        name = view.name
        layoutValue = view.type.name
        updateRelationsValue()
        updateDefaultObjectValue(with: view, prevObjectTypeId: prevObjectTypeId)
        
        let sorts = setDocument.sorts(for: viewId)
        updateSortsValue(sorts)
        
        let filters = setDocument.filters(for: viewId)
        updateFiltersValue(filters)
    }
    
    private func setupTemplatesSubscriptions() {
        setObjectCreationSettingsInteractor?.userTemplates.sink { [weak self] templates in
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
    
    private func setupFocus() {
        focused = mode == .new
    }
    
    private func debounceNameChanges() {
        $name
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { [weak self] name in
                self?.view.name != name
            }
            .sink { [weak self] name in
                self?.updateView(with: name)
            }
            .store(in: &cancellables)
    }
    
    private func updateView(with name: String) {
        let newView = view.updated(name: name)
        Task {
            try await dataviewService.updateView(newView)
        }
    }
    
    private func updateDefaultObjectValue(with view: DataviewView, prevObjectTypeId: String) {
        guard !setDocument.isTypeSet(),
            defaultObjectValue == SetViewSettings.defaultObject.placeholder ||
                prevObjectTypeId != view.defaultObjectTypeID else { return }
        let objectType = try? setDocument.defaultObjectTypeForView(view)
        defaultObjectValue = objectType?.name ?? ""
    }
    
    private func updateRelationsValue() {
        let visibleRelations = setDocument.sortedRelations(for: viewId).filter { $0.option.isVisible }
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

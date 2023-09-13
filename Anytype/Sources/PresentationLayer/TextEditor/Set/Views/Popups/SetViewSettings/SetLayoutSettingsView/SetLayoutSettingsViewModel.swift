import SwiftUI
import Services
import Combine

@MainActor
final class SetLayoutSettingsViewModel: ObservableObject {
    @Published var selectedType: DataviewViewType = .table
    
    var types: [SetViewTypeConfiguration] {
        updatedTypes()
    }
    var settings: [SetViewSettingsItem] {
        updatedSettings()
    }
    
    private let setDocument: SetDocumentProtocol
    private weak var output: SetLayoutSettingsCoordinatorOutput?
    
    private var activeView: DataviewView = .empty
    private var cancellable: Cancellable?
    private let dataviewService: DataviewServiceProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        output: SetLayoutSettingsCoordinatorOutput?,
        dataviewService: DataviewServiceProtocol
    ) {
        self.setDocument = setDocument
        self.output = output
        self.dataviewService = dataviewService
        self.setupSubscription()
    }
    
    private func setupSubscription() {
        cancellable = setDocument.activeViewPublisher.sink { [weak self] activeView in
            guard let self else { return }
            self.activeView = activeView
            selectedType = activeView.type
        }
    }
    
    private func updatedTypes() -> [SetViewTypeConfiguration] {
        DataviewViewType.allCases.compactMap { viewType in
            guard viewType.isSupported else { return nil }
            let selected = viewType == selectedType
            return SetViewTypeConfiguration(
                id: viewType.name,
                icon: viewType.icon(selected: selected),
                name: viewType.name,
                isSelected: selected,
                onTap: { [weak self] in
                    guard let self else { return }
                    selectedType = viewType
                    let activeView = activeView.updated(type: selectedType)
                    updateView(activeView)
                }
            )
        }
    }
    
    private func updatedSettings() -> [SetViewSettingsItem] {
        selectedType.settings.compactMap { setting in
            switch setting {
            case .icon:
                return .toggle(SetViewSettingsToggleItem(
                    title: Loc.icon,
                    isSelected: !activeView.hideIcon,
                    onChange: { [weak self] show in
                        guard let self else { return }
                        let activeView = activeView.updated(hideIcon: !show)
                        updateView(activeView)
                    }
                ))
            case .cardSize:
                let options = DataviewViewSize.availableCases.compactMap { size in
                    SetViewSettingsContextItem.Option(
                        id: size.value,
                        onTap: { [weak self] in
                            guard let self else { return }
                            let activeView = activeView.updated(cardSize: size)
                            updateView(activeView)
                        }
                    )
                }
                return .context(SetViewSettingsContextItem(
                    title: Loc.Set.View.Settings.CardSize.title,
                    value: activeView.cardSize.value,
                    options: options
                ))
            case .imagePreview:
                return .value(SetViewSettingsValueItem(
                    title: Loc.Set.View.Settings.ImagePreview.title,
                    value: imagePreviewValue(),
                    onTap: { [weak self] in
                        self?.onImagePreviewTap()
                    }
                ))
            case .fitImage:
                return .toggle(SetViewSettingsToggleItem(
                    title: Loc.Set.View.Settings.ImageFit.title,
                    isSelected: activeView.coverFit,
                    onChange: { [weak self] fit in
                        guard let self else { return }
                        let activeView = activeView.updated(coverFit: fit)
                        updateView(activeView)
                    }
                ))
            case .colorColumns:
                return .toggle(SetViewSettingsToggleItem(
                    title: Loc.Set.View.Settings.GroupBackgroundColors.title,
                    isSelected: activeView.groupBackgroundColors,
                    onChange: { [weak self] colored in
                        guard let self else { return }
                        let activeView = activeView.updated(groupBackgroundColors: colored)
                        updateView(activeView)
                    }
                ))
            case .groupBy:
                return .value(SetViewSettingsValueItem(
                    title: Loc.Set.View.Settings.GroupBy.title,
                    value: groupByValue(with: activeView.groupRelationKey),
                    onTap: { [weak self] in
                        self?.onGroupByTap()
                    }
                ))
            }
        }
        
    }
    
    private func onImagePreviewTap() {
        output?.onImagePreviewTap { [weak self] key in
            guard let self else { return }
            let activeView = activeView.updated(coverRelationKey: key)
            updateView(activeView)
        }
    }
    
    private func onGroupByTap() {
        output?.onGroupByTap { [weak self] key in
            guard let self else { return }
            let activeView = activeView.updated(groupRelationKey: key)
            updateView(activeView)
        }
    }
    
    private func updateView(_ activeView: DataviewView) {
        if activeView.type != selectedType {
            AnytypeAnalytics.instance().logChangeViewType(type: selectedType.stringValue, objectType: setDocument.analyticsType)
        }
        Task {
            try await dataviewService.updateView(activeView)
        }
    }
    
    private func groupByValue(with key: String) -> String {
        setDocument.dataViewRelationsDetails.first { relation in
            relation.key == key
        }?.name ?? key
    }
    
    private func imagePreviewValue() -> String {
        imagePreviewValueFromCovers() ?? imagePreviewValueFromRelations() ?? ""
    }
    
    private func imagePreviewValueFromCovers() -> String? {
        SetViewSettingsImagePreviewCover.allCases.first { [weak self] cover in
            return cover.rawValue == self?.activeView.coverRelationKey
        }?.title
    }
    
    private func imagePreviewValueFromRelations() -> String? {
        setDocument.dataViewRelationsDetails.first { [weak self] relationDetails in
            return relationDetails.key == self?.activeView.coverRelationKey
        }?.name
    }
}

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
    private let viewId: String
    private weak var output: SetLayoutSettingsCoordinatorOutput?
    
    private var cancellable: Cancellable?
    
    @Injected(\.dataviewService)
    private var dataviewService: DataviewServiceProtocol
    
    private var view: DataviewView = .empty
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        output: SetLayoutSettingsCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.output = output
        self.setupSubscription()
    }
    
    private func setupSubscription() {
        cancellable = setDocument.syncPublisher.receiveOnMain().sink { [weak self] in
            guard let self else { return }
            view = setDocument.view(by: viewId)
            selectedType = view.type
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
                    let activeView = view.updated(type: selectedType)
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
                    isSelected: !view.hideIcon,
                    onChange: { [weak self] show in
                        guard let self else { return }
                        let activeView = view.updated(hideIcon: !show)
                        updateView(activeView)
                    }
                ))
            case .cardSize:
                let options = DataviewViewSize.availableCases.compactMap { size in
                    SetViewSettingsContextItem.Option(
                        id: size.value,
                        onTap: { [weak self] in
                            guard let self else { return }
                            let activeView = view.updated(cardSize: size)
                            updateView(activeView)
                        }
                    )
                }
                return .context(SetViewSettingsContextItem(
                    title: Loc.Set.View.Settings.CardSize.title,
                    value: view.cardSize.value,
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
                    isSelected: view.coverFit,
                    onChange: { [weak self] fit in
                        guard let self else { return }
                        let activeView = view.updated(coverFit: fit)
                        updateView(activeView)
                    }
                ))
            case .colorColumns:
                return .toggle(SetViewSettingsToggleItem(
                    title: Loc.Set.View.Settings.GroupBackgroundColors.title,
                    isSelected: view.groupBackgroundColors,
                    onChange: { [weak self] colored in
                        guard let self else { return }
                        let activeView = view.updated(groupBackgroundColors: colored)
                        updateView(activeView)
                    }
                ))
            case .groupBy:
                return .value(SetViewSettingsValueItem(
                    title: Loc.Set.View.Settings.GroupBy.title,
                    value: groupByValue(with: view.groupRelationKey),
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
            let activeView = view.updated(coverRelationKey: key)
            updateView(activeView)
        }
    }
    
    private func onGroupByTap() {
        output?.onGroupByTap { [weak self] key in
            guard let self else { return }
            let activeView = view.updated(groupRelationKey: key)
            updateView(activeView)
        }
    }
    
    private func updateView(_ activeView: DataviewView) {
        Task {
            try await dataviewService.updateView(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                view: activeView
            )
            AnytypeAnalytics.instance().logChangeViewType(type: selectedType.analyticStringValue, objectType: setDocument.analyticsType)
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
            return cover.rawValue == self?.view.coverRelationKey
        }?.title
    }
    
    private func imagePreviewValueFromRelations() -> String? {
        setDocument.dataViewRelationsDetails.first { [weak self] relationDetails in
            return relationDetails.key == self?.view.coverRelationKey
        }?.name
    }
}

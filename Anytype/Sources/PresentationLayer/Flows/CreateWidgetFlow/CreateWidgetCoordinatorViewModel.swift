import Foundation
import SwiftUI

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: CreateWidgetCoordinatorModel
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    // MARK: - State
    
    @Published var showWidgetTypeData: WidgetTypeModuleCreateModel?
    @Published var dismiss: Bool = false
    
    init(
        data: CreateWidgetCoordinatorModel,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.data = data
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }

    func makeWidgetSourceModule() -> AnyView {
        return newSearchModuleAssembly.widgetSourceSearchModule(
            data: WidgetSourceSearchModuleModel(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                context: data.context,
                onSelect: { [weak self] source in
                    self?.showSelectWidgetType(source: source)
                }
            )
        )
    }
    
    func makeWidgetTypeModule(data: WidgetTypeModuleCreateModel) -> AnyView {
        return widgetTypeModuleAssembly.makeCreateWidget(data: data)
    }
    
    // MARK: - Private
    
    private func showSelectWidgetType(source: WidgetSource) {
        showWidgetTypeData = WidgetTypeModuleCreateModel(
            widgetObjectId: data.widgetObjectId,
            source: source,
            position: data.position,
            context: data.context,
            onFinish: { [weak self] in
                self?.dismissForLegacyOS()
                self?.dismiss.toggle()
            }
        )
    }
    
    @available(iOS, deprecated: 16.4)
    private func dismissForLegacyOS() {
        if #available(iOS 16.4, *) {
        } else {
            showWidgetTypeData = nil
        }
    }
}

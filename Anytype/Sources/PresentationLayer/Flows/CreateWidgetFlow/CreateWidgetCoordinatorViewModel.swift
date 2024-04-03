import Foundation
import SwiftUI

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    private let data: CreateWidgetCoordinatorModel
    
    // MARK: - State
    
    lazy var widgetSourceSearchData = {
        WidgetSourceSearchModuleModel(
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            context: data.context
        )
    }()
    
    @Published var showWidgetTypeData: WidgetTypeCreateData?
    @Published var dismiss: Bool = false
    
    init(data: CreateWidgetCoordinatorModel) {
        self.data = data
    }
    
    func onSelectSource(source: WidgetSource) {
        showWidgetTypeData = WidgetTypeCreateData(
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

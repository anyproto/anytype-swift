import Foundation
import SwiftUI
import AnytypeCore

@MainActor
final class CreateWidgetCoordinatorViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: CreateWidgetCoordinatorModel
    
    // MARK: - State
    
    lazy var widgetSourceSearchData = {
        WidgetSourceSearchModuleModel(
            spaceId: data.spaceId,
            widgetObjectId: data.widgetObjectId,
            position: data.position,
            context: data.context
        )
    }()
    
    @Published var showWidgetTypeData: WidgetTypeCreateData?
    @Published var dismiss: Bool = false
    
    init(data: CreateWidgetCoordinatorModel) {
        self.data = data
    }
    
    func onSelectSource(source: WidgetSource) {
        if FeatureFlags.widgetCreateWithoutType {
            dismiss.toggle()
        } else {
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
    }
    
    @available(iOS, deprecated: 16.4)
    private func dismissForLegacyOS() {
        if #available(iOS 16.4, *) {
        } else {
            showWidgetTypeData = nil
        }
    }
}

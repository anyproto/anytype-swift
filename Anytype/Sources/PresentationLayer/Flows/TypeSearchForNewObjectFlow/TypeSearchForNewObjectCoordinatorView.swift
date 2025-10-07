import SwiftUI
import Services


struct TypeSearchForNewObjectCoordinatorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: TypeSearchForNewObjectCoordinatorViewModel
    
    init(spaceId: String, openObject: @escaping (ObjectDetails)->()) {
        _model = StateObject(
            wrappedValue: TypeSearchForNewObjectCoordinatorViewModel(spaceId: spaceId, openObject: openObject)
        )
    }
    
    var body: some View {
        model.typeSearchModule()
            .onChange(of: model.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss { dismiss() }
            }
    }
}

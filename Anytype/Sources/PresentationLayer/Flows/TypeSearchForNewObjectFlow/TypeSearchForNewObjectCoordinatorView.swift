import SwiftUI
import Services


struct TypeSearchForNewObjectCoordinatorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: TypeSearchForNewObjectCoordinatorViewModel
    
    init(openObject: @escaping (ObjectDetails)->()) {
        _model = StateObject(
            wrappedValue: TypeSearchForNewObjectCoordinatorViewModel(openObject: openObject)
        )
    }
    
    var body: some View {
        model.typeSearchModule()
            .onChange(of: model.shouldDismiss) { shouldDismiss in
                if shouldDismiss { dismiss() }
            }
    }
}

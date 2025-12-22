import SwiftUI
import Services


struct TypeSearchForNewObjectCoordinatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var pageNavigation
    @State private var model: TypeSearchForNewObjectCoordinatorViewModel

    init(spaceId: String, openObject: @escaping (ObjectDetails)->()) {
        _model = State(
            initialValue: TypeSearchForNewObjectCoordinatorViewModel(spaceId: spaceId, openObject: openObject)
        )
    }
    
    var body: some View {
        model.typeSearchModule()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss { dismiss() }
            }
    }
}

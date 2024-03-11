import SwiftUI

struct TypeSearchForNewObjectCoordinatorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var model: TypeSearchForNewObjectCoordinatorViewModel
    
    var body: some View {
        model.typeSearchModule()
            .onChange(of: model.shouldDismiss) { shouldDismiss in
                if shouldDismiss { dismiss() }
            }
    }
}

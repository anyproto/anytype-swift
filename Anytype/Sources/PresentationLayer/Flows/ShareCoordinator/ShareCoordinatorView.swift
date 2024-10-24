import Foundation
import SwiftUI

struct ShareCoordinatorView: View {
    
    @StateObject private var model: ShareCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: ShareCoordinatorViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        NavigationView {
            ShareOptionsView(spaceId: model.spaceId, output: model)
        }
        .sheet(item: $model.showSearchObjectData) {
            ObjectSearchView(data: $0)
        }
        .sheet(item: $model.showSpaceSearchData) {
            SpaceSearchView(data: $0)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}

#Preview {
    ShareCoordinatorView(spaceId: "1337")
}

import Foundation
import SwiftUI

struct ShareLegacyCoordinatorView: View {
    
    @StateObject private var model: ShareLegacyCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: ShareLegacyCoordinatorViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        NavigationView {
            ShareLegacyOptionsView(spaceId: model.spaceId, output: model)
        }
        .sheet(item: $model.showSearchObjectData) {
            // Delete with FeatureFlags.newSharingExtension
            ObjectSearchView(data: $0)
        }
        .sheet(item: $model.showSpaceSearchData) {
            // Delete with FeatureFlags.newSharingExtension
            SpaceSearchView(data: $0)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}

#Preview {
    ShareLegacyCoordinatorView(spaceId: "1337")
}

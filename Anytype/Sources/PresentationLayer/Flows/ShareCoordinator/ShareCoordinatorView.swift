import Foundation
import SwiftUI

struct ShareCoordinatorView: View {
    
    @StateObject private var model = ShareCoordinatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ShareOptionsView(output: model)
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

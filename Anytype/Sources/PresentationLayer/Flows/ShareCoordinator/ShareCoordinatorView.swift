import Foundation
import SwiftUI

struct ShareCoordinatorView: View {
    
    @StateObject var model: ShareCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.shareModule()
        .sheet(item: $model.showSearchData) { data in
            model.searchModule(data: data)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}

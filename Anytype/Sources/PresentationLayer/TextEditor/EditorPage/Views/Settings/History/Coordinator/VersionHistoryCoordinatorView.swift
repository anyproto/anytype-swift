import Foundation
import SwiftUI

struct VersionHistoryCoordinatorView: View {
    
    @StateObject private var model: VersionHistoryCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: VersionHistoryData) {
        _model = StateObject(wrappedValue: VersionHistoryCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        VersionHistoryView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.objectVersionData) {
            ObjectVersionView(data: $0)
        }
    }
}

import Foundation
import SwiftUI

struct VersionHistoryCoordinatorView: View {

    @State private var model: VersionHistoryCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: VersionHistoryData, output: (any ObjectVersionModuleOutput)?) {
        _model = State(initialValue: VersionHistoryCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        VersionHistoryView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.objectVersionData) {
            ObjectVersionView(data: $0, output: model)
        }
    }
}

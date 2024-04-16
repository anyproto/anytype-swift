import SwiftUI

struct SetLayoutSettingsCoordinatorView: View {
    @StateObject var model: SetLayoutSettingsCoordinatorViewModel
    
    var body: some View {
        SetLayoutSettingsView(
            setDocument: model.setDocument,
            viewId: model.viewId,
            output: model
        )
        .sheet(item: $model.imagePreviewData) { data in
            SetViewSettingsImagePreviewView(
                setDocument: model.setDocument,
                onSelect: data.completion
            )
            .mediumPresentationDetents()
        }
        .sheet(item: $model.groupByData) { data in
            CheckPopupView(
                viewModel: SetViewSettingsGroupByViewModel(
                    setDocument: model.setDocument,
                    onSelect: data.completion
                )
            )
            .fitPresentationDetents()
        }
    }
}

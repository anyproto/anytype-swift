import Foundation
import SwiftUI

struct CreateWidgetCoordinatorView: View {
    
    @StateObject private var model: CreateWidgetCoordinatorViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    init(data: CreateWidgetCoordinatorModel) {
        self._model = StateObject(wrappedValue: CreateWidgetCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        WidgetSourceSearchView(data: model.widgetSourceSearchData) {
            model.onSelectSource(source: $0)
        }
        .sheet(item: $model.showWidgetTypeData) {
            WidgetTypeCreateObjectView(data: $0)
        }
        .onChange(of: model.dismiss) { _ in
            presentationMode.dismiss()
        }
    }
}

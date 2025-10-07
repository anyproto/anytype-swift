import Foundation
import SwiftUI

struct CreateWidgetCoordinatorView: View {
    
    @StateObject private var model: CreateWidgetCoordinatorViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    init(data: CreateWidgetCoordinatorModel, onOpenObject: @escaping (_ openObject: ScreenData?) -> Void) {
        self._model = StateObject(wrappedValue: CreateWidgetCoordinatorViewModel(data: data, onOpenObject: onOpenObject))
    }
    
    var body: some View {
        WidgetSourceSearchView(data: model.widgetSourceSearchData) {
            model.onSelectSource(source: $0, openObject: $1)
        }
        .onChange(of: model.dismiss) {
            presentationMode.dismiss()
        }
    }
}

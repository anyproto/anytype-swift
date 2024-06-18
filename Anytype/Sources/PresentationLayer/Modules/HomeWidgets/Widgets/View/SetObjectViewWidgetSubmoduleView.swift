import Foundation
import SwiftUI

struct SetObjectViewWidgetSubmoduleView: View {
    
    private let data: WidgetSubmoduleData
    @StateObject private var model: SetObjectWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: SetObjectWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        // TODO: Adopt SetObjectWidgetInternalViewModel for SetWidgetView
        SetObjectGalleryWidgetSubmoduleView()
    }
}

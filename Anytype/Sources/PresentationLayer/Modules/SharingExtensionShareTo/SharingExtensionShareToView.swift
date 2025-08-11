import SwiftUI
import DesignKit

struct SharingExtensionShareToData: Hashable, Identifiable {
    let spaceId: String
    
    var id: Int { hashValue }
}

struct SharingExtensionShareToView: View {
    
    @StateObject private var model: SharingExtensionShareToViewModel
    
    init(data: SharingExtensionShareToData) {
        self._model = StateObject(wrappedValue: SharingExtensionShareToViewModel(data: data))
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            ModalNavigationHeader(title: model.title)
            SearchBar(
                text: $model.searchText,
                focused: false,
                placeholder: Loc.search,
                shouldShowDivider: false
            )
            ZStack(alignment: .bottom) {
                list
                bottomPanel
            }
        }
        .task(id: model.searchText) {
            await model.search()
        }
    }
    
    private var list: some View {
        PlainList {
            ForEach(model.rows) { data in
                SharingExtensionsShareRow(data: data)
                    .fixTappableArea()
                    .onTapGesture {
                        model.onTapCell(data: data)
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer.fixedHeight(150)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        if model.selectedObjectIds.isNotEmpty {
            SharingExtensionBottomPanel(
                comment: $model.comment,
                commentLimit: model.commentLimit,
                commentWarningLimit: model.commentWarningLimit) {
                    try await model.onTapSend()
                }
        }
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"))
    }
}

import Foundation
import SwiftUI

struct ChatHeaderView: View {
    
    @StateObject private var model: ChatHeaderViewModel
    
    init(spaceId: String, onTapOpenWidgets: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: ChatHeaderViewModel(spaceId: spaceId, onTapOpenWidgets: onTapOpenWidgets))
    }
    
    var body: some View {
        PageNavigationHeader {
            IncreaseTapButton {
                model.tapOpenWidgets()
            } label: {
                AnytypeText(model.title, style: .uxTitle1Semibold)
                    .lineLimit(1)
            }
        } rightView: {
            IncreaseTapButton {
                model.tapOpenWidgets()
            } label: {
                IconView(icon: model.icon)
                    .frame(width: 28, height: 28)
            }
        }
        .task {
            await model.subscribe()
        }
    }
}

import Foundation
import SwiftUI

struct ChatHeaderView: View {
    
    @StateObject private var model: ChatHeaderViewModel
    
    init(spaceId: String, chatId: String, onTapOpenWidgets: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: ChatHeaderViewModel(spaceId: spaceId, chatId: chatId, onTapOpenWidgets: onTapOpenWidgets))
    }
    
    var body: some View {
        PageNavigationHeader {
            IncreaseTapButton {
                model.tapOpenWidgets()
            } label: {
                HStack(spacing: 6) {
                    if model.showLoading {
                        CircleLoadingView(.Text.primary)
                            .frame(width: 18, height: 18)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Spacer.fixedWidth(18)
                    }
                    AnytypeText(model.title, style: .uxTitle1Semibold)
                        .lineLimit(1)
                    if model.muted {
                        Image(asset: .X18.muted)
                            .foregroundColor(.Text.primary)
                    } else {
                        Spacer.fixedWidth(18)
                    }
                }
            }
        } rightView: {
            if model.showWidgetsButton {
                IncreaseTapButton {
                    model.tapOpenWidgets()
                } label: {
                    IconView(icon: model.icon)
                        .frame(width: 28, height: 28)
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .animation(.default, value: model.showLoading)
    }
}

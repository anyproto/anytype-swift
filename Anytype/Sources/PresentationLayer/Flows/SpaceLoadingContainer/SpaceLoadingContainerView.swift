import SwiftUI
import Services

struct SpaceLoadingContainerView<Content: View>: View {
    
    @StateObject private var model: SpaceLoadingContainerViewModel
    private var content: (_ info: AccountInfo) -> Content
    
    init(spaceId: String, showBackground: Bool, content: @escaping (_ info: AccountInfo) -> Content) {
        self._model = StateObject(wrappedValue: SpaceLoadingContainerViewModel(spaceId: spaceId, showBackground: showBackground))
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if let info = model.info {
                content(info)
            } else {
                loadingState
                    .homeBottomPanelHidden(true)
            }
        }
    }
    
    private var loadingState: some View {
        ZStack {
            if model.showBackground {
                HomeWallpaperView(spaceId: model.spaceId)
            } else {
                Color.Background.primary
            }
            VStack(spacing: 0) {
                PageNavigationHeader(title: "")
                Spacer()
                if let errorText = model.errorText {
                    VStack(spacing: 20) {
                        Text(errorText)
                        StandardButton(
                            Loc.tryAgain,
                            inProgress: false,
                            style: .warningMedium,
                            action: {
                                model.onTryOpenSpaceAgain()
                            }
                        )
                    }.padding(.horizontal, 16)
                } else {
                    IconView(icon: model.spaceIcon)
                        .frame(width: 96, height: 96)
                }
                Spacer()
            }
        }
    }
}

import SwiftUI
import Services

// IMPORTANT: Never nest SpaceLoadingContainerView inside another SpaceLoadingContainerView.
//
// During navigation transitions (especially from push notifications), SwiftUI may create
// and destroy views for both old and new spaces simultaneously. Each SpaceLoadingContainerViewModel
// calls openSpace() in init, which triggers setActiveSpace(). With nested containers,
// multiple ViewModels compete to set different active spaces, causing an infinite loop:
//
//   1. Navigation to space B triggers view creation
//   2. Old space A views still being destroyed, their ViewModels call openSpace(A)
//   3. activeSpaceManager emits change → navigation reacts → views recreated
//   4. Repeat indefinitely → UI freeze
//
// Instead, wrap content at the navigation builder level (e.g., SpaceHubCoordinatorView)
// so there's exactly one SpaceLoadingContainerView per navigation destination.
struct SpaceLoadingContainerView<Content: View>: View {

    @State private var model: SpaceLoadingContainerViewModel
    private var content: (_ info: AccountInfo) -> Content

    init(spaceId: String, showBackground: Bool, content: @escaping (_ info: AccountInfo) -> Content) {
        self._model = State(initialValue: SpaceLoadingContainerViewModel(spaceId: spaceId, showBackground: showBackground))
        self.content = content
    }
    
    private let minSide: CGFloat = 16
    private let middleSide: CGFloat = 80
    private let maxSide: CGFloat = 96
    
    @State private var side: CGFloat = 16

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
                NavigationHeader(title: "")
                Spacer()
            }
            
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
                if let icon = model.spaceIcon {
                    IconView(icon: icon)
                        .frame(width: maxSide, height: maxSide)
                        .scaleEffect(side / maxSide)
                        .opacity(min(1, (side - minSide) / minSide))
                        .modifier(PulseAnimation(side: $side, middleSide: middleSide, maxSide: maxSide))
                }
            }
        }
        .task {
            try? await model.iconTask()
        }
    }
}

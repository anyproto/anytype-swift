import SwiftUI
import Services

struct SpaceLoadingContainerView<Content: View>: View {
    
    @StateObject private var model: SpaceLoadingContainerViewModel
    private var content: (_ info: AccountInfo) -> Content
    
    init(spaceId: String, content: @escaping (_ info: AccountInfo) -> Content) {
        self._model = StateObject(wrappedValue: SpaceLoadingContainerViewModel(spaceId: spaceId))
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if let info = model.info {
                content(info)
            } else {
                loadingState
            }
        }
    }
    
    private var loadingState: some View {
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
                DotsView()
                    .frame(width: 50, height: 10)
            }
            Spacer()
        }
    }
}

extension View {
    func attachSpaceLoadingContainer(spaceId: String) -> some View {
        SpaceLoadingContainerView(spaceId: spaceId) { _ in
            self
        }
    }
}

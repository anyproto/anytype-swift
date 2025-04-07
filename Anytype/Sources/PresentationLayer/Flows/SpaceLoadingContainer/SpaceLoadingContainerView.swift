import SwiftUI
import Services

struct SpaceLoadingContainerView<Content: View>: View {
    
//    @Environment(\.sceneId) private var sceneId
    
    @StateObject private var model: SpaceLoadingContainerViewModel
    private var content: () -> Content
    
    init(spaceId: String, content: @escaping () -> Content) {
        self._model = StateObject(wrappedValue: SpaceLoadingContainerViewModel(spaceId: spaceId))
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if model.showPlaceholder {
                Color.red
            } else {
                content()
            }
        }
        .task {
            await model.openSpace()
        }
    }
}

extension View {
    func attachSpaceLoadingContainer(spaceId: String) -> some View {
        SpaceLoadingContainerView(spaceId: spaceId) {
            self
        }
    }
}

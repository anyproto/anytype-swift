import SwiftUI

struct HomeBottomSheetView<Content: View>: View {
    @Binding var state: HomeBottomSheetViewState
    
    @State private var offset: CGFloat = 0
    @State private var wasOpen = false
    
    private let content: Content
    private let config: Configuration
    
    init(
        containerHeight: CGFloat,
        state: Binding<HomeBottomSheetViewState>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._state = state
        self._wasOpen = State(initialValue: state.wrappedValue == .open)
        let config = Configuration(containerHeight: containerHeight)
        self.config = config
    }

    var body: some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: config.maxHeight)
                .offset(y: offset)
        }
        .onChange(of: state) { state in
            updateOffset(state)
            updateState(state)
        }
        .onAppear {
            offset = countOffset(state)
        }
    }
    
    private func updateOffset(_ state: HomeBottomSheetViewState) {
        withAnimation(offsetAnimation(state: state)) {
            self.offset = countOffset(state)
        }
    }
    
    private func updateState(_ state: HomeBottomSheetViewState) {
        switch state {
        case .open:
            wasOpen = true
        case .closed:
            wasOpen = false
        case .finishDrag:
            if offset >= config.snapOffset {
                self.state = .closed
            } else {
                self.state = wasOpen ? .closed : .open
            }
        case .drag:
            break
        }
    }
     
    private func countOffset(_ state: HomeBottomSheetViewState) -> CGFloat {
        switch state {
        case .open:
            return config.openOffset
        case .closed:
            return config.closedOffset
        case .drag(offset: let offset):            
            return config.validatedOffset(offset, isOpen: wasOpen)
        case .finishDrag(offset: let offset):
            return config.validatedOffset(offset, isOpen: wasOpen)
        }
    }
    
    private func offsetAnimation(state: HomeBottomSheetViewState) -> Animation{
        switch state {
        case .open, .closed:
            return .spring()
        case .drag, .finishDrag:
            return .smoothScroll
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader() { geometry in
            HomeBottomSheetView(
                containerHeight: geometry.size.height,
                state: .constant(.open)
            ) {
                Color.green
            }
        }
    }
}

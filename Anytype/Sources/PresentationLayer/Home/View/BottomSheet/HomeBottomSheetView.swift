import SwiftUI

enum HomeBottomSheetViewState: Equatable {
    case open
    case closed
    case drag(offset: CGFloat)
    case finishDrag(offset: CGFloat)
}

private struct HomeBottomSheetViewConfiguration {
    let cornerRadius: CGFloat = 16
    let snapRatio: CGFloat = 0.05
    let minHeightRatio: CGFloat = 0.55
    let maxHeight: CGFloat
    
    var minHeight: CGFloat {
        maxHeight * minHeightRatio
    }

    var sheetOffset: CGFloat {
        maxHeight - minHeight
    }
}

struct HomeBottomSheetView<Content: View>: View {
    @Binding var state: HomeBottomSheetViewState
    
    @State private var offset: CGFloat = 0
    @State private var wasOpen = false
    
    private let content: Content
    private let config: HomeBottomSheetViewConfiguration
    
    init(
        maxHeight: CGFloat,
        state: Binding<HomeBottomSheetViewState>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._state = state
        self._wasOpen = State(initialValue: state.wrappedValue == .open)
        let config = HomeBottomSheetViewConfiguration(maxHeight: maxHeight)
        self.config = config
    }

    var body: some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: self.config.maxHeight, alignment: .top)
                .cornerRadius(config.cornerRadius, corners: [.topLeft, .topRight])
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: offset)
        }
        .onChange(of: state) { state in
            updateOffset(state)
            updateState(state)
        }
        .onAppear {
            self.offset = countOffset(state)
        }
    }
    
    private func updateOffset(_ state: HomeBottomSheetViewState) {
        let animation: Animation
        
        switch state {
        case .open:
            animation = .spring()
        case .closed:
            animation = .spring()
        case .drag:
            animation = .smoothScroll
        case .finishDrag:
            animation = .smoothScroll
        }
        
        withAnimation(animation) {
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
            if offset >= config.sheetOffset {
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
            return defaultOffset(isOpen: true)
        case .closed:
            return defaultOffset(isOpen: false)
        case .drag(offset: let offset):
            return max(defaultOffset(isOpen: wasOpen) + offset, 0)
        case .finishDrag(offset: let offset):
            return max(defaultOffset(isOpen: wasOpen) + offset, 0)
        }
    }
    
    private func defaultOffset(isOpen: Bool) -> CGFloat {
        if isOpen {
            return 0
        } else {
            return config.sheetOffset
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader() { geometry in
            HomeBottomSheetView(
                maxHeight: geometry.size.height * 0.8,
                state: .constant(.open)
            ) {
                Color.green
            }
        }
    }
}

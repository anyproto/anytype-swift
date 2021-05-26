import SwiftUI

private struct HomeBottomSheetViewConfiguration {
    let cornerRadius: CGFloat = 16
    let snapRatio: CGFloat = 0.05
    let minHeightRatio: CGFloat = 0.55
    let maxHeight: CGFloat
    
    var minHeight: CGFloat {
        maxHeight * minHeightRatio
    }
    
    var snapDistance: CGFloat {
        maxHeight * snapRatio
    }
    
    var sheetOffset: CGFloat {
        maxHeight - minHeight
    }
}

struct HomeBottomSheetView<Content: View>: View {
    @Binding var scrollOffset: CGFloat
    @Binding var isOpen: Bool
    
    private let content: Content
    private let config: HomeBottomSheetViewConfiguration
    
    init(
        maxHeight: CGFloat,
        scrollOffset: Binding<CGFloat>,
        isOpen: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._scrollOffset = scrollOffset
        self._isOpen = isOpen
        self.config = HomeBottomSheetViewConfiguration(maxHeight: maxHeight)
    }
    
    private var offset: CGFloat {
        var offset = isOpen ? 0 : config.sheetOffset
        if !isOpen {
            offset += max(scrollOffset, 0)
        }
        return offset
    }

    var body: some View {
        
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: self.config.maxHeight, alignment: .top)
                .background(HomeBackgroundBlurView())
                .cornerRadius(config.cornerRadius, corners: [.topLeft, .topRight])
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: offset)
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader() { geometry in
            HomeBottomSheetView(
                maxHeight: geometry.size.height * 0.8,
                scrollOffset: .constant(0),
                isOpen: .constant(true)
            ) {
                Color.green
            }
        }
    }
}

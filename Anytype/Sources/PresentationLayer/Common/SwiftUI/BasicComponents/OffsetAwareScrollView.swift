import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue = CGPoint.zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct OffsetAwareScrollView<Content: View>: View {
    let coordinateSpaceName = "OffsetAwareScrollView"
    
    let offsetChanged: (CGPoint) -> Void
    let content: Content
    let axes: Axis.Set
    let showsIndicators: Bool

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named(coordinateSpaceName)).origin
                    )
                }.frame(width: 0, height: 0)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
                content
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

struct OffsetAwareScrollView_Previews: PreviewProvider {
    struct OffsetAwareScrollViewPreviewer: View {
        @State private var scrollOffset = CGPoint.zero
        
        var body: some View {
            VStack {
                AnytypeText("\(scrollOffset.x):\(scrollOffset.y)", style: .bodyRegular)
                    .foregroundColor(.Text.primary)
                OffsetAwareScrollView(
                    axes: [.horizontal, .vertical],
                    showsIndicators: false,
                    offsetChanged: { scrollOffset = $0 }
                ) {
                    ForEach(0..<100) { i in
                        AnytypeText("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", style: .bodyRegular)
                                .foregroundColor(.Text.primary)
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        OffsetAwareScrollViewPreviewer()
    }
}

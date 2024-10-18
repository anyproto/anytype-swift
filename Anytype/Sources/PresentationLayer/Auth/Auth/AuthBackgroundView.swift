import SwiftUI

struct AuthBackgroundView<Content>: View where Content: View {
    
    let url: URL?
    let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let topOffset = geo.size.height / 6.5
            let bottomOffset = geo.size.height / 4
            let height = geo.size.height - topOffset - bottomOffset
            backgroundView(
                width: geo.size.width,
                height: height,
                topOffset: topOffset,
                bottomOffset: bottomOffset
            )
        }
        .background(Color.Background.primary)
        .overlay {
            navigationView
        }
        .ignoresSafeArea(.all)
    }
    
    private func backgroundView(
        width: CGFloat,
        height: CGFloat,
        topOffset: CGFloat,
        bottomOffset: CGFloat) -> some View
    {
        VStack(spacing: 0) {
            Spacer.fixedHeight(topOffset)
            playerView(width: width, height: height)
            Spacer.fixedHeight(bottomOffset)
        }
    }
    
    private var navigationView: some View {
        NavigationStack {
            content()
        }
        .disablePresentationBackground()
    }
    
    @ViewBuilder
    private func playerView(width: CGFloat, height: CGFloat) -> some View {
        if let url {
            LoopingPlayerView(url: url)
                .aspectRatio(UIDevice.isPad ? 0.85 : 0.53, contentMode: .fill)
                .frame(width: width, height: height)
        }
    }
}

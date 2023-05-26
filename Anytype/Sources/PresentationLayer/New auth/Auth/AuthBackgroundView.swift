import SwiftUI

struct AuthBackgroundView<Content>: View where Content: View {
    
    let url: URL?
    let content: () -> Content
    
    @State private var showContent = true

    var body: some View {
        VStack(spacing: 0) {
            playerView
            Spacer.fixedHeight(120)
        }
        .fullScreenCover(isPresented: $showContent) {
            navigationView
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .ignoresSafeArea(.all)
    }
    
    private var navigationView: some View {
        NavigationView {
            content()
        }
        .background(TransparentBackground())
        .transaction { transaction in
            transaction.disablesAnimations = false
        }
    }
    
    @ViewBuilder
    private var playerView: some View {
        if let url {
            GeometryReader { geo in
                LoopingPlayerView(url: url)
                    .aspectRatio(0.5, contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

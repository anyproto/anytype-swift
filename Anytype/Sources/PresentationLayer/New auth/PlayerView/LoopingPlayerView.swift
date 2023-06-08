import SwiftUI

struct LoopingPlayerView: UIViewRepresentable {
    
    let url: URL

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(url: url)
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LoopingPlayerView>) {}
}

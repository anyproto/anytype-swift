import Foundation
import SwiftUI

struct VerticalScrollViewWithOverlayHeader<Content, Header>: View where Content: View, Header: View {
        
    var visibleOfffset: CGFloat
    var header: Header
    var content: Content
    
    @State private var contentTopOffseet: CGFloat = 0
    @State private var safeAreaTopOffset: CGFloat = 0
    @State private var overlayOpacity: CGFloat = 0
    
    init(visibleOfffset: CGFloat = 30, @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.visibleOfffset = visibleOfffset
        self.header = header()
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            PositionCatcher { newPosition in
                contentTopOffseet = newPosition.y
                updateOverlay()
            }
            content
        }
        .safeAreaInset(edge: .top, content: {
            PositionCatcher { newPosition in
                safeAreaTopOffset = newPosition.y
                updateOverlay()
            }
        })
        .overlay(
            VStack(spacing: 0) {
                header
                Spacer()
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .opacity(overlayOpacity)
        )
    }
    
    private func updateOverlay() {
        guard visibleOfffset > 0 else {
            overlayOpacity = 1
            return
        }
        let offset = max(min(safeAreaTopOffset - contentTopOffseet, visibleOfffset), 0)
        overlayOpacity = offset / visibleOfffset
    }
}

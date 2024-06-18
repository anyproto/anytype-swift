import Foundation
import SwiftUI

struct WindowHolder: Equatable {
    let id = UUID()
    weak var window: UIWindow?
}

extension View {
    func readWindowHolder(_ holder: Binding<WindowHolder>) -> some View {
        self.background {
            WindowReaderView(holder: holder)
        }
    }
}

private struct WindowReaderView: UIViewRepresentable {
    
    @Binding var holder: WindowHolder
    
    func makeUIView(context: Context) -> UIWindowReaderView {
        return UIWindowReaderView(holder: $holder)
    }
    
    func updateUIView(_ uiView: UIWindowReaderView, context: Context) {}
}

private final class UIWindowReaderView: UIView {
    
    @Binding private var holder: WindowHolder
    
    init(holder: Binding<WindowHolder>) {
        self._holder = holder
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // If system change window to nil, that means that user present new screen in fullScreen. Ignore it.
        if let window {
            holder = WindowHolder(window: window)
        }
    }
}

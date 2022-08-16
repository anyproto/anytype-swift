import SwiftUI

struct ObjectHeaderFilledContentSwitfUIView: UIViewRepresentable {
    let configuration: ObjectHeaderFilledConfiguration
    
    func makeUIView(context: Context) -> ObjectHeaderFilledContentView {
        let view = ObjectHeaderFilledContentView(frame: .zero)

        view.update(with: configuration)

        return view
    }
    
    func updateUIView(_ view: ObjectHeaderFilledContentView, context: Context) {
        view.update(with: configuration)
    }
}

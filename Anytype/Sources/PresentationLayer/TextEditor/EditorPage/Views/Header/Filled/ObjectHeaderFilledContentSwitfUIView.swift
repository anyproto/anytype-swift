import SwiftUI

struct ObjectHeaderFilledContentSwitfUIView: UIViewRepresentable {
    let configuration: ObjectHeaderFilledConfiguration
    func makeUIView(context: Context) -> ObjectHeaderFilledContentView {
        ObjectHeaderFilledContentView(configuration: configuration)
    }
    
    func updateUIView(_ view: ObjectHeaderFilledContentView, context: Context) {
        view.configuration = configuration
    }
}

import Foundation
import SwiftUI

struct SwiftUIObjectHeaderCoverView: UIViewRepresentable {
    let objectCover: ObjectHeaderCoverType
    let size: CGSize
    let fitImage: Bool
    
    func makeUIView(context: Context) -> ObjectHeaderCoverView {
        ObjectHeaderCoverView()
    }
    
    func updateUIView(_ uiView: ObjectHeaderCoverView, context: Context) {
        uiView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectCover,
                size: size,
                fitImage: fitImage
            )
        )
    }
}

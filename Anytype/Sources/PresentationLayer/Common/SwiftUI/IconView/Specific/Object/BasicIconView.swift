import Foundation
import SwiftUI

struct BasicIconView: View {

    let imageId: String
    let circular: Bool

    var body: some View {
        ImageIdIconView(imageId: imageId)
            .if(circular, if: {
                $0.circleOverCornerRadius()
            }, else: {
                $0.objectIconCornerRadius()
            })
    }
}

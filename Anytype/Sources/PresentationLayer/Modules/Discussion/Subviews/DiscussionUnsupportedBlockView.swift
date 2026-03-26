import Foundation
import SwiftUI
import AnytypeCore

struct DiscussionUnsupportedBlockView: View {
    let blockName: String

    var body: some View {
        Text(title)
            .anytypeStyle(.caption1Medium)
            .foregroundColor(.Text.secondary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Shape.transparentSecondary)
            .clipShape(.rect(cornerRadius: 8))
    }

    private var title: String {
        #if DEBUG
        "\(Loc.unsupportedBlock) (\(blockName))"
        #else
        Loc.unsupportedBlock
        #endif
    }
}

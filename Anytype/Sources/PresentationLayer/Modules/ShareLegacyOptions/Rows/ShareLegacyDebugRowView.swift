import Foundation
import SwiftUI

struct ShareLegacyDebugRowView: View {
    
    let index: Int
    let mimeTypes: [String]
    
    var body: some View {
        HStack {
            AnytypeText("\(index)", style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
            VStack {
                AnytypeText(Loc.Debug.mimeTypes(mimeTypes.joined(separator: ", ")), style: .uxCalloutRegular)
                    .foregroundColor(.Text.primary)
            }
        }
    }
}

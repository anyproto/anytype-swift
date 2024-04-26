import Foundation
import SwiftUI

struct ShareDebugRowView: View {
    
    let index: Int
    let mimeTypes: [String]
    
    var body: some View {
        HStack {
            AnytypeText("\(index)", style: .uxCalloutRegular, color: .Text.primary)
            VStack {
                AnytypeText(Loc.Debug.mimeTypes(mimeTypes.joined(separator: ", ")), style: .uxCalloutRegular, color: .Text.primary)
            }
        }
    }
}

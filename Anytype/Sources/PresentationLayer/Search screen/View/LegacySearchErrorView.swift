import Foundation
import SwiftUI

struct LegacySearchErrorView: View {
    
    let error: LegacySearchError
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                error.title,
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
            error.subtitle.flatMap {
                AnytypeText(
                    $0,
                    style: .uxBodyRegular
                )
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

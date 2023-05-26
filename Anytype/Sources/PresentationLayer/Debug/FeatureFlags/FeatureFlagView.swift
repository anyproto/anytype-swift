import Foundation
import SwiftUI

struct FeatureFlagView: View {
    
    let model: FeatureFlagViewModel
    @State private var isOn: Bool
    
    init(model: FeatureFlagViewModel) {
        self.model = model
        self.isOn = model.value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading) {
                    Text(model.description.title)
                        .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
                        .foregroundColor(.Text.primary)
                    switch model.description.type {
                    case let .feature(author, releaseVersion):
                        Text(Loc.DebugMenu.toggleAuthor(releaseVersion, author))
                            .font(AnytypeFontBuilder.font(anytypeFont: .calloutRegular))
                            .foregroundColor(.Text.secondary)
                    case .debug:
                        EmptyView()
                    }

                        // See AnytypeText padding comment
//                        AnytypeText(flag.description.title, style: .body, color: .Text.primary)
//                        AnytypeText("Release: \(flag.description.releaseVersion), \(flag.description.author)", style: .callout, color: .Text.secondary)
//                        }
                }
            }
        }
        .onChange(of: isOn) {
            model.onChange($0)
        }
        .padding()
        .newDivider()
    }
}

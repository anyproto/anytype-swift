import Foundation
import SwiftUI

struct FeatureFlagView: View {
    
    let model: FeatureFlagViewModel
    @State private var isOn: Bool
    @State private var showDefaultValues: Bool = false
    
    init(model: FeatureFlagViewModel) {
        self.model = model
        self.isOn = model.value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading) {
                    Text(verbatim: model.description.title)
                        .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
                        .foregroundStyle(Color.Text.primary)
                    switch model.description.type {
                    case let .feature(author, releaseVersion):
                        Text(verbatim: Loc.DebugMenu.toggleAuthor(releaseVersion, author))
                            .font(AnytypeFontBuilder.font(anytypeFont: .calloutRegular))
                            .foregroundStyle(Color.Text.secondary)
                    case .debug:
                        EmptyView()
                    }
                }
            }
            
            Button {
                showDefaultValues.toggle()
            } label: {
                Text("> Default values")
                    .font(AnytypeFontBuilder.font(anytypeFont: .previewTitle2Medium))
                    .foregroundStyle(Color.Text.secondary)
            }
            
            if showDefaultValues {
                Group {
                    Text("Nightly - \(model.description.debugValue ? "on" : "off")")
                    Text("Release Anytype - \(model.description.releaseAnytypeValue ? "on" : "off")")
                }
                .font(AnytypeFontBuilder.font(anytypeFont: .calloutRegular))
                .foregroundStyle(Color.Text.secondary)
                .transition(.opacity)
            }
        }
        .onChange(of: isOn) {
            model.onChange($1)
        }
        .padding()
        .newDivider()
    }
}

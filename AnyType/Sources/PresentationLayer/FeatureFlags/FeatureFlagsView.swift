import SwiftUI

struct FeatureFlagsView: View {
    @State var flags = FeatureFlags.features.sorted { $0.0.rawValue < $1.0.rawValue }
    
    var body: some View {
        List(flags.indices) { index in
            Toggle(isOn: $flags[index].onChange(FeatureFlags.update).value) {
                AnytypeText(flags[index].key.rawValue, style: .body)
            }
            .padding()
        }
        .navigationTitle("Feature flags 🤖")
    }
}


struct FeatureFlagsView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsView()
    }
}


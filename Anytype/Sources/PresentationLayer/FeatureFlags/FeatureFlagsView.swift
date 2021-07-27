import SwiftUI
import AnytypeCore

struct FeatureFlagsView: View {
    @State var flags = FeatureFlags.features.sorted { $0.0.rawValue < $1.0.rawValue }
    
    var body: some View {
        VStack {
            buttons
            toggles
        }
        .navigationTitle("Feature flags 🤖")
        .embedInNavigation()
    }
    
    var buttons: some View {
        HStack() {
            StandardButton(text: "Crash", style: .primary) {
                let crash: [Int] = []
                _ = crash[1]
            }.padding()
            StandardButton(text: "Assert", style: .secondary) {
                anytypeAssertionFailure("Test assert")
            }.padding()
        }
    }
    
    var toggles: some View {
        List(flags.indices) { index in
            Toggle(
                isOn: $flags[index].onChange(FeatureFlags.update).value
            ) {
                AnytypeText(flags[index].key.rawValue, style: .body)
            }
            .padding()
        }
    }
}


struct FeatureFlagsView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureFlagsView()
    }
}


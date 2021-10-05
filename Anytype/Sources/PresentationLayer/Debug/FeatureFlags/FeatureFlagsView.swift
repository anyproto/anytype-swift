import SwiftUI
import AnytypeCore

struct FeatureFlagsView: View {
    @State var flags = FeatureFlags.features.sorted { $0.0.rawValue < $1.0.rawValue }
    @State var showLogs = false
    var body: some View {
        VStack {
            DragIndicator()
            AnytypeText("Feature flags 👻", style: .title, color: .textPrimary)
            buttons
            toggles
        }
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
            StandardButton(text: "Logs", style: .secondary) {
                showLogs.toggle()
            }.padding()
        }
        .sheet(isPresented: $showLogs) { EventsLogView(viewModel: .init()) }
    }
    
    var toggles: some View {
        List(flags.indices) { index in
            Toggle(
                isOn: $flags[index].onChange(FeatureFlags.update).value
            ) {
                AnytypeText(flags[index].key.rawValue, style: .bodyRegular, color: .textPrimary)
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


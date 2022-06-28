import SwiftUI

private final class AnytypeToggleModel: ObservableObject {
    @Published var isOn: Bool
    
    init(isOn: Bool) {
        self.isOn = isOn
    }
}

struct AnytypeToggle: View {
    private let title: String
    private let onChange: (Bool) -> ()
    
    @ObservedObject private var model: AnytypeToggleModel
    
    init(title: String, isOn: Bool, onChange: @escaping (Bool) -> ()) {
        self.title = title
        self.model = AnytypeToggleModel(isOn: isOn)
        self.onChange = onChange
    }
    
    var body: some View {
        Toggle(isOn: $model.isOn) {
            AnytypeText(title, style: .uxBodyRegular, color: .textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: .System.amber50))
        
        .onChange(of: model.isOn) { onChange($0) }
    }
}

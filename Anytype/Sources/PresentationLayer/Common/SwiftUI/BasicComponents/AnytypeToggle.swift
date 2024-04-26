import SwiftUI

private final class AnytypeToggleModel: ObservableObject {
    @Published var isOn: Bool
    
    init(isOn: Bool) {
        self.isOn = isOn
    }
}

struct AnytypeToggle: View {
    private let title: String
    private let font: AnytypeFont
    private let onChange: (Bool) -> ()
    
    @ObservedObject private var model: AnytypeToggleModel
    
    init(title: String, font: AnytypeFont = .uxBodyRegular, isOn: Bool, onChange: @escaping (Bool) -> ()) {
        self.title = title
        self.font = font
        self.model = AnytypeToggleModel(isOn: isOn)
        self.onChange = onChange
    }
    
    var body: some View {
        Toggle(isOn: $model.isOn) {
            AnytypeText(title, style: font, color: .Text.primary)
        }
        .toggleStyle(SwitchToggleStyle(tint: .System.amber50))
        
        .onChange(of: model.isOn) { onChange($0) }
    }
}

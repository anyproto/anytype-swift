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
    
    @StateObject private var model: AnytypeToggleModel
    
    init(title: String, font: AnytypeFont = .uxBodyRegular, isOn: Bool, onChange: @escaping (Bool) -> ()) {
        self.title = title
        self.font = font
        self._model = StateObject(wrappedValue: AnytypeToggleModel(isOn: isOn))
        self.onChange = onChange
    }
    
    var body: some View {
        Toggle(isOn: $model.isOn) {
            AnytypeText(title, style: font)
                .foregroundColor(.Text.primary)
        }
        .if(title.isEmpty) {
            $0.labelsHidden()
        }
        .toggleStyle(SwitchToggleStyle(tint: .Control.accent50))
        
        .onChange(of: model.isOn) { onChange($1) }
    }
}

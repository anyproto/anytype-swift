import Foundation
import SwiftUI
import Services

@MainActor
final class PropertyOptionSettingsViewModel: ObservableObject {
    
    @Published var text: String
    @Published var selectedColor: Color
    
    let colors: [Color]
    let configuration: PropertyOptionSettingsConfiguration
    
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    
    private let completion: (_ optionParams: PropertyOptionParameters) -> Void
    
    init(
        configuration: PropertyOptionSettingsConfiguration,
        completion: @escaping (_ optionParams: PropertyOptionParameters) -> Void
    ) {
        self.text = configuration.option.text
        self.selectedColor = configuration.option.color
        self.configuration = configuration
        self.completion = completion
        self.colors = MiddlewareColor.allCasesWithoutDefault.map { Color.Dark.color(from: $0) }
    }
    
    func onColorSelected( _ color: Color) {
        selectedColor = color
    }
    
    func onButtonTap() {
        switch configuration.mode {
        case let .create(data):
            create(with: data)
        case .edit:
            edit()
        }
    }
    
    private func create(with data: PropertyOptionSettingsMode.CreateData) {
        Task {
            let optionId = try await propertiesService.addPropertyOption(
                spaceId: data.spaceId,
                propertyKey: data.relationKey,
                optionText: text,
                color: selectedColor.middlewareString()
            )
            
            guard let optionId else { return }
            
            completion(
                PropertyOptionParameters(
                    id: optionId,
                    text: text,
                    color: selectedColor
                )
            )
        }
    }
    
    private func edit() {
        Task {
            try await propertiesService.updatePropertyOption(
                id: configuration.option.id,
                text: text,
                color: selectedColor.middlewareString()
            )
            completion(
                PropertyOptionParameters(
                    id: configuration.option.id,
                    text: text,
                    color: selectedColor
                )
            )
        }
    }
}

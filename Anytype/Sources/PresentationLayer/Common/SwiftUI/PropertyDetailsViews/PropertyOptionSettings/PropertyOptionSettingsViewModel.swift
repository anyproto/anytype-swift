import Foundation
import SwiftUI
import Services

@MainActor
final class PropertyOptionSettingsViewModel: ObservableObject {
    
    @Published var text: String
    @Published var selectedColor: Color
    
    let colors: [Color]
    let configuration: PropertyOptionSettingsConfiguration
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    private let completion: (_ optionParams: RelationOptionParameters) -> Void
    
    init(
        configuration: PropertyOptionSettingsConfiguration,
        completion: @escaping (_ optionParams: RelationOptionParameters) -> Void
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
            let optionId = try await relationsService.addRelationOption(
                spaceId: data.spaceId,
                relationKey: data.relationKey,
                optionText: text,
                color: selectedColor.middlewareString()
            )
            
            guard let optionId else { return }
            
            completion(
                RelationOptionParameters(
                    id: optionId,
                    text: text,
                    color: selectedColor
                )
            )
        }
    }
    
    private func edit() {
        Task {
            try await relationsService.updateRelationOption(
                id: configuration.option.id,
                text: text,
                color: selectedColor.middlewareString()
            )
            completion(
                RelationOptionParameters(
                    id: configuration.option.id,
                    text: text,
                    color: selectedColor
                )
            )
        }
    }
}

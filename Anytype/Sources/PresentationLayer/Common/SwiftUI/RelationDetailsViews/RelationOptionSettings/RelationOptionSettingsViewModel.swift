import Foundation
import SwiftUI
import Services

@MainActor
final class RelationOptionSettingsViewModel: ObservableObject {
    
    @Published var text: String
    @Published var selectedColor: Color
    
    let colors: [Color]
    let configuration: RelationOptionSettingsConfiguration
    
    private let relationsService: RelationsServiceProtocol
    private let completion: (_ optionParams: RelationOptionParameters) -> Void
    
    init(
        configuration: RelationOptionSettingsConfiguration,
        relationsService: RelationsServiceProtocol,
        completion: @escaping (_ optionParams: RelationOptionParameters) -> Void
    ) {
        self.text = configuration.option.text
        self.selectedColor = configuration.option.color
        self.configuration = configuration
        self.relationsService = relationsService
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
    
    private func create(with data: RelationOptionSettingsMode.CreateData) {
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

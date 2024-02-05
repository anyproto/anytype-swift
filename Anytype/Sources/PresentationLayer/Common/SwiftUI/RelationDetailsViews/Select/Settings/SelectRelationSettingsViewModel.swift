import Foundation
import SwiftUI
import Services

@MainActor
final class SelectRelationSettingsViewModel: ObservableObject {
    
    @Published var text: String
    @Published var selectedColor: Color
    
    let colors: [Color]
    let mode: RelationSettingsMode
    
    private let relationsService: RelationsServiceProtocol
    private let completion: (_ optionId: String) -> Void
    
    init(
        text: String?,
        color: Color?,
        mode: RelationSettingsMode,
        relationsService: RelationsServiceProtocol,
        completion: @escaping (_ optionId: String) -> Void
    ) {
        self.text = text ?? ""
        self.mode = mode
        self.relationsService = relationsService
        self.completion = completion
        self.colors = MiddlewareColor.allCases.filter { $0 != .default }.map { Color.Dark.color(from: $0) }
        self.selectedColor = color ?? colors.randomElement() ?? Color.Dark.grey
    }
    
    func onColorSelected( _ color: Color) {
        selectedColor = color
    }
    
    func onButtonTap() {
        switch mode {
        case let .create(data):
            create(with: data)
        case let .edit(optionId):
            edit(with: optionId)
        }
    }
    
    private func create(with data: RelationSettingsMode.CreateData) {
        Task {
            let optionId = try await relationsService.addRelationOption(
                spaceId: data.spaceId,
                relationKey: data.relationKey,
                optionText: text,
                color: selectedColor.middlewareString()
            )
            
            guard let optionId else { return }
            
            completion(optionId)
        }
    }
    
    private func edit(with optionId: String) {
        Task {
            try await relationsService.updateRelationOption(
                id: optionId,
                text: text,
                color: selectedColor.middlewareString()
            )
            completion(optionId)
        }
    }
}

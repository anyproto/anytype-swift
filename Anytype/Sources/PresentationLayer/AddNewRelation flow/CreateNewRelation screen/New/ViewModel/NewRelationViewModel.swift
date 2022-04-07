import Foundation
import SwiftUI
import BlocksModels

final class NewRelationViewModel: ObservableObject {
    
    @Published var name: String
    @Published private(set) var formatModel: NewRelationFormatSectionView.Model
    @Published private(set) var objectTypesRestrictionModel: [NewRelationRestrictionsSectionView.ObjectTypeModel]?
    
    private var format: SupportedRelationFormat {
        didSet {
            formatModel = format.asViewModel
            handleNewRelationFormatUpdate()
        }
    }
    
    private var objectTypes: [ObjectType]? {
        didSet {
            objectTypesRestrictionModel = objectTypes.flatMap { $0.asViewModel }
        }
    }
    
    private weak var output: NewRelationModuleOutput?
    
    init(name: String, output: NewRelationModuleOutput?) {
        self.name = name
        self.output = output
        
        let defaultFormat = SupportedRelationFormat.text
        self.format = defaultFormat
        self.formatModel = defaultFormat.asViewModel
        
        handleNewRelationFormatUpdate()
    }
    
}

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        output?.didAskToShowRelationFormats()
    }
    
    func didTapTypesRestrictionSection() {
        output?.didAskToShowObjectTypesSearch(selectedObjectTypesIds: [])
    }
    
}

extension NewRelationViewModel: NewRelationModuleInput {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat) {
        format = newFormat
    }
    
    func updateTypesRestriction(objectTypeIds: [String]) {
        objectTypes = objectTypeIds.compactMap {
            ObjectTypeProvider.objectType(url: $0)
        }
    }
    
}

private extension NewRelationViewModel {
    
    func handleNewRelationFormatUpdate() {
        if format == .object {
            objectTypes = []
        } else {
            objectTypes = nil
        }
    }
    
}

private extension SupportedRelationFormat {
    
    var asViewModel: NewRelationFormatSectionView.Model {
        NewRelationFormatSectionView.Model(icon: self.icon, title: self.title)
    }
    
}

private extension Array where Element == ObjectType {
    
    var asViewModel: [NewRelationRestrictionsSectionView.ObjectTypeModel] {
        map {
            NewRelationRestrictionsSectionView.ObjectTypeModel(
                id: $0.url,
                emoji: $0.iconEmoji,
                title: $0.name
            )
        }
    }
    
}

import Foundation
import BlocksModels

final class RelationOptionsSectionBuilder<Option: RelationScopedOptionProtocol> {
 
    static func sections(from options: [Option]) -> [RelationOptionsSection<Option>] {
        var localOptions: [Option] = []
        var otherOptions: [Option] = []
        
        options.forEach {
            if $0.scope == .local {
                localOptions.append($0)
            } else {
                otherOptions.append($0)
            }
        }
        
        var sections: [RelationOptionsSection<Option>] = []
        
        if localOptions.isNotEmpty {
            sections.append(
                RelationOptionsSection<Option>(
                    id: "localOptionsSectionID",
                    title: "In this object".localized,
                    options: localOptions
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationOptionsSection<Option>(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    options: otherOptions
                )
            )
        }
        
        return sections
    }
    
}

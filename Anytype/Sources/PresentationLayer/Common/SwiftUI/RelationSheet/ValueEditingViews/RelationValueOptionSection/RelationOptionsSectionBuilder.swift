import Foundation
import BlocksModels

final class RelationOptionsSectionBuilder<Option: RelationSectionedOptionProtocol> {
 
    static func sections(from options: [Option], filterText: String?) -> [RelationOptionsSection<Option>] {
        let filter: (Bool, String) -> Bool = { scopeFilter, optionText in
            if let text = filterText, text.isNotEmpty {
                return scopeFilter && optionText.lowercased().contains(text.lowercased())
            }
            
            return scopeFilter
        }
        
        let localOptions = options.filter { filter($0.scope == .local, $0.text) }
        let otherOptions = options.filter { filter($0.scope != .local, $0.text) }
        
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

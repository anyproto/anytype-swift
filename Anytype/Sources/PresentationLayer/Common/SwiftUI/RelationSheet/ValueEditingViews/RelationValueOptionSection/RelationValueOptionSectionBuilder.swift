import Foundation
import BlocksModels

final class RelationValueOptionSectionBuilder<Option: RelationValueOptionProtocol> {
 
    static func sections(from options: [Option], filterText: String?) -> [RelationValueOptionSection<Option>] {
        let filter: (Bool, String) -> Bool = { scopeFilter, optionText in
            if let text = filterText, text.isNotEmpty {
                return scopeFilter && optionText.lowercased().contains(text.lowercased())
            }
            
            return scopeFilter
        }
        
        let localOptions = options.filter { filter($0.scope == .local, $0.text) }
        let otherOptions = options.filter { filter($0.scope != .local, $0.text) }
        
        var sections: [RelationValueOptionSection<Option>] = []
        if localOptions.isNotEmpty {
            sections.append(
                RelationValueOptionSection<Option>(
                    id: "localOptionsSectionID",
                    title: "In this object".localized,
                    options: localOptions
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationValueOptionSection<Option>(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    options: otherOptions
                )
            )
        }
        
        return sections
    }
    
}

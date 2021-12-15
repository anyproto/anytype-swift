import Foundation
import BlocksModels

final class RelationValueOptionSectionBuilder<V: RelationValueOptionProtocol> {
 
    static func sections(from options: [V], filterText: String?) -> [RelationValueOptionSection<V>] {
        let filter: (Bool, String) -> Bool = { scopeFilter, optionText in
            if let text = filterText, text.isNotEmpty {
                return scopeFilter && optionText.lowercased().contains(text.lowercased())
            }
            
            return scopeFilter
        }
        
        let localOptions = options.filter { filter($0.scope == .local, $0.text) }
        let otherOptions = options.filter { filter($0.scope != .local, $0.text) }
        
        var sections: [RelationValueOptionSection<V>] = []
        if localOptions.isNotEmpty {
            sections.append(
                RelationValueOptionSection<V>(
                    id: "localOptionsSectionID",
                    title: "In this object".localized,
                    options: localOptions
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                RelationValueOptionSection<V>(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    options: otherOptions
                )
            )
        }
        
        return sections
    }
    
}

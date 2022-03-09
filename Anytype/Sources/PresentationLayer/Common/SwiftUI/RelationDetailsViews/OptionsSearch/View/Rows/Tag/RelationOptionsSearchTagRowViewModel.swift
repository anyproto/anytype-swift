import Foundation

extension RelationOptionsSearchTagRowView {
    
    struct Model: Hashable, Identifiable {
        var id: String {
            tag.id
        }
        
        let tag: Relation.Tag.Option
        let guidlines: TagView.Guidlines
        
        let isSelected: Bool  
    }
    
}

extension RelationOptionsSearchTagRowView.Model {
    
    init(option: Relation.Tag.Option) {
        self.tag = option
        self.guidlines = RelationStyle.regular(allowMultiLine: false).tagViewGuidlines
        self.isSelected = false
    }
    
}

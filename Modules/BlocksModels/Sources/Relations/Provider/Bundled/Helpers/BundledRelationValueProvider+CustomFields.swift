import Foundation
import AnytypeCore
import ProtobufMessages

extension BundledRelationsValueProvider {
    
    public var isDone: Bool {
        return done
    }
    
    public var layoutValue: DetailsLayout {
        guard
            let number = layout,
            let layout = DetailsLayout(rawValue: number)
        else { return .basic }
        
        return layout
    }
    
    
    public var coverTypeValue: CoverType {
        guard
            let number = coverType,
            let coverType = CoverType(rawValue: number)
        else {
            return .none
        }
        
        return coverType
    }
    
    public var layoutAlignValue: LayoutAlignment {
        guard
            let number = layoutAlign,
            let layout = LayoutAlignment(rawValue: number)
        else {
            return .left
        }
        
        return layout
    }
    
    public var internalFlagsWithoutTemplates: [Int] {
        internalFlags.filter {
            $0 != Anytype_Model_InternalFlag.Value.editorSelectTemplate.rawValue
        }
    }
    
    public var isSelectTemplate: Bool {
        let flag = Anytype_Model_InternalFlag.Value.editorSelectTemplate.rawValue
        return internalFlags.contains(flag)
    }
    
    public var isSelectType: Bool {
        let flag = Anytype_Model_InternalFlag.Value.editorSelectType.rawValue
        return internalFlags.contains(flag)
    }
    

}

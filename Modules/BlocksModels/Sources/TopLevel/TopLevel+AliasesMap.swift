import Foundation

public typealias BlockId = String
public typealias DetailsId = String
public typealias DetailsContent = Details.Information.Content

public extension TopLevel {
    typealias BlockContent = Block.Content.ContentType
    typealias ChildrenIds = [BlockId]
    typealias BackgroundColor = String
    typealias Alignment = Block.Information.Alignment
    typealias Position = Block.Common.Position
    
    typealias BlockKind = Block.Common.Kind
    typealias FocusPosition = Block.Common.Focus.Position
    
    typealias BlockTools = Block.Tools
    typealias BlockUtilities = Block.Utilities
    
    //TODO: Remove when possible.
    /// Deprecated.
    /// We shouldn't convert details to blocks...
    typealias InformationUtilitiesDetailsBlockConverter = Block.Information.DetailsAsBlockConverter
}

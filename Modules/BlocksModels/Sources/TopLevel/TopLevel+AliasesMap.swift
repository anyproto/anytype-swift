import Foundation

public typealias BlockId = String
public typealias DetailsId = String
public typealias DetailsContent = Details.Information.Content

public extension TopLevel {
    typealias BlockContent = Block.Content.ContentType
    typealias Alignment = Block.Information.Alignment
    typealias Position = Block.Common.Position
    
    //TODO: Remove when possible.
    /// Deprecated.
    /// We shouldn't convert details to blocks...
    typealias InformationUtilitiesDetailsBlockConverter = Block.Information.DetailsAsBlockConverter
}

import Foundation

public protocol DetailsInformationModel: DetailsInformationProvider {
    
    var details: [DetailsId : DetailsContent] {get set}
    
    var parentId: String? {get set}
    
    init(_ details: [DetailsId : DetailsContent])
    
    static func defaultValue() -> Self
}

// MARK: ToList
public extension DetailsInformationModel {
    func toList() -> [DetailsContent] {
        Array(self.details.values)
    }
}

// MARK: Inits
public extension DetailsInformationModel {
    init(_ list: [DetailsContent]) {
        let keys = list.compactMap({($0.id(), $0)})
        self.init(.init(keys, uniquingKeysWith: {(_, rhs) in rhs}))
    }
}

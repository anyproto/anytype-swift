import Foundation

final class DetailsProviderBuilder: DetailsProviderBuilderProtocol {
    
    func empty() -> DetailsProviderProtocol {
        DetailsProvider([:])
    }
    
    func filled(with list: [DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol {
        let keys = list.compactMap { ($0.id, $0) }

        return DetailsProvider(
            Dictionary(keys, uniquingKeysWith: {(_, rhs) in rhs})
        )
    }
    
}

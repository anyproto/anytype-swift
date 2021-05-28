import Foundation

final class DetailsProviderBuilder: DetailsProviderBuilderProtocol {
    
    func filled(with list: [DetailsId: DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol {
        DetailsProvider(list)
    }
    
    func filled(with detailsEntries: [DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol {
        let keys = detailsEntries.compactMap { ($0.id, $0) }

        return DetailsProvider(
            Dictionary(keys, uniquingKeysWith: {(_, rhs) in rhs})
        )
    }
    
}

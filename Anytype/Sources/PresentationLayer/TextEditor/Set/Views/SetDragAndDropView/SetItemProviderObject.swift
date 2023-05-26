import Foundation

final class SetItemProviderObject: NSObject, NSItemProviderWriting {
    private static let typeIdentifier = String(describing: SetItemProviderObject.self)
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [Self.typeIdentifier]
    }

    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Swift.Void
    ) -> Progress? {
        return nil
    }
}

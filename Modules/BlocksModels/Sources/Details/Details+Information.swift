import Foundation
import os


public extension Details {
    enum Information {}
}

// MARK: Details
extension Details.Information {
    struct InformationModel {
        // MARK: Properties
        /// By default, we use `Details.id()` as a `Key` in this dictionary.
        /// But it is possible to use other id.
        ///
        private var _details: [DetailsId : DetailsContent]

        private var _parentId: String?
        
        // MARK: - Initialization
        
        /// Designed initializer.
        /// - Parameter details: A dictionary of details.
        init(_ details: [DetailsId : DetailsContent]) {
            self._details = details
        }
        
        // MARK: - Initialization / Convenience
        
        /// Create details from a list. It is required for parsing.
        /// - Parameter list: A list of details that we are converting to a `dictionary` and using `.id()` function as a `key`.
//        init(_ list: [Content]) {
//            let keys = list.compactMap({($0.id(), $0)})
//            self.details = .init(keys, uniquingKeysWith: {(_, rhs) in rhs})
//        }
        
        /// Create empty page details.
        /// It is not designed to be public.
        /// Use our static variable instead.
        ///
        private init() {
            self.init([:])
        }
    }
}

extension Details.Information.InformationModel: DetailsInformationModel {
    var details: [DetailsId : DetailsContent] {
        get {
            self._details
        }
        set {
            self._details = newValue
        }
    }
    
    var parentId: String? {
        get {
            self._parentId
        }
        set {
            self._parentId = newValue
        }
    }
    
    static func defaultValue() -> Details.Information.InformationModel {
        self.init()
    }
}

// MARK: Hashable
extension Details.Information.InformationModel: Hashable {}


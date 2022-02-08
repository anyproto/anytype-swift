import AnytypeCore

extension Result {
    func getValue(domain: ErrorDomain) -> Success? {
        switch self {
        case .success(let success):
            return success
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: domain)
            return nil
        }
    }
}

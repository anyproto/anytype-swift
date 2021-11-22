import AnytypeCore

extension Result {
    func getValue() -> Success? {
        switch self {
        case .success(let success):
            return success
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: .resultGetValue)
            return nil
        }
    }
}

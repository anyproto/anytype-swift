import Combine

/// Protocol working with user profile
protocol ProfileServiceProtocol {
    /// User name
    var name: String? { get set }
    /// User avatar
    var avatar: String? {get set }
    
    func obtainUserInformation() -> AnyPublisher<ServiceSuccess, Error>
}

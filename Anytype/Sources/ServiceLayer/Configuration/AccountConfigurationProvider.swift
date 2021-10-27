import Foundation

final class AccountConfigurationProvider: ObservableObject {
    static var shared = AccountConfigurationProvider()
    
    @Published var config = AccountConfiguration.empty
    
    init() { }
}

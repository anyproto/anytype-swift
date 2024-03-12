import ProtobufMessages
import Foundation


public protocol MembershipServiceProtocol {
    func getStatus() async throws -> MembershipStatus
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await ClientCommands.paymentsSubscriptionGetVerificationEmail(.with {
            $0.email = data.email
            $0.subscribeToNewsletter = data.subscribeToNewsletter
        }).invoke()
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await ClientCommands.paymentsSubscriptionVerifyEmailCode(.with {
            $0.code = code
        }).invoke()
    }
    
    public func getStatus() async throws -> MembershipStatus {
        return try await ClientCommands.paymentsSubscriptionGetStatus().invoke().asModel()
    }
}


typealias MiddlewareMembershipStatus = Anytype_Rpc.Payments.Subscription.GetStatus.Response
extension MiddlewareMembershipStatus {
    func asModel() -> MembershipStatus {
        MembershipStatus(
            tier: membershipTier,
            status: status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(dateEnds)),
            paymentMethod: paymentMethod
        )
    }
    
    var membershipTier: MembershipTier? {
        switch tier {
        case 0:
            nil
        case 1:
            .explorer
        case 4:
            .builder
        case 5:
            .coCreator
        default:
            .custom(id: tier)
        }
    }
}

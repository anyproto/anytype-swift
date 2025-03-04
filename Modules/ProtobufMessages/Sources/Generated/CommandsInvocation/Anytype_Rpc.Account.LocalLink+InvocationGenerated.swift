// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.Account.LocalLink.NewChallenge.Response: ResultWithError {}
extension Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.Account.LocalLink.SolveChallenge.Response: ResultWithError {}
extension Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}


// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}


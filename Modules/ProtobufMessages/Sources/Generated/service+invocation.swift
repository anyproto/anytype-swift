import Lib
import SwiftProtobuf
import Combine

public struct ClientCommands {

    public static func appGetVersion(
        _ request: Anytype_Rpc.App.GetVersion.Request = .init()
    ) -> Invocation<Anytype_Rpc.App.GetVersion.Request, Anytype_Rpc.App.GetVersion.Response> {
        return Invocation(messageName: "AppGetVersion", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAppGetVersion(requestData) ?? Data()
            return try Anytype_Rpc.App.GetVersion.Response(serializedData: responseData)
        }
    }

    public static func appSetDeviceState(
        _ request: Anytype_Rpc.App.SetDeviceState.Request = .init()
    ) -> Invocation<Anytype_Rpc.App.SetDeviceState.Request, Anytype_Rpc.App.SetDeviceState.Response> {
        return Invocation(messageName: "AppSetDeviceState", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAppSetDeviceState(requestData) ?? Data()
            return try Anytype_Rpc.App.SetDeviceState.Response(serializedData: responseData)
        }
    }

    public static func appShutdown(
        _ request: Anytype_Rpc.App.Shutdown.Request = .init()
    ) -> Invocation<Anytype_Rpc.App.Shutdown.Request, Anytype_Rpc.App.Shutdown.Response> {
        return Invocation(messageName: "AppShutdown", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAppShutdown(requestData) ?? Data()
            return try Anytype_Rpc.App.Shutdown.Response(serializedData: responseData)
        }
    }

    public static func walletCreate(
        _ request: Anytype_Rpc.Wallet.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.Wallet.Create.Request, Anytype_Rpc.Wallet.Create.Response> {
        return Invocation(messageName: "WalletCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWalletCreate(requestData) ?? Data()
            return try Anytype_Rpc.Wallet.Create.Response(serializedData: responseData)
        }
    }

    public static func walletRecover(
        _ request: Anytype_Rpc.Wallet.Recover.Request = .init()
    ) -> Invocation<Anytype_Rpc.Wallet.Recover.Request, Anytype_Rpc.Wallet.Recover.Response> {
        return Invocation(messageName: "WalletRecover", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWalletRecover(requestData) ?? Data()
            return try Anytype_Rpc.Wallet.Recover.Response(serializedData: responseData)
        }
    }

    public static func walletConvert(
        _ request: Anytype_Rpc.Wallet.Convert.Request = .init()
    ) -> Invocation<Anytype_Rpc.Wallet.Convert.Request, Anytype_Rpc.Wallet.Convert.Response> {
        return Invocation(messageName: "WalletConvert", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWalletConvert(requestData) ?? Data()
            return try Anytype_Rpc.Wallet.Convert.Response(serializedData: responseData)
        }
    }

    public static func accountLocalLinkNewChallenge(
        _ request: Anytype_Rpc.Account.LocalLink.NewChallenge.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.LocalLink.NewChallenge.Request, Anytype_Rpc.Account.LocalLink.NewChallenge.Response> {
        return Invocation(messageName: "AccountLocalLinkNewChallenge", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountLocalLinkNewChallenge(requestData) ?? Data()
            return try Anytype_Rpc.Account.LocalLink.NewChallenge.Response(serializedData: responseData)
        }
    }

    public static func accountLocalLinkSolveChallenge(
        _ request: Anytype_Rpc.Account.LocalLink.SolveChallenge.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.LocalLink.SolveChallenge.Request, Anytype_Rpc.Account.LocalLink.SolveChallenge.Response> {
        return Invocation(messageName: "AccountLocalLinkSolveChallenge", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountLocalLinkSolveChallenge(requestData) ?? Data()
            return try Anytype_Rpc.Account.LocalLink.SolveChallenge.Response(serializedData: responseData)
        }
    }

    public static func walletCreateSession(
        _ request: Anytype_Rpc.Wallet.CreateSession.Request = .init()
    ) -> Invocation<Anytype_Rpc.Wallet.CreateSession.Request, Anytype_Rpc.Wallet.CreateSession.Response> {
        return Invocation(messageName: "WalletCreateSession", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWalletCreateSession(requestData) ?? Data()
            return try Anytype_Rpc.Wallet.CreateSession.Response(serializedData: responseData)
        }
    }

    public static func walletCloseSession(
        _ request: Anytype_Rpc.Wallet.CloseSession.Request = .init()
    ) -> Invocation<Anytype_Rpc.Wallet.CloseSession.Request, Anytype_Rpc.Wallet.CloseSession.Response> {
        return Invocation(messageName: "WalletCloseSession", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWalletCloseSession(requestData) ?? Data()
            return try Anytype_Rpc.Wallet.CloseSession.Response(serializedData: responseData)
        }
    }

    public static func workspaceCreate(
        _ request: Anytype_Rpc.Workspace.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Create.Request, Anytype_Rpc.Workspace.Create.Response> {
        return Invocation(messageName: "WorkspaceCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceCreate(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Create.Response(serializedData: responseData)
        }
    }

    public static func workspaceOpen(
        _ request: Anytype_Rpc.Workspace.Open.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Open.Request, Anytype_Rpc.Workspace.Open.Response> {
        return Invocation(messageName: "WorkspaceOpen", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceOpen(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Open.Response(serializedData: responseData)
        }
    }

    public static func workspaceObjectAdd(
        _ request: Anytype_Rpc.Workspace.Object.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Object.Add.Request, Anytype_Rpc.Workspace.Object.Add.Response> {
        return Invocation(messageName: "WorkspaceObjectAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceObjectAdd(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Object.Add.Response(serializedData: responseData)
        }
    }

    public static func workspaceObjectListAdd(
        _ request: Anytype_Rpc.Workspace.Object.ListAdd.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Object.ListAdd.Request, Anytype_Rpc.Workspace.Object.ListAdd.Response> {
        return Invocation(messageName: "WorkspaceObjectListAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceObjectListAdd(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Object.ListAdd.Response(serializedData: responseData)
        }
    }

    public static func workspaceObjectListRemove(
        _ request: Anytype_Rpc.Workspace.Object.ListRemove.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Object.ListRemove.Request, Anytype_Rpc.Workspace.Object.ListRemove.Response> {
        return Invocation(messageName: "WorkspaceObjectListRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceObjectListRemove(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Object.ListRemove.Response(serializedData: responseData)
        }
    }

    public static func workspaceSelect(
        _ request: Anytype_Rpc.Workspace.Select.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Select.Request, Anytype_Rpc.Workspace.Select.Response> {
        return Invocation(messageName: "WorkspaceSelect", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceSelect(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Select.Response(serializedData: responseData)
        }
    }

    public static func workspaceGetCurrent(
        _ request: Anytype_Rpc.Workspace.GetCurrent.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.GetCurrent.Request, Anytype_Rpc.Workspace.GetCurrent.Response> {
        return Invocation(messageName: "WorkspaceGetCurrent", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceGetCurrent(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.GetCurrent.Response(serializedData: responseData)
        }
    }

    public static func workspaceGetAll(
        _ request: Anytype_Rpc.Workspace.GetAll.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.GetAll.Request, Anytype_Rpc.Workspace.GetAll.Response> {
        return Invocation(messageName: "WorkspaceGetAll", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceGetAll(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.GetAll.Response(serializedData: responseData)
        }
    }

    public static func workspaceSetInfo(
        _ request: Anytype_Rpc.Workspace.SetInfo.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.SetInfo.Request, Anytype_Rpc.Workspace.SetInfo.Response> {
        return Invocation(messageName: "WorkspaceSetInfo", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceSetInfo(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.SetInfo.Response(serializedData: responseData)
        }
    }

    public static func workspaceExport(
        _ request: Anytype_Rpc.Workspace.Export.Request = .init()
    ) -> Invocation<Anytype_Rpc.Workspace.Export.Request, Anytype_Rpc.Workspace.Export.Response> {
        return Invocation(messageName: "WorkspaceExport", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceWorkspaceExport(requestData) ?? Data()
            return try Anytype_Rpc.Workspace.Export.Response(serializedData: responseData)
        }
    }

    public static func accountRecover(
        _ request: Anytype_Rpc.Account.Recover.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Recover.Request, Anytype_Rpc.Account.Recover.Response> {
        return Invocation(messageName: "AccountRecover", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountRecover(requestData) ?? Data()
            return try Anytype_Rpc.Account.Recover.Response(serializedData: responseData)
        }
    }

    public static func accountCreate(
        _ request: Anytype_Rpc.Account.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Create.Request, Anytype_Rpc.Account.Create.Response> {
        return Invocation(messageName: "AccountCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountCreate(requestData) ?? Data()
            return try Anytype_Rpc.Account.Create.Response(serializedData: responseData)
        }
    }

    public static func accountDelete(
        _ request: Anytype_Rpc.Account.Delete.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Delete.Request, Anytype_Rpc.Account.Delete.Response> {
        return Invocation(messageName: "AccountDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountDelete(requestData) ?? Data()
            return try Anytype_Rpc.Account.Delete.Response(serializedData: responseData)
        }
    }

    public static func accountRevertDeletion(
        _ request: Anytype_Rpc.Account.RevertDeletion.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.RevertDeletion.Request, Anytype_Rpc.Account.RevertDeletion.Response> {
        return Invocation(messageName: "AccountRevertDeletion", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountRevertDeletion(requestData) ?? Data()
            return try Anytype_Rpc.Account.RevertDeletion.Response(serializedData: responseData)
        }
    }

    public static func accountSelect(
        _ request: Anytype_Rpc.Account.Select.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Select.Request, Anytype_Rpc.Account.Select.Response> {
        return Invocation(messageName: "AccountSelect", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountSelect(requestData) ?? Data()
            return try Anytype_Rpc.Account.Select.Response(serializedData: responseData)
        }
    }

    public static func accountEnableLocalNetworkSync(
        _ request: Anytype_Rpc.Account.EnableLocalNetworkSync.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.EnableLocalNetworkSync.Request, Anytype_Rpc.Account.EnableLocalNetworkSync.Response> {
        return Invocation(messageName: "AccountEnableLocalNetworkSync", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountEnableLocalNetworkSync(requestData) ?? Data()
            return try Anytype_Rpc.Account.EnableLocalNetworkSync.Response(serializedData: responseData)
        }
    }

    public static func accountStop(
        _ request: Anytype_Rpc.Account.Stop.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Stop.Request, Anytype_Rpc.Account.Stop.Response> {
        return Invocation(messageName: "AccountStop", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountStop(requestData) ?? Data()
            return try Anytype_Rpc.Account.Stop.Response(serializedData: responseData)
        }
    }

    public static func accountMove(
        _ request: Anytype_Rpc.Account.Move.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.Move.Request, Anytype_Rpc.Account.Move.Response> {
        return Invocation(messageName: "AccountMove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountMove(requestData) ?? Data()
            return try Anytype_Rpc.Account.Move.Response(serializedData: responseData)
        }
    }

    public static func accountConfigUpdate(
        _ request: Anytype_Rpc.Account.ConfigUpdate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.ConfigUpdate.Request, Anytype_Rpc.Account.ConfigUpdate.Response> {
        return Invocation(messageName: "AccountConfigUpdate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountConfigUpdate(requestData) ?? Data()
            return try Anytype_Rpc.Account.ConfigUpdate.Response(serializedData: responseData)
        }
    }

    public static func accountRecoverFromLegacyExport(
        _ request: Anytype_Rpc.Account.RecoverFromLegacyExport.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.RecoverFromLegacyExport.Request, Anytype_Rpc.Account.RecoverFromLegacyExport.Response> {
        return Invocation(messageName: "AccountRecoverFromLegacyExport", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountRecoverFromLegacyExport(requestData) ?? Data()
            return try Anytype_Rpc.Account.RecoverFromLegacyExport.Response(serializedData: responseData)
        }
    }

    public static func accountChangeNetworkConfigAndRestart(
        _ request: Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Request = .init()
    ) -> Invocation<Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Request, Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Response> {
        return Invocation(messageName: "AccountChangeNetworkConfigAndRestart", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceAccountChangeNetworkConfigAndRestart(requestData) ?? Data()
            return try Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Response(serializedData: responseData)
        }
    }

    public static func spaceDelete(
        _ request: Anytype_Rpc.Space.Delete.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.Delete.Request, Anytype_Rpc.Space.Delete.Response> {
        return Invocation(messageName: "SpaceDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceDelete(requestData) ?? Data()
            return try Anytype_Rpc.Space.Delete.Response(serializedData: responseData)
        }
    }

    public static func spaceInviteGenerate(
        _ request: Anytype_Rpc.Space.InviteGenerate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.InviteGenerate.Request, Anytype_Rpc.Space.InviteGenerate.Response> {
        return Invocation(messageName: "SpaceInviteGenerate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceInviteGenerate(requestData) ?? Data()
            return try Anytype_Rpc.Space.InviteGenerate.Response(serializedData: responseData)
        }
    }

    public static func spaceInviteGetCurrent(
        _ request: Anytype_Rpc.Space.InviteGetCurrent.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.InviteGetCurrent.Request, Anytype_Rpc.Space.InviteGetCurrent.Response> {
        return Invocation(messageName: "SpaceInviteGetCurrent", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceInviteGetCurrent(requestData) ?? Data()
            return try Anytype_Rpc.Space.InviteGetCurrent.Response(serializedData: responseData)
        }
    }

    public static func spaceInviteRevoke(
        _ request: Anytype_Rpc.Space.InviteRevoke.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.InviteRevoke.Request, Anytype_Rpc.Space.InviteRevoke.Response> {
        return Invocation(messageName: "SpaceInviteRevoke", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceInviteRevoke(requestData) ?? Data()
            return try Anytype_Rpc.Space.InviteRevoke.Response(serializedData: responseData)
        }
    }

    public static func spaceInviteView(
        _ request: Anytype_Rpc.Space.InviteView.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.InviteView.Request, Anytype_Rpc.Space.InviteView.Response> {
        return Invocation(messageName: "SpaceInviteView", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceInviteView(requestData) ?? Data()
            return try Anytype_Rpc.Space.InviteView.Response(serializedData: responseData)
        }
    }

    public static func spaceJoin(
        _ request: Anytype_Rpc.Space.Join.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.Join.Request, Anytype_Rpc.Space.Join.Response> {
        return Invocation(messageName: "SpaceJoin", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceJoin(requestData) ?? Data()
            return try Anytype_Rpc.Space.Join.Response(serializedData: responseData)
        }
    }

    public static func spaceJoinCancel(
        _ request: Anytype_Rpc.Space.JoinCancel.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.JoinCancel.Request, Anytype_Rpc.Space.JoinCancel.Response> {
        return Invocation(messageName: "SpaceJoinCancel", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceJoinCancel(requestData) ?? Data()
            return try Anytype_Rpc.Space.JoinCancel.Response(serializedData: responseData)
        }
    }

    public static func spaceStopSharing(
        _ request: Anytype_Rpc.Space.StopSharing.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.StopSharing.Request, Anytype_Rpc.Space.StopSharing.Response> {
        return Invocation(messageName: "SpaceStopSharing", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceStopSharing(requestData) ?? Data()
            return try Anytype_Rpc.Space.StopSharing.Response(serializedData: responseData)
        }
    }

    public static func spaceRequestApprove(
        _ request: Anytype_Rpc.Space.RequestApprove.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.RequestApprove.Request, Anytype_Rpc.Space.RequestApprove.Response> {
        return Invocation(messageName: "SpaceRequestApprove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceRequestApprove(requestData) ?? Data()
            return try Anytype_Rpc.Space.RequestApprove.Response(serializedData: responseData)
        }
    }

    public static func spaceRequestDecline(
        _ request: Anytype_Rpc.Space.RequestDecline.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.RequestDecline.Request, Anytype_Rpc.Space.RequestDecline.Response> {
        return Invocation(messageName: "SpaceRequestDecline", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceRequestDecline(requestData) ?? Data()
            return try Anytype_Rpc.Space.RequestDecline.Response(serializedData: responseData)
        }
    }

    public static func spaceLeaveApprove(
        _ request: Anytype_Rpc.Space.LeaveApprove.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.LeaveApprove.Request, Anytype_Rpc.Space.LeaveApprove.Response> {
        return Invocation(messageName: "SpaceLeaveApprove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceLeaveApprove(requestData) ?? Data()
            return try Anytype_Rpc.Space.LeaveApprove.Response(serializedData: responseData)
        }
    }

    public static func spaceMakeShareable(
        _ request: Anytype_Rpc.Space.MakeShareable.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.MakeShareable.Request, Anytype_Rpc.Space.MakeShareable.Response> {
        return Invocation(messageName: "SpaceMakeShareable", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceMakeShareable(requestData) ?? Data()
            return try Anytype_Rpc.Space.MakeShareable.Response(serializedData: responseData)
        }
    }

    public static func spaceParticipantRemove(
        _ request: Anytype_Rpc.Space.ParticipantRemove.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.ParticipantRemove.Request, Anytype_Rpc.Space.ParticipantRemove.Response> {
        return Invocation(messageName: "SpaceParticipantRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceParticipantRemove(requestData) ?? Data()
            return try Anytype_Rpc.Space.ParticipantRemove.Response(serializedData: responseData)
        }
    }

    public static func spaceParticipantPermissionsChange(
        _ request: Anytype_Rpc.Space.ParticipantPermissionsChange.Request = .init()
    ) -> Invocation<Anytype_Rpc.Space.ParticipantPermissionsChange.Request, Anytype_Rpc.Space.ParticipantPermissionsChange.Response> {
        return Invocation(messageName: "SpaceParticipantPermissionsChange", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceSpaceParticipantPermissionsChange(requestData) ?? Data()
            return try Anytype_Rpc.Space.ParticipantPermissionsChange.Response(serializedData: responseData)
        }
    }

    public static func objectOpen(
        _ request: Anytype_Rpc.Object.Open.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Open.Request, Anytype_Rpc.Object.Open.Response> {
        return Invocation(messageName: "ObjectOpen", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectOpen(requestData) ?? Data()
            return try Anytype_Rpc.Object.Open.Response(serializedData: responseData)
        }
    }

    public static func objectClose(
        _ request: Anytype_Rpc.Object.Close.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Close.Request, Anytype_Rpc.Object.Close.Response> {
        return Invocation(messageName: "ObjectClose", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectClose(requestData) ?? Data()
            return try Anytype_Rpc.Object.Close.Response(serializedData: responseData)
        }
    }

    public static func objectShow(
        _ request: Anytype_Rpc.Object.Show.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Show.Request, Anytype_Rpc.Object.Show.Response> {
        return Invocation(messageName: "ObjectShow", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectShow(requestData) ?? Data()
            return try Anytype_Rpc.Object.Show.Response(serializedData: responseData)
        }
    }

    public static func objectCreate(
        _ request: Anytype_Rpc.Object.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Create.Request, Anytype_Rpc.Object.Create.Response> {
        return Invocation(messageName: "ObjectCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreate(requestData) ?? Data()
            return try Anytype_Rpc.Object.Create.Response(serializedData: responseData)
        }
    }

    public static func objectCreateBookmark(
        _ request: Anytype_Rpc.Object.CreateBookmark.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateBookmark.Request, Anytype_Rpc.Object.CreateBookmark.Response> {
        return Invocation(messageName: "ObjectCreateBookmark", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateBookmark(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateBookmark.Response(serializedData: responseData)
        }
    }

    public static func objectCreateFromUrl(
        _ request: Anytype_Rpc.Object.CreateFromUrl.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateFromUrl.Request, Anytype_Rpc.Object.CreateFromUrl.Response> {
        return Invocation(messageName: "ObjectCreateFromUrl", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateFromUrl(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateFromUrl.Response(serializedData: responseData)
        }
    }

    public static func objectCreateSet(
        _ request: Anytype_Rpc.Object.CreateSet.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateSet.Request, Anytype_Rpc.Object.CreateSet.Response> {
        return Invocation(messageName: "ObjectCreateSet", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateSet(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateSet.Response(serializedData: responseData)
        }
    }

    public static func objectGraph(
        _ request: Anytype_Rpc.Object.Graph.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Graph.Request, Anytype_Rpc.Object.Graph.Response> {
        return Invocation(messageName: "ObjectGraph", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectGraph(requestData) ?? Data()
            return try Anytype_Rpc.Object.Graph.Response(serializedData: responseData)
        }
    }

    public static func objectSearch(
        _ request: Anytype_Rpc.Object.Search.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Search.Request, Anytype_Rpc.Object.Search.Response> {
        return Invocation(messageName: "ObjectSearch", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSearch(requestData) ?? Data()
            return try Anytype_Rpc.Object.Search.Response(serializedData: responseData)
        }
    }

    public static func objectSearchWithMeta(
        _ request: Anytype_Rpc.Object.SearchWithMeta.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SearchWithMeta.Request, Anytype_Rpc.Object.SearchWithMeta.Response> {
        return Invocation(messageName: "ObjectSearchWithMeta", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSearchWithMeta(requestData) ?? Data()
            return try Anytype_Rpc.Object.SearchWithMeta.Response(serializedData: responseData)
        }
    }

    public static func objectSearchSubscribe(
        _ request: Anytype_Rpc.Object.SearchSubscribe.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SearchSubscribe.Request, Anytype_Rpc.Object.SearchSubscribe.Response> {
        return Invocation(messageName: "ObjectSearchSubscribe", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSearchSubscribe(requestData) ?? Data()
            return try Anytype_Rpc.Object.SearchSubscribe.Response(serializedData: responseData)
        }
    }

    public static func objectSubscribeIds(
        _ request: Anytype_Rpc.Object.SubscribeIds.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SubscribeIds.Request, Anytype_Rpc.Object.SubscribeIds.Response> {
        return Invocation(messageName: "ObjectSubscribeIds", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSubscribeIds(requestData) ?? Data()
            return try Anytype_Rpc.Object.SubscribeIds.Response(serializedData: responseData)
        }
    }

    public static func objectGroupsSubscribe(
        _ request: Anytype_Rpc.Object.GroupsSubscribe.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.GroupsSubscribe.Request, Anytype_Rpc.Object.GroupsSubscribe.Response> {
        return Invocation(messageName: "ObjectGroupsSubscribe", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectGroupsSubscribe(requestData) ?? Data()
            return try Anytype_Rpc.Object.GroupsSubscribe.Response(serializedData: responseData)
        }
    }

    public static func objectSearchUnsubscribe(
        _ request: Anytype_Rpc.Object.SearchUnsubscribe.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SearchUnsubscribe.Request, Anytype_Rpc.Object.SearchUnsubscribe.Response> {
        return Invocation(messageName: "ObjectSearchUnsubscribe", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSearchUnsubscribe(requestData) ?? Data()
            return try Anytype_Rpc.Object.SearchUnsubscribe.Response(serializedData: responseData)
        }
    }

    public static func objectSetDetails(
        _ request: Anytype_Rpc.Object.SetDetails.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetDetails.Request, Anytype_Rpc.Object.SetDetails.Response> {
        return Invocation(messageName: "ObjectSetDetails", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetDetails(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetDetails.Response(serializedData: responseData)
        }
    }

    public static func objectDuplicate(
        _ request: Anytype_Rpc.Object.Duplicate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Duplicate.Request, Anytype_Rpc.Object.Duplicate.Response> {
        return Invocation(messageName: "ObjectDuplicate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectDuplicate(requestData) ?? Data()
            return try Anytype_Rpc.Object.Duplicate.Response(serializedData: responseData)
        }
    }

    public static func objectSetObjectType(
        _ request: Anytype_Rpc.Object.SetObjectType.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetObjectType.Request, Anytype_Rpc.Object.SetObjectType.Response> {
        return Invocation(messageName: "ObjectSetObjectType", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetObjectType(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetObjectType.Response(serializedData: responseData)
        }
    }

    public static func objectSetLayout(
        _ request: Anytype_Rpc.Object.SetLayout.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetLayout.Request, Anytype_Rpc.Object.SetLayout.Response> {
        return Invocation(messageName: "ObjectSetLayout", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetLayout(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetLayout.Response(serializedData: responseData)
        }
    }

    public static func objectSetInternalFlags(
        _ request: Anytype_Rpc.Object.SetInternalFlags.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetInternalFlags.Request, Anytype_Rpc.Object.SetInternalFlags.Response> {
        return Invocation(messageName: "ObjectSetInternalFlags", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetInternalFlags(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetInternalFlags.Response(serializedData: responseData)
        }
    }

    public static func objectSetIsFavorite(
        _ request: Anytype_Rpc.Object.SetIsFavorite.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetIsFavorite.Request, Anytype_Rpc.Object.SetIsFavorite.Response> {
        return Invocation(messageName: "ObjectSetIsFavorite", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetIsFavorite(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetIsFavorite.Response(serializedData: responseData)
        }
    }

    public static func objectSetIsArchived(
        _ request: Anytype_Rpc.Object.SetIsArchived.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetIsArchived.Request, Anytype_Rpc.Object.SetIsArchived.Response> {
        return Invocation(messageName: "ObjectSetIsArchived", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetIsArchived(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetIsArchived.Response(serializedData: responseData)
        }
    }

    public static func objectSetSource(
        _ request: Anytype_Rpc.Object.SetSource.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.SetSource.Request, Anytype_Rpc.Object.SetSource.Response> {
        return Invocation(messageName: "ObjectSetSource", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectSetSource(requestData) ?? Data()
            return try Anytype_Rpc.Object.SetSource.Response(serializedData: responseData)
        }
    }

    public static func objectWorkspaceSetDashboard(
        _ request: Anytype_Rpc.Object.WorkspaceSetDashboard.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.WorkspaceSetDashboard.Request, Anytype_Rpc.Object.WorkspaceSetDashboard.Response> {
        return Invocation(messageName: "ObjectWorkspaceSetDashboard", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectWorkspaceSetDashboard(requestData) ?? Data()
            return try Anytype_Rpc.Object.WorkspaceSetDashboard.Response(serializedData: responseData)
        }
    }

    public static func objectListDuplicate(
        _ request: Anytype_Rpc.Object.ListDuplicate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListDuplicate.Request, Anytype_Rpc.Object.ListDuplicate.Response> {
        return Invocation(messageName: "ObjectListDuplicate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListDuplicate(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListDuplicate.Response(serializedData: responseData)
        }
    }

    public static func objectListDelete(
        _ request: Anytype_Rpc.Object.ListDelete.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListDelete.Request, Anytype_Rpc.Object.ListDelete.Response> {
        return Invocation(messageName: "ObjectListDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListDelete(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListDelete.Response(serializedData: responseData)
        }
    }

    public static func objectListSetIsArchived(
        _ request: Anytype_Rpc.Object.ListSetIsArchived.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListSetIsArchived.Request, Anytype_Rpc.Object.ListSetIsArchived.Response> {
        return Invocation(messageName: "ObjectListSetIsArchived", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListSetIsArchived(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListSetIsArchived.Response(serializedData: responseData)
        }
    }

    public static func objectListSetIsFavorite(
        _ request: Anytype_Rpc.Object.ListSetIsFavorite.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListSetIsFavorite.Request, Anytype_Rpc.Object.ListSetIsFavorite.Response> {
        return Invocation(messageName: "ObjectListSetIsFavorite", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListSetIsFavorite(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListSetIsFavorite.Response(serializedData: responseData)
        }
    }

    public static func objectListSetObjectType(
        _ request: Anytype_Rpc.Object.ListSetObjectType.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListSetObjectType.Request, Anytype_Rpc.Object.ListSetObjectType.Response> {
        return Invocation(messageName: "ObjectListSetObjectType", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListSetObjectType(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListSetObjectType.Response(serializedData: responseData)
        }
    }

    public static func objectListSetDetails(
        _ request: Anytype_Rpc.Object.ListSetDetails.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListSetDetails.Request, Anytype_Rpc.Object.ListSetDetails.Response> {
        return Invocation(messageName: "ObjectListSetDetails", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListSetDetails(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListSetDetails.Response(serializedData: responseData)
        }
    }

    public static func objectListModifyDetailValues(
        _ request: Anytype_Rpc.Object.ListModifyDetailValues.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListModifyDetailValues.Request, Anytype_Rpc.Object.ListModifyDetailValues.Response> {
        return Invocation(messageName: "ObjectListModifyDetailValues", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListModifyDetailValues(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListModifyDetailValues.Response(serializedData: responseData)
        }
    }

    public static func objectApplyTemplate(
        _ request: Anytype_Rpc.Object.ApplyTemplate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ApplyTemplate.Request, Anytype_Rpc.Object.ApplyTemplate.Response> {
        return Invocation(messageName: "ObjectApplyTemplate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectApplyTemplate(requestData) ?? Data()
            return try Anytype_Rpc.Object.ApplyTemplate.Response(serializedData: responseData)
        }
    }

    public static func objectToSet(
        _ request: Anytype_Rpc.Object.ToSet.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ToSet.Request, Anytype_Rpc.Object.ToSet.Response> {
        return Invocation(messageName: "ObjectToSet", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectToSet(requestData) ?? Data()
            return try Anytype_Rpc.Object.ToSet.Response(serializedData: responseData)
        }
    }

    public static func objectToCollection(
        _ request: Anytype_Rpc.Object.ToCollection.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ToCollection.Request, Anytype_Rpc.Object.ToCollection.Response> {
        return Invocation(messageName: "ObjectToCollection", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectToCollection(requestData) ?? Data()
            return try Anytype_Rpc.Object.ToCollection.Response(serializedData: responseData)
        }
    }

    public static func objectShareByLink(
        _ request: Anytype_Rpc.Object.ShareByLink.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ShareByLink.Request, Anytype_Rpc.Object.ShareByLink.Response> {
        return Invocation(messageName: "ObjectShareByLink", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectShareByLink(requestData) ?? Data()
            return try Anytype_Rpc.Object.ShareByLink.Response(serializedData: responseData)
        }
    }

    public static func objectUndo(
        _ request: Anytype_Rpc.Object.Undo.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Undo.Request, Anytype_Rpc.Object.Undo.Response> {
        return Invocation(messageName: "ObjectUndo", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectUndo(requestData) ?? Data()
            return try Anytype_Rpc.Object.Undo.Response(serializedData: responseData)
        }
    }

    public static func objectRedo(
        _ request: Anytype_Rpc.Object.Redo.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Redo.Request, Anytype_Rpc.Object.Redo.Response> {
        return Invocation(messageName: "ObjectRedo", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRedo(requestData) ?? Data()
            return try Anytype_Rpc.Object.Redo.Response(serializedData: responseData)
        }
    }

    public static func objectListExport(
        _ request: Anytype_Rpc.Object.ListExport.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ListExport.Request, Anytype_Rpc.Object.ListExport.Response> {
        return Invocation(messageName: "ObjectListExport", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectListExport(requestData) ?? Data()
            return try Anytype_Rpc.Object.ListExport.Response(serializedData: responseData)
        }
    }

    public static func objectBookmarkFetch(
        _ request: Anytype_Rpc.Object.BookmarkFetch.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.BookmarkFetch.Request, Anytype_Rpc.Object.BookmarkFetch.Response> {
        return Invocation(messageName: "ObjectBookmarkFetch", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectBookmarkFetch(requestData) ?? Data()
            return try Anytype_Rpc.Object.BookmarkFetch.Response(serializedData: responseData)
        }
    }

    public static func objectToBookmark(
        _ request: Anytype_Rpc.Object.ToBookmark.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ToBookmark.Request, Anytype_Rpc.Object.ToBookmark.Response> {
        return Invocation(messageName: "ObjectToBookmark", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectToBookmark(requestData) ?? Data()
            return try Anytype_Rpc.Object.ToBookmark.Response(serializedData: responseData)
        }
    }

    public static func objectImport(
        _ request: Anytype_Rpc.Object.Import.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Import.Request, Anytype_Rpc.Object.Import.Response> {
        return Invocation(messageName: "ObjectImport", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectImport(requestData) ?? Data()
            return try Anytype_Rpc.Object.Import.Response(serializedData: responseData)
        }
    }

    public static func objectImportList(
        _ request: Anytype_Rpc.Object.ImportList.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ImportList.Request, Anytype_Rpc.Object.ImportList.Response> {
        return Invocation(messageName: "ObjectImportList", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectImportList(requestData) ?? Data()
            return try Anytype_Rpc.Object.ImportList.Response(serializedData: responseData)
        }
    }

    public static func objectImportNotionValidateToken(
        _ request: Anytype_Rpc.Object.Import.Notion.ValidateToken.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.Import.Notion.ValidateToken.Request, Anytype_Rpc.Object.Import.Notion.ValidateToken.Response> {
        return Invocation(messageName: "ObjectImportNotionValidateToken", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectImportNotionValidateToken(requestData) ?? Data()
            return try Anytype_Rpc.Object.Import.Notion.ValidateToken.Response(serializedData: responseData)
        }
    }

    public static func objectImportUseCase(
        _ request: Anytype_Rpc.Object.ImportUseCase.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ImportUseCase.Request, Anytype_Rpc.Object.ImportUseCase.Response> {
        return Invocation(messageName: "ObjectImportUseCase", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectImportUseCase(requestData) ?? Data()
            return try Anytype_Rpc.Object.ImportUseCase.Response(serializedData: responseData)
        }
    }

    public static func objectImportExperience(
        _ request: Anytype_Rpc.Object.ImportExperience.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ImportExperience.Request, Anytype_Rpc.Object.ImportExperience.Response> {
        return Invocation(messageName: "ObjectImportExperience", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectImportExperience(requestData) ?? Data()
            return try Anytype_Rpc.Object.ImportExperience.Response(serializedData: responseData)
        }
    }

    public static func objectCollectionAdd(
        _ request: Anytype_Rpc.ObjectCollection.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectCollection.Add.Request, Anytype_Rpc.ObjectCollection.Add.Response> {
        return Invocation(messageName: "ObjectCollectionAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCollectionAdd(requestData) ?? Data()
            return try Anytype_Rpc.ObjectCollection.Add.Response(serializedData: responseData)
        }
    }

    public static func objectCollectionRemove(
        _ request: Anytype_Rpc.ObjectCollection.Remove.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectCollection.Remove.Request, Anytype_Rpc.ObjectCollection.Remove.Response> {
        return Invocation(messageName: "ObjectCollectionRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCollectionRemove(requestData) ?? Data()
            return try Anytype_Rpc.ObjectCollection.Remove.Response(serializedData: responseData)
        }
    }

    public static func objectCollectionSort(
        _ request: Anytype_Rpc.ObjectCollection.Sort.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectCollection.Sort.Request, Anytype_Rpc.ObjectCollection.Sort.Response> {
        return Invocation(messageName: "ObjectCollectionSort", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCollectionSort(requestData) ?? Data()
            return try Anytype_Rpc.ObjectCollection.Sort.Response(serializedData: responseData)
        }
    }

    public static func objectCreateRelation(
        _ request: Anytype_Rpc.Object.CreateRelation.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateRelation.Request, Anytype_Rpc.Object.CreateRelation.Response> {
        return Invocation(messageName: "ObjectCreateRelation", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateRelation(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateRelation.Response(serializedData: responseData)
        }
    }

    public static func objectCreateRelationOption(
        _ request: Anytype_Rpc.Object.CreateRelationOption.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateRelationOption.Request, Anytype_Rpc.Object.CreateRelationOption.Response> {
        return Invocation(messageName: "ObjectCreateRelationOption", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateRelationOption(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateRelationOption.Response(serializedData: responseData)
        }
    }

    public static func relationListRemoveOption(
        _ request: Anytype_Rpc.Relation.ListRemoveOption.Request = .init()
    ) -> Invocation<Anytype_Rpc.Relation.ListRemoveOption.Request, Anytype_Rpc.Relation.ListRemoveOption.Response> {
        return Invocation(messageName: "RelationListRemoveOption", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceRelationListRemoveOption(requestData) ?? Data()
            return try Anytype_Rpc.Relation.ListRemoveOption.Response(serializedData: responseData)
        }
    }

    public static func relationOptions(
        _ request: Anytype_Rpc.Relation.Options.Request = .init()
    ) -> Invocation<Anytype_Rpc.Relation.Options.Request, Anytype_Rpc.Relation.Options.Response> {
        return Invocation(messageName: "RelationOptions", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceRelationOptions(requestData) ?? Data()
            return try Anytype_Rpc.Relation.Options.Response(serializedData: responseData)
        }
    }

    public static func objectRelationAdd(
        _ request: Anytype_Rpc.ObjectRelation.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectRelation.Add.Request, Anytype_Rpc.ObjectRelation.Add.Response> {
        return Invocation(messageName: "ObjectRelationAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRelationAdd(requestData) ?? Data()
            return try Anytype_Rpc.ObjectRelation.Add.Response(serializedData: responseData)
        }
    }

    public static func objectRelationDelete(
        _ request: Anytype_Rpc.ObjectRelation.Delete.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectRelation.Delete.Request, Anytype_Rpc.ObjectRelation.Delete.Response> {
        return Invocation(messageName: "ObjectRelationDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRelationDelete(requestData) ?? Data()
            return try Anytype_Rpc.ObjectRelation.Delete.Response(serializedData: responseData)
        }
    }

    public static func objectRelationAddFeatured(
        _ request: Anytype_Rpc.ObjectRelation.AddFeatured.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectRelation.AddFeatured.Request, Anytype_Rpc.ObjectRelation.AddFeatured.Response> {
        return Invocation(messageName: "ObjectRelationAddFeatured", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRelationAddFeatured(requestData) ?? Data()
            return try Anytype_Rpc.ObjectRelation.AddFeatured.Response(serializedData: responseData)
        }
    }

    public static func objectRelationRemoveFeatured(
        _ request: Anytype_Rpc.ObjectRelation.RemoveFeatured.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectRelation.RemoveFeatured.Request, Anytype_Rpc.ObjectRelation.RemoveFeatured.Response> {
        return Invocation(messageName: "ObjectRelationRemoveFeatured", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRelationRemoveFeatured(requestData) ?? Data()
            return try Anytype_Rpc.ObjectRelation.RemoveFeatured.Response(serializedData: responseData)
        }
    }

    public static func objectRelationListAvailable(
        _ request: Anytype_Rpc.ObjectRelation.ListAvailable.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectRelation.ListAvailable.Request, Anytype_Rpc.ObjectRelation.ListAvailable.Response> {
        return Invocation(messageName: "ObjectRelationListAvailable", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectRelationListAvailable(requestData) ?? Data()
            return try Anytype_Rpc.ObjectRelation.ListAvailable.Response(serializedData: responseData)
        }
    }

    public static func objectCreateObjectType(
        _ request: Anytype_Rpc.Object.CreateObjectType.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.CreateObjectType.Request, Anytype_Rpc.Object.CreateObjectType.Response> {
        return Invocation(messageName: "ObjectCreateObjectType", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectCreateObjectType(requestData) ?? Data()
            return try Anytype_Rpc.Object.CreateObjectType.Response(serializedData: responseData)
        }
    }

    public static func objectTypeRelationAdd(
        _ request: Anytype_Rpc.ObjectType.Relation.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectType.Relation.Add.Request, Anytype_Rpc.ObjectType.Relation.Add.Response> {
        return Invocation(messageName: "ObjectTypeRelationAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectTypeRelationAdd(requestData) ?? Data()
            return try Anytype_Rpc.ObjectType.Relation.Add.Response(serializedData: responseData)
        }
    }

    public static func objectTypeRelationRemove(
        _ request: Anytype_Rpc.ObjectType.Relation.Remove.Request = .init()
    ) -> Invocation<Anytype_Rpc.ObjectType.Relation.Remove.Request, Anytype_Rpc.ObjectType.Relation.Remove.Response> {
        return Invocation(messageName: "ObjectTypeRelationRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectTypeRelationRemove(requestData) ?? Data()
            return try Anytype_Rpc.ObjectType.Relation.Remove.Response(serializedData: responseData)
        }
    }

    public static func historyShowVersion(
        _ request: Anytype_Rpc.History.ShowVersion.Request = .init()
    ) -> Invocation<Anytype_Rpc.History.ShowVersion.Request, Anytype_Rpc.History.ShowVersion.Response> {
        return Invocation(messageName: "HistoryShowVersion", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceHistoryShowVersion(requestData) ?? Data()
            return try Anytype_Rpc.History.ShowVersion.Response(serializedData: responseData)
        }
    }

    public static func historyGetVersions(
        _ request: Anytype_Rpc.History.GetVersions.Request = .init()
    ) -> Invocation<Anytype_Rpc.History.GetVersions.Request, Anytype_Rpc.History.GetVersions.Response> {
        return Invocation(messageName: "HistoryGetVersions", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceHistoryGetVersions(requestData) ?? Data()
            return try Anytype_Rpc.History.GetVersions.Response(serializedData: responseData)
        }
    }

    public static func historySetVersion(
        _ request: Anytype_Rpc.History.SetVersion.Request = .init()
    ) -> Invocation<Anytype_Rpc.History.SetVersion.Request, Anytype_Rpc.History.SetVersion.Response> {
        return Invocation(messageName: "HistorySetVersion", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceHistorySetVersion(requestData) ?? Data()
            return try Anytype_Rpc.History.SetVersion.Response(serializedData: responseData)
        }
    }

    public static func historyDiffVersions(
        _ request: Anytype_Rpc.History.DiffVersions.Request = .init()
    ) -> Invocation<Anytype_Rpc.History.DiffVersions.Request, Anytype_Rpc.History.DiffVersions.Response> {
        return Invocation(messageName: "HistoryDiffVersions", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceHistoryDiffVersions(requestData) ?? Data()
            return try Anytype_Rpc.History.DiffVersions.Response(serializedData: responseData)
        }
    }

    public static func fileSpaceOffload(
        _ request: Anytype_Rpc.File.SpaceOffload.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.SpaceOffload.Request, Anytype_Rpc.File.SpaceOffload.Response> {
        return Invocation(messageName: "FileSpaceOffload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileSpaceOffload(requestData) ?? Data()
            return try Anytype_Rpc.File.SpaceOffload.Response(serializedData: responseData)
        }
    }

    public static func fileReconcile(
        _ request: Anytype_Rpc.File.Reconcile.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.Reconcile.Request, Anytype_Rpc.File.Reconcile.Response> {
        return Invocation(messageName: "FileReconcile", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileReconcile(requestData) ?? Data()
            return try Anytype_Rpc.File.Reconcile.Response(serializedData: responseData)
        }
    }

    public static func fileListOffload(
        _ request: Anytype_Rpc.File.ListOffload.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.ListOffload.Request, Anytype_Rpc.File.ListOffload.Response> {
        return Invocation(messageName: "FileListOffload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileListOffload(requestData) ?? Data()
            return try Anytype_Rpc.File.ListOffload.Response(serializedData: responseData)
        }
    }

    public static func fileUpload(
        _ request: Anytype_Rpc.File.Upload.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.Upload.Request, Anytype_Rpc.File.Upload.Response> {
        return Invocation(messageName: "FileUpload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileUpload(requestData) ?? Data()
            return try Anytype_Rpc.File.Upload.Response(serializedData: responseData)
        }
    }

    public static func fileDownload(
        _ request: Anytype_Rpc.File.Download.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.Download.Request, Anytype_Rpc.File.Download.Response> {
        return Invocation(messageName: "FileDownload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileDownload(requestData) ?? Data()
            return try Anytype_Rpc.File.Download.Response(serializedData: responseData)
        }
    }

    public static func fileDrop(
        _ request: Anytype_Rpc.File.Drop.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.Drop.Request, Anytype_Rpc.File.Drop.Response> {
        return Invocation(messageName: "FileDrop", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileDrop(requestData) ?? Data()
            return try Anytype_Rpc.File.Drop.Response(serializedData: responseData)
        }
    }

    public static func fileSpaceUsage(
        _ request: Anytype_Rpc.File.SpaceUsage.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.SpaceUsage.Request, Anytype_Rpc.File.SpaceUsage.Response> {
        return Invocation(messageName: "FileSpaceUsage", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileSpaceUsage(requestData) ?? Data()
            return try Anytype_Rpc.File.SpaceUsage.Response(serializedData: responseData)
        }
    }

    public static func fileNodeUsage(
        _ request: Anytype_Rpc.File.NodeUsage.Request = .init()
    ) -> Invocation<Anytype_Rpc.File.NodeUsage.Request, Anytype_Rpc.File.NodeUsage.Response> {
        return Invocation(messageName: "FileNodeUsage", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceFileNodeUsage(requestData) ?? Data()
            return try Anytype_Rpc.File.NodeUsage.Response(serializedData: responseData)
        }
    }

    public static func navigationListObjects(
        _ request: Anytype_Rpc.Navigation.ListObjects.Request = .init()
    ) -> Invocation<Anytype_Rpc.Navigation.ListObjects.Request, Anytype_Rpc.Navigation.ListObjects.Response> {
        return Invocation(messageName: "NavigationListObjects", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNavigationListObjects(requestData) ?? Data()
            return try Anytype_Rpc.Navigation.ListObjects.Response(serializedData: responseData)
        }
    }

    public static func navigationGetObjectInfoWithLinks(
        _ request: Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Request = .init()
    ) -> Invocation<Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Request, Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response> {
        return Invocation(messageName: "NavigationGetObjectInfoWithLinks", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNavigationGetObjectInfoWithLinks(requestData) ?? Data()
            return try Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response(serializedData: responseData)
        }
    }

    public static func templateCreateFromObject(
        _ request: Anytype_Rpc.Template.CreateFromObject.Request = .init()
    ) -> Invocation<Anytype_Rpc.Template.CreateFromObject.Request, Anytype_Rpc.Template.CreateFromObject.Response> {
        return Invocation(messageName: "TemplateCreateFromObject", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceTemplateCreateFromObject(requestData) ?? Data()
            return try Anytype_Rpc.Template.CreateFromObject.Response(serializedData: responseData)
        }
    }

    public static func templateClone(
        _ request: Anytype_Rpc.Template.Clone.Request = .init()
    ) -> Invocation<Anytype_Rpc.Template.Clone.Request, Anytype_Rpc.Template.Clone.Response> {
        return Invocation(messageName: "TemplateClone", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceTemplateClone(requestData) ?? Data()
            return try Anytype_Rpc.Template.Clone.Response(serializedData: responseData)
        }
    }

    public static func templateExportAll(
        _ request: Anytype_Rpc.Template.ExportAll.Request = .init()
    ) -> Invocation<Anytype_Rpc.Template.ExportAll.Request, Anytype_Rpc.Template.ExportAll.Response> {
        return Invocation(messageName: "TemplateExportAll", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceTemplateExportAll(requestData) ?? Data()
            return try Anytype_Rpc.Template.ExportAll.Response(serializedData: responseData)
        }
    }

    public static func linkPreview(
        _ request: Anytype_Rpc.LinkPreview.Request = .init()
    ) -> Invocation<Anytype_Rpc.LinkPreview.Request, Anytype_Rpc.LinkPreview.Response> {
        return Invocation(messageName: "LinkPreview", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceLinkPreview(requestData) ?? Data()
            return try Anytype_Rpc.LinkPreview.Response(serializedData: responseData)
        }
    }

    public static func unsplashSearch(
        _ request: Anytype_Rpc.Unsplash.Search.Request = .init()
    ) -> Invocation<Anytype_Rpc.Unsplash.Search.Request, Anytype_Rpc.Unsplash.Search.Response> {
        return Invocation(messageName: "UnsplashSearch", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceUnsplashSearch(requestData) ?? Data()
            return try Anytype_Rpc.Unsplash.Search.Response(serializedData: responseData)
        }
    }

    public static func unsplashDownload(
        _ request: Anytype_Rpc.Unsplash.Download.Request = .init()
    ) -> Invocation<Anytype_Rpc.Unsplash.Download.Request, Anytype_Rpc.Unsplash.Download.Response> {
        return Invocation(messageName: "UnsplashDownload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceUnsplashDownload(requestData) ?? Data()
            return try Anytype_Rpc.Unsplash.Download.Response(serializedData: responseData)
        }
    }

    public static func galleryDownloadManifest(
        _ request: Anytype_Rpc.Gallery.DownloadManifest.Request = .init()
    ) -> Invocation<Anytype_Rpc.Gallery.DownloadManifest.Request, Anytype_Rpc.Gallery.DownloadManifest.Response> {
        return Invocation(messageName: "GalleryDownloadManifest", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceGalleryDownloadManifest(requestData) ?? Data()
            return try Anytype_Rpc.Gallery.DownloadManifest.Response(serializedData: responseData)
        }
    }

    public static func galleryDownloadIndex(
        _ request: Anytype_Rpc.Gallery.DownloadIndex.Request = .init()
    ) -> Invocation<Anytype_Rpc.Gallery.DownloadIndex.Request, Anytype_Rpc.Gallery.DownloadIndex.Response> {
        return Invocation(messageName: "GalleryDownloadIndex", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceGalleryDownloadIndex(requestData) ?? Data()
            return try Anytype_Rpc.Gallery.DownloadIndex.Response(serializedData: responseData)
        }
    }

    public static func blockUpload(
        _ request: Anytype_Rpc.Block.Upload.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Upload.Request, Anytype_Rpc.Block.Upload.Response> {
        return Invocation(messageName: "BlockUpload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockUpload(requestData) ?? Data()
            return try Anytype_Rpc.Block.Upload.Response(serializedData: responseData)
        }
    }

    public static func blockReplace(
        _ request: Anytype_Rpc.Block.Replace.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Replace.Request, Anytype_Rpc.Block.Replace.Response> {
        return Invocation(messageName: "BlockReplace", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockReplace(requestData) ?? Data()
            return try Anytype_Rpc.Block.Replace.Response(serializedData: responseData)
        }
    }

    public static func blockCreate(
        _ request: Anytype_Rpc.Block.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Create.Request, Anytype_Rpc.Block.Create.Response> {
        return Invocation(messageName: "BlockCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockCreate(requestData) ?? Data()
            return try Anytype_Rpc.Block.Create.Response(serializedData: responseData)
        }
    }

    public static func blockSplit(
        _ request: Anytype_Rpc.Block.Split.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Split.Request, Anytype_Rpc.Block.Split.Response> {
        return Invocation(messageName: "BlockSplit", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockSplit(requestData) ?? Data()
            return try Anytype_Rpc.Block.Split.Response(serializedData: responseData)
        }
    }

    public static func blockMerge(
        _ request: Anytype_Rpc.Block.Merge.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Merge.Request, Anytype_Rpc.Block.Merge.Response> {
        return Invocation(messageName: "BlockMerge", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockMerge(requestData) ?? Data()
            return try Anytype_Rpc.Block.Merge.Response(serializedData: responseData)
        }
    }

    public static func blockCopy(
        _ request: Anytype_Rpc.Block.Copy.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Copy.Request, Anytype_Rpc.Block.Copy.Response> {
        return Invocation(messageName: "BlockCopy", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockCopy(requestData) ?? Data()
            return try Anytype_Rpc.Block.Copy.Response(serializedData: responseData)
        }
    }

    public static func blockPaste(
        _ request: Anytype_Rpc.Block.Paste.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Paste.Request, Anytype_Rpc.Block.Paste.Response> {
        return Invocation(messageName: "BlockPaste", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockPaste(requestData) ?? Data()
            return try Anytype_Rpc.Block.Paste.Response(serializedData: responseData)
        }
    }

    public static func blockCut(
        _ request: Anytype_Rpc.Block.Cut.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Cut.Request, Anytype_Rpc.Block.Cut.Response> {
        return Invocation(messageName: "BlockCut", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockCut(requestData) ?? Data()
            return try Anytype_Rpc.Block.Cut.Response(serializedData: responseData)
        }
    }

    public static func blockSetFields(
        _ request: Anytype_Rpc.Block.SetFields.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.SetFields.Request, Anytype_Rpc.Block.SetFields.Response> {
        return Invocation(messageName: "BlockSetFields", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockSetFields(requestData) ?? Data()
            return try Anytype_Rpc.Block.SetFields.Response(serializedData: responseData)
        }
    }

    public static func blockExport(
        _ request: Anytype_Rpc.Block.Export.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Export.Request, Anytype_Rpc.Block.Export.Response> {
        return Invocation(messageName: "BlockExport", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockExport(requestData) ?? Data()
            return try Anytype_Rpc.Block.Export.Response(serializedData: responseData)
        }
    }

    public static func blockSetCarriage(
        _ request: Anytype_Rpc.Block.SetCarriage.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.SetCarriage.Request, Anytype_Rpc.Block.SetCarriage.Response> {
        return Invocation(messageName: "BlockSetCarriage", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockSetCarriage(requestData) ?? Data()
            return try Anytype_Rpc.Block.SetCarriage.Response(serializedData: responseData)
        }
    }

    public static func blockPreview(
        _ request: Anytype_Rpc.Block.Preview.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.Preview.Request, Anytype_Rpc.Block.Preview.Response> {
        return Invocation(messageName: "BlockPreview", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockPreview(requestData) ?? Data()
            return try Anytype_Rpc.Block.Preview.Response(serializedData: responseData)
        }
    }

    public static func blockListDelete(
        _ request: Anytype_Rpc.Block.ListDelete.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListDelete.Request, Anytype_Rpc.Block.ListDelete.Response> {
        return Invocation(messageName: "BlockListDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListDelete(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListDelete.Response(serializedData: responseData)
        }
    }

    public static func blockListMoveToExistingObject(
        _ request: Anytype_Rpc.Block.ListMoveToExistingObject.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListMoveToExistingObject.Request, Anytype_Rpc.Block.ListMoveToExistingObject.Response> {
        return Invocation(messageName: "BlockListMoveToExistingObject", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListMoveToExistingObject(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListMoveToExistingObject.Response(serializedData: responseData)
        }
    }

    public static func blockListMoveToNewObject(
        _ request: Anytype_Rpc.Block.ListMoveToNewObject.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListMoveToNewObject.Request, Anytype_Rpc.Block.ListMoveToNewObject.Response> {
        return Invocation(messageName: "BlockListMoveToNewObject", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListMoveToNewObject(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListMoveToNewObject.Response(serializedData: responseData)
        }
    }

    public static func blockListConvertToObjects(
        _ request: Anytype_Rpc.Block.ListConvertToObjects.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListConvertToObjects.Request, Anytype_Rpc.Block.ListConvertToObjects.Response> {
        return Invocation(messageName: "BlockListConvertToObjects", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListConvertToObjects(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListConvertToObjects.Response(serializedData: responseData)
        }
    }

    public static func blockListSetFields(
        _ request: Anytype_Rpc.Block.ListSetFields.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListSetFields.Request, Anytype_Rpc.Block.ListSetFields.Response> {
        return Invocation(messageName: "BlockListSetFields", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListSetFields(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListSetFields.Response(serializedData: responseData)
        }
    }

    public static func blockListDuplicate(
        _ request: Anytype_Rpc.Block.ListDuplicate.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListDuplicate.Request, Anytype_Rpc.Block.ListDuplicate.Response> {
        return Invocation(messageName: "BlockListDuplicate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListDuplicate(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListDuplicate.Response(serializedData: responseData)
        }
    }

    public static func blockListSetBackgroundColor(
        _ request: Anytype_Rpc.Block.ListSetBackgroundColor.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListSetBackgroundColor.Request, Anytype_Rpc.Block.ListSetBackgroundColor.Response> {
        return Invocation(messageName: "BlockListSetBackgroundColor", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListSetBackgroundColor(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListSetBackgroundColor.Response(serializedData: responseData)
        }
    }

    public static func blockListSetAlign(
        _ request: Anytype_Rpc.Block.ListSetAlign.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListSetAlign.Request, Anytype_Rpc.Block.ListSetAlign.Response> {
        return Invocation(messageName: "BlockListSetAlign", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListSetAlign(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListSetAlign.Response(serializedData: responseData)
        }
    }

    public static func blockListSetVerticalAlign(
        _ request: Anytype_Rpc.Block.ListSetVerticalAlign.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListSetVerticalAlign.Request, Anytype_Rpc.Block.ListSetVerticalAlign.Response> {
        return Invocation(messageName: "BlockListSetVerticalAlign", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListSetVerticalAlign(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListSetVerticalAlign.Response(serializedData: responseData)
        }
    }

    public static func blockListTurnInto(
        _ request: Anytype_Rpc.Block.ListTurnInto.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.ListTurnInto.Request, Anytype_Rpc.Block.ListTurnInto.Response> {
        return Invocation(messageName: "BlockListTurnInto", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockListTurnInto(requestData) ?? Data()
            return try Anytype_Rpc.Block.ListTurnInto.Response(serializedData: responseData)
        }
    }

    public static func blockTextSetText(
        _ request: Anytype_Rpc.BlockText.SetText.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.SetText.Request, Anytype_Rpc.BlockText.SetText.Response> {
        return Invocation(messageName: "BlockTextSetText", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextSetText(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.SetText.Response(serializedData: responseData)
        }
    }

    public static func blockTextSetColor(
        _ request: Anytype_Rpc.BlockText.SetColor.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.SetColor.Request, Anytype_Rpc.BlockText.SetColor.Response> {
        return Invocation(messageName: "BlockTextSetColor", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextSetColor(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.SetColor.Response(serializedData: responseData)
        }
    }

    public static func blockTextSetStyle(
        _ request: Anytype_Rpc.BlockText.SetStyle.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.SetStyle.Request, Anytype_Rpc.BlockText.SetStyle.Response> {
        return Invocation(messageName: "BlockTextSetStyle", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextSetStyle(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.SetStyle.Response(serializedData: responseData)
        }
    }

    public static func blockTextSetChecked(
        _ request: Anytype_Rpc.BlockText.SetChecked.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.SetChecked.Request, Anytype_Rpc.BlockText.SetChecked.Response> {
        return Invocation(messageName: "BlockTextSetChecked", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextSetChecked(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.SetChecked.Response(serializedData: responseData)
        }
    }

    public static func blockTextSetIcon(
        _ request: Anytype_Rpc.BlockText.SetIcon.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.SetIcon.Request, Anytype_Rpc.BlockText.SetIcon.Response> {
        return Invocation(messageName: "BlockTextSetIcon", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextSetIcon(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.SetIcon.Response(serializedData: responseData)
        }
    }

    public static func blockTextListSetColor(
        _ request: Anytype_Rpc.BlockText.ListSetColor.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.ListSetColor.Request, Anytype_Rpc.BlockText.ListSetColor.Response> {
        return Invocation(messageName: "BlockTextListSetColor", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextListSetColor(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.ListSetColor.Response(serializedData: responseData)
        }
    }

    public static func blockTextListSetMark(
        _ request: Anytype_Rpc.BlockText.ListSetMark.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.ListSetMark.Request, Anytype_Rpc.BlockText.ListSetMark.Response> {
        return Invocation(messageName: "BlockTextListSetMark", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextListSetMark(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.ListSetMark.Response(serializedData: responseData)
        }
    }

    public static func blockTextListSetStyle(
        _ request: Anytype_Rpc.BlockText.ListSetStyle.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.ListSetStyle.Request, Anytype_Rpc.BlockText.ListSetStyle.Response> {
        return Invocation(messageName: "BlockTextListSetStyle", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextListSetStyle(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.ListSetStyle.Response(serializedData: responseData)
        }
    }

    public static func blockTextListClearStyle(
        _ request: Anytype_Rpc.BlockText.ListClearStyle.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.ListClearStyle.Request, Anytype_Rpc.BlockText.ListClearStyle.Response> {
        return Invocation(messageName: "BlockTextListClearStyle", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextListClearStyle(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.ListClearStyle.Response(serializedData: responseData)
        }
    }

    public static func blockTextListClearContent(
        _ request: Anytype_Rpc.BlockText.ListClearContent.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockText.ListClearContent.Request, Anytype_Rpc.BlockText.ListClearContent.Response> {
        return Invocation(messageName: "BlockTextListClearContent", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTextListClearContent(requestData) ?? Data()
            return try Anytype_Rpc.BlockText.ListClearContent.Response(serializedData: responseData)
        }
    }

    public static func blockFileSetName(
        _ request: Anytype_Rpc.BlockFile.SetName.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockFile.SetName.Request, Anytype_Rpc.BlockFile.SetName.Response> {
        return Invocation(messageName: "BlockFileSetName", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockFileSetName(requestData) ?? Data()
            return try Anytype_Rpc.BlockFile.SetName.Response(serializedData: responseData)
        }
    }

    public static func blockFileSetTargetObjectId(
        _ request: Anytype_Rpc.BlockFile.SetTargetObjectId.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockFile.SetTargetObjectId.Request, Anytype_Rpc.BlockFile.SetTargetObjectId.Response> {
        return Invocation(messageName: "BlockFileSetTargetObjectId", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockFileSetTargetObjectId(requestData) ?? Data()
            return try Anytype_Rpc.BlockFile.SetTargetObjectId.Response(serializedData: responseData)
        }
    }

    public static func blockImageSetName(
        _ request: Anytype_Rpc.BlockImage.SetName.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockImage.SetName.Request, Anytype_Rpc.BlockImage.SetName.Response> {
        return Invocation(messageName: "BlockImageSetName", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockImageSetName(requestData) ?? Data()
            return try Anytype_Rpc.BlockImage.SetName.Response(serializedData: responseData)
        }
    }

    public static func blockVideoSetName(
        _ request: Anytype_Rpc.BlockVideo.SetName.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockVideo.SetName.Request, Anytype_Rpc.BlockVideo.SetName.Response> {
        return Invocation(messageName: "BlockVideoSetName", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockVideoSetName(requestData) ?? Data()
            return try Anytype_Rpc.BlockVideo.SetName.Response(serializedData: responseData)
        }
    }

    public static func blockFileCreateAndUpload(
        _ request: Anytype_Rpc.BlockFile.CreateAndUpload.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockFile.CreateAndUpload.Request, Anytype_Rpc.BlockFile.CreateAndUpload.Response> {
        return Invocation(messageName: "BlockFileCreateAndUpload", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockFileCreateAndUpload(requestData) ?? Data()
            return try Anytype_Rpc.BlockFile.CreateAndUpload.Response(serializedData: responseData)
        }
    }

    public static func blockFileListSetStyle(
        _ request: Anytype_Rpc.BlockFile.ListSetStyle.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockFile.ListSetStyle.Request, Anytype_Rpc.BlockFile.ListSetStyle.Response> {
        return Invocation(messageName: "BlockFileListSetStyle", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockFileListSetStyle(requestData) ?? Data()
            return try Anytype_Rpc.BlockFile.ListSetStyle.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewCreate(
        _ request: Anytype_Rpc.BlockDataview.View.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.View.Create.Request, Anytype_Rpc.BlockDataview.View.Create.Response> {
        return Invocation(messageName: "BlockDataviewViewCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewCreate(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.View.Create.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewDelete(
        _ request: Anytype_Rpc.BlockDataview.View.Delete.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.View.Delete.Request, Anytype_Rpc.BlockDataview.View.Delete.Response> {
        return Invocation(messageName: "BlockDataviewViewDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewDelete(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.View.Delete.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewUpdate(
        _ request: Anytype_Rpc.BlockDataview.View.Update.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.View.Update.Request, Anytype_Rpc.BlockDataview.View.Update.Response> {
        return Invocation(messageName: "BlockDataviewViewUpdate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewUpdate(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.View.Update.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewSetActive(
        _ request: Anytype_Rpc.BlockDataview.View.SetActive.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.View.SetActive.Request, Anytype_Rpc.BlockDataview.View.SetActive.Response> {
        return Invocation(messageName: "BlockDataviewViewSetActive", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewSetActive(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.View.SetActive.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewSetPosition(
        _ request: Anytype_Rpc.BlockDataview.View.SetPosition.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.View.SetPosition.Request, Anytype_Rpc.BlockDataview.View.SetPosition.Response> {
        return Invocation(messageName: "BlockDataviewViewSetPosition", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewSetPosition(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.View.SetPosition.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewSetSource(
        _ request: Anytype_Rpc.BlockDataview.SetSource.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.SetSource.Request, Anytype_Rpc.BlockDataview.SetSource.Response> {
        return Invocation(messageName: "BlockDataviewSetSource", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewSetSource(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.SetSource.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewRelationAdd(
        _ request: Anytype_Rpc.BlockDataview.Relation.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Relation.Add.Request, Anytype_Rpc.BlockDataview.Relation.Add.Response> {
        return Invocation(messageName: "BlockDataviewRelationAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewRelationAdd(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Relation.Add.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewRelationDelete(
        _ request: Anytype_Rpc.BlockDataview.Relation.Delete.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Relation.Delete.Request, Anytype_Rpc.BlockDataview.Relation.Delete.Response> {
        return Invocation(messageName: "BlockDataviewRelationDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewRelationDelete(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Relation.Delete.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewRelationListAvailable(
        _ request: Anytype_Rpc.BlockDataview.Relation.ListAvailable.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Relation.ListAvailable.Request, Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response> {
        return Invocation(messageName: "BlockDataviewRelationListAvailable", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewRelationListAvailable(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewGroupOrderUpdate(
        _ request: Anytype_Rpc.BlockDataview.GroupOrder.Update.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.GroupOrder.Update.Request, Anytype_Rpc.BlockDataview.GroupOrder.Update.Response> {
        return Invocation(messageName: "BlockDataviewGroupOrderUpdate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewGroupOrderUpdate(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.GroupOrder.Update.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewObjectOrderUpdate(
        _ request: Anytype_Rpc.BlockDataview.ObjectOrder.Update.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ObjectOrder.Update.Request, Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response> {
        return Invocation(messageName: "BlockDataviewObjectOrderUpdate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewObjectOrderUpdate(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewObjectOrderMove(
        _ request: Anytype_Rpc.BlockDataview.ObjectOrder.Move.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ObjectOrder.Move.Request, Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response> {
        return Invocation(messageName: "BlockDataviewObjectOrderMove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewObjectOrderMove(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewCreateFromExistingObject(
        _ request: Anytype_Rpc.BlockDataview.CreateFromExistingObject.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.CreateFromExistingObject.Request, Anytype_Rpc.BlockDataview.CreateFromExistingObject.Response> {
        return Invocation(messageName: "BlockDataviewCreateFromExistingObject", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewCreateFromExistingObject(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.CreateFromExistingObject.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewFilterAdd(
        _ request: Anytype_Rpc.BlockDataview.Filter.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Filter.Add.Request, Anytype_Rpc.BlockDataview.Filter.Add.Response> {
        return Invocation(messageName: "BlockDataviewFilterAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewFilterAdd(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Filter.Add.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewFilterRemove(
        _ request: Anytype_Rpc.BlockDataview.Filter.Remove.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Filter.Remove.Request, Anytype_Rpc.BlockDataview.Filter.Remove.Response> {
        return Invocation(messageName: "BlockDataviewFilterRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewFilterRemove(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Filter.Remove.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewFilterReplace(
        _ request: Anytype_Rpc.BlockDataview.Filter.Replace.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Filter.Replace.Request, Anytype_Rpc.BlockDataview.Filter.Replace.Response> {
        return Invocation(messageName: "BlockDataviewFilterReplace", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewFilterReplace(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Filter.Replace.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewFilterSort(
        _ request: Anytype_Rpc.BlockDataview.Filter.Sort.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Filter.Sort.Request, Anytype_Rpc.BlockDataview.Filter.Sort.Response> {
        return Invocation(messageName: "BlockDataviewFilterSort", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewFilterSort(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Filter.Sort.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewSortAdd(
        _ request: Anytype_Rpc.BlockDataview.Sort.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Sort.Add.Request, Anytype_Rpc.BlockDataview.Sort.Add.Response> {
        return Invocation(messageName: "BlockDataviewSortAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewSortAdd(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Sort.Add.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewSortRemove(
        _ request: Anytype_Rpc.BlockDataview.Sort.Remove.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Sort.Remove.Request, Anytype_Rpc.BlockDataview.Sort.Remove.Response> {
        return Invocation(messageName: "BlockDataviewSortRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewSortRemove(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Sort.Remove.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewSortReplace(
        _ request: Anytype_Rpc.BlockDataview.Sort.Replace.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Sort.Replace.Request, Anytype_Rpc.BlockDataview.Sort.Replace.Response> {
        return Invocation(messageName: "BlockDataviewSortReplace", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewSortReplace(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Sort.Replace.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewSortSort(
        _ request: Anytype_Rpc.BlockDataview.Sort.SSort.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.Sort.SSort.Request, Anytype_Rpc.BlockDataview.Sort.SSort.Response> {
        return Invocation(messageName: "BlockDataviewSortSort", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewSortSort(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.Sort.SSort.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewRelationAdd(
        _ request: Anytype_Rpc.BlockDataview.ViewRelation.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ViewRelation.Add.Request, Anytype_Rpc.BlockDataview.ViewRelation.Add.Response> {
        return Invocation(messageName: "BlockDataviewViewRelationAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewRelationAdd(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ViewRelation.Add.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewRelationRemove(
        _ request: Anytype_Rpc.BlockDataview.ViewRelation.Remove.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ViewRelation.Remove.Request, Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response> {
        return Invocation(messageName: "BlockDataviewViewRelationRemove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewRelationRemove(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewRelationReplace(
        _ request: Anytype_Rpc.BlockDataview.ViewRelation.Replace.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ViewRelation.Replace.Request, Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response> {
        return Invocation(messageName: "BlockDataviewViewRelationReplace", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewRelationReplace(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response(serializedData: responseData)
        }
    }

    public static func blockDataviewViewRelationSort(
        _ request: Anytype_Rpc.BlockDataview.ViewRelation.Sort.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDataview.ViewRelation.Sort.Request, Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response> {
        return Invocation(messageName: "BlockDataviewViewRelationSort", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDataviewViewRelationSort(requestData) ?? Data()
            return try Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response(serializedData: responseData)
        }
    }

    public static func blockTableCreate(
        _ request: Anytype_Rpc.BlockTable.Create.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.Create.Request, Anytype_Rpc.BlockTable.Create.Response> {
        return Invocation(messageName: "BlockTableCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableCreate(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.Create.Response(serializedData: responseData)
        }
    }

    public static func blockTableExpand(
        _ request: Anytype_Rpc.BlockTable.Expand.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.Expand.Request, Anytype_Rpc.BlockTable.Expand.Response> {
        return Invocation(messageName: "BlockTableExpand", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableExpand(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.Expand.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowCreate(
        _ request: Anytype_Rpc.BlockTable.RowCreate.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowCreate.Request, Anytype_Rpc.BlockTable.RowCreate.Response> {
        return Invocation(messageName: "BlockTableRowCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowCreate(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowCreate.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowDelete(
        _ request: Anytype_Rpc.BlockTable.RowDelete.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowDelete.Request, Anytype_Rpc.BlockTable.RowDelete.Response> {
        return Invocation(messageName: "BlockTableRowDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowDelete(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowDelete.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowDuplicate(
        _ request: Anytype_Rpc.BlockTable.RowDuplicate.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowDuplicate.Request, Anytype_Rpc.BlockTable.RowDuplicate.Response> {
        return Invocation(messageName: "BlockTableRowDuplicate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowDuplicate(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowDuplicate.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowSetHeader(
        _ request: Anytype_Rpc.BlockTable.RowSetHeader.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowSetHeader.Request, Anytype_Rpc.BlockTable.RowSetHeader.Response> {
        return Invocation(messageName: "BlockTableRowSetHeader", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowSetHeader(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowSetHeader.Response(serializedData: responseData)
        }
    }

    public static func blockTableColumnCreate(
        _ request: Anytype_Rpc.BlockTable.ColumnCreate.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.ColumnCreate.Request, Anytype_Rpc.BlockTable.ColumnCreate.Response> {
        return Invocation(messageName: "BlockTableColumnCreate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableColumnCreate(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.ColumnCreate.Response(serializedData: responseData)
        }
    }

    public static func blockTableColumnMove(
        _ request: Anytype_Rpc.BlockTable.ColumnMove.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.ColumnMove.Request, Anytype_Rpc.BlockTable.ColumnMove.Response> {
        return Invocation(messageName: "BlockTableColumnMove", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableColumnMove(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.ColumnMove.Response(serializedData: responseData)
        }
    }

    public static func blockTableColumnDelete(
        _ request: Anytype_Rpc.BlockTable.ColumnDelete.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.ColumnDelete.Request, Anytype_Rpc.BlockTable.ColumnDelete.Response> {
        return Invocation(messageName: "BlockTableColumnDelete", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableColumnDelete(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.ColumnDelete.Response(serializedData: responseData)
        }
    }

    public static func blockTableColumnDuplicate(
        _ request: Anytype_Rpc.BlockTable.ColumnDuplicate.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.ColumnDuplicate.Request, Anytype_Rpc.BlockTable.ColumnDuplicate.Response> {
        return Invocation(messageName: "BlockTableColumnDuplicate", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableColumnDuplicate(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.ColumnDuplicate.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowListFill(
        _ request: Anytype_Rpc.BlockTable.RowListFill.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowListFill.Request, Anytype_Rpc.BlockTable.RowListFill.Response> {
        return Invocation(messageName: "BlockTableRowListFill", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowListFill(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowListFill.Response(serializedData: responseData)
        }
    }

    public static func blockTableRowListClean(
        _ request: Anytype_Rpc.BlockTable.RowListClean.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.RowListClean.Request, Anytype_Rpc.BlockTable.RowListClean.Response> {
        return Invocation(messageName: "BlockTableRowListClean", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableRowListClean(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.RowListClean.Response(serializedData: responseData)
        }
    }

    public static func blockTableColumnListFill(
        _ request: Anytype_Rpc.BlockTable.ColumnListFill.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.ColumnListFill.Request, Anytype_Rpc.BlockTable.ColumnListFill.Response> {
        return Invocation(messageName: "BlockTableColumnListFill", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableColumnListFill(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.ColumnListFill.Response(serializedData: responseData)
        }
    }

    public static func blockTableSort(
        _ request: Anytype_Rpc.BlockTable.Sort.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockTable.Sort.Request, Anytype_Rpc.BlockTable.Sort.Response> {
        return Invocation(messageName: "BlockTableSort", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockTableSort(requestData) ?? Data()
            return try Anytype_Rpc.BlockTable.Sort.Response(serializedData: responseData)
        }
    }

    public static func blockCreateWidget(
        _ request: Anytype_Rpc.Block.CreateWidget.Request = .init()
    ) -> Invocation<Anytype_Rpc.Block.CreateWidget.Request, Anytype_Rpc.Block.CreateWidget.Response> {
        return Invocation(messageName: "BlockCreateWidget", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockCreateWidget(requestData) ?? Data()
            return try Anytype_Rpc.Block.CreateWidget.Response(serializedData: responseData)
        }
    }

    public static func blockWidgetSetTargetId(
        _ request: Anytype_Rpc.BlockWidget.SetTargetId.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockWidget.SetTargetId.Request, Anytype_Rpc.BlockWidget.SetTargetId.Response> {
        return Invocation(messageName: "BlockWidgetSetTargetId", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockWidgetSetTargetId(requestData) ?? Data()
            return try Anytype_Rpc.BlockWidget.SetTargetId.Response(serializedData: responseData)
        }
    }

    public static func blockWidgetSetLayout(
        _ request: Anytype_Rpc.BlockWidget.SetLayout.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockWidget.SetLayout.Request, Anytype_Rpc.BlockWidget.SetLayout.Response> {
        return Invocation(messageName: "BlockWidgetSetLayout", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockWidgetSetLayout(requestData) ?? Data()
            return try Anytype_Rpc.BlockWidget.SetLayout.Response(serializedData: responseData)
        }
    }

    public static func blockWidgetSetLimit(
        _ request: Anytype_Rpc.BlockWidget.SetLimit.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockWidget.SetLimit.Request, Anytype_Rpc.BlockWidget.SetLimit.Response> {
        return Invocation(messageName: "BlockWidgetSetLimit", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockWidgetSetLimit(requestData) ?? Data()
            return try Anytype_Rpc.BlockWidget.SetLimit.Response(serializedData: responseData)
        }
    }

    public static func blockWidgetSetViewId(
        _ request: Anytype_Rpc.BlockWidget.SetViewId.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockWidget.SetViewId.Request, Anytype_Rpc.BlockWidget.SetViewId.Response> {
        return Invocation(messageName: "BlockWidgetSetViewId", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockWidgetSetViewId(requestData) ?? Data()
            return try Anytype_Rpc.BlockWidget.SetViewId.Response(serializedData: responseData)
        }
    }

    public static func blockLinkCreateWithObject(
        _ request: Anytype_Rpc.BlockLink.CreateWithObject.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockLink.CreateWithObject.Request, Anytype_Rpc.BlockLink.CreateWithObject.Response> {
        return Invocation(messageName: "BlockLinkCreateWithObject", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockLinkCreateWithObject(requestData) ?? Data()
            return try Anytype_Rpc.BlockLink.CreateWithObject.Response(serializedData: responseData)
        }
    }

    public static func blockLinkListSetAppearance(
        _ request: Anytype_Rpc.BlockLink.ListSetAppearance.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockLink.ListSetAppearance.Request, Anytype_Rpc.BlockLink.ListSetAppearance.Response> {
        return Invocation(messageName: "BlockLinkListSetAppearance", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockLinkListSetAppearance(requestData) ?? Data()
            return try Anytype_Rpc.BlockLink.ListSetAppearance.Response(serializedData: responseData)
        }
    }

    public static func blockBookmarkFetch(
        _ request: Anytype_Rpc.BlockBookmark.Fetch.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockBookmark.Fetch.Request, Anytype_Rpc.BlockBookmark.Fetch.Response> {
        return Invocation(messageName: "BlockBookmarkFetch", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockBookmarkFetch(requestData) ?? Data()
            return try Anytype_Rpc.BlockBookmark.Fetch.Response(serializedData: responseData)
        }
    }

    public static func blockBookmarkCreateAndFetch(
        _ request: Anytype_Rpc.BlockBookmark.CreateAndFetch.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockBookmark.CreateAndFetch.Request, Anytype_Rpc.BlockBookmark.CreateAndFetch.Response> {
        return Invocation(messageName: "BlockBookmarkCreateAndFetch", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockBookmarkCreateAndFetch(requestData) ?? Data()
            return try Anytype_Rpc.BlockBookmark.CreateAndFetch.Response(serializedData: responseData)
        }
    }

    public static func blockRelationSetKey(
        _ request: Anytype_Rpc.BlockRelation.SetKey.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockRelation.SetKey.Request, Anytype_Rpc.BlockRelation.SetKey.Response> {
        return Invocation(messageName: "BlockRelationSetKey", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockRelationSetKey(requestData) ?? Data()
            return try Anytype_Rpc.BlockRelation.SetKey.Response(serializedData: responseData)
        }
    }

    public static func blockRelationAdd(
        _ request: Anytype_Rpc.BlockRelation.Add.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockRelation.Add.Request, Anytype_Rpc.BlockRelation.Add.Response> {
        return Invocation(messageName: "BlockRelationAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockRelationAdd(requestData) ?? Data()
            return try Anytype_Rpc.BlockRelation.Add.Response(serializedData: responseData)
        }
    }

    public static func blockDivListSetStyle(
        _ request: Anytype_Rpc.BlockDiv.ListSetStyle.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockDiv.ListSetStyle.Request, Anytype_Rpc.BlockDiv.ListSetStyle.Response> {
        return Invocation(messageName: "BlockDivListSetStyle", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockDivListSetStyle(requestData) ?? Data()
            return try Anytype_Rpc.BlockDiv.ListSetStyle.Response(serializedData: responseData)
        }
    }

    public static func blockLatexSetText(
        _ request: Anytype_Rpc.BlockLatex.SetText.Request = .init()
    ) -> Invocation<Anytype_Rpc.BlockLatex.SetText.Request, Anytype_Rpc.BlockLatex.SetText.Response> {
        return Invocation(messageName: "BlockLatexSetText", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBlockLatexSetText(requestData) ?? Data()
            return try Anytype_Rpc.BlockLatex.SetText.Response(serializedData: responseData)
        }
    }

    public static func processCancel(
        _ request: Anytype_Rpc.Process.Cancel.Request = .init()
    ) -> Invocation<Anytype_Rpc.Process.Cancel.Request, Anytype_Rpc.Process.Cancel.Response> {
        return Invocation(messageName: "ProcessCancel", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceProcessCancel(requestData) ?? Data()
            return try Anytype_Rpc.Process.Cancel.Response(serializedData: responseData)
        }
    }

    public static func logSend(
        _ request: Anytype_Rpc.Log.Send.Request = .init()
    ) -> Invocation<Anytype_Rpc.Log.Send.Request, Anytype_Rpc.Log.Send.Response> {
        return Invocation(messageName: "LogSend", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceLogSend(requestData) ?? Data()
            return try Anytype_Rpc.Log.Send.Response(serializedData: responseData)
        }
    }

    public static func debugStat(
        _ request: Anytype_Rpc.Debug.Stat.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.Stat.Request, Anytype_Rpc.Debug.Stat.Response> {
        return Invocation(messageName: "DebugStat", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugStat(requestData) ?? Data()
            return try Anytype_Rpc.Debug.Stat.Response(serializedData: responseData)
        }
    }

    public static func debugTree(
        _ request: Anytype_Rpc.Debug.Tree.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.Tree.Request, Anytype_Rpc.Debug.Tree.Response> {
        return Invocation(messageName: "DebugTree", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugTree(requestData) ?? Data()
            return try Anytype_Rpc.Debug.Tree.Response(serializedData: responseData)
        }
    }

    public static func debugTreeHeads(
        _ request: Anytype_Rpc.Debug.TreeHeads.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.TreeHeads.Request, Anytype_Rpc.Debug.TreeHeads.Response> {
        return Invocation(messageName: "DebugTreeHeads", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugTreeHeads(requestData) ?? Data()
            return try Anytype_Rpc.Debug.TreeHeads.Response(serializedData: responseData)
        }
    }

    public static func debugSpaceSummary(
        _ request: Anytype_Rpc.Debug.SpaceSummary.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.SpaceSummary.Request, Anytype_Rpc.Debug.SpaceSummary.Response> {
        return Invocation(messageName: "DebugSpaceSummary", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugSpaceSummary(requestData) ?? Data()
            return try Anytype_Rpc.Debug.SpaceSummary.Response(serializedData: responseData)
        }
    }

    public static func debugStackGoroutines(
        _ request: Anytype_Rpc.Debug.StackGoroutines.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.StackGoroutines.Request, Anytype_Rpc.Debug.StackGoroutines.Response> {
        return Invocation(messageName: "DebugStackGoroutines", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugStackGoroutines(requestData) ?? Data()
            return try Anytype_Rpc.Debug.StackGoroutines.Response(serializedData: responseData)
        }
    }

    public static func debugExportLocalstore(
        _ request: Anytype_Rpc.Debug.ExportLocalstore.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.ExportLocalstore.Request, Anytype_Rpc.Debug.ExportLocalstore.Response> {
        return Invocation(messageName: "DebugExportLocalstore", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugExportLocalstore(requestData) ?? Data()
            return try Anytype_Rpc.Debug.ExportLocalstore.Response(serializedData: responseData)
        }
    }

    public static func debugPing(
        _ request: Anytype_Rpc.Debug.Ping.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.Ping.Request, Anytype_Rpc.Debug.Ping.Response> {
        return Invocation(messageName: "DebugPing", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugPing(requestData) ?? Data()
            return try Anytype_Rpc.Debug.Ping.Response(serializedData: responseData)
        }
    }

    public static func debugSubscriptions(
        _ request: Anytype_Rpc.Debug.Subscriptions.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.Subscriptions.Request, Anytype_Rpc.Debug.Subscriptions.Response> {
        return Invocation(messageName: "DebugSubscriptions", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugSubscriptions(requestData) ?? Data()
            return try Anytype_Rpc.Debug.Subscriptions.Response(serializedData: responseData)
        }
    }

    public static func debugOpenedObjects(
        _ request: Anytype_Rpc.Debug.OpenedObjects.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.OpenedObjects.Request, Anytype_Rpc.Debug.OpenedObjects.Response> {
        return Invocation(messageName: "DebugOpenedObjects", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugOpenedObjects(requestData) ?? Data()
            return try Anytype_Rpc.Debug.OpenedObjects.Response(serializedData: responseData)
        }
    }

    public static func debugRunProfiler(
        _ request: Anytype_Rpc.Debug.RunProfiler.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.RunProfiler.Request, Anytype_Rpc.Debug.RunProfiler.Response> {
        return Invocation(messageName: "DebugRunProfiler", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugRunProfiler(requestData) ?? Data()
            return try Anytype_Rpc.Debug.RunProfiler.Response(serializedData: responseData)
        }
    }

    public static func debugAccountSelectTrace(
        _ request: Anytype_Rpc.Debug.AccountSelectTrace.Request = .init()
    ) -> Invocation<Anytype_Rpc.Debug.AccountSelectTrace.Request, Anytype_Rpc.Debug.AccountSelectTrace.Response> {
        return Invocation(messageName: "DebugAccountSelectTrace", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDebugAccountSelectTrace(requestData) ?? Data()
            return try Anytype_Rpc.Debug.AccountSelectTrace.Response(serializedData: responseData)
        }
    }

    public static func metricsSetParameters(
        _ request: Anytype_Rpc.Metrics.SetParameters.Request = .init()
    ) -> Invocation<Anytype_Rpc.Metrics.SetParameters.Request, Anytype_Rpc.Metrics.SetParameters.Response> {
        return Invocation(messageName: "MetricsSetParameters", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMetricsSetParameters(requestData) ?? Data()
            return try Anytype_Rpc.Metrics.SetParameters.Response(serializedData: responseData)
        }
    }

    public static func notificationList(
        _ request: Anytype_Rpc.Notification.List.Request = .init()
    ) -> Invocation<Anytype_Rpc.Notification.List.Request, Anytype_Rpc.Notification.List.Response> {
        return Invocation(messageName: "NotificationList", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNotificationList(requestData) ?? Data()
            return try Anytype_Rpc.Notification.List.Response(serializedData: responseData)
        }
    }

    public static func notificationReply(
        _ request: Anytype_Rpc.Notification.Reply.Request = .init()
    ) -> Invocation<Anytype_Rpc.Notification.Reply.Request, Anytype_Rpc.Notification.Reply.Response> {
        return Invocation(messageName: "NotificationReply", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNotificationReply(requestData) ?? Data()
            return try Anytype_Rpc.Notification.Reply.Response(serializedData: responseData)
        }
    }

    public static func notificationTest(
        _ request: Anytype_Rpc.Notification.Test.Request = .init()
    ) -> Invocation<Anytype_Rpc.Notification.Test.Request, Anytype_Rpc.Notification.Test.Response> {
        return Invocation(messageName: "NotificationTest", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNotificationTest(requestData) ?? Data()
            return try Anytype_Rpc.Notification.Test.Response(serializedData: responseData)
        }
    }

    public static func membershipGetStatus(
        _ request: Anytype_Rpc.Membership.GetStatus.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.GetStatus.Request, Anytype_Rpc.Membership.GetStatus.Response> {
        return Invocation(messageName: "MembershipGetStatus", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipGetStatus(requestData) ?? Data()
            return try Anytype_Rpc.Membership.GetStatus.Response(serializedData: responseData)
        }
    }

    public static func membershipIsNameValid(
        _ request:  Anytype_Rpc.Membership.IsNameValid.Request = .init()
    ) -> Invocation< Anytype_Rpc.Membership.IsNameValid.Request, Anytype_Rpc.Membership.IsNameValid.Response> {
        return Invocation(messageName: "MembershipIsNameValid", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipIsNameValid(requestData) ?? Data()
            return try Anytype_Rpc.Membership.IsNameValid.Response(serializedData: responseData)
        }
    }

    public static func membershipRegisterPaymentRequest(
        _ request: Anytype_Rpc.Membership.RegisterPaymentRequest.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.RegisterPaymentRequest.Request, Anytype_Rpc.Membership.RegisterPaymentRequest.Response> {
        return Invocation(messageName: "MembershipRegisterPaymentRequest", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipRegisterPaymentRequest(requestData) ?? Data()
            return try Anytype_Rpc.Membership.RegisterPaymentRequest.Response(serializedData: responseData)
        }
    }

    public static func membershipGetPortalLinkUrl(
        _ request: Anytype_Rpc.Membership.GetPortalLinkUrl.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.GetPortalLinkUrl.Request, Anytype_Rpc.Membership.GetPortalLinkUrl.Response> {
        return Invocation(messageName: "MembershipGetPortalLinkUrl", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipGetPortalLinkUrl(requestData) ?? Data()
            return try Anytype_Rpc.Membership.GetPortalLinkUrl.Response(serializedData: responseData)
        }
    }

    public static func membershipGetVerificationEmailStatus(
        _ request:  Anytype_Rpc.Membership.GetVerificationEmailStatus.Request = .init()
    ) -> Invocation< Anytype_Rpc.Membership.GetVerificationEmailStatus.Request, Anytype_Rpc.Membership.GetVerificationEmailStatus.Response> {
        return Invocation(messageName: "MembershipGetVerificationEmailStatus", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipGetVerificationEmailStatus(requestData) ?? Data()
            return try Anytype_Rpc.Membership.GetVerificationEmailStatus.Response(serializedData: responseData)
        }
    }

    public static func membershipGetVerificationEmail(
        _ request: Anytype_Rpc.Membership.GetVerificationEmail.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.GetVerificationEmail.Request, Anytype_Rpc.Membership.GetVerificationEmail.Response> {
        return Invocation(messageName: "MembershipGetVerificationEmail", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipGetVerificationEmail(requestData) ?? Data()
            return try Anytype_Rpc.Membership.GetVerificationEmail.Response(serializedData: responseData)
        }
    }

    public static func membershipVerifyEmailCode(
        _ request: Anytype_Rpc.Membership.VerifyEmailCode.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.VerifyEmailCode.Request, Anytype_Rpc.Membership.VerifyEmailCode.Response> {
        return Invocation(messageName: "MembershipVerifyEmailCode", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipVerifyEmailCode(requestData) ?? Data()
            return try Anytype_Rpc.Membership.VerifyEmailCode.Response(serializedData: responseData)
        }
    }

    public static func membershipFinalize(
        _ request: Anytype_Rpc.Membership.Finalize.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.Finalize.Request, Anytype_Rpc.Membership.Finalize.Response> {
        return Invocation(messageName: "MembershipFinalize", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipFinalize(requestData) ?? Data()
            return try Anytype_Rpc.Membership.Finalize.Response(serializedData: responseData)
        }
    }

    public static func membershipGetTiers(
        _ request: Anytype_Rpc.Membership.GetTiers.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.GetTiers.Request, Anytype_Rpc.Membership.GetTiers.Response> {
        return Invocation(messageName: "MembershipGetTiers", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipGetTiers(requestData) ?? Data()
            return try Anytype_Rpc.Membership.GetTiers.Response(serializedData: responseData)
        }
    }

    public static func membershipVerifyAppStoreReceipt(
        _ request: Anytype_Rpc.Membership.VerifyAppStoreReceipt.Request = .init()
    ) -> Invocation<Anytype_Rpc.Membership.VerifyAppStoreReceipt.Request, Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response> {
        return Invocation(messageName: "MembershipVerifyAppStoreReceipt", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceMembershipVerifyAppStoreReceipt(requestData) ?? Data()
            return try Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response(serializedData: responseData)
        }
    }

    public static func nameServiceUserAccountGet(
        _ request:  Anytype_Rpc.NameService.UserAccount.Get.Request = .init()
    ) -> Invocation< Anytype_Rpc.NameService.UserAccount.Get.Request, Anytype_Rpc.NameService.UserAccount.Get.Response> {
        return Invocation(messageName: "NameServiceUserAccountGet", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNameServiceUserAccountGet(requestData) ?? Data()
            return try Anytype_Rpc.NameService.UserAccount.Get.Response(serializedData: responseData)
        }
    }

    public static func nameServiceResolveName(
        _ request:  Anytype_Rpc.NameService.ResolveName.Request = .init()
    ) -> Invocation< Anytype_Rpc.NameService.ResolveName.Request, Anytype_Rpc.NameService.ResolveName.Response> {
        return Invocation(messageName: "NameServiceResolveName", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNameServiceResolveName(requestData) ?? Data()
            return try Anytype_Rpc.NameService.ResolveName.Response(serializedData: responseData)
        }
    }

    public static func nameServiceResolveAnyId(
        _ request:  Anytype_Rpc.NameService.ResolveAnyId.Request  = .init()
    ) -> Invocation< Anytype_Rpc.NameService.ResolveAnyId.Request , Anytype_Rpc.NameService.ResolveAnyId.Response> {
        return Invocation(messageName: "NameServiceResolveAnyId", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceNameServiceResolveAnyId(requestData) ?? Data()
            return try Anytype_Rpc.NameService.ResolveAnyId.Response(serializedData: responseData)
        }
    }

    public static func broadcastPayloadEvent(
        _ request: Anytype_Rpc.Broadcast.PayloadEvent.Request = .init()
    ) -> Invocation<Anytype_Rpc.Broadcast.PayloadEvent.Request, Anytype_Rpc.Broadcast.PayloadEvent.Response> {
        return Invocation(messageName: "BroadcastPayloadEvent", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceBroadcastPayloadEvent(requestData) ?? Data()
            return try Anytype_Rpc.Broadcast.PayloadEvent.Response(serializedData: responseData)
        }
    }

    public static func deviceSetName(
        _ request: Anytype_Rpc.Device.SetName.Request = .init()
    ) -> Invocation<Anytype_Rpc.Device.SetName.Request, Anytype_Rpc.Device.SetName.Response> {
        return Invocation(messageName: "DeviceSetName", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDeviceSetName(requestData) ?? Data()
            return try Anytype_Rpc.Device.SetName.Response(serializedData: responseData)
        }
    }

    public static func deviceList(
        _ request: Anytype_Rpc.Device.List.Request = .init()
    ) -> Invocation<Anytype_Rpc.Device.List.Request, Anytype_Rpc.Device.List.Response> {
        return Invocation(messageName: "DeviceList", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDeviceList(requestData) ?? Data()
            return try Anytype_Rpc.Device.List.Response(serializedData: responseData)
        }
    }

    public static func deviceNetworkStateSet(
        _ request: Anytype_Rpc.Device.NetworkState.Set.Request = .init()
    ) -> Invocation<Anytype_Rpc.Device.NetworkState.Set.Request, Anytype_Rpc.Device.NetworkState.Set.Response> {
        return Invocation(messageName: "DeviceNetworkStateSet", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceDeviceNetworkStateSet(requestData) ?? Data()
            return try Anytype_Rpc.Device.NetworkState.Set.Response(serializedData: responseData)
        }
    }

    public static func chatAddMessage(
        _ request: Anytype_Rpc.Chat.AddMessage.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.AddMessage.Request, Anytype_Rpc.Chat.AddMessage.Response> {
        return Invocation(messageName: "ChatAddMessage", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatAddMessage(requestData) ?? Data()
            return try Anytype_Rpc.Chat.AddMessage.Response(serializedData: responseData)
        }
    }

    public static func chatEditMessageContent(
        _ request: Anytype_Rpc.Chat.EditMessageContent.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.EditMessageContent.Request, Anytype_Rpc.Chat.EditMessageContent.Response> {
        return Invocation(messageName: "ChatEditMessageContent", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatEditMessageContent(requestData) ?? Data()
            return try Anytype_Rpc.Chat.EditMessageContent.Response(serializedData: responseData)
        }
    }

    public static func chatToggleMessageReaction(
        _ request: Anytype_Rpc.Chat.ToggleMessageReaction.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.ToggleMessageReaction.Request, Anytype_Rpc.Chat.ToggleMessageReaction.Response> {
        return Invocation(messageName: "ChatToggleMessageReaction", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatToggleMessageReaction(requestData) ?? Data()
            return try Anytype_Rpc.Chat.ToggleMessageReaction.Response(serializedData: responseData)
        }
    }

    public static func chatDeleteMessage(
        _ request: Anytype_Rpc.Chat.DeleteMessage.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.DeleteMessage.Request, Anytype_Rpc.Chat.DeleteMessage.Response> {
        return Invocation(messageName: "ChatDeleteMessage", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatDeleteMessage(requestData) ?? Data()
            return try Anytype_Rpc.Chat.DeleteMessage.Response(serializedData: responseData)
        }
    }

    public static func chatGetMessages(
        _ request: Anytype_Rpc.Chat.GetMessages.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.GetMessages.Request, Anytype_Rpc.Chat.GetMessages.Response> {
        return Invocation(messageName: "ChatGetMessages", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatGetMessages(requestData) ?? Data()
            return try Anytype_Rpc.Chat.GetMessages.Response(serializedData: responseData)
        }
    }

    public static func chatGetMessagesByIds(
        _ request: Anytype_Rpc.Chat.GetMessagesByIds.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.GetMessagesByIds.Request, Anytype_Rpc.Chat.GetMessagesByIds.Response> {
        return Invocation(messageName: "ChatGetMessagesByIds", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatGetMessagesByIds(requestData) ?? Data()
            return try Anytype_Rpc.Chat.GetMessagesByIds.Response(serializedData: responseData)
        }
    }

    public static func chatSubscribeLastMessages(
        _ request: Anytype_Rpc.Chat.SubscribeLastMessages.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.SubscribeLastMessages.Request, Anytype_Rpc.Chat.SubscribeLastMessages.Response> {
        return Invocation(messageName: "ChatSubscribeLastMessages", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatSubscribeLastMessages(requestData) ?? Data()
            return try Anytype_Rpc.Chat.SubscribeLastMessages.Response(serializedData: responseData)
        }
    }

    public static func chatUnsubscribe(
        _ request: Anytype_Rpc.Chat.Unsubscribe.Request = .init()
    ) -> Invocation<Anytype_Rpc.Chat.Unsubscribe.Request, Anytype_Rpc.Chat.Unsubscribe.Response> {
        return Invocation(messageName: "ChatUnsubscribe", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceChatUnsubscribe(requestData) ?? Data()
            return try Anytype_Rpc.Chat.Unsubscribe.Response(serializedData: responseData)
        }
    }

    public static func objectChatAdd(
        _ request: Anytype_Rpc.Object.ChatAdd.Request = .init()
    ) -> Invocation<Anytype_Rpc.Object.ChatAdd.Request, Anytype_Rpc.Object.ChatAdd.Response> {
        return Invocation(messageName: "ObjectChatAdd", request: request) { request in
            let requestData = try request.serializedData()
            let responseData = Lib.ServiceObjectChatAdd(requestData) ?? Data()
            return try Anytype_Rpc.Object.ChatAdd.Response(serializedData: responseData)
        }
    }

}

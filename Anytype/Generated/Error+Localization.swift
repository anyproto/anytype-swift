// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import ProtobufMessages

extension Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.ChangeNetworkConfigAndRestart.accountIsNotRunning", table: "LocalizableError")
            case .accountFailedToStop:
                String(localizedFixedKey: "Account.ChangeNetworkConfigAndRestart.accountFailedToStop", table: "LocalizableError")
            case .configFileNotFound:
                String(localizedFixedKey: "Account.ChangeNetworkConfigAndRestart.configFileNotFound", table: "LocalizableError")
            case .configFileInvalid:
                String(localizedFixedKey: "Account.ChangeNetworkConfigAndRestart.configFileInvalid", table: "LocalizableError")
            case .configFileNetworkIDMismatch:
                String(localizedFixedKey: "Account.ChangeNetworkConfigAndRestart.configFileNetworkIDMismatch", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.ConfigUpdate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.ConfigUpdate.accountIsNotRunning", table: "LocalizableError")
            case .failedToWriteConfig:
                String(localizedFixedKey: "Account.ConfigUpdate.failedToWriteConfig", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountCreatedButFailedToStartNode:
                String(localizedFixedKey: "Account.Create.accountCreatedButFailedToStartNode", table: "LocalizableError")
            case .accountCreatedButFailedToSetName:
                String(localizedFixedKey: "Account.Create.accountCreatedButFailedToSetName", table: "LocalizableError")
            case .failedToStopRunningNode:
                String(localizedFixedKey: "Account.Create.failedToStopRunningNode", table: "LocalizableError")
            case .failedToWriteConfig:
                String(localizedFixedKey: "Account.Create.failedToWriteConfig", table: "LocalizableError")
            case .failedToCreateLocalRepo:
                String(localizedFixedKey: "Account.Create.failedToCreateLocalRepo", table: "LocalizableError")
            case .accountCreationIsCanceled:
                String(localizedFixedKey: "Account.Create.accountCreationIsCanceled", table: "LocalizableError")
            case .configFileNotFound:
                String(localizedFixedKey: "Account.Create.configFileNotFound", table: "LocalizableError")
            case .configFileInvalid:
                String(localizedFixedKey: "Account.Create.configFileInvalid", table: "LocalizableError")
            case .configFileNetworkIDMismatch:
                String(localizedFixedKey: "Account.Create.configFileNetworkIDMismatch", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsAlreadyDeleted:
                String(localizedFixedKey: "Account.Delete.accountIsAlreadyDeleted", table: "LocalizableError")
            case .unableToConnect:
                String(localizedFixedKey: "Account.Delete.unableToConnect", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.EnableLocalNetworkSync.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.EnableLocalNetworkSync.accountIsNotRunning", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.LocalLink.NewChallenge.accountIsNotRunning", table: "LocalizableError")
            case .tooManyRequests:
                String(localizedFixedKey: "Account.LocalLink.NewChallenge.tooManyRequests", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.LocalLink.SolveChallenge.accountIsNotRunning", table: "LocalizableError")
            case .invalidChallengeID:
                String(localizedFixedKey: "Account.LocalLink.SolveChallenge.invalidChallengeID", table: "LocalizableError")
            case .challengeAttemptsExceeded:
                String(localizedFixedKey: "Account.LocalLink.SolveChallenge.challengeAttemptsExceeded", table: "LocalizableError")
            case .incorrectAnswer:
                String(localizedFixedKey: "Account.LocalLink.SolveChallenge.incorrectAnswer", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Move.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .failedToStopNode:
                String(localizedFixedKey: "Account.Move.failedToStopNode", table: "LocalizableError")
            case .failedToIdentifyAccountDir:
                String(localizedFixedKey: "Account.Move.failedToIdentifyAccountDir", table: "LocalizableError")
            case .failedToRemoveAccountData:
                String(localizedFixedKey: "Account.Move.failedToRemoveAccountData", table: "LocalizableError")
            case .failedToCreateLocalRepo:
                String(localizedFixedKey: "Account.Move.failedToCreateLocalRepo", table: "LocalizableError")
            case .failedToWriteConfig:
                String(localizedFixedKey: "Account.Move.failedToWriteConfig", table: "LocalizableError")
            case .failedToGetConfig:
                String(localizedFixedKey: "Account.Move.failedToGetConfig", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Recover.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .needToRecoverWalletFirst:
                String(localizedFixedKey: "Account.Recover.needToRecoverWalletFirst", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.RecoverFromLegacyExport.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .differentAccount:
                String(localizedFixedKey: "Account.RecoverFromLegacyExport.differentAccount", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.RevertDeletion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsActive:
                String(localizedFixedKey: "Account.RevertDeletion.accountIsActive", table: "LocalizableError")
            case .unableToConnect:
                String(localizedFixedKey: "Account.RevertDeletion.unableToConnect", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Select.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .failedToCreateLocalRepo:
                String(localizedFixedKey: "Account.Select.failedToCreateLocalRepo", table: "LocalizableError")
            case .localRepoExistsButCorrupted:
                String(localizedFixedKey: "Account.Select.localRepoExistsButCorrupted", table: "LocalizableError")
            case .failedToRunNode:
                String(localizedFixedKey: "Account.Select.failedToRunNode", table: "LocalizableError")
            case .failedToFindAccountInfo:
                String(localizedFixedKey: "Account.Select.failedToFindAccountInfo", table: "LocalizableError")
            case .localRepoNotExistsAndMnemonicNotSet:
                String(localizedFixedKey: "Account.Select.localRepoNotExistsAndMnemonicNotSet", table: "LocalizableError")
            case .failedToStopSearcherNode:
                String(localizedFixedKey: "Account.Select.failedToStopSearcherNode", table: "LocalizableError")
            case .anotherAnytypeProcessIsRunning:
                String(localizedFixedKey: "Account.Select.anotherAnytypeProcessIsRunning", table: "LocalizableError")
            case .failedToFetchRemoteNodeHasIncompatibleProtoVersion:
                String(localizedFixedKey: "Account.Select.failedToFetchRemoteNodeHasIncompatibleProtoVersion", table: "LocalizableError")
            case .accountIsDeleted:
                String(localizedFixedKey: "Account.Select.accountIsDeleted", table: "LocalizableError")
            case .accountLoadIsCanceled:
                String(localizedFixedKey: "Account.Select.accountLoadIsCanceled", table: "LocalizableError")
            case .configFileNotFound:
                String(localizedFixedKey: "Account.Select.configFileNotFound", table: "LocalizableError")
            case .configFileInvalid:
                String(localizedFixedKey: "Account.Select.configFileInvalid", table: "LocalizableError")
            case .configFileNetworkIDMismatch:
                String(localizedFixedKey: "Account.Select.configFileNetworkIDMismatch", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Account.Stop.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .accountIsNotRunning:
                String(localizedFixedKey: "Account.Stop.accountIsNotRunning", table: "LocalizableError")
            case .failedToStopNode:
                String(localizedFixedKey: "Account.Stop.failedToStopNode", table: "LocalizableError")
            case .failedToRemoveAccountData:
                String(localizedFixedKey: "Account.Stop.failedToRemoveAccountData", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.App.GetVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.App.SetDeviceState.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.App.Shutdown.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Copy.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.CreateWidget.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Cut.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Export.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListConvertToObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListMoveToNewObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetAlign.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetFields.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetVerticalAlign.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.ListTurnInto.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Merge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Paste.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Preview.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.SetCarriage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.SetFields.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Split.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Block.Upload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockBookmark.Fetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.CreateBookmark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.CreateFromExistingObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.GroupOrder.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.ListAvailable.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.SetSource.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.SSort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockFile.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockFile.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockImage.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockImage.SetWidth.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockLatex.SetProcessor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockLatex.SetText.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockLink.CreateWithObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockRelation.SetKey.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnCreate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnListFill.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnMove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Expand.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowCreate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowListClean.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowListFill.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowSetHeader.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListClearContent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListClearStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetMark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetChecked.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetIcon.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetMarks.Get.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetText.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockVideo.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockVideo.SetWidth.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetLayout.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetLimit.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetTargetId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetViewId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Broadcast.PayloadEvent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Broadcast.PayloadEvent.internalError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.ExportLocalstore.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.OpenedObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.Ping.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.SpaceSummary.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.StackGoroutines.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.Stat.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.Subscriptions.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.Tree.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Debug.TreeHeads.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.Drop.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.ListOffload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .nodeNotStarted:
                String(localizedFixedKey: "File.ListOffload.nodeNotStarted", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.NodeUsage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.Offload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .nodeNotStarted:
                String(localizedFixedKey: "File.Offload.nodeNotStarted", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.SpaceOffload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .nodeNotStarted:
                String(localizedFixedKey: "File.SpaceOffload.nodeNotStarted", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.SpaceUsage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.File.Upload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Gallery.DownloadIndex.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .unmarshallingError:
                String(localizedFixedKey: "Gallery.DownloadIndex.unmarshallingError", table: "LocalizableError")
            case .downloadError:
                String(localizedFixedKey: "Gallery.DownloadIndex.downloadError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.GenericErrorResponse.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.History.GetVersions.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.History.SetVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.History.ShowVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.LinkPreview.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Log.Send.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.Finalize.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.Finalize.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.Finalize.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.Finalize.cacheError", table: "LocalizableError")
            case .membershipNotFound:
                String(localizedFixedKey: "Membership.Finalize.membershipNotFound", table: "LocalizableError")
            case .membershipWrongState:
                String(localizedFixedKey: "Membership.Finalize.membershipWrongState", table: "LocalizableError")
            case .badAnyname:
                String(localizedFixedKey: "Membership.Finalize.badAnyname", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetPaymentUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetPaymentUrl.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetPaymentUrl.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.GetPaymentUrl.cacheError", table: "LocalizableError")
            case .tierNotFound:
                String(localizedFixedKey: "Membership.GetPaymentUrl.tierNotFound", table: "LocalizableError")
            case .tierInvalid:
                String(localizedFixedKey: "Membership.GetPaymentUrl.tierInvalid", table: "LocalizableError")
            case .paymentMethodInvalid:
                String(localizedFixedKey: "Membership.GetPaymentUrl.paymentMethodInvalid", table: "LocalizableError")
            case .badAnyname:
                String(localizedFixedKey: "Membership.GetPaymentUrl.badAnyname", table: "LocalizableError")
            case .membershipAlreadyExists:
                String(localizedFixedKey: "Membership.GetPaymentUrl.membershipAlreadyExists", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetPortalLinkUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetPortalLinkUrl.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetPortalLinkUrl.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.GetPortalLinkUrl.cacheError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetStatus.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetStatus.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetStatus.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.GetStatus.cacheError", table: "LocalizableError")
            case .membershipNotFound:
                String(localizedFixedKey: "Membership.GetStatus.membershipNotFound", table: "LocalizableError")
            case .membershipWrongState:
                String(localizedFixedKey: "Membership.GetStatus.membershipWrongState", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetTiers.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetTiers.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetTiers.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.GetTiers.cacheError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetVerificationEmail.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetVerificationEmail.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetVerificationEmail.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.GetVerificationEmail.cacheError", table: "LocalizableError")
            case .emailWrongFormat:
                String(localizedFixedKey: "Membership.GetVerificationEmail.emailWrongFormat", table: "LocalizableError")
            case .emailAlreadyVerified:
                String(localizedFixedKey: "Membership.GetVerificationEmail.emailAlreadyVerified", table: "LocalizableError")
            case .emailAlredySent:
                String(localizedFixedKey: "Membership.GetVerificationEmail.emailAlredySent", table: "LocalizableError")
            case .emailFailedToSend:
                String(localizedFixedKey: "Membership.GetVerificationEmail.emailFailedToSend", table: "LocalizableError")
            case .membershipAlreadyExists:
                String(localizedFixedKey: "Membership.GetVerificationEmail.membershipAlreadyExists", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.GetVerificationEmailStatus.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.GetVerificationEmailStatus.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.GetVerificationEmailStatus.paymentNodeError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.IsNameValid.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .tooShort:
                String(localizedFixedKey: "Membership.IsNameValid.tooShort", table: "LocalizableError")
            case .tooLong:
                String(localizedFixedKey: "Membership.IsNameValid.tooLong", table: "LocalizableError")
            case .hasInvalidChars:
                String(localizedFixedKey: "Membership.IsNameValid.hasInvalidChars", table: "LocalizableError")
            case .tierFeaturesNoName:
                String(localizedFixedKey: "Membership.IsNameValid.tierFeaturesNoName", table: "LocalizableError")
            case .tierNotFound:
                String(localizedFixedKey: "Membership.IsNameValid.tierNotFound", table: "LocalizableError")
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.IsNameValid.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.IsNameValid.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.IsNameValid.cacheError", table: "LocalizableError")
            case .inBlacklist:
                String(localizedFixedKey: "Membership.IsNameValid.inBlacklist", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Membership.VerifyEmailCode.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "Membership.VerifyEmailCode.notLoggedIn", table: "LocalizableError")
            case .paymentNodeError:
                String(localizedFixedKey: "Membership.VerifyEmailCode.paymentNodeError", table: "LocalizableError")
            case .cacheError:
                String(localizedFixedKey: "Membership.VerifyEmailCode.cacheError", table: "LocalizableError")
            case .emailAlreadyVerified:
                String(localizedFixedKey: "Membership.VerifyEmailCode.emailAlreadyVerified", table: "LocalizableError")
            case .expired:
                String(localizedFixedKey: "Membership.VerifyEmailCode.expired", table: "LocalizableError")
            case .wrong:
                String(localizedFixedKey: "Membership.VerifyEmailCode.wrong", table: "LocalizableError")
            case .membershipNotFound:
                String(localizedFixedKey: "Membership.VerifyEmailCode.membershipNotFound", table: "LocalizableError")
            case .membershipAlreadyActive:
                String(localizedFixedKey: "Membership.VerifyEmailCode.membershipAlreadyActive", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Metrics.SetParameters.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveAnyId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveSpaceId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.NameService.UserAccount.Get.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notLoggedIn:
                String(localizedFixedKey: "NameService.UserAccount.Get.notLoggedIn", table: "LocalizableError")
            case .badNameResolve:
                String(localizedFixedKey: "NameService.UserAccount.Get.badNameResolve", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Navigation.ListObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Notification.List.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Notification.List.internalError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Notification.Reply.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Notification.Reply.internalError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Notification.Test.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Notification.Test.internalError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ApplyTemplate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.BookmarkFetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Close.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateBookmark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateFromUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateRelation.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateRelationOption.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.CreateSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .unknownObjectTypeURL:
                String(localizedFixedKey: "Object.CreateSet.unknownObjectTypeURL", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Duplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Graph.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.GroupsSubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Object.Import.Notion.ValidateToken.internalError", table: "LocalizableError")
            case .unauthorized:
                String(localizedFixedKey: "Object.Import.Notion.ValidateToken.unauthorized", table: "LocalizableError")
            case .forbidden:
                String(localizedFixedKey: "Object.Import.Notion.ValidateToken.forbidden", table: "LocalizableError")
            case .serviceUnavailable:
                String(localizedFixedKey: "Object.Import.Notion.ValidateToken.serviceUnavailable", table: "LocalizableError")
            case .accountIsNotRunning:
                String(localizedFixedKey: "Object.Import.Notion.ValidateToken.accountIsNotRunning", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Import.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Object.Import.internalError", table: "LocalizableError")
            case .noObjectsToImport:
                String(localizedFixedKey: "Object.Import.noObjectsToImport", table: "LocalizableError")
            case .importIsCanceled:
                String(localizedFixedKey: "Object.Import.importIsCanceled", table: "LocalizableError")
            case .limitOfRowsOrRelationsExceeded:
                String(localizedFixedKey: "Object.Import.limitOfRowsOrRelationsExceeded", table: "LocalizableError")
            case .fileLoadError:
                String(localizedFixedKey: "Object.Import.fileLoadError", table: "LocalizableError")
            case .insufficientPermissions:
                String(localizedFixedKey: "Object.Import.insufficientPermissions", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ImportExperience.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .insufficientPermission:
                String(localizedFixedKey: "Object.ImportExperience.insufficientPermission", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ImportList.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .internalError:
                String(localizedFixedKey: "Object.ImportList.internalError", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ImportUseCase.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListExport.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetIsArchived.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetIsFavorite.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Open.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notFound:
                String(localizedFixedKey: "Object.Open.notFound", table: "LocalizableError")
            case .anytypeNeedsUpgrade:
                String(localizedFixedKey: "Object.Open.anytypeNeedsUpgrade", table: "LocalizableError")
            case .objectDeleted:
                String(localizedFixedKey: "Object.Open.objectDeleted", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Redo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .canNotMove:
                String(localizedFixedKey: "Object.Redo.canNotMove", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Search.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SearchSubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SearchUnsubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetBreadcrumbs.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetDetails.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetInternalFlags.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetIsArchived.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetIsFavorite.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetLayout.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SetSource.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ShareByLink.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Show.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .notFound:
                String(localizedFixedKey: "Object.Show.notFound", table: "LocalizableError")
            case .objectDeleted:
                String(localizedFixedKey: "Object.Show.objectDeleted", table: "LocalizableError")
            case .anytypeNeedsUpgrade:
                String(localizedFixedKey: "Object.Show.anytypeNeedsUpgrade", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.SubscribeIds.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ToBookmark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ToCollection.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.ToSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.Undo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .canNotMove:
                String(localizedFixedKey: "Object.Undo.canNotMove", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Object.WorkspaceSetDashboard.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Relation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .readonlyObjectType:
                String(localizedFixedKey: "ObjectType.Relation.Add.readonlyObjectType", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .readonlyObjectType:
                String(localizedFixedKey: "ObjectType.Relation.Remove.readonlyObjectType", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Process.Cancel.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Relation.ListRemoveOption.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .optionUsedByObjects:
                String(localizedFixedKey: "Relation.ListRemoveOption.optionUsedByObjects", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Relation.Options.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.Delete.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.Delete.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.Delete.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.Delete.limitReached", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.Delete.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.InviteGenerate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.InviteGenerate.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.InviteGenerate.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.InviteGenerate.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.InviteGenerate.limitReached", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.InviteGenerate.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.InviteGetCurrent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noActiveInvite:
                String(localizedFixedKey: "Space.InviteGetCurrent.noActiveInvite", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.InviteRevoke.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.InviteRevoke.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.InviteRevoke.spaceIsDeleted", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.InviteRevoke.limitReached", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.InviteRevoke.requestFailed", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.InviteRevoke.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.InviteView.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .inviteNotFound:
                String(localizedFixedKey: "Space.InviteView.inviteNotFound", table: "LocalizableError")
            case .inviteBadContent:
                String(localizedFixedKey: "Space.InviteView.inviteBadContent", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.Join.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.Join.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.Join.spaceIsDeleted", table: "LocalizableError")
            case .inviteNotFound:
                String(localizedFixedKey: "Space.Join.inviteNotFound", table: "LocalizableError")
            case .inviteBadContent:
                String(localizedFixedKey: "Space.Join.inviteBadContent", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.Join.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.Join.limitReached", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.Join.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.JoinCancel.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.JoinCancel.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.JoinCancel.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.JoinCancel.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.JoinCancel.limitReached", table: "LocalizableError")
            case .noSuchRequest:
                String(localizedFixedKey: "Space.JoinCancel.noSuchRequest", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.JoinCancel.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.LeaveApprove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.LeaveApprove.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.LeaveApprove.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.LeaveApprove.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.LeaveApprove.limitReached", table: "LocalizableError")
            case .noApproveRequests:
                String(localizedFixedKey: "Space.LeaveApprove.noApproveRequests", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.LeaveApprove.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.MakeShareable.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.MakeShareable.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.MakeShareable.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.MakeShareable.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.MakeShareable.limitReached", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.ParticipantPermissionsChange.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.limitReached", table: "LocalizableError")
            case .participantNotFound:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.participantNotFound", table: "LocalizableError")
            case .incorrectPermissions:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.incorrectPermissions", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.ParticipantPermissionsChange.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.ParticipantRemove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.ParticipantRemove.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.ParticipantRemove.spaceIsDeleted", table: "LocalizableError")
            case .participantNotFound:
                String(localizedFixedKey: "Space.ParticipantRemove.participantNotFound", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.ParticipantRemove.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.ParticipantRemove.limitReached", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.ParticipantRemove.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.RequestApprove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.RequestApprove.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.RequestApprove.spaceIsDeleted", table: "LocalizableError")
            case .noSuchRequest:
                String(localizedFixedKey: "Space.RequestApprove.noSuchRequest", table: "LocalizableError")
            case .incorrectPermissions:
                String(localizedFixedKey: "Space.RequestApprove.incorrectPermissions", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.RequestApprove.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.RequestApprove.limitReached", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.RequestApprove.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.RequestDecline.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.RequestDecline.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.RequestDecline.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.RequestDecline.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.RequestDecline.limitReached", table: "LocalizableError")
            case .noSuchRequest:
                String(localizedFixedKey: "Space.RequestDecline.noSuchRequest", table: "LocalizableError")
            case .notShareable:
                String(localizedFixedKey: "Space.RequestDecline.notShareable", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Space.StopSharing.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .noSuchSpace:
                String(localizedFixedKey: "Space.StopSharing.noSuchSpace", table: "LocalizableError")
            case .spaceIsDeleted:
                String(localizedFixedKey: "Space.StopSharing.spaceIsDeleted", table: "LocalizableError")
            case .requestFailed:
                String(localizedFixedKey: "Space.StopSharing.requestFailed", table: "LocalizableError")
            case .limitReached:
                String(localizedFixedKey: "Space.StopSharing.limitReached", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Template.Clone.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Template.CreateFromObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Template.ExportAll.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Unsplash.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .rateLimitExceeded:
                String(localizedFixedKey: "Unsplash.Download.rateLimitExceeded", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Unsplash.Search.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .rateLimitExceeded:
                String(localizedFixedKey: "Unsplash.Search.rateLimitExceeded", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Wallet.CloseSession.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Wallet.Convert.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Wallet.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .failedToCreateLocalRepo:
                String(localizedFixedKey: "Wallet.Create.failedToCreateLocalRepo", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Wallet.CreateSession.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .appTokenNotFoundInTheCurrentAccount:
                String(localizedFixedKey: "Wallet.CreateSession.appTokenNotFoundInTheCurrentAccount", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Wallet.Recover.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .failedToCreateLocalRepo:
                String(localizedFixedKey: "Wallet.Recover.failedToCreateLocalRepo", table: "LocalizableError")
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Export.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.GetAll.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.GetCurrent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.ListAdd.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.ListRemove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Open.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.Select.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}

extension Anytype_Rpc.Workspace.SetInfo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if localizeError.isNotEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                ""
            case .unknownError:
                ""
            case .badInput:
                ""
            case .UNRECOGNIZED:
                ""
        }
    }
}


private extension String {
    // If default value is emplty, Apple return key. But we expect that localziation return empty string
    init(localizedFixedKey: StaticString, table: String? = nil) {
        let result = String(localized: localizedFixedKey, defaultValue: "", table: table)
        if result == "\(localizedFixedKey)" {
            self = ""
        } else {
            self = result
        }
    }
}
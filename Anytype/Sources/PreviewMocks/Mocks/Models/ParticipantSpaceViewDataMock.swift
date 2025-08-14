import Services

extension ParticipantSpaceViewData {
    static func mock(accountStatus: SpaceStatus? = .allCases.randomElement(), localStatus: SpaceStatus? = .allCases.randomElement()) -> Self {
        ParticipantSpaceViewData(
            spaceView: SpaceView.mock(accountStatus: accountStatus, localStatus: localStatus),
            participant: Participant.mock(),
            permissions: SpacePermissions.mock()
        )
    }
}

import Foundation

extension ProfileElement {
    /// ProfileElementにキャスト
    func toMyProfileElement() -> MyProfileElement {
        let profile = MyProfileElement(
            id: self.id ?? "",
            userName: self.userName,
            introduction: self.introduction,
            birth: self.birth,
            gender: self.gender,
            address: self.address,
            grade: self.grade,
            hobby: self.hobby,
            location: self.location,
            profession: self.profession,
            profileImages: self.profileImages,
            homeImage: self.homeImage,
            point: self.point
        )

        return profile
    }

    /// ProfileTypeを指定して、文字列にする
    func toString(profileType: ProfileType) -> String? {
        var result: String? = nil
        let profile = self

        switch profileType {
        case .userName:
            result = profile.userName
        case .introduction:
            result = profile.introduction
        case .birth:
            result = profile.birth.toStringDate()
        case .gender:
            result = profile.gender.rawValue
        case .address:
            result = profile.address
        case .grade:
            result = String(profile.grade)
        case .hobby:
            if !profile.hobby.isEmpty {
                result = profile.hobby.joined(separator: "・")
            }
        case .location:
            /// 使用しない。
            result = String(profile.location.debugDescription)
        case .profession:
            result = profile.profession
        case .point:
            result = String(profile.point) + "ポイント"
        }

        return result
    }

    /// 年齢、出身地、職業を「|」でつなげる
    func jointProfile() -> String {
        var result: String = ""
        var jointingInfo: [String] = []

        jointingInfo.append(self.birth.toAge())
        jointingInfo.append(self.address)
        if let profession = profession {
            jointingInfo.append(profession)
        }
        result = jointingInfo.joined(separator: " | ")

        return result
    }
}

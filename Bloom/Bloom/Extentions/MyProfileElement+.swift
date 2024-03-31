import Foundation

extension MyProfileElement {
    /// ProfileElementにキャスト
    func toProfileElement() -> ProfileElement {
        let profile = ProfileElement(
            id: self.id,
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
}

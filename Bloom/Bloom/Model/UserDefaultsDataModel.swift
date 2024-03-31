import Foundation

struct UserDefaultsDataModel {
    let userDataModel = UserDataModel()
    let myProfileKey: String = "myProfileKey"
    let filterKey: String = "filterKey"

    // MARK: - MyProfile
    /// MyProfileデータの追加・更新
    func addMyProfile(myProfile: ProfileElement) {
        guard let uid = userDataModel.fetchUid() else { return }
        let myProfileElement: MyProfileElement = MyProfileElement(
            id: myProfile.id ?? uid,
            userName: myProfile.userName,
            introduction: myProfile.introduction,
            birth: myProfile.birth,
            gender: myProfile.gender,
            address: myProfile.address,
            grade: myProfile.grade,
            hobby: myProfile.hobby,
            location: myProfile.location,
            profession: myProfile.profession,
            profileImages: myProfile.profileImages,
            homeImage: myProfile.homeImage,
            point: myProfile.point
        )
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        guard let profileStrData = try? jsonEncoder.encode(myProfileElement) else {
            print("encodeでエラー")
            return
        }
        
        UserDefaults.standard.set(profileStrData, forKey: myProfileKey)
    }
    
    /// MyProfileのデータの取得
    func fetchMyProfile() -> MyProfileElement? {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = UserDefaults.standard.data(forKey: myProfileKey),
              let profile = try? jsonDecoder.decode(MyProfileElement.self, from: data) else {
            print("error: アカウントがDeviceにないか、decodeエラー")
            return nil
        }
        
        return profile
    }
    
    /// MyProfileのデータの削除
    func deleteMyProfile() {
        UserDefaults.standard.removeObject(forKey: myProfileKey)
    }

    // MARK: - フィルター
    /// フィルターデータの追加・更新
    func addFilter(filter: FilterElement) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        guard let filterStrData = try? jsonEncoder.encode(filter) else {
            print("encodeでエラー")
            return
        }

        UserDefaults.standard.set(filterStrData, forKey: filterKey)
    }

    /// フィルターデータの取得
    func fetchFilter() -> FilterElement? {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = UserDefaults.standard.data(forKey: filterKey),
              let filter = try? jsonDecoder.decode(FilterElement.self, from: data) else {
            print("error: filterの取得に失敗")
            return nil
        }

        return filter
    }

    /// フィルターデータの削除
    func deleteFilter() {
        UserDefaults.standard.removeObject(forKey: filterKey)
    }
}

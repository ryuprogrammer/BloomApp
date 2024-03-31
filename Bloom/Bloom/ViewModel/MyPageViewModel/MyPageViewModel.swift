import Foundation
import FirebaseFirestore
import FirebaseAuth

class MyPageViewModel: ObservableObject {
    let userDataModel = UserDataModel()
    let userDefaultsDataModel = UserDefaultsDataModel()
    let authenticationManager = AuthenticationManager()
    @Published var myProfile: ProfileElement? = nil
    @Published var locationString: String? = nil

    /// プロフィール取得：UserDefaultsから
    func fetchMyProfile() {
        if let profile = userDefaultsDataModel.fetchMyProfile() {
            myProfile = ProfileElement(
                userName: profile.userName,
                introduction: profile.introduction,
                birth: profile.birth,
                gender: profile.gender,
                address: profile.address,
                grade: profile.grade,
                hobby: profile.hobby,
                location: profile.location,
                profession: profile.profession,
                profileImages: profile.profileImages,
                homeImage: profile.homeImage,
                point: profile.point
            )
        } else {
            print("error: fetchMyProfile")
        }
    }
    
    /// profile更新：UserDefaultsとfirestrage
    func upDateMyProfile(profile: ProfileElement) {
        userDataModel.addProfile(profile: profile) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        userDefaultsDataModel.addMyProfile(myProfile: profile)
    }
    
    /// ProfileのprofileImagesを全削除（profileImagesを更新する前に削除する）
    func deleteProfileImages(deleteImageCount: Int) async {
        await userDataModel.deleteProfileImages(deleteImageCount: deleteImageCount) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /// 退会（ユーザーデータ削除）
    func deleteUser() {
//        authenticationManager.deleteUser()
        userDefaultsDataModel.deleteMyProfile()
    }

    // MARK: - extention系メソッド
    /// Locationから住所取得
    func fetchAddress(location: Location?) async {
        guard let location = location else { return }
        let address = await location.toAddress()
        DispatchQueue.main.async {
            self.locationString = address
        }
    }
}

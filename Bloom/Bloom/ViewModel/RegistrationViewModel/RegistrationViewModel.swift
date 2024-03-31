import Foundation
import FirebaseFirestore

/// @Observableを使うことでプロパティ変数profileの変更によって自動でデータが更新
class RegistrationViewModel: ObservableObject {
    @Published private(set) var friendProfiles: [ProfileElement] = []
    private var lister: ListenerRegistration?
    private var userDataModel = UserDataModel()
    let explanationText = ExplanationText()
    let prefectures = Prefectures()
    let userDefaultsDataModel = UserDefaultsDataModel()
    
    // 初期化
    init() {
        lister = userDataModel.listenProfiles { [weak self] (profiles, error) in
            if let profiles = profiles {
                self?.friendProfiles.append(contentsOf: profiles)
                self?.friendProfiles.removeAll(where: { profile in
                    if let profileUid = profile.id {
                        let myUid = self?.userDataModel.fetchUid()
                        if profileUid == myUid {
                            return true
                        }
                    }
                    return false
                })
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    deinit {
        lister?.remove()
    }
    
    /// Profile追加メソッド
    func addProfile(profile: ProfileElement) {
        // firestrageに追加
        userDataModel.addProfile(
            profile: ProfileElement(
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
            )) { error in
                print("error: error")
            }
        
        // UserDefaultsにも追加する
        userDefaultsDataModel.addMyProfile(myProfile: profile)
    }
}

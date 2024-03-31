import SwiftUI
import PhotosUI

struct HomeImageEntryView: View {
    var registrationVM = RegistrationViewModel()
    let explanationText = ExplanationText()
    @State var selectedItem: PhotosPickerItem?
    @State var uiImage: UIImage = UIImage()
    @Binding var homeImage: Data
    @Binding var registrationState: RegistrationState
    @State var isImageValid: Bool = false
    // 画面横幅取得→写真の横幅と縦幅に利用
    let imageWidth = UIScreen.main.bounds.width / 2
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Text(explanationText.homeImageEntryDescription)
                        .font(.title3)
                        .padding()
                    
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .strokeBorder(Color.black.opacity(0.8), lineWidth: 5)
                            .frame(width: imageWidth, height: imageWidth)
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageWidth/2, height: imageWidth/2)
                            .foregroundStyle(Color.white)
                        
                        if isImageValid {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: imageWidth, height: imageWidth)
                                .clipShape(Circle())
                        }
                        
                        PhotosPicker(selection: $selectedItem) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: imageWidth/3, height: imageWidth/3)
                                .foregroundStyle(Color.pink.opacity(0.8))
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(x: imageWidth/3, y: imageWidth/3)
                        .onChange(of: selectedItem) {
                            Task {
                                guard let data = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
                                guard let uiImage = UIImage(data: data) else { return }
                                self.uiImage = uiImage
                                
                                if let imageData = uiImage.jpegData(compressionQuality: 0.1) {
                                    homeImage = imageData
                                }
                            }
                            isImageValid = true
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationBarTitle("ホーム写真", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            registrationState = .profileImage
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(Color.black)
                        })
                    }
                }
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        registrationState = .doneAll
                    }
                }, label: {
                    Text("次へ")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isImageValid ? Color.pink.opacity(0.8) : Color(UIColor.lightGray))
                        .clipShape(Capsule())
                        .padding()
                })
                .disabled(!isImageValid)
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var homeImage: Data = Data()
        @State var registrationState: RegistrationState = .noting
        var body: some View {
            HomeImageEntryView(
                homeImage: $homeImage,
                registrationState: $registrationState
            )
        }
    }
    
    return PreviewView()
}

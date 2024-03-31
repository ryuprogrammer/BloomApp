import SwiftUI

struct IntroductionEditView: View {
    let explanationText = ExplanationText()
    
    @Binding var introduction: String?
    @State var editIntroduction: String = ""
    @State var isTextValid: Bool = true
    let introdictionHeight = UIScreen.main.bounds.height / 4
    let maxIntroductionLength: Int = 120

    // 画面遷移用
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text(explanationText.introductionEditDescription)
                        .font(.title3)
                        .padding()

                    TextEditor(text: $editIntroduction)
                        .frame(height: introdictionHeight)
                        .border(Color.pink.opacity(0.3), width: 1)
                        .padding()
                        .onChange(of: editIntroduction) {
                            if editIntroduction.count > maxIntroductionLength {
                                isTextValid = false
                            }
                        }

                    if !isTextValid {
                        Text(explanationText.introductionEditError)
                            .foregroundStyle(Color.red)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }

                VStack {
                    Spacer()

                    Button(action: {
                        introduction = editIntroduction
                        dismiss()
                    }, label: {
                        Text("自己紹介文を更新")
                            .font(.title2)
                            .foregroundStyle(Color.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(isTextValid ? Color.pink.opacity(0.8) : Color(UIColor.lightGray))
                            .clipShape(Capsule())
                            .padding()
                    })
                    .disabled(!isTextValid)
                }
            }
            .navigationTitle("自己紹介文を入力")
            .toolbarTitleDisplayMode(.inline)
        }
        .onAppear {
            editIntroduction = introduction ?? "読み込み中"
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var introduction: String? = ""
        @State var path: [MyPagePath] = []
        var body: some View {
            IntroductionEditView(
                introduction: $introduction
            )
        }
    }
    
    return PreviewView()
}

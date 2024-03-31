import SwiftUI

struct NameEntryView: View {
    let explanationText = ExplanationText()
    @Binding var name: String
    @Binding var registrationState: RegistrationState
    @State var isNameValid: Bool = false
    let maxNameCount: Int = 10
    let minNameCount: Int = 2
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Text(explanationText.nameEntryReason)
                        .font(.title3)
                        .padding()
                    
                    TextField("ニックネームを入力", text: $name)
                        .padding()
                        .font(.title)
                        .padding(.horizontal, 40)
                        .onChange(of: name) {
                            if name.count >= minNameCount && name.count <= maxNameCount {
                                isNameValid = true
                            } else {
                                isNameValid = false
                            }
                        }
                    
                    if name.count > maxNameCount {
                        Text(explanationText.nameEntryMaxError)
                            .foregroundStyle(Color.red)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    if name.count < minNameCount {
                        Text(explanationText.nameEntryMinError)
                            .foregroundStyle(Color.red)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    Spacer()
                }
                .navigationBarTitle("ニックネーム", displayMode: .inline)
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        registrationState = .birth
                    }
                }, label: {
                    Text("次へ")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isNameValid ? Color.pink.opacity(0.8) : Color(UIColor.lightGray))
                        .clipShape(Capsule())
                        .padding()
                })
                .disabled(!isNameValid)
            }
        }
        .onAppear {
            if name.count >= minNameCount && name.count <= maxNameCount {
                isNameValid = true
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var name: String = ""
        @State var registrationState: RegistrationState = .noting
        var body: some View {
            NameEntryView(name: $name, registrationState: $registrationState)
        }
    }
    
    return PreviewView()
}

import SwiftUI

struct GenderEntryView: View {
    @Binding var selectedGender: Gender
    @Binding var registrationState: RegistrationState
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ForEach(Gender.allCases, id: \.id) { gender in
                        if selectedGender.rawValue == gender.rawValue {
                            Text(gender.rawValue)
                                .font(.title)
                                .foregroundStyle(Color.pink.opacity(0.8))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 15)
                                .background {
                                    Capsule().stroke(Color.pink.opacity(0.8), lineWidth: 5)
                                }
                                .padding(2)
                        } else {
                            Text(gender.rawValue)
                                .font(.title)
                                .foregroundStyle(Color(UIColor.lightGray))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 15)
                                .onTapGesture {
                                    withAnimation {
                                        selectedGender = gender
                                    }
                                }
                                .padding(2)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationBarTitle("性別", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            registrationState = .birth
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
                        registrationState = .address
                    }
                }, label: {
                    Text("次へ")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.8))
                        .clipShape(Capsule())
                        .padding()
                })
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var gender: Gender = .men
        @State var registrationState: RegistrationState = .noting
        var body: some View {
            GenderEntryView(selectedGender: $gender, registrationState: $registrationState)
        }
    }
    
    return PreviewView()
}

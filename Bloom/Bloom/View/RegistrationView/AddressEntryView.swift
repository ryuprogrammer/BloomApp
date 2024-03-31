import SwiftUI

struct AddressEntryView: View {
    let explanationText = ExplanationText()
    @Binding var address: String
    @Binding var registrationState: RegistrationState
    @State var isAddressValid: Bool = false
    let registrationVM = RegistrationViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    ForEach(registrationVM.prefectures.prefectures, id: \.self) { prefecture in
                        if address == prefecture {
                            Text(prefecture)
                                .font(.title)
                                .foregroundStyle(Color.pink.opacity(0.8))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 15)
                                .background {
                                    Capsule().stroke(Color.pink.opacity(0.8), lineWidth: 5)
                                }
                                .padding(2)
                        } else {
                            Text(prefecture)
                                .font(.title)
                                .foregroundStyle(Color(UIColor.lightGray))
                                .onTapGesture {
                                    withAnimation {
                                        address = prefecture
                                        isAddressValid = true
                                    }
                                }
                                .padding(2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(height: 130)
                }
                .navigationBarTitle("居住地", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            registrationState = .gender
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
                        registrationState = .profileImage
                    }
                }, label: {
                    Text("次へ")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isAddressValid ? Color.pink.opacity(0.8) : Color(UIColor.lightGray))
                        .clipShape(Capsule())
                        .padding()
                })
                .disabled(!isAddressValid)
            }
        }
        .onAppear {
            if !address.isEmpty {
                isAddressValid = true
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var address: String = ""
        @State var registrationState: RegistrationState = .noting
        var body: some View {
            AddressEntryView(address: $address, registrationState: $registrationState)
        }
    }
    
    return PreviewView()
}

//
//  ProfileView.swift
//  HealthCare
//
//  Created by lonely. on 4/23/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var auth: AuthViewModel = AuthViewModel()
    @EnvironmentObject var router: Router
    @State var isPresented: Bool = false
    @State var alertText: String = ""
    @State var height: String = ""
    @State var weight: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack{
            Text("Hello, \(user.userdata?.name ?? "NoName")!")
                .font(.title2)
            
            Label("ID: \(user.userdata?.id ?? "NoData")", systemImage: "document.on.document")
                .onTapGesture {
                    UIPasteboard.general.string = user.userdata?.id
                    isPresented = true
                    if user.userdata?.role == .doctor {
                        alertText = "Ваш ID скопирован!\nНикому не разглашайте свой ID!"
                    } else if user.userdata?.role == .patient {
                        alertText = "Ваш ID скопирован!\nОтправьте его только своему врачу!"
                    }
                }
            
            if user.userdata?.role == .patient{
                HStack{
                    Text("Height")
                    TextField("Height", text: $height)
                        .focused($isInputFocused)
                        .padding()
                        .glassEffect()
                        .keyboardType(.numberPad)
                    Text("centimeters")
                }
                .padding()
                HStack{
                    Text("Weight")
                    TextField("Weight", text: $weight)
                        .focused($isInputFocused)
                        .padding()
                        .glassEffect()
                        .keyboardType(.numberPad)
                    
                    Text("kilograms")
                }
                .padding()
                Button {
                    let patVM = PatientViewModel(user: user.userdata)
                    Task{
                        do{
                            try await patVM?.uploadHeightWeight(height: height, weight: weight)
                            isPresented = true
                            alertText = "Data was upload!"
                        } catch{
                            isPresented = true
                            alertText = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Upload data")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .glassEffect()
                .padding()
            }
            
            Spacer()
            
            HStack{
                Button {
                    
                } label: {
                    Label("Change password", systemImage: "key.fill")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .glassEffect()
                
                Button {
                    //TODO: - перенести все внутрь auth.signOut()
                    router.becomeRoot(screen: .login)
                    user.userdata = nil
                    auth.signOut()
                } label: {
                    Label("Log out", systemImage: "door.right.hand.open")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .glassEffect()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false
        }
        .padding()
        .alert(isPresented: $isPresented) {
            Alert(title: Text(alertText))
        }
    }
}

//#Preview {
//    ProfileView()
//}

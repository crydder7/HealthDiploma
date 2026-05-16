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
    
    var body: some View {
        VStack{
            Text("Hello, \(user.userdata?.name ?? "NoName")!")
                .font(.title2)
            
            Label("ID: \(user.userdata?.id ?? "NoData")", systemImage: "document.on.document")
                .onTapGesture {
                    UIPasteboard.general.string = user.userdata?.id
                    isPresented = true
                    if user.userdata?.role == .doctor {
                        alertText = "Никому не разглашайте свой ID!"
                    } else if user.userdata?.role == .patient {
                        alertText = "Отправьте его только своему врачу!"
                    }
                }
                .alert(isPresented: $isPresented) {
                    Alert(title: Text("Ваш ID скопирован"), message: Text(alertText))
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
        .padding()
    }
}

//#Preview {
//    ProfileView()
//}

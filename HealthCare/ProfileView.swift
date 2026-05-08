//
//  ProfileView.swift
//  HealthCare
//
//  Created by lonely. on 4/23/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var patientVM: PatientViewModel
    @ObservedObject var auth: AuthViewModel
    @State var isLoggedOut: Bool = false
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack{
            Button {
                router.popToRoot()
                auth.signOut()
                isLoggedOut = true
                UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
            } label: {
                Text("Log out")
            }
            .padding()
            .glassEffect()
            
            Button {
                
            } label: {
                Text("Change password")
            }
            .padding()
            .glassEffect()
        }
    }
}

//#Preview {
//    ProfileView()
//}

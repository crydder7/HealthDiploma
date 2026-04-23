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
    var body: some View {
        Button {
            auth.signOut()
            isLoggedOut = true
        } label: {
            Text("Log out")
        }

    }
}

//#Preview {
//    ProfileView()
//}

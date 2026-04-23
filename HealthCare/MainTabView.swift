//
//  MainTabView.swift
//  HealthCare
//
//  Created by lonely. on 4/23/26.
//

import SwiftUI

struct MainTabView: View {
    var user: AppUser
    var body: some View {
        TabView {
            
            Tab("Home", systemImage: "house.fill") {
                ChartView(patient: PatientViewModel(user: user)!)
            }
            
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView(patientVM: PatientViewModel(user: user)!, auth: AuthViewModel())
            }
            
        }
    }
}

//#Preview {
//    MainTabView()
//}

//
//  MainTabView.swift
//  HealthCare
//
//  Created by lonely. on 4/23/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var user: AppUser
    @State var selectedTab = 1
    @StateObject var pickedPatient: PickedPatient = PickedPatient(fullName: "NONAME", uid: "", birthday: "", gender: "", height: nil, weight: nil)
    @StateObject var docInfo: DoctorInfo = DoctorInfo(fullName: "NONAME")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            if user.userdata?.role == .doctor {
                Tab("Info", systemImage: "info.circle.fill", value: 0) {
                    DoctorInfoView()
                }
            } else if user.userdata?.role == .patient {
                Tab("Info", systemImage: "info.circle.fill", value: 0) {
                    PatientInfoView()
                }
            }
            
            if user.userdata?.role == .patient {
                Tab("Home", systemImage: "house.fill", value: 1) {
                    ChartView(patient: PatientViewModel(user: user.userdata)!)
                }
            } else if user.userdata?.role == .doctor {
                Tab("Home", systemImage: "house.fill", value: 1) {
                    DoctorChartView(doctor: DoctorViewModel(user: user.userdata)!)
                }
            }
            
            Tab("Profile", systemImage: "person.fill", value: 2) {
                ProfileView()
            }
            
        }
        .environmentObject(pickedPatient)
        .environmentObject(docInfo)
    }
}

//#Preview {
//    MainTabView()
//}

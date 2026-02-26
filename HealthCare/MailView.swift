//
//  MailView.swift
//  HealthCare
//
//  Created by lonely. on 2/21/26.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var patient: PatientViewModel
    
    var body: some View {
        Text("Hello, \(patient.user.name)!")
    }
}

//#Preview {
//    MailView()
//}

//
//  PatientInfoView.swift
//  HealthCare
//
//  Created by lonely. on 5/15/26.
//

import SwiftUI

struct PatientInfoView: View {
    @EnvironmentObject var docInfo: DoctorInfo
    @State var showAlert: Bool = false
    @State var alerText: String = ""
    
    var body: some View {
        VStack {
            Text("Doctor information")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.leading)
            
            if docInfo.fullName != "NONAME"{
                Section {
                    LabeledContent("Full name", value: docInfo.fullName)
                        .font(.title3)
                    Divider()
                    LabeledContent("Email", value: docInfo.email ?? "-")
                        .font(.title3)
                        .underline(true)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            UIPasteboard.general.string = docInfo.email
                            alerText = "Email скопирован"
                            showAlert = true
                        }
                    Divider()
                    LabeledContent("Phone", value: docInfo.phone ?? "-")
                        .font(.title3)
                        .underline(true)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            UIPasteboard.general.string = docInfo.phone
                            alerText = "Номер телефона скопирован"
                            showAlert = true
                        }
                    Divider()
                    LabeledContent("Birthday", value: docInfo.birthday ?? "-")
                        .font(.title3)
                }
                .padding(.horizontal)
            } else {
                Spacer()
                Text("Нет данных о враче!")
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alerText))
        }
    }
}

//#Preview {
//    PatientInfoView()
//}

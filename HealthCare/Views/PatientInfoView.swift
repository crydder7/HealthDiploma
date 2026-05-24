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
                    if let email = docInfo.email, let url = URL(string:"mailto:\(email)"){
                        HStack{
                            Text("Email")
                                .font(.title3)
                            Spacer()
                            Link(destination: url) {
                                Text(email)
                                    .font(.title3)
                            }
                        }
                    } else {
                        LabeledContent("Email", value: "-")
                            .font(.title3)
                    }
                    Divider()
                    if let phone = docInfo.phone, let url = URL(string: "tel://\(phone)") {
                        HStack{
                            Text("Phone")
                                .font(.title3)
                            Spacer()
                            Link(destination: url) {
                                Text(phone)
                                    .font(.title3)
                            }
                        }
                    } else {
                        LabeledContent("Phone", value: "-")
                            .font(.title3)
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

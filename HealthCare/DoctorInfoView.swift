//
//  DoctorInfoView.swift
//  HealthCare
//
//  Created by lonely. on 5/13/26.
//

import SwiftUI

struct DoctorInfoView: View {
    
    @EnvironmentObject var pickedPatient: PickedPatient
    @State var showAlert: Bool = false
    @State var alerText: String = ""
    
    var body: some View {
        VStack{
            Text("Patient information")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.leading)
                
            if pickedPatient.uid != "" && pickedPatient.fullName != "NONAME" {
                Section {
                    LabeledContent("Full name", value: pickedPatient.fullName)
                        .font(.title3)
                    Divider()
                    LabeledContent("Gender", value: pickedPatient.gender ?? "-")
                        .font(.title3)
                    Divider()
                    LabeledContent("Email", value: pickedPatient.email ?? "-")
                        .underline(true)
                        .foregroundStyle(.blue)
                        .font(.title3)
                        .onTapGesture {
                            UIPasteboard.general.string = pickedPatient.email
                            alerText = "Email cкопирован"
                            showAlert = true
                        }
                    Divider()
                    LabeledContent("Phone", value: pickedPatient.phone ?? "-")
                        .font(.title3)
                        .underline(true)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            UIPasteboard.general.string = pickedPatient.phone
                            alerText = "Номер телефона скопирован"
                            showAlert = true
                        }
                    Divider()
                    LabeledContent("Birthday", value: pickedPatient.birthday ?? "-")
                        .font(.title3)
                }
                .padding(.horizontal)
            } else {
                Spacer()
                Text("No picked patient!")
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alerText))
        }
    }
}

//#Preview {
//    DoctorInfoView()
//}

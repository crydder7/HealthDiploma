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
                    if let email = pickedPatient.email, let url = URL(string:"mailto:\(email)"){
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
                    if let phone = pickedPatient.phone, let url = URL(string: "tel://\(phone)") {
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
                    LabeledContent("Birthday", value: pickedPatient.birthday ?? "-")
                        .font(.title3)
                    Divider()
                    LabeledContent("Height", value: "\(pickedPatient.height, default: "-")")
                        .font(.title3)
                    Divider()
                    LabeledContent("Weight", value: "\(pickedPatient.weight, default: "-")")
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

//
//  CreateNotificationView.swift
//  LocalNotifications-Template
//
//  Created by Juan Diego Ocampo on 13/03/2022.
//

import SwiftUI

struct CreateNotificationView: View {
    
    @ObservedObject var notificationManager: NotificationManager
    
    @State private var title         = ""
    @State private var content       = ""
    @State private var date          = Date()
    @State private var number        = 1
    
    @Binding var isPresented: Bool
    
    private var isValidInput: Bool {
        if title.isEmpty || title == "" {
            return false
        } else if content.isEmpty || content == "" {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Notification Details")) {
                TextField("Title", text: $title)
                TextField("Body", text: $content)
                HStack {
                    Text("Number")
                    Spacer()
                    Stepper("\(number)", value: $number, in: 1...12)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section(header: Text("Scheduling Details")) {
                DatePicker("Notify Me At", selection: $date, displayedComponents: [.hourAndMinute])
            }
        }
        .onDisappear {
            notificationManager.reloadLocalNotifications()
        }
        .navigationTitle("New Notification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            /// Tag: Cancel Button
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                }
            }
            /// Tag: Add Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
                    guard let hour = dateComponents.hour, let minute = dateComponents.minute else { return }
                    notificationManager.createLocalNotification(title: title, body: content, hour: hour, minute: minute, count: number) { error in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.isPresented = false
                            }
                        }
                    }
                } label: {
                    Text("Add")
                }
                .disabled(isValidInput == false)
            }
        }
    }
    
}

struct CreateNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateNotificationView(
                notificationManager: NotificationManager(),
                isPresented: .constant(false)
            )
        }
    }
}

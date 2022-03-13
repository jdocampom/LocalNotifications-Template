//
//  NotificationListView.swift
//  LocalNotifications-Template
//
//  Created by Juan Diego Ocampo on 13/03/2022.
//

import SwiftUI

struct NotificationListView: View {
    
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var isCreatePresented = false
    
    private static var notificationDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    private func timeDisplayText(from notification: UNNotificationRequest) -> String {
        guard let nextTriggerDate = (notification.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() else { return "" }
        return Self.notificationDateFormatter.string(from: nextTriggerDate)
    }
    
    private func setLabelColor(from notification: UNNotificationRequest) -> Color {
        guard let nextTriggerDate = (notification.trigger as? UNCalendarNotificationTrigger)?.dateComponents else { return Color.blue }
        if nextTriggerDate.date! > Date() {
            return Color.red
        } else {
            return Color.green
        }
    }
    
    @ViewBuilder
    var infoOverlayView: some View {
        switch notificationManager.authorizationStatus {
        case .authorized:
            if notificationManager.notifications.isEmpty {
                InfoOverlayView(
                    infoMessage: "No Notifications",
                    buttonTitle: "Create New Notification",
                    systemImageName: "plus.circle.fill",
                    action: {
                        isCreatePresented = true
                    }
                )
            }
        case .denied:
            InfoOverlayView(
                infoMessage: "Notifications are Disabled",
                buttonTitle: "Go to Settings",
                systemImageName: "gear",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            )
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        List {
            ForEach(notificationManager.notifications, id: \.identifier) { notification in
                HStack {
                    Image(systemName: "calendar")
                        .imageScale(.large)
                        .padding(.trailing)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(notification.content.title)
                        Text(notification.content.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(timeDisplayText(from: notification))
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(InsetGroupedListStyle())
        .overlay(infoOverlayView)
        .navigationTitle("Local Notifications")
        .onAppear(perform: notificationManager.reloadAuthorizationStatus)
        .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                notificationManager.requestAuthorization()
            case .authorized:
                notificationManager.reloadLocalNotifications()
            default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            notificationManager.reloadAuthorizationStatus()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !notificationManager.noNotifications {
                    Button {
                        isCreatePresented = true
                    } label: {
                        Text("Add")
                    }
                }
            }
        }
        .sheet(isPresented: $isCreatePresented) {
            NavigationView {
                CreateNotificationView(
                    notificationManager: notificationManager,
                    isPresented: $isCreatePresented
                )
            }
        }
    }
    
}

extension NotificationListView {
    func delete(_ indexSet: IndexSet) {
        notificationManager.deleteLocalNotifications(
            identifiers: indexSet.map { notificationManager.notifications[$0].identifier }
        )
        notificationManager.reloadLocalNotifications()
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
    }
}

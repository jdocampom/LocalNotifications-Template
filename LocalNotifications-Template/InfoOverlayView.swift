//
//  InfoOverlayView.swift
//  LocalNotifications-Template
//
//  Created by Juan Diego Ocampo on 13/03/2022.
//

import SwiftUI

struct InfoOverlayView: View {
    
    let infoMessage     : String
    let buttonTitle     : String
    let systemImageName : String
    let action          : () -> Void
    
    var body: some View {
        VStack {
            Text(infoMessage)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Button {
                action()
            } label: {
                Label(buttonTitle, systemImage: systemImageName)
                    .frame(minWidth: UIScreen.main.bounds.width / 3)
            }
            .buttonStyle(GrowingButton())
        }
        .padding()
    }
    
}

/// MARK: - SwiftUI Previews

struct InfoOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        InfoOverlayView(infoMessage: "No Notifications",
                        buttonTitle: "Create New",
                        systemImageName: "plus.circle.fill",
                        action: {})
    }
}

fileprivate struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.systemBlue))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.125 : 1)
            .animation(.easeOut(duration: 0.25), value: configuration.isPressed)
    }
}

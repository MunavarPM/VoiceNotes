//
//  SearchBarView.swift
//  VoiceNotes
//
//  A single rounded search field with the "Ask AI" pill floating inside it
//  on the trailing edge (matches the mockup).
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var onAskAI: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(AppConstants.searchPlaceholder, text: $text)
                .textFieldStyle(.plain)

            Button(action: onAskAI) {
                HStack(spacing: 5) {
                    Image("ic-aiHead")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text(AppConstants.askAI)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.appBackground, in: Capsule())
                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 14)
        .padding(.trailing, 5)
        .padding(.vertical, 5)
        .background(Color.fieldFill, in: Capsule())
    }
}

#Preview {
    SearchBarView(text: .constant("")) {}
        .padding()
}

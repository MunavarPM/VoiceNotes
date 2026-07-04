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
    var isListening: Bool = false
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
                    Text(isListening ? "Listening…" : AppConstants.askAI)
                        .font(.askAI)
                }
                .foregroundStyle(isListening ? Color.dodgerBlue : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isListening ? Color.dodgerBlue.opacity(0.12) : Color.appBackground, in: Capsule())
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

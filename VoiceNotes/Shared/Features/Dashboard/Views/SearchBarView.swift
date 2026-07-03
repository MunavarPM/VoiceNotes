//
//  SearchBarView.swift
//  VoiceNotes
//
//  Search field plus the "Ask AI" pill (matches iOS + macOS mockups).
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var onAskAI: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(AppConstants.searchPlaceholder, text: $text)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.fieldFill, in: Capsule())

            Button(action: onAskAI) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                    Text(AppConstants.askAI)
                }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.appBackground, in: Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.25)))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SearchBarView(text: .constant("")) {}
        .padding()
}

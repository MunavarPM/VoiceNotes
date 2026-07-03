//
//  FilterChipsView.swift
//  VoiceNotes
//
//  All / Shared / Starred segmented chips (iOS dashboard).
//

import SwiftUI

struct FilterChipsView: View {
    @Binding var selection: RecordingFilter

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RecordingFilter.allCases) { option in
                let isSelected = selection == option
                Button {
                    selection = option
                } label: {
                    Text(option.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            isSelected ? Color.primary : Color.fieldFill,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    FilterChipsView(selection: .constant(.all))
        .padding()
}

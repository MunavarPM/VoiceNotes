//
//  ToolbarIconButtonStyle.swift
//  VoiceNotes
//
//  Toolbar icons render in the brand gray and turn black while pressed
//  (matches the Figma).
//

import SwiftUI

struct ToolbarIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? Color.primary : Color.darkGrayish)
            .contentShape(Rectangle())
    }
}

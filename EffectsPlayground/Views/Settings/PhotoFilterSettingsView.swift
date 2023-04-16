//
//  PhotoFilterSettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension FilterPSD1.Settings.PhotoFilter: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<FilterPSD1.Settings.PhotoFilter>) -> some View {
        Toggle("👁️ Visible?", isOn: binding.isOn)
            .fixedSize()

        Spacer(minLength: 32)

        Text(String(format: "Density: %.2f", binding.density.wrappedValue))
        Slider(value: binding.density, in: 0.0...1.0, step: 0.01) {
            Text(String(format: "Density: %.2f", binding.density.wrappedValue))
        } minimumValueLabel: {
            Text("0.0")
        } maximumValueLabel: {
            Text("1.0")
        }

        ColorPicker("Color", selection: binding.color)
            .fixedSize()
    }
}

struct FilterPSD1SettingsPhotoFilter_Preview: PreviewProvider {
    @State
    private static var photoFilter = FilterPSD1.Settings.default.photoFilter

    static var previews: some View {
        ScrollView {
            photoFilter.makeSwiftView(binding: $photoFilter)
        }
    }
}

//
//  ColorBalanceSettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension FilterPSD1.Settings.ColorBalance: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<FilterPSD1.Settings.ColorBalance>) -> some View {
        Toggle("👁️ Visible?", isOn: binding.isOn)
            .fixedSize()

        Spacer(minLength: 32)

        Text("Midtones:")
            .font(.title3)

        Spacer(minLength: 32)

        Text(String(format: "Cyan - Red: %.2f", binding.midtones.x.wrappedValue))
        Slider(value: binding.midtones.x, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Cyan - Red: %.2f", binding.midtones.x.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }

        Text(String(format: "Magenta - Green: %.2f", binding.midtones.y.wrappedValue))
        Slider(value: binding.midtones.y, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Magenta - Green: %.2f", binding.midtones.y.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }

        Text(String(format: "Yellow - Blue: %.2f", binding.midtones.z.wrappedValue))
        Slider(value: binding.midtones.z, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Yellow - Blue: %.2f", binding.midtones.z.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }
    }
}

struct FilterPSD1SettingsColorBalance_Preview: PreviewProvider {
    @State
    private static var colorBalance = FilterPSD1.Settings.default.colorBalance

    static var previews: some View {
        ScrollView {
            colorBalance.makeSwiftView(binding: $colorBalance)
        }
    }
}

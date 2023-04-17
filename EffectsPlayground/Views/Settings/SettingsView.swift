//
//  SettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension PSDSettings: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<PSDSettings>) -> some View {
            VStack {
                Text("Photo filter")
                    .font(.title2)

                Divider()

                binding.photoFilter.wrappedValue.makeSwiftView(binding: binding.photoFilter)
            }
            .padding()
            .background(Colors.lightGray)
            .cornerRadius(16)

        VStack {
            Text("Color balance")
                .font(.title2)

            Divider()

            binding.colorBalance.wrappedValue.makeSwiftView(binding: binding.colorBalance)
        }
        .padding()
        .background(Colors.lightGray)
        .cornerRadius(16)

        VStack {
            Text("Channel mixer")
                .font(.title2)

            Divider()

            binding.channelMixer.wrappedValue.makeSwiftView(binding: binding.channelMixer)
        }
        .padding()
        .background(Colors.lightGray)
        .cornerRadius(16)

        VStack {
            Text("Texture overlay")
                .font(.title2)

            Divider()

            binding.overlay.wrappedValue.makeSwiftView(binding: binding.overlay)
        }
        .padding()
        .background(Colors.lightGray)
        .cornerRadius(16)
    }
}

struct PSDSettings_Preview: PreviewProvider {
    @State
    private static var settings = PSDSettings.default

    static var previews: some View {
        ScrollView {
            settings.makeSwiftView(binding: $settings)
        }
    }
}

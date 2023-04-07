//
//  ContentView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import SwiftUI
import CoreImage

struct ContentView: View {
    private let items = EffectsShowcase.shared.renderExamples()

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack {
                ForEach(items) { item in
                    HStack {
                        Image(uiImage: UIImage(named: "example_photo")!)
                        Image(uiImage: item.image)
                    }
                    Text(item.name)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

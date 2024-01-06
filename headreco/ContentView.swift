//
//  ContentView.swift
//  headreco
//
//  Created by BLG-BC-018 on 6.01.2024.
//

import SwiftUI
import Vision


struct ContentView: View {
    var body: some View {
        VStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}



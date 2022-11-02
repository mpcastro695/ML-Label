//
//  WelcomeView.swift
//  ML Label
//
//  Created by Martin Castro on 10/20/22.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack{
            Button("New Document") {
                print("open a document")
            }
            .buttonStyle(LineBorderStyle())
        }
        .frame(width: 400, height: 200)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

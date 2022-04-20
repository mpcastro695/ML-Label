//
//  AddNewClass.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/21.
//

import SwiftUI

struct NewClassDialog: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var mlSet: MLSet
    let colorPalette = ColorPalette()
    
    @State var textFieldEntry: String = ""
    @State var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    
    var body: some View {
        
        VStack(alignment: .center){
            // Directions
            Text("Add a new class label:")
                .padding(.bottom, 20)
                .font(.headline)
            
            // Textfield and textfield label
            TextField("Enter a Class Name", text: $textFieldEntry)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 330, height: 20)
                .padding(.bottom,10)
            
            Text("Label Color:")
                
            HStack{
                ForEach(colorPalette.colors, id: \.self) { color in
                    if color == selectedColor{
                        Circle()
                            .fill(Color(red: color.red, green: color.green, blue: color.blue))
                            .frame(width:30, height: 30)
                            .onTapGesture {
                                selectedColor = color
                            }
                    }else{
                        Circle()
                            .fill(Color(red: color.red, green: color.green, blue: color.blue))
                            .frame(width:20, height: 20)
                            .onTapGesture {
                                selectedColor = color
                            }
                        }
                        
                    }
            }
            .frame(height: 40)
            .padding(.bottom, 20)

            
//MARK: - Buttons
            // Confirmation and Cancellation buttons
            HStack{
                // Button for Cancelling
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                }
                // Button for adding the class
                Button {
                    if textFieldEntry != "" {
                        mlSet.addClass(label: textFieldEntry, color: selectedColor)
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Add Class")
                }
            }

        }
        .frame(width: 400, height: 250)
    }
}


//MARK: - Color Palette

class ColorPalette {
    let red = MLColor(red: 213/255, green: 49/255, blue: 48/255)
    let orange = MLColor(red: 223/255, green: 125/255, blue: 0/255)
    let yellow = MLColor(red: 236/255, green: 204/255, blue: 0/255)
    let green = MLColor(red: 56/255, green: 116/255, blue: 61/255)
    let blue = MLColor(red: 62/255, green: 84/255, blue: 155/255)
    let purple = MLColor(red: 149/255, green: 66/255, blue: 159/255)
    let pink = MLColor(red: 220/255, green: 94/255, blue: 130/255)
    let gray = MLColor(red: 64/255, green: 61/255, blue: 61/255)
    let brown = MLColor(red: 106/255, green: 60/255, blue: 37/255)
    let indigo = MLColor(red: 50/255, green: 50/255, blue: 124/255)
    let black = MLColor(red: 0/255, green: 0/255, blue: 0/255)
    let white = MLColor(red: 255/255, green: 255/255, blue: 255/255)
    
    var colors: [MLColor]
    
    init() {
        self.colors = []
        colors.append(red)
        colors.append(orange)
        colors.append(yellow)
        colors.append(green)
        colors.append(blue)
        colors.append(purple)
        colors.append(pink)
        colors.append(gray)
        colors.append(brown)
        colors.append(indigo)
        colors.append(black)
        colors.append(white)
    }
    
}

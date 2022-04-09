//
//  AddNewClass.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/21.
//

import SwiftUI

struct AddNewClass: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var classStore: ClassHandler
    let colorPalette = ColorPalette()
    
    @State var textFieldEntry: String = ""
    @State var selectedColor = Color(.lightGray)
    
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
                            .fill(color)
                            .frame(width:30, height: 30)
                            .onTapGesture {
                                selectedColor = color
                            }
                    }else{
                        Circle()
                            .fill(color)
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
                        classStore.addClass(label: textFieldEntry, color: selectedColor)
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
    let red = Color(red: 213/255, green: 49/255, blue: 48/255)
    let orange = Color(red: 223/255, green: 125/255, blue: 0/255)
    let yellow = Color(red: 236/255, green: 204/255, blue: 0/255)
    let green = Color(red: 56/255, green: 116/255, blue: 61/255)
    let blue = Color(red: 62/255, green: 84/255, blue: 155/255)
    let purple = Color(red: 149/255, green: 66/255, blue: 159/255)
    let pink = Color(red: 220/255, green: 94/255, blue: 130/255)
    let gray = Color(red: 64/255, green: 61/255, blue: 61/255)
    let brown = Color(red: 106/255, green: 60/255, blue: 37/255)
    let indigo = Color(red: 50/255, green: 50/255, blue: 124/255)
    let black = Color(red: 0/255, green: 0/255, blue: 0/255)
    let white = Color(red: 255/255, green: 255/255, blue: 255/255)
    
    var colors: [Color]
    
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

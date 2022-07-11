//
//  LabelTools.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct LabelTools: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @State var textFieldEntry: String = ""
    @State var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    @Binding var classSelection: MLClass?
    
    let colorPalette = ColorPalette()
    let colorSpotRows = [
        GridItem(.fixed(30)),
        GridItem(.fixed(30))
    ]
    
    
    var body: some View {
        
        VStack(alignment: .center){
            
//MARK: - Labels List
            
            if mlSet.classes.isEmpty {
                MissingLabels()
                    .padding(20)
            }else{
                List(mlSet.classes) { label in
                    ClassListRow(classLabel: label)
                }
                .padding(5)
            }
    
            Text("Add a new class:")
                .font(.subheadline)
            
            // Textfield and textfield label
            TextField("Class Name", text: $textFieldEntry)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 250, maxWidth: 350)
                .padding()
                
            LazyHGrid(rows: colorSpotRows, alignment: .center) {
                
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

            
//MARK: - Add Button
            // Confirmation and Cancellation buttons
            HStack{
                // Button for adding the class
                Button {
                    if textFieldEntry != "" {
                        mlSet.addClass(label: textFieldEntry, color: selectedColor)
                        classSelection = mlSet.classes.last!
                        textFieldEntry = ""
                    }
                } label: {
                    Text("Add Class")
                }
            }
            .padding(.bottom)

        }//END VSTACK
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


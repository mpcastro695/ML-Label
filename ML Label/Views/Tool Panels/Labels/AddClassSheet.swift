//
//  AddClassSheet.swift
//  ML Label
//
//  Created by Martin Castro on 8/23/22.
//

import SwiftUI

struct AddClassSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mlSet: MLSetDocument
    
//    @Binding var classSelection: MLClass?
    
    @Binding var classSelection: MLClass?
    
    @State private var className: String = ""
    @State private var description: String = ""
    @State private var tags: String = ""
    
    @State private var selectedColor: MLColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    @State var showColorPallete: Bool = false
    let colorPalette = ColorPalette()
    let colorSpotRows = [
        GridItem(.fixed(30)),
        GridItem(.fixed(30))
    ]
    
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Add New Class")
                .font(.title)
                .foregroundColor(.secondary)
            HStack{
                VStack(alignment: .trailing){
                    Image(systemName: "tag.square")
                        .resizable()
                        .frame(width:60, height: 60)
                        .foregroundColor(selectedColor.toColor())
                        .padding(.bottom)
                    
                    HStack{
                        Button {
                            showColorPallete = true
                        } label: {
                            Image(systemName: "paintpalette")
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showColorPallete) {
                            LazyHGrid(rows: colorSpotRows, alignment: .center) {
                                
                                ForEach(colorPalette.colors, id: \.self) { color in
                                    ZStack{
                                        Circle()
                                            .fill(selectedColor == color ? Color.primary : Color.clear)
                                            .frame(width: 22, height: 22)
                                        Circle()
                                            .fill(Color(red: color.red, green: color.green, blue: color.blue))
                                            .opacity(selectedColor == color ? 1.0 : 0.8)
                                            .frame(width:20, height: 20)
                                            .onTapGesture {
                                                selectedColor = color
                                            }
                                    }//END ZSTACK
                                }//END FOREACH
                            }//END LAZYHGRID
                            .padding(10)
                        }
                        Button {
                            print("present finder to select photo")
                        } label: {
                            Image(systemName: "photo")
                        }
                        .buttonStyle(.plain)

                    }//END HSTACK
                }//END VSTACK
                .padding(.leading, 5)
                .padding(.trailing)
                
                VStack(alignment: .leading){
                    Text("Name:")
                    TextField("Class Name", text: $className)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Tags:")
                    TextField("Class Tags", text: $tags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }//END HSTACK
            .padding(.bottom)
            
            Text("Description (optional):")
            TextField("Class Description", text: $description)
                .frame(height: 40)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Classes added are unique to this dataset. Be sure to check for typos before annotating.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            
            //Buttons
            HStack{
                Spacer()
                
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }.keyboardShortcut(.cancelAction)
                
                Button {
                    if className != "" {
                        mlSet.addClass(label: className, color: selectedColor)
                        className = ""
                        classSelection = mlSet.classes.last!
                        dismiss()
                    }
                } label: {
                    Text("Add Class")
                }.keyboardShortcut(.defaultAction)
                
                
            }
            
            
        }//END VSTACK
        .padding()
        .frame(width: 400)
    }
}

//struct AddClassSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddClassSheet()
//    }
//}

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

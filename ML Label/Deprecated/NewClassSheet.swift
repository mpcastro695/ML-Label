//
//  AddNewClass.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/21.
//

import SwiftUI

@available(macOS 12.0, *)
struct NewClassSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var mlSet: MLSetDocument
    
    @Binding var classSelection: MLClass?
    
    @State var textFieldEntry: String = ""
    @State var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    
    let colorPalette = ColorPalette()
    let colorSpotRows = [
        GridItem(.fixed(30)),
        GridItem(.fixed(30))
    ]
    
    var body: some View {
        
        VStack(alignment: .center){
            
            Text("Add a new class:")
                .font(.subheadline)
            
            TextField("Class Name", text: $textFieldEntry)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 250, maxWidth: 350)
                .padding(.horizontal)
                .padding(.bottom)
            
            HStack(spacing: 40){
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
                .frame(height: 40)
                .padding(.bottom, 20)
                
                VStack{
                    // Button for adding the class
                    Button {
                        if textFieldEntry != "" {
                            mlSet.addClass(label: textFieldEntry, color: selectedColor)
                            classSelection = mlSet.classes.last!
                            textFieldEntry = ""
                            dismiss()
                        }
                    } label: {
                        Text("Add Class")
                    }
                    
                    // Cancel Button
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
                
            }//END HSTACK
        }//END VSTACK
        .padding()
    }
}


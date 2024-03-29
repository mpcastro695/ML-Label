////
////  ClassTools.swift
////  ML Label
////
////  Created by Martin Castro on 7/9/22.
////
//
//import SwiftUI
//
//struct ClassToolsView: View {
//    
//    @EnvironmentObject var mlSet: MLSet
//    @EnvironmentObject var userSelections: UserSelections
//    
//    @State private var newClassSheetVisible: Bool = false
//    @State private var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
//    
//    
//    var body: some View {
//        
//        VStack(alignment: .center){
//            
//            if mlSet.classes.isEmpty {
//                MissingLabels()
//            }else{
//                HStack{
//                    Text("Class Labels")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                    Spacer()
//                    // New Class Button
//                    Button {
//                        newClassSheetVisible.toggle()
//                    } label: {
//                        Image(systemName: "plus")
//                            .font(.headline)
//                    }.buttonStyle(.plain)
//
//                }//END HSTACK
//                .padding(.bottom)
//                .sheet(isPresented: $newClassSheetVisible, content: {
//                    NewClassSheet(classSelection: $userSelections.mlClass)
//                })
//        
//                if #available(macOS 13.0, *) {
//                    ClassList()
//                } else {
//                    // Fallback on earlier versions
//                }
//            }
//            
//            
//        }//END VSTACK
//        .padding()
//    }
//}
//

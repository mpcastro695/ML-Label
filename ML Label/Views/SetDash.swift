//
//  SetDetailsView.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct SetDash: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    var fileName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: -15){
            HStack(alignment: .top, spacing: -15){
                VStack(alignment: .leading){ //Document Title & Decscription
                    HStack{
                        Text("\(fileName)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.secondary)
                        Button {
                            print("Open Document in Finder") //FIX
                        } label: {
                            Image(systemName: "arrow.forward.circle")
                        }.buttonStyle(.plain)
                    }
                    Text("ML Data Set")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    Text("Last Edited on 2/25/23 11:21PM") //FIX
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
                StatTable(rowData: [
                    ("Images", "\(mlSet.images.count)"),
                    ("Sources", "\(mlSet.imageSources.count)"),
                    ("Classes", "\(mlSet.classes.count)"),
                    ("% Annotated", "\(Int.zero)")
                ])
                .padding()
                .frame(maxWidth: 400)
            }//END UPPER HSTACK
            .padding(.bottom)
            
            HStack(spacing: -15){
                VStack(alignment: .leading, spacing: -15){
                    Text("Images")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.secondary)
                    Gallery(imageSources: mlSet.imageSources)
                }
                VStack(alignment: .leading, spacing: -15){
                    Text("Classes")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.secondary)
                    ClassList()
                        .frame(width: 300)
                }
            }
            
        }//END VSTACK
        .toolbar {
            Button {
                mlSet.saveAnnotationsToDisk()
            } label: {
                Text("\(Image(systemName: "square.and.arrow.up"))")
            }

        }
    }
}

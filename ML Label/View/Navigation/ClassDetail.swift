//
//  ClassDetail.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct ClassDetail: View {
    
    @ObservedObject var classLabel: MLClass
    @EnvironmentObject var imageStore: MLImageSet
    
    var gridItemLayout = GridItem(.adaptive(minimum: 105, maximum: 105))
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("\(classLabel.label)")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 5)
            Text("\(classLabel.annotations.count) annotations.")
                .padding(.bottom, 10)
            
            Divider()
            
            ScrollView{
                if classLabel.annotations.count == 0 {
                    Text("No annotations yet.")
                    
                }else{
                    ScrollView{
                        LazyVGrid(columns: [gridItemLayout], spacing: 10) {
                            ForEach(classLabel.annotations) { annotation in
                                if let image = imageStore.images.first(where: {$0.name == annotation.imageName}) {
                                    GridBox(image: image, boundBox: annotation)
                                        .frame(width: 100, height: 100)
                                        .background(Color.white)
                                }
                                
                            }
                        }
                    }.padding(.top, 10)
                }
            }
            
        }.padding(20)
        
        
// MARK: - Toolbar Items
        .toolbar{
            
            Button(action: {print("Edit class data.")}, label: {
                Image(systemName: "rectangle.and.pencil.and.ellipsis").font(.body.weight(.heavy))
            })
            
        }
        
    }
    
    
    
}

//struct ClassDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassDetail()
//    }
//}

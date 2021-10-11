//
//  ImageViewerView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 06.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import UIKit

struct ImageViewerView: View {
    @StateObject var viewModel: ImageViewerViewModel

    let dismiss: () -> Void

    private let dragGesture = DragGesture()
    @State private var opacity = 1.0
    @State private var willDismiss = false
    @State private var imageViewOffset = 0.0
    @State private var imageScale = 1.0
    @State private var isSharePresented = false

    var body: some View {
        ZStack {
            Color.white
                .opacity(opacity)
                .ignoresSafeArea()
            VStack {
                tabView
                shareButtonView
            }
        }
        .sheet(isPresented: $isSharePresented) {
            ActivityViewController(activityItems: viewModel.activityItems)
        }
        .overlay(closeButton ,alignment: .topTrailing)
    }

    private var tabView: some View {
        TabView(selection: $viewModel.selectedImageId) {
            ForEach(viewModel.images, id: \.self) { imageDescriptor in
                ZoomableScrollView {
                    imagePreviewView(imageDescriptor)
                }
                .offset(y: imageViewOffset)
                .gesture(imageDismissingGesture)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }


    private func imagePreviewView(_ image: ImageViewerViewModel.ImageDescriptor) -> some View {
        Image(uiImage: image.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tag(image.id)
    }

    private var closeButton: some View {
        Button(action: dismiss) {
            Image.System.xmark
                .foregroundColor(Color.white)
                .padding()
                .background(Color.buttonPrimary.opacity(0.6))
                .clipShape(Circle())
                .opacity(opacity)
        }
        .frame(width: 15, height: 15)
        .padding(25)
    }

    private var shareButtonView: some View {
        VStack {
            Divider()
            Button(action: {
                isSharePresented.toggle()
            }) {
                Image.System.share
                    .foregroundColor(Color.buttonPrimary)
            }
            .opacity(opacity)
            .padding()
        }
    }

    private var imageDismissingGesture: some Gesture {
        dragGesture.onChanged({ value in
            imageViewOffset = value.translation.height

            let halfScreen = UIScreen.main.bounds.height / 2
            let progress = abs(imageViewOffset) / halfScreen
            opacity = willDismiss ? 0 : Double(1 - progress)
        }).onEnded({ value in
            withAnimation(.easeInOut) {
                if abs(value.translation.height) > 200 {
                    willDismiss = true
                    dismiss()
                } else {
                    opacity = 1
                    imageViewOffset = .zero
                }
            }
        })
    }
}

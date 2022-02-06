//
//  ViewController.swift
//  Program Interface
//
//  Created by Александр Панин on 04.02.2022.
//

import UIKit

// MARK: - type source
enum TypeSource {
    case camera
    case gallary
}

class MainViewController: UIViewController {
    
    // создаем объект класса ImageScrollView для изменения размеров
    
    var imagePhotoPicker = UIImagePickerController()
    var imageScroll = ImageScrollView()
    var photoImage: UIImage = {
        let image = UIImage(systemName: "person.fill.questionmark") ?? UIImage()
        return image
    }()
    
    private let widthPhoto: CGFloat = 180
    private let heigthPhoto: CGFloat = 240
    
    private let widthButton: CGFloat = 40
    private let heigthButton: CGFloat = 35
    
    // создали кнопки
    private let libraryButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setBackgroundImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(getPhotoLibrary), for: .touchDown)
        return button
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(getPhotoCamera), for: .touchDown)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(sharePhoto), for: .touchDown)
        return button
    }()
    
    private let rotateRigthButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setBackgroundImage(UIImage(systemName: "rotate.right"), for: .normal)
        button.addTarget(self, action: #selector(rotatedRigth), for: .touchDown)
        return button
    }()
    
    private let rotateLeftButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setBackgroundImage(UIImage(systemName: "rotate.left"), for: .normal)
        button.addTarget(self, action: #selector(rotatedLeft), for: .touchDown)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imagePhotoPicker.delegate = self
        // добавили на наше view дополнительное subview и установили констрейнты для кнопок
        setupImageScrollView(width: widthPhoto, heigth: heigthPhoto)
        setupLibraryButton()
        setupPhotoButton()
        setupShareButton()
        setupRotateLeftButton()
        setupRotateRigthButton()
        // выгружаем изображение в ScrollView
        self.imageScroll.set(image: photoImage)
    }
    
    // MARK: - 2objc - функции кнопок
    @objc func getPhotoCamera() {
        fetchImage(.camera)
    }
    
    @objc func getPhotoLibrary() {
        fetchImage(.gallary)
    }
    
    @objc func sharePhoto() {
        let shareImage = self.imageScroll.getImage()
        let shareController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        
        /* для обработки сообщений после работы контроллера
         shareController.completionWithItemsHandler = { _, bool, _, _ in
         if bool { print("Yes")}
         }
         */
        present(shareController, animated: true, completion: nil)
    }
    
    @objc func rotatedRigth() {
        let rotatedImage = photoImage.rotate(radians: .pi * 0.5)
        photoImage = rotatedImage
        self.imageScroll.set(image: photoImage)
    }
    
    @objc func rotatedLeft() {
        let rotatedImage = photoImage.rotate(radians: .pi * 1.5)
        photoImage = rotatedImage
        self.imageScroll.set(image: photoImage)
    }
    
    //MARK: -  действия после окончания работы встроенных вью контроллеров
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // проверка какое фото используем, редактируемое или оригинальное
        if let image = info[.editedImage] as? UIImage {
            imageFilter(image)
        } else {
            guard  let image = info[.originalImage] as? UIImage else { return }
            imageFilter(image)
        }
        // выключение встроенного вью контроллера
        imagePhotoPicker.dismiss(animated: true, completion: nil)
        self.imageScroll.set(image: photoImage)
    }
    
    // MARK: -  настройка кнопок поворота
    private func setupRotateRigthButton() {
        view.addSubview(rotateRigthButton)
        rotateRigthButton.translatesAutoresizingMaskIntoConstraints = false
        // задали размеры
        rotateRigthButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        rotateRigthButton.heightAnchor.constraint(equalToConstant: heigthButton).isActive = true
        // привязали к левому верхнему углу
        rotateRigthButton.topAnchor.constraint(equalTo: imageScroll.bottomAnchor, constant: 5).isActive = true
        rotateRigthButton.rightAnchor.constraint(equalTo: imageScroll.rightAnchor).isActive = true
    }
    
    private func setupRotateLeftButton() {
        view.addSubview(rotateLeftButton)
        rotateLeftButton.translatesAutoresizingMaskIntoConstraints = false
        // задали размеры
        rotateLeftButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        rotateLeftButton.heightAnchor.constraint(equalToConstant: heigthButton).isActive = true
        // привязали к левому верхнему углу
        rotateLeftButton.topAnchor.constraint(equalTo: imageScroll.bottomAnchor, constant: 5).isActive = true
        rotateLeftButton.leftAnchor.constraint(equalTo: imageScroll.leftAnchor).isActive = true
    }
    
    // MARK: -  настройка кнопки для сохранения фото
    private func setupShareButton() {
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        // задали размеры
        shareButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: heigthButton).isActive = true
        // привязали к левому верхнему углу
        shareButton.topAnchor.constraint(equalTo: imageScroll.bottomAnchor, constant: 5).isActive = true
        shareButton.centerXAnchor.constraint(equalTo: imageScroll.centerXAnchor).isActive = true
    }
    
    // MARK: -  настройка кнопки для доступа к камере
    private func setupPhotoButton() {
        view.addSubview(photoButton)
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        // задали размеры
        photoButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: heigthButton).isActive = true
        // привязали к левому верхнему углу
        photoButton.bottomAnchor.constraint(equalTo: imageScroll.topAnchor, constant: -5).isActive = true
        photoButton.rightAnchor.constraint(equalTo: imageScroll.rightAnchor).isActive = true
    }
    
    // MARK: -  настройка кнопки для доступа в библиотеку
    private func setupLibraryButton() {
        view.addSubview(libraryButton)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        // задали размеры
        libraryButton.widthAnchor.constraint(equalToConstant: widthButton).isActive = true
        libraryButton.heightAnchor.constraint(equalToConstant: heigthButton).isActive = true
        // привязали к левому верхнему углу
        libraryButton.bottomAnchor.constraint(equalTo: imageScroll.topAnchor, constant: -5).isActive = true
        libraryButton.leftAnchor.constraint(equalTo: imageScroll.leftAnchor).isActive = true
    }
    
    // MARK: - устанавливаем констрейнты для ImageScrollView
    private func setupImageScrollView(width:CGFloat, heigth: CGFloat) {
        imageScroll = ImageScrollView(frame: CGRect(
            x: (view.bounds.width - width) / 2,
            y: (view.bounds.height - heigth) / 2,
            width: width,
            height: heigth))
        view.addSubview(imageScroll)
        // установка фона ширины рамки и цвета фона
        imageScroll.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageScroll.layer.borderWidth = 1.0
        imageScroll.layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        imageScroll.layer.cornerRadius = 15
        // разрешили использовать констрейнты
        imageScroll.translatesAutoresizingMaskIntoConstraints = false
        // привязали к границам view
        imageScroll.heightAnchor.constraint(equalToConstant: heigth).isActive = true
        imageScroll.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageScroll.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageScroll.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - получение изображения в зависимости от типа
    private func fetchImage(_ type: TypeSource) {
        imagePhotoPicker.modalPresentationStyle = .pageSheet // вид представления встроенных инструментов
        
        switch type {
        case .camera:
            imagePhotoPicker.allowsEditing = true // разрешение редактирования встроенными методами
            imagePhotoPicker.sourceType = .camera
            imagePhotoPicker.cameraDevice = .front
        case .gallary:
            imagePhotoPicker.allowsEditing = false // разрешение редактирования встроенными методами
            imagePhotoPicker.sourceType = .photoLibrary // указываем что используем
        }
        present(imagePhotoPicker, animated: true, completion: nil) // запуск контроллера
    }
    
    // MARK: - применение фильтра и вывод изображения во вью
    private func imageFilter(_ image: UIImage) {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let currentFilter = CIFilter(name: "CIPhotoEffectMono")
        currentFilter?.setDefaults()
        currentFilter?.setValue(inputImage, forKey: kCIInputImageKey) // ключ определяет определяет входное изображение
        //      currentFilter.setValue(0.9, forKey: kCIInputIntensityKey) - ключ определяет интенсивность фильта, для Монохрома не нужен
        if let output = currentFilter?.outputImage {
            if let cgImage = context.createCGImage(output, from: output.extent) {
                  photoImage = UIImage(cgImage: cgImage)
            }
        }
    }
}

// MARK: - расширение для UIImage с функцией поворота
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        return self
    }
}

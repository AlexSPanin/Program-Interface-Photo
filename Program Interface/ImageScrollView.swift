//
//  ImageScrollView.swift
//  Program Interface
//
//  Created by Александр Панин on 04.02.2022.
//

// клас для прокрутки и перемещения изображения!!!

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    var imageZoomView: UIImageView?
    
    // MARK: - переменная для авто зуминга при двойном нажатии
    //Дискретный распознаватель жестов, который интерпретирует одно или несколько касаний.
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    // MARK: - передаем что наш класс должен использовать своства делегата
    override init(frame: CGRect) {
        super.init(frame: frame)
        // сообщаем кто будет выполнять функции делегата
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - обновление интерфейса
    override func layoutSubviews() {
        super.layoutSubviews()
        positionImage()
    }
    
    // MARK: - загрузка изображения в ScrollView
    func set(image: UIImage) {
        // удаляет предыдущую фотографию при переиспользовании ячейки
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        
        // инициализируем объект нашим изображением
        imageZoomView = UIImageView(image: image)
        imageZoomView?.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        

        // после проверки опционала добавляем наше subview
        guard let imageZoomView = imageZoomView else { return }
        
        addSubview(imageZoomView)
        
        // задаем входные размеры изображения
        configurate(imageSize: image.size)
    }
    // MARK: - Обрезка изображения
    func getImage() -> UIImage {
        guard let image = imageZoomView?.image else { return UIImage() }
        let width: CGFloat = bounds.width / zoomScale
        let height: CGFloat = bounds.height / zoomScale
        let x = bounds.origin.x / zoomScale
        let y = bounds.origin.y / zoomScale
        
        let cgRect = CGRect(x: x,
                            y: y,
                            width: width,
                            height: height)
        
        let orientation = image.imageOrientation
        let scale = image.scale
        let cgImage = image.cgImage

        if let cropperCGImage = cgImage?.cropping(to: cgRect) {
            let context = CIContext(options: nil)
            let ciImage = CIImage(cgImage: cropperCGImage)
            if let refImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: refImage, scale: scale, orientation: orientation)
                return uiImage
            }
        }
        return UIImage()
    }
    
    // MARK: - задаем методы делегата UIScrollViewDelegate
    // Запрашивает делегата о масштабировании вида при приближении масштабирования на виде прокрутки.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageZoomView
    }
    // Сообщает делегату, что коэффициент масштабирования вида прокрутки изменился.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        positionImage()
    }
    
    // функция отрпбатывающая нажание на экран см в переменной
    @objc func handleZoomingTap(sender: UITapGestureRecognizer) {
        // передаем где нажатие
        let location = sender.location(in: sender.view)
        zoomToTap(point: location, animated: true)
    }
    // прописываем логику при первом нажатии 2 раза - увеличивается, а при повторном уменьшается
    private func zoomToTap(point: CGPoint, animated: Bool) {
        let currectScale = zoomScale
        let minScale = minimumZoomScale
        let maxScale = maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return
        }
        let toScale = maxScale
        let finalScale = (currectScale == minScale ) ? toScale : minScale
        
        let zoomRect = zoomRect(scale: finalScale, center: point)
        // встроенная ункция
        zoom(to: zoomRect, animated: animated)
    }
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        
        return zoomRect
    }
    
    // MARK: - загрузка размеров изображения
    private func configurate(imageSize: CGSize) {
        
        // передаем размеры картинки
        contentSize = imageSize
        // задаем параметры зуминга
        setZoomScale()
        
        // свойству zoomScale у UIScrollView присваиваем минимальный зум
        zoomScale = minimumZoomScale
        
        imageZoomView?.addGestureRecognizer(zoomingTap)
        imageZoomView?.isUserInteractionEnabled = true
        
        // удаляем горизонтальные и вертикальные прокрутки
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        // скорость зуминга
        decelerationRate = UIScrollView.DecelerationRate.normal
    }
    // MARK: - установка параметров изображения после зуминга
    private func setZoomScale() {
        //  извлечение опционала
        guard let imageZoomView = imageZoomView else { return }
        // фиксируем размеры рамки и изображения
        let boundsSize = bounds.size
        let imageSize = imageZoomView.bounds.size
        // вычисляем соотношения экранов по x и y
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        // определяем минимальный и максимальный зум
        let minScale = min(xScale, yScale)
        let maxScale: CGFloat = max(0.5, minScale)
        // задаем параметры минимального и максимального зума
        minimumZoomScale = minScale
        maximumZoomScale = maxScale
    }
    
    // MARK: - задаем место расположения картинки после зума
    private func positionImage() {
        //  извлечение опционала
        guard let imageZoomView = imageZoomView else { return }
        // фиксируем размеры рамки и изображения
        let boundsSize = bounds.size
        
        var frameToCenter = imageZoomView.frame
        // если размеры высоты view при зум меньше ширины экрана то view вписывается в ширику экрана
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        // если размеры ширины view при зум меньше ширины экрана то view вписывается в ширику экрана
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
       
        // присваиваем новый frame
        imageZoomView.frame = frameToCenter
    }
}

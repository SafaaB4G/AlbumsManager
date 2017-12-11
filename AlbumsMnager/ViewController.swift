import UIKit
import GBHFacebookImagePicker
import SKPhotoBrowser
import NVActivityIndicatorView

///la classe qui s'occupe de l'interfaçage avec API facebook et qui affiche les photos importés et offre la possibilité de les exportés au firebase storage
class ViewController: UIViewController ,SKPhotoBrowserDelegate ,NVActivityIndicatorViewable{
    
    
    // MARK: - Var
    ///l'image de charegement
    var imageUploadManager: ImageUploadManager?
    ///le model d'image pour la collection d'image
    var images = [SKPhotoProtocol]()
    /// le tableau d'image importé
    fileprivate var imageModels = [GBHFacebookImage]() {
        didSet {
            DispatchQueue.main.async {
                
                print("images number from datasource: \(self.imageModels.count)")
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlet
    ///la collection des vues utilisé pour afficher les photos selectionnées par l'utilisateur
    @IBOutlet weak var collectionView: UICollectionView!
    ///ce boutton lance une action en cas du click si l'utilisateur veut importer ses photos de facebook
    @IBOutlet weak var showAlbumButton: UIButton!
    
    ///this IBOtlet for handling the click action to upload the selected images

    @IBAction func UploadImage(_ sender: Any) {
        var ImageArray : [UIImage] = []
        //this part to get the selected images :
        if !(self.imageModels.count == 0) {
            ImageArray = [UIImage]()
            for i in 0...imageModels.count - 1 {
                print("the index is : \(i) the image is \(imageModels[i].image!)")
                ImageArray.append(imageModels[i].image!)
            }
        }
        //call the function to upload the image ,if the image is empty ,no action is needed
        imageUploadManager = ImageUploadManager()
        for i in 0...ImageArray.count - 1 {
            if !(ImageArray.count <= 0) {
                //starting the loader
                let size = CGSize(width: 30, height: 30)
                let frame = CGRect(x: 90, y: 90, width: 50, height: 50)
                NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.white, padding: 20)
                startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: (sender as AnyObject).tag)!)
                
                imageUploadManager?.uploadImage(ImageArray[i], progressBlock: { (percentage) in
                    print("the pourcentage is : \(percentage)")
                }, completionBlock: { [weak self] (fileURL, errorMessage) in
                    guard let strongSelf = self else {
                        return
                    }
                    print(fileURL)
                    print("this is nul : \(errorMessage)")
                    self?.stopAnimating()
                    
                })
            }
            else {
                
                print("please select an item ")
            }
        }
        
        
    }
    ///this function used when the application need to load this view
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        print("lauched :) ")
        /// Controller title
        self.title = "Facebook Image Picker"
        self.collectionView.backgroundColor = UIColor.clear
        /// Prepare picker button
        self.showAlbumButton.setTitle("Show picker",
                                      for: .normal)
        self.showAlbumButton.setTitleColor(UIColor.white,
                                           for: .normal)
        self.showAlbumButton.layer.cornerRadius = 3.0
        self.showAlbumButton.backgroundColor = UIColor(red: 59/255.0,
                                                       green: 89/255.0,
                                                       blue: 152/255.0,
                                                       alpha: 1.0)
        self.showAlbumButton.addTarget(self,
                                       action: #selector(self.showAlbumClick),
                                       for: UIControlEvents.touchUpInside)
        
        
        ///this part for showing the grid view in the first page
        let frameCollection : CGRect = CGRect(x:0 , y: 0 , width : UIScreen.main.bounds.width , height : UIScreen.main.bounds.height)
        collectionView.frame = frameCollection
        
        /// la configuration Statique
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        
        ///setupTestData()
        setupCollectionView()
        
    }
    ///configuration background d'image
    func assignbackground(){
        let background = UIImage(named: "background")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        print("frame : \(imageView.frame)")
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    
    ///cette fonction est pour customiser l'ensemble des composants de GBHFacebookImagePicker
    fileprivate func someCustomisation() {
        // Navigation bar title
        GBHFacebookImagePicker.pickerConfig.title = "Facebook Pictures"
        
        // Navigation barTintColor
        //        GBHFacebookImagePicker.pickerConfig.uiConfig.navBarTintColor = UIColor.red
        
        // Close button color
        GBHFacebookImagePicker.pickerConfig.uiConfig.closeButtonColor = UIColor.black
        
        // Global backgroundColor
        //        GBHFacebookImagePicker.pickerConfig.uiConfig.backgroundColor = UIColor.red
        
        // Navigation bar title color
        GBHFacebookImagePicker.pickerConfig.uiConfig.navTitleColor = UIColor.black
        
        // Navigation bar tintColor
        GBHFacebookImagePicker.pickerConfig.uiConfig.navTintColor = UIColor.orange
        
        // Album's name color
        GBHFacebookImagePicker.pickerConfig.uiConfig.albumsTitleColor = UIColor.black
        
        // Album's count color
        GBHFacebookImagePicker.pickerConfig.uiConfig.albumsCountColor = UIColor.black
        
        // Maximum selected pictures
        GBHFacebookImagePicker.pickerConfig.maximumSelectedPictures = 20
        
        // Display tagged album
        GBHFacebookImagePicker.pickerConfig.taggedAlbumName = "Tagged photos"
        
        // Tagged album name
        GBHFacebookImagePicker.pickerConfig.displayTaggedAlbum = true
        
        // Number of picture per row (4 by default)
        GBHFacebookImagePicker.pickerConfig.picturePerRow = 3
        
        // Space beetween album photo cell (1.5 by default)
        GBHFacebookImagePicker.pickerConfig.cellSpacing = 2.0
        
        // Perform animation on picture tap (true by default)
        GBHFacebookImagePicker.pickerConfig.performTapAnimation = true
        
        // Show check style with image and layer (true by default)
        GBHFacebookImagePicker.pickerConfig.uiConfig.showCheckView = true
        
        // Change checkview background color
        //        GBHFacebookImagePicker.pickerConfig.uiConfig.checkViewBackgroundColor = UIColor.red
    }
    
    // MARK: - Action
    /// showAlbumClick
    @objc func showAlbumClick() {
        print(self, #function)
        
        // Init picker
        let picker = GBHFacebookImagePicker()
        
        // Allow multiple selection (false by default)
        GBHFacebookImagePicker.pickerConfig.allowMultipleSelection = true
        GBHFacebookImagePicker.pickerConfig.picturePerRow = 3
        GBHFacebookImagePicker.pickerConfig.performTapAnimation = true
        
        // Make some customisation
        self.someCustomisation()
        
        // Present picker
        picker.presentFacebookAlbumImagePicker(from: self,
                                               delegate: self)
    }
    /// si l'action de suppression est lancé
    @IBAction func doDeleteClick(_ sender: Any) {
        // Clear data src
        self.imageModels = [GBHFacebookImage]()
    }
    
    
    /// l'action a executé si un message d'invertisement est reçu

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: GBHFacebookImagePickerDelegate {
    
    // MARK: - GBHFacebookImagePicker Protocol
    func facebookImagePicker(imagePicker: UIViewController,
                             successImageModels: [GBHFacebookImage],
                             errorImageModels: [GBHFacebookImage],
                             errors: [Error?]) {
        /// Append selected image(s)
        /// Do what you want with selected image
        
        self.imageModels.append(contentsOf: successImageModels)
        print("number of imageModelss: \(imageModels.count) VS number of images: \(images.count)")
        images = createLocalPhotos()
        print("number of imageModelss: \(imageModels.count) VS number of images: \(images.count)")
    }
    
    func facebookImagePicker(imagePicker: UIViewController, didFailWithError error: Error?) {
        print("Cancelled Facebook Album picker with error")
        print(error.debugDescription)
    }
    
    // Optional
    func facebookImagePicker(didCancelled imagePicker: UIViewController) {
        print("Cancelled Facebook Album picker")
    }
    
    // Optional
    func facebookImagePickerDismissed() {
        print("Picker dismissed")
    }
}

extension ViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension ViewController {
    /// la configuration de la collection
    // MARK: Public methods
    
    /**
     numberOfItemsInSection c'est pour definir le nombre de items dans une section .
     - parameter collectionView:   la collection laquelle qu'on veut personnaliser.
     - parameter section: la section qu'on veut configurer.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageModels.count
    }
    
    //LA methode cellForItemAtIndexPath c'est pour affecter l'image correcspondante à la cellule courante .
    // MARK: Public methods
    
    /**
     cellForItemAtIndexPath c'est pour affecter l'image correcspondante à la cellule courante .
     - parameter collectionView:   la collection laquelle qu'on veut personnaliser.
     - parameter indexPath: l'index de la celulle courante.
     */
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        if let img = self.imageModels[indexPath.row].image {
            cell.CollectionViewCell.image = img
        }
        cell.CollectionViewCell.contentMode = .scaleAspectFill
        return cell
    }
}

extension ViewController {
    // MARK: - Configuration de collectionView
    // MARK: Public methods
    
    /**
     didSelectItemAtIndexPath: L'action a faire si une photo dans la cellection est cliquer .
     - parameter collectionView:   la collection laquelle qu'on veut personnaliser.
     - parameter indexPath: l'index de la celulle courante.
     */
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
            return
            
        }
        print("index path is : \(indexPath)")
        guard let originImage = cell.CollectionViewCell.image else {
            print("this is else")
            
            return
        }
        
        let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
        print("initial page index : \(indexPath.row)")
        ///browser.currentPageIndex(indexPath)
        browser.initializePageIndex(indexPath.row)
        browser.delegate = self
        /// browser.updateCloseButton(UIImage(named: "casa.jpg")!)
        
        
        present(browser, animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 70, height: 300)
            
            
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 70, height: 200)
        }
    }
}



extension ViewController {
    // MARK: - SKPhotoBrowserDelegate
    
    // MARK: Public methods
    
    /**
     didShowPhotoAtIndex: si l'image va etre afficher qui correspond de l'index passer en parametre .
     - parameter index: l'index de la cellule.
     */
    func didShowPhotoAtIndex(_ index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
        
        
        print("didShowPhotoAtIndex")
        
    }
    
    func willDismissAtPageIndex(_ index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
        print("willDismissAtPageIndex")
        
        
    }
    
    func willShowActionSheet(_ photoIndex: Int) {
        // do some handle if you need
    }
    
    func didDismissAtPageIndex(_ index: Int) {
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = false
    }
    
    func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
        // handle dismissing custom actions
    }
    
    func removePhoto(index: Int, reload: (() -> Void)) {
        reload()
    }
    
    func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
}

extension ViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    //MARK : UICollectionViewDelegate & UICollectionViewDataSource
    
    func setupTestData() {
        images = createLocalPhotos()
        print("number of images: \(images.count)")
    }
    ///affecter le datasource et le delegate à la collection
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    ///la creation des photos qui vont etre afficher dans la cellule
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<self.imageModels.count).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImage(self.imageModels[i].image!)
            photo.contentMode = .scaleAspectFill
            photo.shouldCachePhotoURLImage = true
            return photo
            
        }
    }
    
    
}
/// - La configuration de style de la cellule de la collection

class CollectionViewCell: UICollectionViewCell {

    //MARK : IBOutlet
    @IBOutlet weak var CollectionViewCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CollectionViewCell.image = nil
        //  layer.cornerRadius = 25.0
        layer.masksToBounds = true
        CollectionViewCell.frame.size.width = 500
        CollectionViewCell.frame.size.height = 500
        
        
    }
    
    override func prepareForReuse() {
        CollectionViewCell.image = nil
    }
}

//
//  EjercicioOrdenarVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 10/7/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit


class EjercicioOrdenarVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    struct Fila{
        static let EspacioMinimoEntreCeldas = CGFloat(5)
        static var LargoMax: CGFloat?
        var largo: CGFloat
        let contiene: String
        var palabras: [UILabel] {
            didSet{
                largo = -Fila.EspacioMinimoEntreCeldas // para no contar el espacio de la ultima palabra
                for p in palabras{
                    largo += p.frame.size.width + Fila.EspacioMinimoEntreCeldas
                }
            }
        }
        init (tipo: String){
            palabras = []
            largo = 0
            contiene = tipo
        }
        func puedeContener(otra label: UILabel) -> Bool {
            if(contiene == "opciones"){
                return true
            }else {// respuestas
                return Fila.LargoMax! > (largo + label.frame.size.width)
            }
        }
    }

    @IBOutlet weak var preguntaTextView: UITextView!
    @IBOutlet weak var BotonRevisar: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var CalificacionImageView: UIImageView!
    
    @IBOutlet weak var AlturaDeImagenConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var EspacioBotonFondoCosntraint: NSLayoutConstraint!
    @IBOutlet weak var AlturaViewControllerConstraint: NSLayoutConstraint!
    @IBOutlet weak var AlturaCollectionViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var EspacioBotonCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioCollectionImagenConstraint: NSLayoutConstraint!
    var Ejercicios: [Ejercicio]!
    var EjercicioActual: Ejercicio!    
    var IndiceSeccionDeOpciones: Int!
    var UltimaFilaUsada: Int = 0 {
        didSet{
            UltimaFilaUsada = (UltimaFilaUsada < 0) ? 0 : UltimaFilaUsada
        }
    }
    var AltoDeEtiqueta: CGFloat!
    
    var color : UIColor!// = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
    var yaFueRevisado = false
    var RespuestaCorrecta: String!
    var relleno: String = ""
    var dataSource: [Fila] = []
    
    let EspacioEntreRenglones = CGFloat(15)
    let EspacioEntreSecciones = CGFloat(50)
    let AlturaImagen = CGFloat(65)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AltoDeEtiqueta = nuevaLabel().frame.size.height
        // calculando el ancho de los renglones del collectionview
        let anchoPantalla = self.view.frame.size.width
        let margenesYConstraints = CGFloat( (2 * 10) + (2 * 10))
        Fila.LargoMax = anchoPantalla - margenesYConstraints
        
        EjercicioActual = Ejercicios.removeFirst()
        preguntaTextView.text = EjercicioActual.textos!
        
        var  arreglo = EjercicioActual.respuestas!.characters.split{$0 == "|"}.map(String.init)
        // removiendo el @
        arreglo[0].remove(at: arreglo[0].startIndex)
        RespuestaCorrecta = arreglo.removeFirst()
        
        
        // calcular el numero de secciones para asi mostrar parrafos 
        // basandonos en el ancho de cada etiqueta mas el espacio entre ellas
        // y agregarlos como secciones vacias al principio del datasource
        
        
        // inicializar data source
        // con seccion de opciones
        var seccionDeOpciones = Fila(tipo: "opciones")
        var opcionesDeRespuesta = RespuestaCorrecta.components(separatedBy: " ") + arreglo
        opcionesDeRespuesta.shuffle()
        for palabra in opcionesDeRespuesta{
            let etiqueta = nuevaLabel(palabra)
            seccionDeOpciones.palabras.append(etiqueta)
        }
        
        // agregar secciones/renglones en blanco para poner respuestas
        let filasParaRespuestas = Int(seccionDeOpciones.largo / Fila.LargoMax!)
        for _ in 0...filasParaRespuestas{
            dataSource.append(Fila(tipo: "respuestas"))
        }
        // agregar la seccion de opciones de respuesta
        dataSource.append(seccionDeOpciones)
        IndiceSeccionDeOpciones = dataSource.count - 1
        
        // ocultando la imagen
        AlturaDeImagenConstraint.constant = 0
        CalificacionImageView.alpha = 0
        
        
        // calculando altura de las cosas
        preguntaTextView.sizeToFit()
        AlturaCollectionViewConstraint.constant = ((AltoDeEtiqueta.magnitude  /*+ EspacioEntreRenglones*/ ) * CGFloat(dataSource.count)) * 2
        AlturaCollectionViewConstraint.constant += EspacioEntreSecciones / 2
        
        var alturaRequerida = CGFloat(0)
        // espacio disponible cambiar nombre a
        let alturaPantalla = self.view.frame.size.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height
        // el 60 viene del espacio vertical entre las constraints del textview y el collectionview en el IB
        
        alturaRequerida = 60 + preguntaTextView.frame.size.height +  AlturaCollectionViewConstraint.constant
        alturaRequerida += EspacioBotonCollectionConstraint.constant
        alturaRequerida += BotonRevisar.frame.size.height
        
        // si la altura minima requerida es menor que la altura de la pantalla
        if(alturaRequerida <= alturaPantalla){
            AlturaViewControllerConstraint.constant = alturaPantalla
            // mantener el boton sobre la guia del fondo
            EspacioBotonFondoCosntraint.isActive = true
            EspacioBotonCollectionConstraint.isActive = false
        }else {
            AlturaViewControllerConstraint.constant = alturaRequerida + 60
            EspacioBotonFondoCosntraint.isActive = false
            EspacioBotonCollectionConstraint.isActive = true
            // la altura calculada permanece como altura de la pantalla
            //el boton se pega bajo el collection view o la imageview
        }        

        // iniciando boton
        iniciarBoton()
        
    }
    
   
    
    func nuevaLabel(_ titulo: String = "word") -> UILabel{
        let label = UILabel()
        label.text = titulo
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = color
        
        label.adjustsFontForContentSizeCategory = false
        label.adjustsFontSizeToFitWidth = false
        label.sizeToFit()
        // añadirle un poco de padding
        label.frame.size.width += 15
        label.frame.size.height += 15
        label.layer.cornerRadius = 5
        label.frame.origin.y -= 3
        label.layer.masksToBounds = true
        
        return label
    }
    
    @objc func accionDelBoton() {
        if let titulo = BotonRevisar.titleLabel?.text{
            switch titulo {
            case "Revisar":
                revisar()
            case "Siguiente":
                siguienteEjercicio()
            default:
                print("Texto del boton desconocido '\(titulo)'")
            }
        }
    }
    func iniciarBoton(){
        BotonRevisar.backgroundColor = UIColor.white
        BotonRevisar.addTarget(self, action: #selector(accionDelBoton), for: .touchDown)
        BotonRevisar.layer.cornerRadius = 10
        BotonRevisar.layer.borderWidth = 1.5
        BotonRevisar.layer.borderColor = color.cgColor
        BotonRevisar.setTitleColor( #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), for: .disabled)
    }
    
    func revisar() {
        yaFueRevisado = true
        collectionView.isUserInteractionEnabled = false
        var respuestaDelUsuario: String = ""
        for fila in dataSource{
            if(fila.contiene == "opciones"){
                break
            }
            for palabra in fila.palabras{
                respuestaDelUsuario.append(palabra.text!)
                respuestaDelUsuario.append(" ")
            }
        }
        if !respuestaDelUsuario.isEmpty{
            // removiendo el ultimo espacio del ciclo
            respuestaDelUsuario.remove(at: respuestaDelUsuario.index(before: respuestaDelUsuario.endIndex))
        }
        BotonRevisar.setTitle("Siguiente", for: .normal)

        if(RespuestaCorrecta == respuestaDelUsuario){
            CalificacionImageView.image = #imageLiteral(resourceName: "correcto")
            EjercicioActual.vecesAcertado += 1
        }else {
            CalificacionImageView.image = #imageLiteral(resourceName: "equivocado")
            EjercicioActual.vecesFallado += 1
            mostrarRespuesta()
        }
        AlturaCollectionViewConstraint.constant /= 2
        AlturaViewControllerConstraint.constant += AlturaImagen
        UIView.animate(withDuration: 0.3, animations: {
            self.AlturaDeImagenConstraint.constant = self.AlturaImagen
            self.CalificacionImageView.alpha = 1
            if let _ = self.EspacioBotonCollectionConstraint{
                self.EspacioBotonCollectionConstraint.constant += self.AlturaImagen * 2.5
            }
            
        })
        print("Veces acertado: \(EjercicioActual.vecesAcertado)")
        print("Veces fallado: \(EjercicioActual.vecesFallado)")
        do{
            try EjercicioActual.managedObjectContext?.save()
        }catch{
            print("No se pudo guardar en CoreData la calificacion del ejercicio")
        }
        
    }
    // MARK:- Navegacion
    func siguienteEjercicio() {
        if let siguienteE = Ejercicios.first{
            let storyBoard: UIStoryboard = (self.navigationController?.storyboard)!
            var siguienteViewController: UIViewController?
            switch siguienteE.tipo! {
            case "Voz":
                let eVoz = storyBoard.instantiateViewController(withIdentifier: "EjercicioVozVC") as! EjercicioVozVC
                eVoz.color = self.color
                eVoz.Ejercicios = Ejercicios
                siguienteViewController = eVoz
            case "Opcion multiple":
                let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                eOpMul.color = self.color
                eOpMul.Ejercicios = Ejercicios
                siguienteViewController = eOpMul
            case "Ordenar oracion":
                let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                eOrOr.color = self.color
                eOrOr.Ejercicios = Ejercicios
                siguienteViewController = eOrOr
            case "Escritura":
                let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                eEs.color = self.color
                eEs.Ejercicios = Ejercicios
                siguienteViewController = eEs
            default:
                print("Tipo de ejercicio desconocido: \(siguienteE.tipo!)")
            }
            if let sViewC = siguienteViewController{
                var stack = self.navigationController!.viewControllers
                stack.popLast()
                stack.append(sViewC)
                self.navigationController?.setViewControllers(stack, animated: true)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueEscritura"){
            let vc = segue.destination as! EjercicioEscrituraVC
            vc.color = self.color
        }
    }
    
    // MARK:- CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].palabras.count
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(!BotonRevisar.isEnabled){
            BotonRevisar.isEnabled = true
        }
        var filaOrigen = indexPath.section
        let posicionOrigen = indexPath.item
        var posicionDestino: Int
        var filaDestino: Int
        // si tocan una palabra en la seccion de opciones, esta se va a la primer fila, si esta ya esta llena a la siguente
        // y asi sucesivamente hasta encontrar una fila donde haya espacio
        if(filaOrigen == IndiceSeccionDeOpciones){
            filaDestino = UltimaFilaUsada
            let etiquetaPorMover = dataSource[filaOrigen].palabras.remove(at: posicionOrigen)
            
            for _ in UltimaFilaUsada...(dataSource.count - 2){
                if(dataSource[UltimaFilaUsada].puedeContener(otra: etiquetaPorMover)){
                    filaDestino = UltimaFilaUsada
                    break
                }else{
                    UltimaFilaUsada += 1
                }
            }
            // mover  en data source
            dataSource[filaDestino].palabras.append(etiquetaPorMover)
            // mover la celda en collectionview
            posicionDestino = collectionView.numberOfItems(inSection: filaDestino)
            collectionView.moveItem(at: indexPath, to: IndexPath(item:posicionDestino, section: filaDestino))
            
            }
        
        // palabras tocadas en cualquier otra seccion regresaran a la seccion de opciones y se re organizan las palabras las 
        // palabras en las otras secciones
    
        else  { // mandar al fondo
            posicionDestino = collectionView.numberOfItems(inSection: IndiceSeccionDeOpciones)
            // en data source
            let etiquetaPorMover = dataSource[filaOrigen].palabras.remove(at: posicionOrigen)
            dataSource[IndiceSeccionDeOpciones].palabras.append(etiquetaPorMover)
            // en collectionView
            collectionView.moveItem(at: indexPath, to: IndexPath(item:posicionDestino, section:IndiceSeccionDeOpciones))
            if(dataSource[filaOrigen].palabras.isEmpty){
                UltimaFilaUsada -= 1
            }
            
            // en el espacio que se libero, intentar encajar palabras de las filas de abajo
            // a menos que la siguiente sea la fila de opciones
            var filaSiguiente = filaOrigen + 1
            while (!dataSource[filaSiguiente].palabras.isEmpty && dataSource[filaSiguiente].contiene == "respuestas") {
                if(dataSource[filaOrigen].puedeContener(otra: dataSource[filaSiguiente].palabras.first!)){
                    let pPorMover = dataSource[filaSiguiente].palabras.remove(at: 0)
                    dataSource[filaOrigen].palabras.append(pPorMover)
                    collectionView.moveItem(at:IndexPath(item: 0, section: filaSiguiente), to: IndexPath(item: collectionView.numberOfItems(inSection: filaOrigen), section: filaOrigen))
                    
                }else{
                    filaOrigen += 1
                    filaSiguiente += 1
                }
            }
            if(dataSource[filaSiguiente].palabras.isEmpty){
                UltimaFilaUsada -= 1
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ancho = dataSource[indexPath.section].palabras[indexPath.item].frame.size.width
        return CGSize(width: ancho, height: AltoDeEtiqueta)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if(section == (collectionView.numberOfSections - 2) ) &&  !yaFueRevisado{
            // espacio entre la secion de respuestas y la de opcionnes
            return CGSize.init(width: Fila.LargoMax!, height: EspacioEntreSecciones)
        }
        else {// espacio normal entre renglones
            return CGSize.init(width: Fila.LargoMax!, height: EspacioEntreRenglones)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(collectionView.numberOfItems(inSection: section) == 0) {
            return CGSize.init(width: Fila.LargoMax!, height: AltoDeEtiqueta + 1)
        }else{
            // si tuviera la altura = 0 daria un bug cuando todas las palabras estan una seccion intermedia y luego intentas sacarla
            return CGSize(width: 0, height: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "collection_cell", for: indexPath)
        let label = dataSource[indexPath.section].palabras[indexPath.item]
        label.tag = 1
        celda.contentView.addSubview(label)
        celda.clipsToBounds = false
        return celda
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if(kind == "UICollectionElementKindSectionFooter"){
            // remueve la linea del parrafo del footer en caso de ser la ultima seccion (donde se encuentran las opciones)
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collection_footer", for: indexPath)
           // footer.viewWithTag(2)?.frame.size.width = Fila.LargoMax! // hace el renglon(lo que es visible) del ancho adecuado
            if(indexPath.section == (collectionView.numberOfSections - 1)){
                footer.viewWithTag(2)?.isHidden = true
            }
            return footer;
        }else {//header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collection_header", for: indexPath)
            return header
        }
    }
    
    func mostrarRespuesta() {
        collectionView.performBatchUpdates({
            // borrar todo
            var palabrasPorBorrarIndices: [IndexPath] = []
            for fila in 0..<self.dataSource.count{
                if(!self.dataSource[fila].palabras.isEmpty){
                    for p in 0..<self.dataSource[fila].palabras.count{
                        self.dataSource[fila].palabras.remove(at: 0)
                        palabrasPorBorrarIndices.append(IndexPath(item: p, section: fila))
                    }
                }
            }
            self.collectionView.deleteItems(at: palabrasPorBorrarIndices)
            //volver a llenar con las respuestas correctas
            let palabrasCorrectas = self.RespuestaCorrecta.components(separatedBy: " ")
            var palabrasPorInsertarIndices: [IndexPath] = []
            var indiceP: Int = 0
            var fila: Int = 0
            
            for p in palabrasCorrectas{
                let label = self.nuevaLabel(p)
                if(self.dataSource[fila].puedeContener(otra: label)){
                    self.dataSource[fila].palabras.append(label)
                    palabrasPorInsertarIndices.append(IndexPath(item: indiceP, section: fila))
                    indiceP += 1
                }else{
                    fila += 1
                    indiceP = 0
                    self.dataSource[fila].palabras.append(label)
                    palabrasPorInsertarIndices.append(IndexPath(item: indiceP, section: fila))
                    indiceP += 1
                }
                
            }
            self.collectionView.insertItems(at: palabrasPorInsertarIndices)
            // borrar seccion de opciones
            var set = IndexSet()
            set.insert(IndexSet.Element(self.IndiceSeccionDeOpciones))
            self.collectionView.deleteSections(set)
            self.dataSource.remove(at: self.IndiceSeccionDeOpciones)
            self.collectionView.sizeToFit()
        
        }, completion: nil)
    }
    
}

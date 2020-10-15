//
//  SDOSFirebase.swift
//
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseCore

public enum SDOSFirebaseConfigType: String {
    case plist
}

enum SDOSFirebaseScreenConfigType: String {
    case plist
}

public class SDOSFirebase {
    public static let screensPlistNameDefault = "FirebaseScreens"
    public static let fileConfigurationName = "GoogleService-Info"
    public static let fileConfigurationExtension = SDOSFirebaseConfigType.plist
    
    fileprivate static var configurationLoaded = false
    fileprivate static var screensPlistName = "FirebaseScreens" {
        didSet {
            guard let screensPlist = Bundle.main.path(forResource: screensPlistName, ofType: SDOSFirebaseScreenConfigType.plist.rawValue),
                let _ = NSDictionary(contentsOfFile: screensPlist)
                else {
                    print("[\(self)] - No se ha podido cargar el fichero de configuración de los nombres de pantallas de Firebase. Comprueba que el fichero \"\(screensPlistName).\(SDOSFirebaseScreenConfigType.plist.rawValue)\" existe")
                    return
            }
            self.screensDictionary = NSDictionary(contentsOfFile: screensPlist)
            print("[\(self)] - Fichero \"\(screensPlistName).\(SDOSFirebaseScreenConfigType.plist.rawValue)\" cargado correctamente")
        }
    }
    fileprivate static var screensDictionary: NSDictionary?
    
    
    /// Recupera la configuración para enviar a Firebase a partir del fichero de configuración indicado
    ///
    /// - Parameters:
    ///   - environment: Entorno de ejecución. Este String se usará para formar el nombre completo del fichero a cargar. El fichero a buscar será: fileName-environment.fileExtension (Ejemplo: GoogleService-Info-Debug.plist)
    ///   - fileName: Nombre del fichero de configuración sin la extensión. Default: GoogleService-Info
    ///   - fileExtension: Extensión del fichero de configuración. Default: plist
    ///   - bundle: Paquete donde se buscará el fichero de configuración: Default: Bundle.main
    ///   - screensPlist: Nombre del fichero que contiene la asociación de nombres de las pantallas que se setearan en firebase
    /// - Returns: Objeto options con la configuración del fichero. Devuelve nil si no se encuentra el fichero de configuración
    public static func options(environment: String, fileName: String = fileConfigurationName, fileExtension: SDOSFirebaseConfigType = fileConfigurationExtension, bundle: Bundle = Bundle.main, screensPlist: String = screensPlistNameDefault) -> FirebaseOptions? {
        self.screensPlistName = screensPlist
        let completeName = "\(fileName)-\(environment)"
        return options(fileName: completeName, fileExtension: fileExtension, bundle: bundle, screensPlist: screensPlist)
    }
    
    /// Recupera la configuración para enviar a Firebase a partir del fichero de configuración indicado
    ///
    /// - Parameters:
    ///   - fileName: Nombre del fichero de configuración sin la extensión. Default: GoogleService-Info
    ///   - fileExtension: Extensión del fichero de configuración. Default: plist
    ///   - bundle: Paquete donde se buscará el fichero de configuración: Default: Bundle.main
    ///   - screensPlist: Nombre del fichero que contiene la asociación de nombres de las pantallas que se setearan en firebase
    /// - Returns: Objeto options con la configuración del fichero. Devuelve nil si no se encuentra el fichero de configuración
    public static func options(fileName: String = fileConfigurationName, fileExtension: SDOSFirebaseConfigType = fileConfigurationExtension, bundle: Bundle = Bundle.main, screensPlist: String = screensPlistNameDefault) -> FirebaseOptions? {
        self.screensPlistName = screensPlist
        guard let firebasePlist = bundle.path(forResource: fileName, ofType: fileExtension.rawValue),
            let firebaseOptions = FirebaseOptions(contentsOfFile: firebasePlist)
            else {
                print("[\(self)] - No se ha podido recuperar la configuración de Firebase. Comprueba que el fichero \"\(fileName).\(fileExtension.rawValue)\" existe")
                return nil
        }
        print("[\(self)] - Cargada la configuración de Firebase del fichero \"\(fileName).\(fileExtension.rawValue)\"")
        return firebaseOptions
    }
    
    /// Lanza la configuración de Firebase. Este método sólo puede ser invocado una vez
    ///
    /// - Parameter options: Configuración a cargar en Firebase
    public static func configure(options: FirebaseOptions?) {
        guard let options = options else {
            print("[\(self)] - No se ha podido cargar la configuración de Firebase. FirebaseOptions es nil")
            return
        }
        guard !configurationLoaded else {
            assertionFailure("[\(self)] - No se puede volver a cargar la configuración de Firebase una vez que ya ha sido inicializada")
            return
        }
        FirebaseApp.configure(options: options)
        configurationLoaded = true
        print("[\(self)] - Configuración de Firebase realizada correctamente")
    }
    
    
    /// Setea el nombre de una pantalla para la instancia indicada en Firebase. El nombre de la pantalla será uno de los siguientes (en este orden):
    ///     * La implementación del método firebaseScreenName
    ///     * El nombre que la clase tiene asociado en el fichero .plist (Por defecto "FirebaseScreens.plist")
    ///     * El nombre de la clase
    ///
    /// - Parameters:
    ///   - forInstance: Instancia de la clase a la que setear el nombre
    public static func setScreenName(forInstance screenInstance: SDOSFirebaseScreen) {
        setScreenAnalytic(name: getScreenName(forInstance: screenInstance), screenClassName: String(describing: type(of: screenInstance)))
    }
    
    /// Setea el nombre de una pantalla para la clase indicada en Firebase. El nombre de la pantalla será uno de los siguientes (en este orden):
    ///     * El String indicado en el parámetro "name"
    ///     * El nombre que la clase tiene asociado en el fichero .plist (Por defecto "FirebaseScreens.plist")
    ///     * El nombre de la clase
    ///
    /// - Parameters:
    ///   - name: Nombre de la pantalla a setear. Si viene nulo pondrá el nombre de la clase
    ///   - forClass: Clase a la que setear el nombre
    public static func setScreenName(_ name: String?, forClass screenClass: SDOSFirebaseScreen.Type) {
        setScreenAnalytic(name: getScreenName(name, forClass: screenClass), screenClassName: String(describing: screenClass))
    }
    
    /// Obtiene el nombre de Firebase de una pantalla para la instancia indicada. El nombre de la pantalla será uno de los siguientes (en este orden):
    ///     * La implementación del método firebaseScreenName
    ///     * El nombre que la clase tiene asociado en el fichero .plist (Por defecto "FirebaseScreens.plist")
    ///     * El nombre de la clase
    ///
    /// - Parameters:
    ///   - forInstance: Instancia de la clase de la que obtener el nombre
    /// - Returns: Nombre de una pantalla para la clase indicada en Firebase
    public static func getScreenName(forInstance screenInstance: SDOSFirebaseScreen) -> String? {
        guard configurationLoaded else {
            return nil
        }
        
        var screenName = screenInstance.firebaseScreenName?()
        if screenName == nil {
            screenName = getScreenName(nil, forClass: type(of: screenInstance))
        }
        return screenName
    }
    
    /// Obtiene el nombre de Firebase de una pantalla para la clase indicada. El nombre de la pantalla será uno de los siguientes (en este orden):
    ///     - El nombre que la clase tiene asociado en el fichero .plist (Por defecto "FirebaseScreens.plist")
    ///     - El nombre de la clase
    ///
    /// - Parameters:
    ///   - forClass: Clase a la que obtener el nombre
    /// - Returns: Nombre de una pantalla para la clase indicada en Firebase
    public static func getScreenName(forClass screenClass: SDOSFirebaseScreen.Type) -> String? {
        return getScreenName(nil, forClass: screenClass)
    }
    
    private static func getScreenName(_ name: String?, forClass screenClass: SDOSFirebaseScreen.Type) -> String? {
        guard configurationLoaded else {
            return nil
        }
        
        var screenName = String(describing: screenClass)
        if let name = name {
            screenName = name
        } else if let screensDictionary = screensDictionary, let name = screensDictionary[String(describing: screenClass)] as? String {
            screenName = name
        }
        return screenName
    }
    
    private static func setScreenAnalytic(name: String?, screenClassName: String?) {
        //[FIRAnalytics logEventWithName:kFIREventScreenView parameters:]
        
        Analytics.setScreenName(name, screenClass: screenClassName)
    }
}

@objc public protocol SDOSFirebaseScreen {
    /// Sobrescribe el nombre de la pantalla para marcar en Firebase
    ///
    /// - Returns: Nombre para marcar en Firebase
    @objc optional func firebaseScreenName() -> String?
}

extension UIView: SDOSFirebaseScreen { }

extension UIViewController: SDOSFirebaseScreen { }

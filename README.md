- [SDOSFirebase](#sdosfirebase)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Cocoapods](#cocoapods)
    - [Swift Package Manager](#swift-package-manager)
      - [**En el "Project"**](#en-el-project)
      - [**En un Package.swift**](#en-un-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Configuración del proyecto](#configuración-del-proyecto)
    - [Implementación](#implementación)
      - [Configuración inicial](#configuración-inicial)
      - [Uso](#uso)
    - [Otros ejemplos de configuración](#otros-ejemplos-de-configuración)
  - [Dependencias](#dependencias)
  - [Referencias](#referencias)

# SDOSFirebase

- Enlace confluence: https://kc.sdos.es/x/jAPLAQ
- Changelog: https://github.com/SDOSLabs/SDOSFirebase/blob/master/CHANGELOG.md

## Introducción

SDOSFirebase implementa las funcionalidades necesarias para el marcado de pantallas en la plataforma Firebase. La librería se encarga de recuperar la configuración del fichero .plist que proporciona Google y posteriormente la aplica. En caso de que sea necesaria alguna configuración adicional de Firebase la carga del fichero .plist se puede hacer sin la librería, pero **sí es obligatorio aplicar la configuración de Firebase con esta librería**. Si no se aplica la configuración con la librería, ésta no funcionará.

La librería se encarga de leer un fichero .plist con la asociación de los ViewControllers y el nombre que deben tener en Firebase y los aplica al llamarase al método viewDidAppear. Está implementación se realiza en un controlador base del que deberán heredar todas las pantallas.

## Instalación

### Cocoapods

Usaremos [CocoaPods](https://cocoapods.org). 

Añadir el "source" privado de SDOSLabs al `Podfile`. Añadir también el source público de cocoapods para poder seguir instalando dependencias desde éste:
```ruby
source 'https://github.com/SDOSLabs/cocoapods-specs.git' #SDOSLabs source
source 'https://github.com/CocoaPods/Specs.git' #Cocoapods source
```

Añadir la dependencia al `Podfile`:

```ruby
pod 'SDOSFirebase', '~>3.0' 
```

### Swift Package Manager

A partir de Xcode 12 podemos incluir esta librería a través de Swift package Manager. 

Al incluir la librería con Swift Package Manager debemos ir al `Build Settings` del target, buscar la opción `Other Linker Flags` y añadir el valor `-ObjC`. Sin este paso la aplicación fallará al usar cualquier función de `Firebase`. Podéis consultar el [siguiente artículo](https://applecoding.com/tutoriales/firebase-instalacion-con-swift-package-manager-y-uso-en-swiftui-con-ios-14-y-xcode-12) donde explican como se añade la librería de Firebase a un proyecto.

Existen 2 formas de añadir esta librería a un proyecto:

#### **En el "Project"**

Debemos abrir nuestro proyecto en Xcode y seleccionar el proyecto para abrir su configuración. Una vez aquí seleccionar la pestaña "Swift Packages" y añadir el siguiente repositorio

```
https://github.com/SDOSLabs/SDOSFirebase.git
```

En el siguiente paso deberemos seleccionar la versión que queremos instalar. Recomentamos indicar "Up to Next Major" `3.0.0`.

Por último deberemos indicar el o los targets donde se deberá incluir la librería

#### **En un Package.swift**

Incluir la dependencia en el bloque `dependencies`:

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/SDOSFirebase.git", .upToNextMajor(from: "3.0.0"))
]
```

Incluir la librería en el o los targets desados:

```js
.target(
    name: "YourDependency",
    dependencies: [
        "SDOSFirebase"
    ]
)
```

## Cómo se usa

### Configuración del proyecto

La librería está planteada para usarse conjuntamente con los entornos configurados para SDOSEnvironment. Google proporciona un fichero .plist con la configuración de la aplicación de Firebase correspondiente y por lo general, una aplicación tendrá configuraciones diferentes dependiendo del entorno. Para aplicar una correcta configuración hay que realizar los siguientes pasos:

- Descargar el fichero GoogleService-Info.plist desde Firebase y renombrarlo a GoogleService-Info-<*Entorno*>.plist (Ejemplo: GoogleService-Info-Debug.plist)
- Hacer el paso anterior para todos los entornos disponibles
- Añadir un fichero .plist llamado *FirebaseScreens.plist*. Este fichero contedrá los nombres de pantallas a poner en Firebase para cada ViewController. Ejemplo:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>DocumentationViewController</key>
        <string>Documentation</string>
    </dict>
    </plist>
    ```

> Los nombres de los ficheros plist pueden modificarse, en cuyo caso la librería se deberá inicializar como se muestra en los ejemplos de configuración

### Implementación

#### Configuración inicial

La librería requiere que se lance la configuración inicial durante la carga de la aplicación (preferiblemente en el método *application(application:didFinishLaunchingWithOptions:)*). Está configuración se realiza con la siguiente implementación:

1. Cargar el fichero de configuración de Firebase con la siguiente llamada
    ```js
    //If environment is "Debug" load config file from GoogleService-Info-Debug.plist
    var options = SDOSFirebase.options(environment: SDOSEnvironment.environmentKey)
    ```
2. Aplicar la configuración
    ```js
    SDOSFirebase.configure(options: options)
    ```
La configuración de Firebase se puede cargar de otra forma o recibir modificaciones una vez cargada. Está implementación es válida si se configuran los ficheros por entornos.

#### Uso

Para que una pantalla pueda ser marcada en firebase la clase debe implementar el protocolo `SDOSFirebaseScreen`. Este protocolo implementa un método para definir el nombre de la pantalla
```js
@objc optional func firebaseScreenName() -> String?
```

Por defecto la librería crea unas extensiones para que las clases `UIViewController` y `UIView` implementen dicho protocolo


Para realizar el marcaje de las pantallas hay que implementar el siguiente código durante la presentación de la vista:

Si tenemos la instancia:
```js
SDOSFirebase.setScreenName(forInstance: self)
```

Si tenemos la clase:
```js
SDOSFirebase.setScreenName(nil, forClass: type(of: self)) 
//El primer parámetro es el nombre para marcar en Firebase que puede ser opcional
```

Un ejemplo sería llamar al método en el viewDidAppear:
```js
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    SDOSFirebase.setScreenName(forInstance: self)
}
```

En algunos casos la pantalla puede tomar diferentes valores para el marcaje en Firebase dependiendo de varios factores que no puede ser configurados en el fichero *FirebaseScreens.plist*. Para estos casos se puede sobrescribir el método `firebaseScreenName() -> String?` que define el protocolo `SDOSFirebaseScreen` (lo implementan por defecto las clases `UIViewController` y `UIView`) para indicar el nombre que se debe marcar en Firebase:
```js
override func firebaseScreenName() -> String? {
    return "TestView"
}
```

En el caso que el nombre no exista en el fichero *FirebaseScreens.plist* y no sobrescriba el método `firebaseScreenName() -> String?`, la pantalla se marcará con el nombre del propio controlador

También se puede consultar el nombre que la pantalla tendrá en Firebase a través del siguiente método:

Para la instancia:
```js
let screenName = SDOSFirebase.getScreenName(forInstance: self)
```

Para la clase:
```js
let screenName = SDOSFirebase.getScreenName(forClass: type(of: self))
```

### Otros ejemplos de configuración

- Cargar la configuración de Firebase del fichero *GoogleService-Info.plist* (2 opciones válidas)
    
    Opción 1:
    ```js
    var options = SDOSFirebase.options()
    ```
    Opción 2:
    ```js
    var options = SDOSFirebase.options(filename: "GoogleService-Info")
    ```
- Cargar la configuración de Firebase del fichero *GoogleService-Info-Development.plist*
    ```js
    var options = SDOSFirebase.options(environment: "Development")
    ```
- Cargar la configuración de Firebase del fichero *Configuration.plist* y la asociación de pantallas del fichero *Screens.plist*
    ```js
    SDOSFirebase.options(fileName: "Configuration", screensPlist: "Screens")
    ```
- Cargar la configuración de Firebase del fichero *Configuration-Development.plist* y la asociación de pantallas del fichero *Screens.plist*
    ```js
    SDOSFirebase.options(environment: "Development", fileName: "Configuration", screensPlist: "Screens")
    ```

## Dependencias
* [Firebase/Core](https://cocoapods.org/pods/Firebase)

## Referencias
* https://github.com/SDOSLabs/SDOSFirebase

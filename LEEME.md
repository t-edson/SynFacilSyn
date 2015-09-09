SynFacilSyn
===========

Resaltador de sintaxis programable, para el componente  SynEdit de Lazarus.

![SynFacilCompletion](http://blog.pucp.edu.pe/blog/tito/wp-content/uploads/sites/610/1969/12/synfacilsyn1.png "Título de la imagen")

Este resaltador, es similar al resaltador SynAnySyn de Lazarus, pero mucho más rápido, eficiente y configurable.

El resaltador en sí, es además un completo analizador léxico que puede ser configurado para manejar una diversidad de lenguajes de programación.

El resaltador TSynFacilSyn es capaz de leer una sintaxis completa definida en un archivo externo en formato XML.

Características

•	Es configurable. Permite definir una sintaxis para el resaltado, usando un archivo externo XML o usando instrucciones de código.

•	Es de ejecución rápida y ligero en cuanto a memoria. Está optimizado para ser comparable en velocidad a un resaltador no-configurable.

•	Permite configurar de forma sencilla la mayoría de elementos de una sintaxis, como identificadores, cadenas, números y comentarios, de forma que se adapta a la mayoría de lenguajes.

•	Está orientado al manejo de tokens y atributos. Cada token contiene un único atributo.

•	Permite definir los caracteres que son válidos para los identificadores. Así se puede adaptar a la definición específica de cada lenguaje.

•	Permite manejar subconjuntos de identificadores (palabras reservadas, variables, etc) y subconjuntos de símbolos (operadores, separadores, etc).

•	Permite definir comentarios y cadenas multi-línea.

•	Permite crear tokens nuevos, usando identificadores como delimitadores (similar a los bloques <<HEREDOC).

•	Incluye la propiedad “CaseSensitive”, para poder reconocer identificadores ignorando la caja.

•	Permite definir bloques de plegado de código. Incluye diversas opciones para adecuarse a la mayoría de lenguajes de programación.

•	Se pueden definir bloques sin plegado. Puede colorear el fondo de los bloques.

•	El archivo de sintaxis en XML, permite formas resumidas para la definición de tokens.

•	Maneja diversos atributos predefinidos, pero pueden crearse más dinámicamente.

•	Puede manejar expresiones regulares sencillas para la definición de tokens.

•	Incluye un lenguaje de guíon para implementar definiciones complejas de tokens. 

Uso dentro de un programa.

Este resaltador, se compone de dos archivos que son  "SynFacilHighlighter.pas” y "SynFacilBasic.pas”. Se deben descargar estos archivos y copiarlos en la carpeta donde está el proyecto de trabajo o en la carpeta de unidades.

Una vez copiados, se debe incluir "SynFacilHighlighter" en la sentencia USES, de las unidades que requieran trabajar con este resaltador.

Como con cualquier resaltador, se debe crear una instancia del resaltador (TSynFacilSyn) y asignarla al editor que vayamos a usar:

```
uses  ... , SynHighlighterFacil;

var
    hlt : TSynFacilSyn;

  ...
  
  hlt := TSynFacilSyn.Create(self); //crea resaltador
  editor.Highlighter := hlt;
  hlt.LoadFromFile('SynPHP.xml');   //carga archivo de sintaxis
  ...
  
  htl.Free;  //libera 
```

Para usar el resaltador, es necesario configurar primero la sintaxis. Esto se puede hacer usando un archivo externo (archivo de sintaxis) o por código.

Un archivo XML de sintaxis sencilla podría ser:

```
<Language name=”simple”>
  <Keywords> 
and echo else exit for if 
 </Keywords>
</Language>
```

Para más información, revisar la documentación.

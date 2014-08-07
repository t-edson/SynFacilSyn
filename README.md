SynFacilSyn
===========

Scriptable Highlighter for SynEdit Component of Lazarus 

This highlighter is similar to the SynAnySyn of Lazarus, but it's much more faster, efficient and more configurable.

It can be used too, like a full lexical analyzer that can be configured to handle a variety of programming languages.

The highlighter TSynFacilSyn can read a complete syntax from an external XML file.

Features

•	Configurable. Can highlight words of a SynEdit control, using an external XML file, or using code.

•	It's fast and Light. It's optimized on speed for to be comparable to a hard coded highlighter.

•	It's easy for to configure the more common elements of a language, like identifiers, strings, numbers, and comments.

•	It's based on tokens and attributes.  Each kind of token contains a single attribute.

•	It's possible to define the characters that are valid for identifiers. So it can be adapted to the specific definition of each language.

•	It can manage subsets of identifiers (keywords, variables, ..) and subsets of symbols (operators, separators, etc).

•	It can define multiline elements like strings and comments.

•	It can define new tokens using pre-defined tokens, like <<HEREDOC elements.

•	Includes the property “CaseSensitive”, for to compare the Case of chars.

•	It can define blocks of code folding. Includes several options to suit most programming languages.

•	It can define syntax blocks (with or without folding) and can paint the background of the blocks.

•	The XML file admits complete and simplified forms of definitions.

•	It includes several predefined attributes, but it can be defined more dynamically.


SynFacilSyn
===========

Resaltador de sintaxis programable, para el componente  SynEdit de Lazarus.

Este resaltador, es similar al resaltador SynAnySyn de Lazarus, pero mucho más rápido, eficiente y configurable.

El resaltador en sí, es además un completo analizador léxico que puede ser configurado para manejar una diversidad de lenguajes de programación.

El resaltador TSynFacilSyn es capaz de leer una sintaxis completa definida en un archivo externo en formato XML.

Características

•	Es configurable. Permite definir una sintaxis para el resaltado, usando un archivo externo XML o usando instrucciones de código.

•	Es de ejecución rápida y ligero en cuanto a memoria. Está optimizado para ser comparable en velocidad a un resaltador no-configurable.

•	Permite configurar de forma sencilla la mayoría de elementos de una sintaxis, como identificadores, cadenas, números y comentarios, de forma que se adapta a la mayoría de lenguajes.

•	Está orientado al manejo de tokens y atributos. Cada token contiene un único atributo.

•	Permite definir los caracteres que son válidos para los identificadores. Así se puede adaptar a la definición específica de cada lenguaje.

•	Permite manejar subconjuntos de identificadores (palabras reservadas, variables, directivas, etc) y subconjuntos de símbolos (operadores, separadores, etc).

•	Permite definir comentarios y cadenas multi-línea.

•	Permite crear tokens nuevos, usando identificadores como delimitadores (similar a los bloques <<HEREDOC).

•	Incluye la propiedad “CaseSensitive”, para poder reconocer identificadores ignorando la caja.

•	Permite definir bloques de plegado de código. Incluye diversas opciones para adecuarse a la mayoría de lenguajes de programación.

•	Se pueden definir bloques sin plegado. Puede colorear el fondo de los bloques.

•	El archivo de sintaxis en XML, permite formas resumidas para la definición de tokens.

•	Maneja diversos atributos predefinidos, pero pueden crearse más dinámicamente.


Uso dentro de un programa.

Este resaltador, se compone de un solo archivo que es la unidad “SynHighLighterFile.pas”. Se debe descargar este archivo y copiarlo en la carpeta donde está el proyecto de trabajo.

Una vez copiado, se debe incluir en la sentencia USES, de las unidades que requieran trabajar con este resaltador.

Como con cualquier resaltador, se debe crear una instancia del resaltador (TSynFacilSyn) y asignarla al editor que vayamos a usar:

´´´
uses  ... , SynHighlighterFacil;

var
    hlt : TSynFacilSyn;

  ...
  
  hlt := TSynFacilSyn.Create(self); //crea resaltador
  editor.Highlighter := hlt;
  hlt.LoadFromFile('SynPHP.xml');   //carga archivo de sintaxis
  ...
  
  htl.Free;  //libera 
´´´

Para usar el resaltador, es necesario configurar primero la sintaxis. Esto se puede hacer usando un archivo externo (archivo de sintaxis) o por código.

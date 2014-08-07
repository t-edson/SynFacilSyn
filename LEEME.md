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

Para más información, revisar la documentación.
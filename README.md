SynFacilSyn 1.16
================

Scriptable Highlighter for SynEdit Component of Lazarus 

![SynFacilCompletion](http://blog.pucp.edu.pe/blog/tito/wp-content/uploads/sites/610/1969/12/synfacilsyn1.png "Título de la imagen")

This highlighter is similar to the SynAnySyn of Lazarus, but it's much more faster, efficient and more configurable.

It can be used too, like a full lexical analyzer that can be configured to handle a variety of programming languages.

The highlighter TSynFacilSyn can read a complete syntax from an external XML file.

Features

•	Configurable. Can highlight words of a SynEdit control, using an external XML file, or using code.

•	It's fast and Light. It's optimized on speed to be comparable to a hard coded highlighter.

•	It's easy to configure the more common elements of a language, like identifiers, strings, numbers, and comments.

•	It's based on tokens and attributes.  Each kind of token contains a single attribute.

•	It's possible to define the characters that are valid for identifiers. So it can be adapted to the specific definition of each language.

•	It can manage subsets of identifiers (keywords, variables, ..) and subsets of symbols (operators, separators, etc).

•	It can define multiline elements like strings and comments.

•	It can define new tokens using pre-defined tokens, like <<HEREDOC elements.

•	Includes the property “CaseSensitive”, to compare the Case of chars.

•	It can define blocks of code folding. Includes several options to suit most programming languages.

•	It can define syntax blocks (with or without folding) and can paint the background of the blocks.

•	The XML file admits complete and simplified forms of definitions.

•	It includes several predefined attributes, but it can be defined more dynamically.

•	It can use basic Regex for the token definition.

•	Includes a script language to create complex definitions of tokens.

Using on a program.

This highlighter, is contained on two files: "SynFacilHighlighter.pas" and "SynFacilBasic.pas". You should copy them to the folder where the project is working, or on your personal units path.

Once copied, it must be included the unit "SynFacilHighlighter" in the USES statement of the units who are going to work with the highlighter. 

Then it's necessary to create an object of the class TSynFacilSyn, and assign it to the SynEdit editor:

```
uses  ... , SynFacilHighlighter;

var
    hlt : TSynFacilSyn;

  ...
  
  hlt := TSynFacilSyn.Create(self); 
  editor.Highlighter := hlt;
  hlt.LoadFromFile('SynPHP.xml');   //load the syntax file
  ...
  
  htl.Free; 
```

To use the highlighter, it's necessary first, to have the syntax configurated on the XML file or by code. 

One simple XML syntax file could be:

```
<Language name=”simple”>
  <Keywords> 
and echo else exit for if 
 </Keywords>
</Language>
```

For more information, see the documentation.

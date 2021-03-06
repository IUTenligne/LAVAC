{ Parsed from Webkit.framework DOMHTMLTableSectionElement.h }

{$ifdef TYPES}
{$ifndef DOMHTMLTABLESECTIONELEMENT_PAS_T}
{$define DOMHTMLTABLESECTIONELEMENT_PAS_T}

{$endif}
{$endif}

{$ifdef RECORDS}
{$ifndef DOMHTMLTABLESECTIONELEMENT_PAS_R}
{$define DOMHTMLTABLESECTIONELEMENT_PAS_R}

{$endif}
{$endif}

{$ifdef FUNCTIONS}
{$ifndef DOMHTMLTABLESECTIONELEMENT_PAS_F}
{$define DOMHTMLTABLESECTIONELEMENT_PAS_F}

{$endif}
{$endif}

{$ifdef EXTERNAL_SYMBOLS}
{$ifndef DOMHTMLTABLESECTIONELEMENT_PAS_S}
{$define DOMHTMLTABLESECTIONELEMENT_PAS_S}

{$endif}
{$endif}

{$ifdef FORWARD}
  DOMHTMLTableSectionElement = objcclass;
  DOMHTMLTableSectionElementPointer = ^DOMHTMLTableSectionElement;
  DOMHTMLTableSectionElementPtr = DOMHTMLTableSectionElementPointer;

{$endif}

{$ifdef CLASSES}
{$ifndef DOMHTMLTABLESECTIONELEMENT_PAS_C}
{$define DOMHTMLTABLESECTIONELEMENT_PAS_C}

{ DOMHTMLTableSectionElement }
  DOMHTMLTableSectionElement = objcclass external (DOMHTMLElement)
    
  public
    procedure setAlign (newValue: NSString); message 'setAlign:';
    function align: NSString; message 'align';
    procedure setCh (newValue: NSString); message 'setCh:';
    function ch: NSString; message 'ch';
    procedure setChOff (newValue: NSString); message 'setChOff:';
    function chOff: NSString; message 'chOff';
    procedure setVAlign (newValue: NSString); message 'setVAlign:';
    function vAlign: NSString; message 'vAlign';
    function rows: DOMHTMLCollection; message 'rows';
    function insertRow(index: cint): DOMHTMLElement; message 'insertRow:';
    procedure deleteRow(index: cint); message 'deleteRow:';
  end;

{$endif}
{$endif}

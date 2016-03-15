{ $Id: qtwscontrols.pp 30105 2011-04-01 08:33:48Z juha $}
{
 *****************************************************************************
 *                              QtWSControls.pp                              * 
 *                              ---------------                              * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    * 
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit QtWSControls;

{$mode objfpc}{$H+}

interface

{$I qtdefines.inc}

uses
  // Bindings
  qt4,
  qtwidgets, qtobjects, qtproc, qtint,
  // LCL
  SysUtils, Classes, Types, Controls, LCLType, LCLProc, Forms, Graphics,
  StdCtrls,
  // Widgetset
  InterfaceBase, WSProc, WSControls, WSLCLClasses;

type

  { TQtWSDragImageList }

  TQtWSDragImageList = class(TWSDragImageList)
  published
    class function BeginDrag(const ADragImageList: TDragImageList; Window: HWND; AIndex, X, Y: Integer): Boolean; override;
    class function DragMove(const ADragImageList: TDragImageList; X, Y: Integer): Boolean; override;
    class procedure EndDrag(const ADragImageList: TDragImageList); override;
    class function HideDragImage(const ADragImageList: TDragImageList;
      ALockedWindow: HWND; DoUnLock: Boolean): Boolean; override;
    class function ShowDragImage(const ADragImageList: TDragImageList;
      ALockedWindow: HWND; X, Y: Integer; DoLock: Boolean): Boolean; override;
  end;

  { TQtWSControl }

  TQtWSControl = class(TWSControl)
  published
  end;

  { TQtWSWinControl }

  TQtWSWinControl = class(TWSWinControl)
  published
    class function  CanFocus(const AWinControl: TWinControl): Boolean; override;
    class function  CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLIntfHandle; override;
    class procedure DestroyHandle(const AWinControl: TWinControl); override;
    class procedure Invalidate(const AWinControl: TWinControl); override;
    class procedure AddControl(const AControl: TControl); override;
    class function  GetClientBounds(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class function  GetClientRect(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class function GetDesignInteractive(const AWinControl: TWinControl; AClientPos: TPoint): Boolean; override;

    class procedure SetBiDiMode(const AWinControl: TWinControl; UseRightToLeftAlign, UseRightToLeftReading, UseRightToLeftScrollBar : Boolean); override;
    class procedure SetBounds(const AWinControl: TWinControl; const ALeft, ATop, AWidth, AHeight: Integer); override;
    class procedure SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle); override;
    class procedure SetPos(const AWinControl: TWinControl; const ALeft, ATop: Integer); override;
    class procedure SetSize(const AWinControl: TWinControl; const AWidth, AHeight: Integer); override;
    class procedure ShowHide(const AWinControl: TWinControl); override; //TODO: rename to SetVisible(control, visible)
    class procedure SetColor(const AWinControl: TWinControl); override;
    class procedure SetCursor(const AWinControl: TWinControl; const ACursor: HCURSOR); override;
    class procedure SetFont(const AWinControl: TWinControl; const AFont: TFont); override;
    class procedure SetShape(const AWinControl: TWinControl; const AShape: HBITMAP); override;

    class procedure GetPreferredSize(const AWinControl: TWinControl;
      var PreferredWidth, PreferredHeight: integer; WithThemeSpace: Boolean); override;

    class function  GetText(const AWinControl: TWinControl; var AText: String): Boolean; override;
    class procedure SetText(const AWinControl: TWinControl; const AText: string); override;

    class procedure SetChildZPosition(const AWinControl, AChild: TWinControl;
                                      const AOldPos, ANewPos: Integer;
                                      const AChildren: TFPList); override;

    class procedure ConstraintsChange(const AWinControl: TWinControl); override;
    class procedure PaintTo(const AWinControl: TWinControl; ADC: HDC; X, Y: Integer); override;
  end;

  { TQtWSGraphicControl }

  TQtWSGraphicControl = class(TWSGraphicControl)
  published
  end;

  { TQtWSCustomControl }

  TQtWSCustomControl = class(TWSCustomControl)
  published
    class function CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLIntfHandle; override;
  end;

  { TQtWSImageList }

  TQtWSImageList = class(TWSImageList)
  published
  end;

const
  TBorderStyleToQtFrameShapeMap: array[TBorderStyle] of QFrameShape =
  (
 { bsNone   } QFrameNoFrame,
 { bsSingle } QFrameStyledPanel
  );
  TLayoutDirectionMap: array[Boolean] of QtLayoutDirection =
  (
 { False } QtLeftToRight,
 { True  } QtRightToLeft
  );
implementation

{------------------------------------------------------------------------------
  Method: TQtWSCustomControl.CreateHandle
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class function TQtWSCustomControl.CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLIntfHandle;
var
  QtCustomControl: TQtCustomControl;
begin
  {$ifdef VerboseQt}
    WriteLn('> TQtWSCustomControl.CreateHandle for ',dbgsname(AWinControl));
  {$endif}

  QtCustomControl := TQtCustomControl.Create(AWinControl, AParams);
  QtCustomControl.setFrameShape(TBorderStyleToQtFrameShapeMap[TCustomControl(AWinControl).BorderStyle]);
  QtCustomControl.viewportNeeded;
  QtCustomControl.AttachEvents;
  Result := TLCLIntfHandle(QtCustomControl);

  {$ifdef VerboseQt}
    WriteLn('< TQtWSCustomControl.CreateHandle for ',dbgsname(AWinControl),' Result: ', dbgHex(Result));
  {$endif}
end;

{------------------------------------------------------------------------------
  Function: TQtWSWinControl.CanFocus
  Params:  TWinControl
  Returns: Boolean
 ------------------------------------------------------------------------------}
class function TQtWSWinControl.CanFocus(const AWinControl: TWinControl): Boolean;
var
  Widget: TQtWidget;
begin
  if AWinControl.HandleAllocated then
  begin
    Widget := TQtWidget(AWinControl.Handle);
    Result := (Widget.getFocusPolicy <> QtNoFocus);
  end else
    Result := False;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.CreateHandle
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class function TQtWSWinControl.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLIntfHandle;
var
  QtWidget: TQtWidget;
begin

  {$ifdef VerboseQt}
    WriteLn('> TQtWSWinControl.CreateHandle for ',dbgsname(AWinControl));
  {$endif}
  QtWidget := TQtWidget.Create(AWinControl, AParams);

  QtWidget.AttachEvents;

  // Finalization

  Result := TLCLIntfHandle(QtWidget);

  {$ifdef VerboseQt}
    WriteLn('< TQtWSWinControl.CreateHandle for ',dbgsname(AWinControl),' Result: ', dbgHex(Result));
  {$endif}
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.DestroyHandle
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.DestroyHandle(const AWinControl: TWinControl);
begin
  TQtWidget(AWinControl.Handle).Release;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.Invalidate
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.Invalidate(const AWinControl: TWinControl);
begin
  if not WSCheckHandleAllocated(AWinControl, 'Invalidate') then
    Exit;

  TQtWidget(AWinControl.Handle).Update;
end;

class procedure TQtWSWinControl.AddControl(const AControl: TControl);
var
  Child: TQtWidget;
  Parent: TQtWidget;
begin
  if (AControl is TWinControl) and (TWinControl(AControl).HandleAllocated) then
  begin
    Child := TQtWidget(TWinControl(AControl).Handle);
    Parent := TQtWidget(AControl.Parent.Handle);
    if Child.getParent <> Parent.GetContainerWidget then
    begin
      Child.BeginUpdate;
      Child.setParent(Parent.GetContainerWidget);
      Child.EndUpdate;
    end;
  end;
end;

class function TQtWSWinControl.GetClientBounds(const AWincontrol: TWinControl;
  var ARect: TRect): Boolean;
begin
  Result := False;
  if not WSCheckHandleAllocated(AWinControl, 'GetClientBounds') then
    Exit;

  ARect := TQtWidget(AWinControl.Handle).getClientBounds;
  Result := True;
end;

class function TQtWSWinControl.GetClientRect(const AWincontrol: TWinControl;
  var ARect: TRect): Boolean;
begin
  Result := False;
  if not WSCheckHandleAllocated(AWinControl, 'GetClientRect') then
    Exit;
    
  ARect := TQtWidget(AWinControl.Handle).getClientBounds;
  OffsetRect(ARect, -ARect.Left, -ARect.Top);
  Result := True;
end;

class function TQtWSWinControl.GetDesignInteractive(
  const AWinControl: TWinControl; AClientPos: TPoint): Boolean;
begin
  Result := False;
  if not WSCheckHandleAllocated(AWinControl, 'GetDesignInteractive') then
    Exit;
end;

class procedure TQtWSWinControl.SetBiDiMode(const AWinControl : TWinControl;
  UseRightToLeftAlign, UseRightToLeftReading, UseRightToLeftScrollBar : Boolean
  );
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetBiDiMode') then
    Exit;

  TQtWidget(AWinControl.Handle).setLayoutDirection(TLayoutDirectionMap[UseRightToLeftAlign]);
end;

class procedure TQtWSWinControl.GetPreferredSize(const AWinControl: TWinControl;
  var PreferredWidth, PreferredHeight: integer; WithThemeSpace: Boolean);
begin
  if AWinControl.HandleAllocated then
    TQtWidget(AWinControl.Handle).PreferredSize(PreferredWidth,
      PreferredHeight, WithThemeSpace);
end;

class function TQtWSWinControl.GetText(const AWinControl: TWinControl;
  var AText: String): Boolean;
begin
  Result := False;
  if not WSCheckHandleAllocated(AWincontrol, 'GetText') then
    Exit;

  Result := not TQtWidget(AWinControl.Handle).getTextStatic;
  if Result then
    AText := UTF16ToUTF8(TQtWidget(AWinControl.Handle).getText);
end;

class procedure TQtWSWinControl.SetText(const AWinControl: TWinControl;
  const AText: string);
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetText') then
    Exit;
  TQtWidget(AWinControl.Handle).BeginUpdate;
  TQtWidget(AWinControl.Handle).setText(GetUtf8String(AText));
  TQtWidget(AWinControl.Handle).EndUpdate;
end;

class procedure TQtWSWinControl.SetChildZPosition(const AWinControl,
                AChild: TWinControl; const AOldPos, ANewPos: Integer; const AChildren: TFPList);
var
  n: Integer;
  Child: TWinControl;
  Reorder: TFPList;
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetChildZPosition') then
    Exit;
  if not WSCheckHandleAllocated(AChild, 'SetChildZPosition (child)') then
    Exit;

  if (ANewPos <= 0) or (ANewPos >= AChildren.Count - 1) then
  begin
    // simple
    if ANewPos <= 0 then // bottom
      TQtWidget(AChild.Handle).lowerWidget
    else
      TQtWidget(AChild.Handle).raiseWidget;
  end else
  begin
    if (ANewPos >= 0) and (ANewPos < AChildren.Count -1) then
    begin
      Reorder := TFPList.Create;
      for n := AChildren.Count - 1 downto 0 do
        Reorder.Add(AChildren[n]);
      Child := TWinControl(Reorder[ANewPos + 1]);
      if Child.HandleAllocated then
        TQtWidget(AChild.Handle).stackUnder(TQtWidget(Child.Handle).Widget)
      else
        TQtWidget(AChild.Handle).lowerWidget;
      Reorder.Free;
    end;
  end;
end;

class procedure TQtWSWinControl.ConstraintsChange(const AWinControl: TWinControl);
const
  QtMaxContraint = $FFFFFF;
var
  Widget: TQtWidget;
  MaxW, MaxH: Integer;
begin
  if not WSCheckHandleAllocated(AWincontrol, 'ConstraintsChange') then
    Exit;
    
  Widget := TQtWidget(AWinControl.Handle);
  with AWinControl do
  begin
    Widget.setMinimumSize(Constraints.MinWidth, Constraints.MinHeight);
    if Constraints.MaxWidth = 0 then
      MaxW := QtMaxContraint
    else
      MaxW := Constraints.MaxWidth;
    if Constraints.MaxHeight = 0 then
      MaxH := QtMaxContraint
    else
      MaxH := Constraints.MaxHeight;
    Widget.setMaximumSize(MaxW, MaxH);
  end;
end;

class procedure TQtWSWinControl.PaintTo(const AWinControl: TWinControl;
  ADC: HDC; X, Y: Integer);
var
  Context: TQtDeviceContext absolute ADC;
  Widget: TQtWidget;
  Pixmap: TQtPixmap;
  DCSize: TSize;
  APoint: TQtPoint;
  ARect, GRect: TRect;
begin
  if not WSCheckHandleAllocated(AWincontrol, 'PaintTo') or (ADC = 0) then
    Exit;

  Widget := TQtWidget(AWinControl.Handle);
  ARect := Widget.getFrameGeometry;
  GRect := Widget.getGeometry;
  with DCSize, ARect do
  begin
    cx := Right - Left;
    cy := Bottom - Top;
  end;
  Pixmap := TQtPixmap.Create(@DCSize);
  OffsetRect(GRect, -ARect.Left, -ARect.Top);
  Pixmap.grabWidget(Widget.Widget, 0, 0);
  APoint := QtPoint(X + GRect.Left, Y + GRect.Top);
  ARect := Rect(0, 0, Pixmap.getWidth, Pixmap.getHeight);
  Context.drawPixmap(@APoint, Pixmap.Handle, @ARect);
  Pixmap.Free;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetBounds
  Params:  AWinControl - the calling object
           ALeft, ATop - Position
           AWidth, AHeight - Size
  Returns: Nothing

  Sets the position and size of a widget
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetBounds(const AWinControl: TWinControl;
  const ALeft, ATop, AWidth, AHeight: Integer);
var
  Pt: TQtPoint;
  R: TRect;
  Box: TQtWidget;
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetBounds') then
    Exit;
  R := Rect(ALeft, ATop, AWidth, AHeight);

  Box := nil;
  if Assigned(AWinControl.Parent) and
    AWinControl.Parent.HandleAllocated then
      Box := TQtWidget(AWinControl.Parent.Handle);

  if Assigned(Box) and
    (Box.ChildOfComplexWidget = ccwScrollingWinControl) then
  begin
    Pt := TQtWidget(AWinControl.Handle).getPos;

    R := Rect(ALeft - TQtCustomControl(Box).horizontalScrollBar.getValue,
      ATop - TQtCustomControl(Box).verticalScrollBar.getValue, AWidth, AHeight);
  end;

  TQtWidget(AWinControl.Handle).BeginUpdate;
  with R do
  begin
    TQtWidget(AWinControl.Handle).move(Left, Top);
    TQtWidget(AWinControl.Handle).resize(Right, Bottom);
  end;
  TQtWidget(AWinControl.Handle).EndUpdate;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetPos
  Params:  AWinControl - the calling object
           ALeft, ATop - Position
  Returns: Nothing

  Sets the position of a widget
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetPos(const AWinControl: TWinControl;
  const ALeft, ATop: Integer);
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetPos') then
    Exit;

  TQtWidget(AWinControl.Handle).BeginUpdate;
  TQtWidget(AWinControl.Handle).move(ALeft, ATop);
  TQtWidget(AWinControl.Handle).EndUpdate;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetSize
  Params:  AWinControl     - the calling object
           AWidth, AHeight - Size
  Returns: Nothing

  Sets the size of a widget
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetSize(const AWinControl: TWinControl;
  const AWidth, AHeight: Integer);
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetSize') then
    Exit;
  TQtWidget(AWinControl.Handle).BeginUpdate;
  TQtWidget(AWinControl.Handle).resize(AWidth, AHeight);
  TQtWidget(AWinControl.Handle).EndUpdate;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.ShowHide
  Params:  AWinControl     - the calling object

  Returns: Nothing

  Shows or hides a widget.
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.ShowHide(const AWinControl: TWinControl);
var
  Widget: TQtWidget;
begin
  if not WSCheckHandleAllocated(AWincontrol, 'ShowHide') then
    Exit;

  Widget := TQtWidget(AWinControl.Handle);

  Widget.BeginUpdate;
  Widget.setVisible(AWinControl.HandleObjectShouldBeVisible);
  Widget.EndUpdate;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetColor
  Params:  AWinControl     - the calling object
  Returns: Nothing

  Sets the color of the widget.
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetColor(const AWinControl: TWinControl);
var
  QColor: TQColor;
  Color: TColor;
  QtWidget: TQtWidget;
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetColor') then
    Exit;

  if AWinControl.Color = CLR_INVALID then exit;

  // Get the color numeric value (system colors are mapped to numeric colors depending on the widget style)
  if AWinControl.Color = clDefault then
  begin
    QtWidget := TQtWidget(AWinControl.Handle);
    QtWidget.BeginUpdate;
    QtWidget.SetDefaultColor(dctBrush);
    QtWidget.EndUpdate;
  end
  else
  begin
    Color := ColorToRGB(AWinControl.Color);

    // Fill QColor
    QColor_fromRgb(@QColor,Red(Color),Green(Color),Blue(Color));

    // Set color of the widget to QColor
    QtWidget := TQtWidget(AWinControl.Handle);
    QtWidget.BeginUpdate;
    QtWidget.SetColor(@QColor);
    QtWidget.EndUpdate;
  end;
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetCursor
  Params:  AWinControl     - the calling object
  Returns: Nothing

  Sets the cursor of the widget.
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetCursor(const AWinControl: TWinControl; const ACursor: HCURSOR);
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetCursor') then
    Exit;
  if ACursor <> 0 then
    TQtWidget(AWinControl.Handle).SetCursor(TQtCursor(ACursor).Handle)
  else
    TQtWidget(AWinControl.Handle).SetCursor(nil);
end;

{------------------------------------------------------------------------------
  Method: TQtWSWinControl.SetFont
  Params:  AWinControl - the calling object, AFont - object font
  Returns: Nothing

  Sets the font of the widget.
 ------------------------------------------------------------------------------}
class procedure TQtWSWinControl.SetFont(const AWinControl: TWinControl; const AFont: TFont);
var
  QtWidget: TQtWidget;
  QColor: TQColor;
  Color: TColor;
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetFont') then
    Exit;

  QtWidget := TQtWidget(AWinControl.Handle);
  QtWidget.setFont(TQtFont(AFont.Reference.Handle).Widget);

  if AFont.Color = CLR_INVALID then exit;

  if AFont.Color = clDefault then
  begin
    QtWidget.BeginUpdate;
    QtWidget.SetDefaultColor(dctFont);
    QtWidget.EndUpdate;
  end
  else
  begin
    Color := ColorToRGB(AFont.Color);
    QColor_fromRgb(@QColor,Red(Color),Green(Color),Blue(Color));
    QtWidget.BeginUpdate;
    QtWidget.SetTextColor(@QColor);
    QtWidget.EndUpdate;
  end;
end;

class procedure TQtWSWinControl.SetShape(const AWinControl: TWinControl;
  const AShape: HBITMAP);
var
  Widget: TQtWidget;
  Shape: TQtImage;
  AMask: QBitmapH;
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetShape') then
    Exit;
  Widget := TQtWidget(AWinControl.Handle);

  if AShape <> 0 then
  begin
    Shape := TQtImage(AShape);
    // invert white/black
    Shape.invertPixels;
    AMask := Shape.AsBitmap;
    Widget.setMask(AMask);
    QBitmap_destroy(AMask);
    // invert back
    Shape.invertPixels;
  end
  else
    Widget.clearMask;
end;

class procedure TQtWSWinControl.SetBorderStyle(const AWinControl: TWinControl;
  const ABorderStyle: TBorderStyle);
var
  Widget: TQtWidget;
  QtEdit: IQtEdit;
begin
  if not WSCheckHandleAllocated(AWinControl, 'SetBorderStyle') then
    Exit;
    
  Widget := TQtWidget(AWinControl.Handle);
  QtEdit := nil;
  if Widget is TQtFrame then
    TQtFrame(Widget).setFrameShape(TBorderStyleToQtFrameShapeMap[ABorderStyle])
  else
  if Supports(Widget, IQtEdit, QtEdit) then
    QtEdit.setBorder(ABorderStyle = bsSingle);
end;

{ TQtWSDragImageList }

class function TQtWSDragImageList.BeginDrag(
  const ADragImageList: TDragImageList; Window: HWND; AIndex, X, Y: Integer): Boolean;
var
  ABitmap: TBitmap;
begin
  ABitmap := TBitmap.Create;
  ADragImageList.GetBitmap(AIndex, ABitmap);

  if (ABitmap.Handle = 0) or (ABitmap.Width = 0) or (ABitmap.Height = 0) then
  begin
    Result := False;
    Exit;
  end;

  Result := TQtWidgetset(Widgetset).DragImageList_BeginDrag(TQtImage(ABitmap.Handle).Handle, ADragImageList.DragHotSpot);
  if Result then
    TQtWidgetset(Widgetset).DragImageList_DragMove(X, Y);
  ABitmap.Free;
end;

class function TQtWSDragImageList.DragMove(
  const ADragImageList: TDragImageList; X, Y: Integer): Boolean;
begin
  Result := TQtWidgetset(Widgetset).DragImageList_DragMove(X, Y);
end;

class procedure TQtWSDragImageList.EndDrag(const ADragImageList: TDragImageList
  );
begin
  TQtWidgetset(Widgetset).DragImageList_EndDrag;
end;

class function TQtWSDragImageList.HideDragImage(
  const ADragImageList: TDragImageList; ALockedWindow: HWND; DoUnLock: Boolean
  ): Boolean;
begin
  Result := True;
  if DoUnlock then
  begin
    TQtWidgetset(Widgetset).DragImageLock := False;
    Result := TQtWidgetset(Widgetset).DragImageList_SetVisible(False);
  end;
end;

class function TQtWSDragImageList.ShowDragImage(
  const ADragImageList: TDragImageList; ALockedWindow: HWND; X, Y: Integer;
  DoLock: Boolean): Boolean;
begin
  Result := TQtWidgetset(Widgetset).DragImageLock;
  if not DoLock then
  begin
    if not Result then
      Result := TQtWidgetset(Widgetset).DragImageList_SetVisible(True);
  end else
  begin
    TQtWidgetset(Widgetset).DragImageLock := True;
    Result := TQtWidgetset(Widgetset).DragImageList_DragMove(X, Y) and TQtWidgetset(Widgetset).DragImageList_SetVisible(True);
  end;
end;

end.

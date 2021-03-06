{
    This file is part of the PTCPas framebuffer library
    Copyright (C) 2001-2010 Nikolay Nikolov (nickysn@users.sourceforge.net)
    Original C++ version by Christian Nentwich (c.nentwich@cs.ucl.ac.uk)

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version
    with the following modification:

    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent modules,and
    to copy and distribute the resulting executable under terms of your choice,
    provided that you also meet, for each linked independent module, the terms
    and conditions of the license of that module. An independent module is a
    module which is not derived from or based on this library. If you modify
    this library, you may extend this exception to your version of the library,
    but you are not obligated to do so. If you do not wish to do so, delete this
    exception statement from your version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{$IFDEF ENABLE_X11_EXTENSION_XF86DGA1}

type
  TX11DGA1Display = class(TX11Display)
  private
    FModeInfo: PPXF86VidModeModeInfo;
    FModeInfoNum: Integer;
    FPreviousMode: Integer;

    FDGAAddr: PByte;
    FDGALineWidth: Integer;
    FDGABankSize: Integer;
    FDGAMemSize: Integer;
    FDGAWidth, FDGAHeight: Integer;

    { Coordinates of upper left frame corner }
    FDestX, FDestY: Integer;

    FInDirect, FInMode: Boolean;

    function NextEvent(var AEvent: TPTCEvent; AWait: Boolean; const AEventMask: TPTCEventMask): Boolean; override;
    function PeekEvent(AWait: Boolean; const AEventMask: TPTCEventMask): TPTCEvent; override;

    procedure HandleEvents;
  public
    constructor Create(ADisplay: PDisplay; AScreen: Integer; const AFlags: TX11Flags); override;
    destructor Destroy; override;

    procedure Open(ATitle: string; AWidth, AHeight: Integer; const AFormat: TPTCFormat); override;
    procedure Open(AWindow: TWindow; const AFormat: TPTCFormat); override;
    procedure Open(AWindow: TWindow; const AFormat: TPTCFormat; AX, AY, AWidth, AHeight: Integer); override;
    procedure Close; override;
    procedure GetModes(var AModes: TPTCModeDynArray); override;
    procedure Update; override;
    procedure Update(const AArea: TPTCArea); override;
    function Lock: Pointer; override;
    procedure Unlock; override;
    procedure Palette(const APalette: TPTCPalette); override;
    function GetPitch: Integer; override;
    function GetX11Window: TWindow; override;
    function IsFullScreen: Boolean; override;
    procedure SetCursor(AVisible: Boolean); override;
    procedure SetMouseGrab(AGrabMouse: Boolean); override;
  end;

{$ENDIF ENABLE_X11_EXTENSION_XF86DGA1}

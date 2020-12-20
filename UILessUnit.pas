unit UILessUnit;

interface
uses
     Winapi.Windows,
     System.Classes,
     ActiveX,
     MSHTML;

const
  DISPID_AMBIENT_DLCONTROL = (-5512);

type
  TUILess = class(TComponent, IUnknown, IDispatch, IOleClientSite)
    protected
    // IDispatch
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
    // IOleClientSite
    function SaveObject: HRESULT; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HRESULT; stdcall;
    function GetContainer(out container: IOleContainer): HRESULT; stdcall;
    function ShowObject: HRESULT; stdcall;
    function OnShowWindow(fShow: BOOL): HRESULT; stdcall;
    function RequestNewObjectLayout: HRESULT; stdcall;
  end;

implementation

function TUILess.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
const
  DLCTL_NO_SCRIPTS = $00000080;
  DLCTL_NO_JAVA = $00000100;
  DLCTL_NO_RUNACTIVEXCTLS = $00000200;
  DLCTL_NO_DLACTIVEXCTLS = $00000400;
  DLCTL_DOWNLOADONLY = $00000800;
  DLCTL_NO_FRAMEDOWNLOAD = $00001000;
  DLCTL_NO_BEHAVIORS = $00008000;
  DLCTL_SILENT = $40000000;
var
  I: Integer;
begin
  if DISPID_AMBIENT_DLCONTROL = DispID then
  begin
    I := DLCTL_DOWNLOADONLY + DLCTL_NO_SCRIPTS +
      DLCTL_NO_JAVA + DLCTL_NO_DLACTIVEXCTLS +
      DLCTL_NO_RUNACTIVEXCTLS + DLCTL_NO_BEHAVIORS +
      DLCTL_SILENT + DLCTL_NO_FRAMEDOWNLOAD;
    PVariant(VarResult)^ := I;
    Result := S_OK;
  end
  else
    Result := DISP_E_MEMBERNOTFOUND;
end;

function TUILess.SaveObject: HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TUILess.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TUILess.GetContainer(out container: IOleContainer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TUILess.ShowObject: HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TUILess.OnShowWindow(fShow: BOOL): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TUILess.RequestNewObjectLayout: HRESULT;
begin
  Result := E_NOTIMPL;
end;

end.

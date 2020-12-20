unit CRT;

interface

procedure ClrScr;
procedure SetAttr(attr: word);
function GetAttr: word;
procedure GotoXY(aX, aY: integer); { zero-based coords }
function WhereX: integer;
function WhereY: integer;

implementation

uses Windows;

var
  UpperLeft: TCoord = (X:0; Y:0);
  hCon: integer;

procedure GotoXY(aX, aY: integer);
var
  aCoord: TCoord;
begin
  aCoord.x:=aX;
  aCoord.y:=aY;
  SetConsoleCursorPosition(hCon,aCoord);
end;

procedure SetAttr(attr: word);
begin
  SetConsoleTextAttribute(hCon,attr);
end;

function WhereX: integer;
var
  ScrBufInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hCon,ScrBufInfo);
  Result:=ScrBufInfo.dwCursorPosition.x;
end;

function WhereY: integer;
var
  ScrBufInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hCon,ScrBufInfo);
  Result:=ScrBufInfo.dwCursorPosition.y;
end;

function GetAttr: word;
var
  ScrBufInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hCon,ScrBufInfo);
  Result:=ScrBufInfo.wAttributes;
end;

procedure ClrScr;
var
  fill: DWORD;
  ScrBufInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hCon,ScrBufInfo);
  fill:=ScrBufInfo.dwSize.x*ScrBufInfo.dwSize.y;
  FillConsoleOutputCharacter(hCon,' ',fill,UpperLeft,fill);
  FillConsoleOutputAttribute(hCon,ScrBufInfo.wAttributes, fill,
  UpperLeft, fill);
  GotoXY(0,0);
end;

initialization
  hCon := GetStdHandle(STD_OUTPUT_HANDLE);

end.

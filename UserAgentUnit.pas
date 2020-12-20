unit UserAgentUnit; //HTTP UserAgent generator

interface

uses
    System.Generics.Collections,
    StrUtils,SysUtils,Classes;

function GenerateUserAgent(const BrowserType :string = ''):string;
function SpinText(const LIN:string):string;

implementation


function GenerateUserAgent(const BrowserType :string = ''):string;
const
    // ‘ормируем набор версий операционной системы Windows
    // 6.0 Windows Vista
    // 6.1 Windows 7
    // 6.2 Windows 8
    // 6.3 Windows 8.1
    // 10.0 Windows 10
    WINOS = '{6.0|6.1|6.2|6.3|10.0}';
    PLATFORMAPP = '{; WOW64|; Win64; x64}';
    BROWSERS = '{Firefox|Chrome|Internet Explorer|Edge}';
    //FireFox versions
    //'57', '20171112125346'
    //'56', '20171024165158'  // 56.0.2
    //'56', '20171002220106'  // 56.0.1
    //'56', '20170926190823'
    //'55', '20170802111421'
    //'54', '20170608105825'
    //'53', '20170413192749'
    //'52', '20171206101620'  // 52.5.2
    //'52', '20171107091003'  // 52.5.0
    //'52', '20170316213829'
    //'51', '20170125094131'
    //'50', '20161104212021'
    //'49', '20161019084923'
    FIREFOXVERSIONS = '{49|50|51|52|53|54|55|56|57}';
    CHROMEVERSIONS = '{' +
                     '55.0.2883.87|' +
                     '56.0.2924.87|' +
                     '57.0.2987.133|' +
                     '58.0.3029.110|' +
                     '59.0.3071.115|' +
                     '60.0.3112.113|' +
                     '60.0.3112.90|' +
                     '61.0.3163.100|' +
                     '62.0.3202.89|' +
                     '63.0.3239.84|' +
                     '64.0.3282.21|' +
                     '64.0.3282.186|' +
                     '65.0.3325.181|' +
                     '66.0.3359.181' +
                     '}';

    IEVERSIONS = '{11|10|9}';
    EDGEVERSIONS = '{16.16299|15.15063|14.14393}';
var
    IEversionsDictionary: TDictionary<String, String>;
    bType: string;
    WinVer, PlatformVer,Version: string;
begin
    Result := 'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:59.0) Gecko/20100101 Firefox/59.0';
    if BrowserType = '' then bType := SpinText(BROWSERS) else bType := BrowserType;
    WinVer := SpinText(WINOS);
    PlatformVer := SpinText(PLATFORMAPP);

    if bType = 'Firefox' then
    begin
        Version := SpinText(FIREFOXVERSIONS);
        Result := Format('Mozilla/5.0 (Windows NT %0:s%1:s; rv:%2:s.0) Gecko/20100101 Firefox/%2:s.0', [WinVer, PlatformVer, version]);
        exit;
    end;

    if bType = 'Chrome' then
    begin
        Version := SpinText(CHROMEVERSIONS);
        Result := Format('Mozilla/5.0 (Windows NT %0:s%1:s) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%2:s Safari/537.36', [WinVer, PlatformVer, version]);
        exit;
    end;

    if bType = 'Internet Explorer' then
    begin
        Version := SpinText(IEVERSIONS);
        IEversionsDictionary := TDictionary<String, String>.Create;
        IEversionsDictionary.Add('11', '7.0');
        IEversionsDictionary.Add('10', '6.0');
        IEversionsDictionary.Add('9', '5.0');
        if WinVer = '10.0' then
            Result := Format('Mozilla/5.0 (Windows NT %0:s%1:s; Trident/%2:s.0; rv:11.0) like Gecko', [WinVer, PlatformVer, IEversionsDictionary['11']])
        else
            Result := Format('Mozilla/5.0 (compatible; MSIE %0:s.0; Windows NT %1:s%2:s; Trident/%3:s.0)', [version, WinVer, PlatformVer, IEversionsDictionary[Version]]);
        IEversionsDictionary.Clear;
        IEversionsDictionary.Free;
        exit;
    end;

    if bType = 'Edge' then
    begin
        WinVer := '10.0';
        Version := SpinText(EDGEVERSIONS);
        IEversionsDictionary := TDictionary<String, String>.Create;
        IEversionsDictionary.Add('16.16299', '58.0.3029.110');
        IEversionsDictionary.Add('15.15063', '52.0.2743.116');
        IEversionsDictionary.Add('14.14393', '51.0.2704.79');
        Result := Format('Mozilla/5.0 (Windows NT %0:s%1:s) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/%2:s Safari/537.36 Edge/%3:s', [WinVer, PlatformVer, IEversionsDictionary[Version], Version]);
        IEversionsDictionary.Clear;
        IEversionsDictionary.Free;
    end;

end;

function SpinText(const LIN:string):string;

var
  i: integer;
  PhraseCount, n, start, stop:integer;
  {index, }PhraseIndex:integer;
  line, Lineout:string;
  Phrases:array [0..100] of string;
  id,idref:string;
  SpinSets:TStringList;

begin
    Result := '';
    Randomize;
    SpinSets := TStringList.Create;
    //SpinSets.clear;
    Line:=LIN + '{|}';
    {copy all of the input text into a single string}
    Lineout:='';
    n:=1;
    repeat
        start:=n; {next start point for scanning the line}
        n:=posex('{',line,n); {find next phrase set}
        if n>0 then
        begin
            Lineout := Lineout + copy(line,start, n-start);
            start:=n+1; {update next word start position}
            PhraseCount:=0;
            stop:=posex('}',line,n);
            if stop>0 then
            begin  {found the closing bracket }
                id:='';
                idref:='';
                if line[start]='%' then
                begin {"id" specified for this spinset}
                    id:=line[start+1];
                    inc(start,2);
                end
                else if line[start]='&' then
                     begin {this is a reference to a previously defined spinset}
                         idref:=line[start+1];
                         inc(start,2);
                     end;
                while (n>0) and (n<stop) do
                begin {Loop looking for phrase dividers}
                    n := posex('|',line,start);
                    if (n=0) or (n>stop) then n:=stop; {didn't find one, use closing bracket as the last}
                    Phrases[PhraseCount]:=copy(line,start,n-start); {save the phrase}
                    inc(PhraseCount);
                    start:=n+1; {next start index is right after the divider or closing bracket}
                end;
                PhraseIndex := -1;
                if idref <> '' then
                begin {add the worded indexed by the referenced phrase's word index to the line}
                    phraseindex:=-1;
                    for i:=0 to spinsets.Count-1 do
                    begin
                        if spinsets[i][1]=idref then
                        begin
                            phraseindex:=strtoint(copy(spinsets[i],2,length(spinsets[i])-1));
                            break;
                        end;
                    end;
                    if phraseindex<0
                    then Result := ''; //showmessage('The referenced item  &'+idref + ' is undefined');
                end
                else
                begin {add a random phrase to the output}
                      {We have all the phrases, pick one randomly from those found}
                    if PhraseCount>1 then PhraseIndex:=random(PhraseCount)
                    {unles only one phrase found, select it half the time}
                    //else if (PhraseCount=1) then if (random(2)=1) then PhraseIndex:=0;//origin
                    else if (PhraseCount=1) then PhraseIndex:=0;
                end;
                    //If PhraseIndex>=0 then //origin
                if Phrases[PhraseIndex]<>'b' then lineout:=lineout+ Phrases[PhraseIndex];
                if id<>'' then
                begin
                    spinsets.add(id+ inttostr(PhraseIndex));
                end;
                n:=stop+1; {Update N just past the closing bracket}
            end
            else  //'No closing ''}'' for choices phrase set';
            begin
                Result := '';
                n:=0; {to stop the loop}
            end;
        end;
    until n=0;

    Result := lineout;
    SpinSets.Free;
end;

end.

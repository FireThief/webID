unit Tools;

interface

uses
    Definitions,
    RegularExpressions,
    IdURI,
    Winapi.Windows,
    System.Threading,
    System.Masks,
    System.Math,
    System.SysUtils,
    System.StrUtils,
    System.Classes,
    System.Character,
    //System.Types,
    Generics.Collections,
    Generics.Defaults,
    mAVLTree;

function LinesCount(const Filename: string): Integer;
function _GetFileSize(FileName: string): Int64;
function GetFileEnoding(const FileName: string): TEncoding;
procedure ReadCSVRecord(const Line: string; var Strings : TStringList{TStrings});
function IsAdditionalField(const InStr: string): boolean;
function ReadString(const InReader: TStreamReader; const ColCount: integer; var OutInputSL: TStringList): string;
function IsRightField(const InStr: string): boolean;
function DeleteBetween(const StartTag, EndTag, InStr: string): string;
function GetPercentage(const InText: string;
                       const InStrToFind: string;
                       var OutWordCount: integer): double;
function ExtractAreaCode(const InPhoneNumber: string): string;
function IsThereAnyExcludes(const exclArr: TArray<string>; const InText: string; var ExclVal: string;
                            const ExactMatch: boolean = false): boolean;
function FillTargetsArray(const inpSL: TStringList; var OutArray: TTargetsArr; var outTreshold: integer): string;

function ClearParsingResults(const InData: TArray<TJSONparsingResults>{TJSONresultsArray};
                             const excludesUrlArray, excludesNamesArray, excludesKeyArray: TArray<string>;
                             var ExcludedDomains: string): TArray<TJSONparsingResults>{TJSONresultsArray};

function CountPageScore(const InPage: string;
                        const InBingResponse: TBingResponse;
                        const InScoreArr: TTargetsArr): integer;
procedure SortArray(var A: TArray<TJSONparsingResults>{TJSONresultsArray}; n: Integer);

function CountURLScore(var JSONresults: TJSONparsingResults;
                        const InCompanyName: string;
                        const InScoreRec: TTargetsArr;
                        var IsSocialNw: boolean;
                        const pSimple: boolean): integer;

function CountNameScore(const InText, InStrToFind: string;
                        const InScoreRec: TTargetsArr): integer;                        

function ExtractDomain(const InURL: string; const AddProtocol: boolean = false): string;
procedure GetSocialNetworks(var InResponse: TBingResponse;
                            var InParsingRes: TJSONparsingResults; const InScore: integer);
function PrepareFileName(const InFileName: string): string;
function GetDomainName(url: string; const URLpattern: string): string;
procedure MarkDuplicatesInSearchResults(var A: TArray<TJSONparsingResults>; const LowBorder: integer = 0);
function ExtractSubParameter(const InValue, Delim: string): string;
function ExtractParameter(const InValue, Delim: string): string;
function CSVfromSL(const InSL: TStringList):string;
function SetQuotes(const InStr: string): string;
function SetQuotesI(const InValue: string): string;
function GetNsymbolsBeforeDelim(const N: integer; const InText, Delim: string): string;
function SearchStringsInText(const ValuesToSearch: TArray<string>;
                             const InText: string;
                             const CS: boolean = false): string;
function SearchStringsInText2(const ValuesToSearch: TArray<string>;
                              const InText: string;
                              const CS: boolean = false): TArray<TDomainRec>;
function ClearStr2(const InStr: string): string; overload;
function ClearStr2(const InStr: string; const A: array of string): string; overload;
function NormalizeString(const InText: string; const ToLower: boolean = false): string; overload;
function NormalizeString(const InText: string;
                         const A: array of string;
                         const ToLower: boolean = false): string; overload;

//---получение данных из дерева--------------------------------
function GetDataFromTree(const StringWithDelimiters: string;      //строка с исходными данными
                         const DataTree: TAVLtree;                //дерево - справочник
                         const Delimiter: string = ';'): string;  //раздедитель данных в строке
//---получение данных о городах и штатах из текста------------------------------
function GetStatesAndCitiesFromSnippet(const Response: TBingResponse;
                                       //const JsonResults: TJSONparsingResults;
                                       const InText: string;
                                       const CitiesArray: TArray<string>;
                                       const CityTree: TAVLTree;
                                       const StatesFullNameArray: TArray<string>;
                                       const StatesAbbrNameArray: TArray<string>;
                                       const StatesTree: TAVLTree;
                                       const WorkAnyWay: boolean = false): TArray<string>;

function FormOutputString(const Response: TBingResponse;
                          const SourceString: string;
                          const ResponseLimit: integer;
                          const URL_QA_modifier: boolean): string;

function FormSimpleHeader(const InResultsCount: integer; const OriginalHeader: string): string;
function FormSimpleOutputString(const Response: TBingResponse;
                                const SourceString: string;
                                const ResponseLimit: integer): string;

function CalculateScoreField(const parsingResults: TJSONparsingResults): integer;
function FormCalcFieldForOutput(const parsingResults: TJSONparsingResults): string;
//---формирует список дублированных доменов-------------------------------------
procedure CreateDomainDuplicatesList(var ParsingResults: TArray<TJSONparsingResults>{TJSONresultsArray};
                                    const ddGroup, ddTreshold: integer;
                                    var DomainDuplicatesArr: TArray<string>);
function CountWords(const InText: string): integer;
procedure SortStringArray(var InArray: TArray<string>);
function SearchDataInText(const ControlInfo, InText: string;
                          const DictArray: TArray<string>;
                          var DataFound: TArray<TDomainRec>;
                          const CS: boolean = false): string;
function NormalizeCompanyName(const InText: string;
                              const LengthInWords: integer;
                              const ModifiersArray: TArray<string>): string;
function GetNumbers(const Value: string): string;
function FindCityStatePairs(const CityArr, StateArr: TArray<TDomainRec>): TArray<TPairRec>;
procedure NormalizeStatesArr(var StateArr: TArray<TPairRec>; const StatesTree: TAVLTree);
function DetectAndExtractPhoneNumber(const InText: string{; var OriginalText: TArray<string>}): TArray<string>;
function DeleteDuplicatesFromPhoneArray(const InArray: TArray<string>; const Normalize: boolean = true): TArray<string>;
function StandartizePhone(const InPhone: string): string;
//---поиск описания ответов Bing----------------------------------------
function FindBingDescr(const BingCode: integer): string;
//---удаление повторяющихся пробелов--------------------------------------------
function DeleteUselessSpaces(s:String):string;
//---добавление в строковый массив уникального значения-------------------------
function ArrAddUniqueValue(var InArray: TArray<string>; Value: string): boolean;
//---вычисление баллов для названия страницы (или названия сайта)---------------
//---url и имя компании должны быть в нормализованном виде----------------------
function WordMatchCount(const InUrl, InCompanyName: string): integer;

function ProcessDirectories(exclDirArr: TArray<string>;
                            var A: TArray<TJSONparsingResults>;
                            const NormCompName: string;
                            SR: TScoreRecord
                           ): TArray<string>;
//---загрузка файла с исключениями--------------------------------------
procedure UploadExcludesConfig(const InFile: string;
                               var exclUrlArr: TArray<string>;  //---массив с исключениями урл
                               var exclDirArr: TArray<string>;  //---массив с доменами социальных сетей
                               var exclNamArr: TArray<string>;  //---массив с исключениями в имени
                               var exclKeyArr: TArray<string>   //---массив с исключениями-ключевыми словами
                              );
//---загрузка файла с ключами-------------------------------------------
function UploadFillerConfig(const InFile: string): TFillerConfigSettings;
//---загрузка файла с телефонными зонами--------------------------------
procedure UploadAreaCodes(const InFile: string; var PhoneCodesTree: TAVLTree);
//---убираем подстроки с левой стороны строки---------------------------
function RemoveFromLeft(const InValue: string;
                        const A: array of string;
                        const IgnoreCase: boolean = true): string;

implementation

function LinesCount(const Filename: string): Integer;
var   //подсчет строчек в файле
    HFile: THandle;
    FSize, WasRead, i: Cardinal;
    Buf: array[1..4096] of byte;
  //Buf: array[1..4096] of AnsiChar;
begin
    Result := 0;
    HFile := CreateFile(Pchar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if HFile <> INVALID_HANDLE_VALUE then
    begin
        FSize := GetFileSize(HFile, nil);
        if FSize > 0 then
        begin
            Inc(Result);
            ReadFile(HFile, Buf, 4096, WasRead, nil);
            repeat
                for i := WasRead downto 1 do
                    if Buf[i] = 10 then
                Inc(Result);
                ReadFile(HFile, Buf, 4096, WasRead, nil);
            until WasRead = 0;
        end;
    end;
    CloseHandle(HFile);
end;

function _GetFileSize(FileName: string): Int64;
var
    FS: TFilestream;
begin
    Result := 0;
    try
        FS := TFilestream.Create(Filename, fmShareDenyRead);
    except
        Result := 0;
    end;
    if Result <> 0 then Result := FS.Size;
    FS.Free;
end;

function GetFileEnoding(const FileName: string): TEncoding;
var LEncoding: TEncoding;
    LFileStream: TFileStream;
    LBuffer: TBytes;
    LOffset: Integer;
    BufferLength: Integer;
begin
    LEncoding := nil;
    BufferLength := 100;
    LFileStream := TFileStream.Create(FileName, fmOpenRead);
    try
        // Read the file into buffer.
        BufferLength := Min(LFileStream.Size, BufferLength);
        SetLength(LBuffer, BufferLength);
        LFileStream.ReadBuffer(Pointer(LBuffer)^, Length(LBuffer));
        // Get data encoding of read data.
        LOffset := TEncoding.GetBufferEncoding(LBuffer, LEncoding);
    finally
        LFileStream.Free;
    end;
    Result := LEncoding;
end;

procedure ReadCSVRecord(const Line: string; var Strings : TStringList{TStrings});
var P : PChar;
    Field : string;
    Quote : boolean;
begin
    P := nil;
    Strings.Clear;
    if length(Line) > 0 then
    begin
        P := @Line[1];
        repeat
            Field := '';
            if P^ = '"' then
            begin
                Field := Field + P^; //new 31_08_2017
                Inc(P);
                repeat
                    Quote := true;
                    while (P^ <> '"') and (P^ <> #0) do
                    begin
                        Field := Field + P^;
                        Inc(P);
                    end;
                    Quote := False;
                    while P^ = '"' do
                    begin
                        Inc(P);
                        {if Quote then} Field := Field + '"';
                        Quote := not Quote;
                    end;
                until (P^ = #0) or (Quote and (P^ = ',')); //new
            end
            else
            begin
                while (P^ <> #0) and (P^ <> ',') do
                begin
                    Field := Field + P^;
                    Inc(P);
                end;
            end;
            Strings.Add(Trim(Field));
            if P^ = #0 then exit;
            Inc(P);
        until P^ = #0;
       Strings.Add('');
    end;
end;

function IsAdditionalField(const InStr: string): boolean;
var I, {LenInStr, LenSubInStr,} SubStrPos: integer;
    //strsubtemp, strtemp: string;
begin
    Result := false;

    for I := Low(AdditionalFields) to High(AdditionalFields) do
    begin
        //SubStrPos := 0;
        SubStrPos := Pos(AdditionalFields[I].ToLowerInvariant,
                         InStr.ToLowerInvariant);
        //if SubStrPos > 0 then
        if SubStrPos = 1 then
            if SubStrPos = (Length(InStr) - Length(AdditionalFields[I]) + 1) then
            begin
                Result := true;
                break;
            end;
    end;

//    for I := Low(BeforeCompanyFields) to High(BeforeCompanyFields) do
//    begin
//        //SubStrPos := 0;
//        SubStrPos := Pos(BeforeCompanyFields[I].ToLowerInvariant,
//                         InStr.ToLowerInvariant);
//        if SubStrPos > 0 then
//            if SubStrPos = (Length(InStr) - Length(BeforeCompanyFields[I]) + 1) then
//            begin
//                Result := true;
//                exit;
//            end;
//    end;
end;

function ReadString(const InReader: TStreamReader;
                    const ColCount: integer;
                    var OutInputSL: TStringList): string;
var str{, strtemp}: string;
begin
    str := InReader.ReadLine();
    //str :=StringReplace(str,#0,' ',[rfReplaceAll]);

    while (Length(str) = 0) and (not InReader.EndOfStream) do
        str := InReader.ReadLine();

    if ColCount = 1 then
        if str.IndexOf(',') > -1 then
        begin
            str := str.Trim(['"']);
            str := '"' + str + '"';
        end;

    str :=StringReplace(str,#0,' ',[rfReplaceAll]);
    ReadCSVRecord(str, OutInputSL);

    while (OutInputSL.Count < ColCount) and (not InReader.EndOfStream) do
    begin
        str := str + InReader.ReadLine();
        str :=StringReplace(str,#0,' ',[rfReplaceAll]);
        ReadCSVRecord(str, OutInputSL)
    end;

    while OutInputSL.Count > ColCount do
        OutInputSL.Delete(OutInputSL.Count - 1);

    Result := str;
end;

function IsRightField(const InStr: string): boolean;
var I: integer;
begin
    Result := false;
    for I := Low(possibleNames) to High(possibleNames) do
        if possibleNames[I].ToLower = InStr.ToLower then Result := true;
        //if Pos(possibleNames[I].ToLower, InStr.ToLower) > 0 then Result := true;
end;

Function DeleteUselessSpaces(s:String):string;
begin
    Repeat
        Result:=s;
        s:=StringReplace(Result,'  ',' ',[rfReplaceAll]);
        //заменяем все двойные пробелы на одинарные
    Until Result=s;
    //повторяем до тех пор пока есть двойные пробелы
end;

function ClearStr(const InStr: string): string;
var s: string;
    i: integer;
begin
    s := InStr.ToLower;
    for I := 0 to High(CharsToReplace) do
        s := StringReplace(s, CharsToReplace[I], ' ', [rfReplaceAll]);
    for I := 0 to High(CharsToRemove) do
        s := StringReplace(s, CharsToRemove[I], '', [rfReplaceAll]);
    s := DeleteUselessSpaces(s);
    Result := Trim(s);
end;

function PrepareFileName(const InFileName: string): string;
var s: string;
    i: integer;
begin
    s := InFileName;
    for I := 0 to High(UnacceptableChars) do
        s := s.Replace(UnacceptableChars[I], ' ', [rfReplaceAll]);
    s := DeleteUselessSpaces(s);
    Result := s.Trim;
end;

function DeleteBetween(const StartTag, EndTag, InStr: string): string;
var
    strTemp: string;
    StartPos, EndPos: Cardinal;
    StartTagLen, EndTagLen: Word;
begin
    // очистить текст от тегов
    strTemp := InStr;
    StartTagLen := Length(StartTag);
    EndTagLen := Length(EndTag);
    StartPos := Pos(StartTag, strTemp);
    //while (Pos(StartTag, strTemp) <> 0) or (Pos(EndTag, strTemp) <> 0) do
    while (Pos(StartTag, strTemp) <> 0) and (PosEx(EndTag, strTemp, StartPos + StartTagLen) <> 0) do
    begin
        StartPos := Pos(StartTag, strTemp);
        EndPos := PosEx(EndTag, strTemp, StartPos + StartTagLen);

        if (StartPos > 0) and (EndPos = 0) then break;

        if EndPos > StartPos
        then Delete(strTemp, StartPos, EndPos - StartPos + EndTagLen)
        else Delete(strTemp, EndPos, EndTagLen);
    end;
    Result := strTemp;
end;

function MySortStr(List: TStringList; Index1, Index2: Integer): Integer;
begin //кастомная сортировка stringlist по возрастанию
  try
      if Length(List[Index1])<Length(List[Index2]) then
      begin
          Result := 1;
          Exit;
      end;
      if Length(List[Index1])=Length(List[Index2])
      then Result := 0
      else Result := -1;
  except
      Result := 0;
  end;
end;

function Dequote(const InStr: string): string;
var strtemp: string;
begin
    strtemp := InStr;
    strtemp := AnsiDequotedStr(strtemp,'"');
    strtemp := AnsiDequotedStr(strtemp,'''');
    Result := strtemp;
end;

function PreparePatterns(const InText: string): TStringList;
var strtemp, ss: string; //подготовка шаблонов для поиска текста в странице
    TempSL: TStringList;
    i, j: integer;
begin
    //strtemp := LowerCase(InText);  2018.03.04
    strtemp := Dequote(strtemp);
    strtemp := ClearStr(InText); //возможно этого лучше не делать
    //strtemp := Trim(strtemp);    2018.03.04

    TempSL := TStringList.Create;
    TempSL.CommaText := strtemp;

    Result := TStringList.Create;

    for i := 0 to TempSL.Count - 1 do
    begin
        ss := '';
        for j := i to TempSL.Count - 1 do
        begin
            ss := ss + TempSL[j];
            Result.Add(ss);
            ss := ss + ' ';
        end;
    end;
    TempSL.Free;
    Result.CustomSort(MySortStr);
end;

function WordCount(CText: string): Longint;

function Seps(As_Arg: Char): Boolean;
begin
  Seps := As_Arg in
    [#0..#$1F, ' ', '.', ',', '?', ':', ';', '(', ')', '/', '\', '"'];
end;

var
  Ix: Word;
  Work_Count: Longint;
begin
    Work_Count := 0;
    Ix         := 1;
    while Ix <= Length(CText) do
    begin
        while (Ix <= Length(CText)) and (Seps(CText[Ix])) do
            Inc(Ix);
        if Ix <= Length(CText) then
        begin
            Inc(Work_Count);
            while (Ix <= Length(CText)) and (not Seps(CText[Ix])) do
                Inc(Ix);
        end;
    end;
    Result := Work_Count;
end;

function GetPercentage(const InText: string;
                       const InStrToFind: string;
                       var OutWordCount: integer): double;
var strtemp, strContains, WorkText: string;
    TempSL: TStringList;
    percent: double;
    OriginalWordCount, RealWordCount: integer;
    I{, J }:integer;
    RegEx: TRegEx;
    //RegExMatches: TMatchCollection;
begin
    Result := 0;
    OutWordCount := 0;
    if Length(InStrToFind) = 0 then exit;
    strtemp := ClearStr(InStrToFind);

    OriginalWordCount := WordCount(strtemp);
    if OriginalWordCount = 0 then exit;

    TempSL := PreparePatterns(strtemp);
    if TempSL.Count = 0 then exit;

    WorkText := ClearStr(InText);

    percent := 0;
    RealWordCount := 0;
    try
        for I := 0 to TempSL.Count - 1 do
        begin
            strContains := ' ' + (TempSL[I]) + ' ';
//            RegExMatches := RegEx.Matches(' ' + InText + ' ', strContains,
//                                                        [roIgnoreCase, roCompiled, roMultiLine]);
//            J := RegExMatches.Count;
//            if J > 0 then
//            begin
//                RealWordCount := WordCount(strContains);
//                percent := RoundTo((RealWordCount * 100) / OriginalWordCount, -2);
//                OutWordCount := J;
//                break;
//            end;
            if RegEx.IsMatch(' ' + WorkText{InText} + ' ', strContains, [roCompiled, roMultiLine, roIgnoreCase])
            then begin
                RealWordCount := WordCount(strContains);
                percent := RoundTo((RealWordCount * 100) / OriginalWordCount, -2);
                OutWordCount := RealWordCount;
                break;
            end;

        end;
    except
        on E: Exception do
        begin
            Result := 0;
            OutWordCount := 0;
        end;
    end;
    if Assigned(TempSL) then TempSL.Free;
    //Result := '"' + FloatToStr(percent) + '%"';
    Result := percent;
end;

function CountNameScore(const InText, InStrToFind: string;
                        const InScoreRec: TTargetsArr): integer;
var NamePercent: double; 
    I, WordCount, osScore: integer;
    strWorkText{, strWorkStrToFing}: string;
begin
    Result := 0;
    strWorkText := ClearStr(InText);
    //=get official-site scores=================================================
    for I := 0 to High(InScoreRec) do
    begin
        if InScoreRec[I].RecordName = OFFICAILSITE 
        then begin 
                 osScore := InScoreRec[I].Score;   //get company name score
                 break;
             end;              
    end;
    //==========================================================================
    NamePercent := GetPercentage(InText, InStrToFind, WordCount);
    if NamePercent >=80 
        then if strWorkText.Contains('official site') 
                 then Result := osScore;
end;

function ExtractDomain(const InURL: string; const AddProtocol: boolean = false): string;
var U: TIdURI;
begin
    Result := '';
    try
        U := TIdURI.Create(InURL);

        if AddProtocol = true then
            if U.Protocol.Length > 0 then
                Result := U.Protocol + '://';

        if U.Host.Length > 0 then
            Result := Result + U.Host
            //Result := Result + U.
        else Result := U.Document;
    finally
        if Assigned(U) then U.Free;
    end;
end;

function GetDomainName(url: string; const URLpattern: string): string;
var
    RegEx: TRegEx;
    RegExMatches: TMatchCollection;
    I,J :integer;
    strTemp: string;
begin
    Result := '';
    if url.Length = 0 then exit;

    if url[length(url)-1] <> '/' then url := url + '/';
    RegExMatches := RegEx.Matches(url, URLpattern, [roIgnoreCase, roCompiled, roMultiLine]);
    if RegExMatches.Count > 0 then
    begin
        Result := RegExMatches.Item[0].Value;
        if result[1] = '.' then Result := Copy(Result, 2, length(Result)-1);
        result := copy(result, 1, length(result)-1);

        if URLpattern = URL_DOMAIN_PATTERN then
        begin
            J := 0;
            for I := result.Length downto 1 do
            begin
                if result[I] = '.' then inc(J);
                if J < 2 
                    then strTemp := result[I] + strTemp
                    else break;
            end;
            result := strTemp;
        end;
    end;
end;
//---функция проверяет наличие хотябы одной пдстроки в строке-------------------
function ContainsAny(const InValue: string; A: array of string): boolean;
var I: integer;
begin
    Result := false;
    for I := Low(A) to High(A) do
    begin
        if InValue.ToLower.Contains(A[I].ToLower) = true
        then begin
                 Result := true;
                 break;
             end;
    end;
end;

function CountURLScore(var JSONresults: TJSONparsingResults;
                        const InCompanyName: string;
                        const InScoreRec: TTargetsArr;
                        var IsSocialNw: boolean;
                        const pSimple: boolean): integer;

const wwwArray: array [0..1] of string = ('www.', 'www4.');
const uselessChars: array [0..0] of string = ('-');

var strWorkCompanyName, strDomain, strSubDomain, strShortDomain, strShortSubDomain: string;
    strContains, strTemp: string;
    I, J, companyNameScore, exactMatchScore, isSubDomainScore, cnameIsDomain: integer;
    modFactorCount, modifierCount, modFactorValue, fullCount: integer;
    OriginalWordCount, RealWordCount: integer;
    TempSL: TStringList;
    percent, percent_factor: double;
    modFactorArray: array of integer;
    normalizeDomain: boolean;

    //---для новых переменных
begin
    Result := 0;
    normalizeDomain := true;
    if JSONresults.displayUrl.Length = 0 then exit;
//    strDomain := ' ' + ExtractDomain(InURL) + ' ';
    //get domain variations=====================================================
    strDomain := GetDomainName(JSONresults.displayUrl, URL_DOMAIN_PATTERN);

//    J := 0;
//    for I := strDomain.Length downto 1 do
//    begin
//        if strDomain[I] = '.' then inc(J);
//        if J < 2 
//            then strTemp := strDomain[I] + strTemp
//            else break;
//    end;
//    strDomain := strTemp;
    
//    for I := 0 to High(wwwArray) do  // remove "www"
//        if strDomain.StartsWith(wwwArray[I]) = true then
//            strDomain := strDomain.Replace(wwwArray[I],'');

    //JSONresults.domainName := strDomain;
    strShortDomain := strDomain.Substring(0, strDomain.LastIndexOf('.'));
    strSubDomain := GetDomainName(JSONresults.displayUrl, URL_SUBDOMAIN_PATTERN);
    for I := 0 to High(wwwArray) do  // remove "www"
        if strSubDomain.StartsWith(wwwArray[I]) = true then
            strSubDomain := strSubDomain.Replace(wwwArray[I],'');
    if pSimple = false then
        strShortSubDomain := strSubDomain.Substring(0, strSubDomain.LastIndexOf('.'))
    else begin
             if JSONresults.displayUrl.EndsWith('/') = true
             then JSONresults.displayUrl := JSONresults.displayUrl.TrimRight(['/']);

             strShortSubDomain := JSONresults.displayUrl.Substring(JSONresults.displayUrl.LastIndexOf('/') + 1, MaxInt);
         end;
    //==========================================================================
    //normalize domain names====================================================
    if normalizeDomain = true then
        for I := 0 to High(uselessChars) do
        begin  
            strDomain := strDomain.Replace(uselessChars[I],'');
            strShortDomain := strShortDomain.Replace(uselessChars[I],'');
            strSubDomain := strSubDomain.Replace(uselessChars[I],'');
            strShortSubDomain := strShortSubDomain.Replace(uselessChars[I],'');
        end;
    //==========================================================================    
    //---определяем является ли домен социальной сетью--------------------------
    //IsSocialNw := true;
    if pSimple = false
    then begin
             //if strDomain.ToLower.Contains('facebook.') = true then exit;
             //if strDomain.ToLower.Contains('instagram.') = true then exit;
             //if strDomain.ToLower.Contains('twitter.') = true then exit;
             //if strDomain.ToLower.Contains('linkedin.') = true then exit;
             IsSocialNw := ContainsAny(strDomain, ['facebook.','instagram.','twitter.','linkedin.']);
         end;
    //IsSocialNw := false;

    if InCompanyName.Length = 0 then exit;
    strWorkCompanyName := ClearStr(InCompanyName);
    
    OriginalWordCount := WordCount(strWorkCompanyName);
    if OriginalWordCount = 0 then exit;

    TempSL := PreparePatterns(strWorkCompanyName);
    if TempSL.Count = 0 then exit;
    //=get all modificators and scores==========================================
    modFactorCount := 0;  //обрабатываем список со счетом
    for I := 0 to High(InScoreRec) do
    begin
        if (InScoreRec[I].RecordName = 'company')
        and (InScoreRec[I].RecordType = 'target')
        then companyNameScore := InScoreRec[I].Score;   //get company name score

        if InScoreRec[I].RecordName = EXACTMATCH then exactMatchScore := InScoreRec[I].Score;   //get exact match score        
        if InScoreRec[I].RecordName = ISSUBDOMAIN then isSubDomainScore  := InScoreRec[I].Score;//get "is subdomain" score
        if InScoreRec[I].RecordName = COMPANYISDOMAIN then cnameIsDomain := InScoreRec[I].Score;//get company-is-domain    

        if InScoreRec[I].RecordType = 'mod_factor'
            then begin
                inc(modFactorCount);
                SetLength(modFactorArray, Length(modFactorArray) + 1);
                modFactorArray[High(modFactorArray)] := InScoreRec[I].Score;
            end;
    end;
    //==========================================================================
    percent := 0;
    RealWordCount := 0;

    for I := 0 to TempSL.Count - 1 do
    begin
        strContains := ' ' + TempSL[I] + ' ';
        
        modifierCount := 0;
        modFactorValue := 0;
        for J := 0 to High(InScoreRec) do
        begin               
            if InScoreRec[J].RecordType = MODIFIERTAG then
                if strContains.Contains(' ' + InScoreRec[J].RecordName.Trim + ' ') = true then
                begin
                    inc(modifierCount);
                    if modifierCount <= Length(modFactorArray) then
                        modFactorValue := modFactorValue + modFactorArray[modifierCount - 1];
                end;
        end;
        
        RealWordCount := WordCount(strContains);
        strContains := strContains.Replace(' ','',[rfReplaceAll]);
        if strShortSubDomain.ToLower.Contains(strContains) = true then
        begin
            percent := RoundTo((RealWordCount * 100) / OriginalWordCount, -2);

//            if modifierCount > 0 then
//            begin
//                if modifierCount > Length(modFactorArray) then modifierCount := Length(modFactorArray);
//                fullCount := RealWordCount - modifierCount;
//                percent_factor := (fullCount * 100 + modFactorValue) / RealWordCount;
//                percent := percent * percent_factor / 100;
//            end;
            break;

        end;
    end;
    TempSL.Free;
    if percent > 0 then
    begin
        Result := Trunc(RoundTo((companyNameScore * percent) / 100, 0));
        JSONresults.onlyURLscore := Result;

        if pSimple = false
        then begin
                 //strTemp := strWorkCompanyName.Replace(' ','',[rfReplaceAll]).ToLower;
                 strTemp := InCompanyName.Replace(' ','',[rfReplaceAll]).ToLower;
                 if strTemp = strDomain     //company name exact match with domain
                 then begin
                          Result := Result +  cnameIsDomain;
                          JSONresults.cidScore := cnameIsDomain;
                      end;

                 if strDomain <> strSubDomain    //
                 then begin
                          Result := Result + isSubDomainScore; //if subdomain
                          JSONresults.isdScore := isSubDomainScore;
                      end;
                 //if strShortDomain.Trim = strContains.Trim
                 //if strDomain.Trim = strContains.Trim
                 if strShortDomain.Trim = strWorkCompanyName.Replace(' ','',[rfReplaceAll]).Trim
                 then begin
                          Result := Result + exactMatchScore; //if company name = domain without .com for example
                          JSONresults.cdemScore := exactMatchScore;
                      end;
             end;
    end
    else begin 
             Result := -1;
             JSONresults.onlyURLscore := Result;
         end;
end;

function GetNameScore2(const InText, InCompanyName: string; const InScore: integer): integer;
var strWorkName, strWorkText, strContains: string;
    I: integer;
    OriginalWordCount, RealWordCount: integer;
    TempSL: TStringList;
    percent: double;
begin
    Result := 0;

    if Length(InText) = 0 then exit;
    //strWorkText := ExtractDomain(InText);
    strWorkText := InText;

    if Length(InCompanyName) = 0 then exit;
    strWorkName := InCompanyName;

    OriginalWordCount := WordCount(strWorkName);
    if OriginalWordCount = 0 then exit;

    TempSL := PreparePatterns(strWorkName);
    if TempSL.Count = 0 then exit;

    percent := 0;
    RealWordCount := 0;

    for I := 0 to TempSL.Count - 1 do
    begin
        strContains := TempSL[I];
        RealWordCount := WordCount(strContains);
        //strContains := strContains.Replace(' ','',[rfReplaceAll]);
        if strWorkText.ToLower.Contains(strContains) = true then
        begin
            percent := RoundTo((RealWordCount * 100) / OriginalWordCount, -2);
            break;
        end;
    end;
    TempSL.Free;
    if percent > 0
    then Result := Trunc(RoundTo((InScore * percent) / 100, 0))
    else Result := -1;
end;

function InsertSpaces(const InStr: string): string;
const DIGITS = '0123456789';
var i: integer;
begin
    Result := '';
    for i := 1 to InStr.Length - 1 do
    begin
        if DIGITS.Contains(InStr[I]) = true then
            if DIGITS.Contains(InStr[I + 1]) = false then
            begin
                Result := Result + InStr[I] + ' ';
                continue;
            end else
            begin
                Result := Result + InStr[I];
                continue;
            end
        else
            if DIGITS.Contains(InStr[I + 1]) = false then
            begin
                Result := Result + InStr[I];
                continue;
            end else
            begin
                Result := Result + InStr[I] + ' ';
                continue;
            end
    end;
    Result := Result + InStr[InStr.Length];
end;



procedure GetSocialNetworks(var InResponse: TBingResponse; var InParsingRes: TJSONparsingResults; const InScore: integer);
var i, Res, Res2, Res3: integer;
    companyName, strWorkName, strWorkName2, strWorkName3: string;
begin
    if InResponse.Name.Length = 0 then exit;
    strWorkName := ClearStr(InResponse.Name).ToLower.Replace(' ','',[rfReplaceAll]);

    strWorkName2 := InsertSpaces(strWorkName);

    strWorkName3 := ClearStr(InResponse.Name).ToLower;

    i := InParsingRes.displayUrl.LastIndexOf('/');
    companyName := InParsingRes.displayUrl.Substring(i + 1, MaxInt);
    companyName := ClearStr(companyName).Replace(' ','',[rfReplaceAll]);

    if InParsingRes.domain.ToLower.Contains('linkedin') then
        if InParsingRes.displayUrl.ToLower.Contains('linkedin') then
            if InParsingRes.displayUrl.ToLower.Contains('/company/') then
                if InParsingRes.arrWebName.ToLower.Contains('linkedin') then
                    begin
                        if companyName.Contains(strWorkName) then
                        begin
                            InParsingRes.linkedin := InParsingRes.displayUrl;
                            InParsingRes.urlScore := InScore;
                            if InParsingRes.domain.ToLower = 'https://www.linkedin.com' then
                            begin
                                InResponse.LinkedIn := InParsingRes.linkedin;
                                Res := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName, InScore);
                                Res2 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName2, InScore);
                                Res3 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName3, InScore);
                                InResponse.LIscore := MaxIntValue([Res, Res2, Res3]);
                            end;
                        end;
                    end;

    if InParsingRes.domain.ToLower.Contains('instagram') then
        if InParsingRes.displayUrl.ToLower.Contains('instagram') then
            begin
                if companyName.Contains(strWorkName) then
                begin
                    InParsingRes.instagram := InParsingRes.displayUrl;
                    InParsingRes.urlScore := InScore;
                    if InParsingRes.domain.ToLower = 'https://www.instagram.com' then
                    begin
                        InResponse.Instagram := InParsingRes.Instagram;
                        Res := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName, InScore);
                        Res2 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName2, InScore);
                        Res3 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName3, InScore);
                        InResponse.IGscore := MaxIntValue([Res, Res2, Res3]);
                    end;
                end;
            end;

     if InParsingRes.domain.ToLower.Contains('facebook') then
        if InParsingRes.displayUrl.ToLower.Contains('facebook') then
            begin
                if companyName.Contains(strWorkName) then
                begin
                    InParsingRes.facebook := InParsingRes.displayUrl;
                    InParsingRes.urlScore := InScore;
                    if InParsingRes.domain.ToLower = 'https://www.facebook.com' then
                    begin
                        InResponse.facebook := InParsingRes.facebook;
                        Res := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName, InScore);
                        Res2 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName2, InScore);
                        Res3 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName3, InScore);
                        InResponse.FBscore := MaxIntValue([Res, Res2, Res3]);
                    end;
                end;
            end;

     if InParsingRes.domain.ToLower.Contains('twitter') then
        if InParsingRes.displayUrl.ToLower.Contains('twitter') then
            begin
                if companyName.Contains(strWorkName) then
                begin
                    InParsingRes.twitter := InParsingRes.displayUrl;
                    InParsingRes.urlScore := InScore;
                    if InParsingRes.domain.ToLower = 'https://twitter.com' then
                    begin
                        InResponse.twitter := InParsingRes.twitter;
                        Res := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName, InScore);
                        Res2 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName2, InScore);
                        Res3 := GetNameScore2(ClearStr(InParsingRes.arrSnippet), strWorkName3, InScore);
                        InResponse.TWscore := MaxIntValue([Res, Res2, Res3]);
                    end;
                end;
            end;
end;

function ExtractAreaCode(const InPhoneNumber: string): string;
var StartPos, EndPos: integer;
    //Len: integer;
    strTemp: string;
begin
    Result := '';
    if InPhoneNumber.IsEmpty then exit;
    if InPhoneNumber.Length < 3 then exit;

    StartPos := -1;
    EndPos := -1;

    StartPos := InPhoneNumber.IndexOf('(');   //if we have "(..)" in the string
    if StartPos > -1 then
    begin
        EndPos := InPhoneNumber.IndexOf(')', StartPos + 1);
        if ((EndPos > StartPos)
        and ((EndPos + 1) <> InPhoneNumber.Length))
        then
        begin
            Result := InPhoneNumber.Substring(StartPos + 1, EndPos - (StartPos + 1));
            exit;
        end;
    end;

    strTemp := InPhoneNumber.Replace('-', ' ');  //no brackets in a string, just " " or "-"

    if strTemp.IndexOf(' ') > 0 then
        if strTemp.IndexOf(' ') <=10 then
        begin
            Result := strTemp.Substring(0, strTemp.IndexOf(' '));
            exit;
        end;

end;

function IsThereAnyExcludes(const exclArr: TArray<string>; const InText: string; var ExclVal: string;
                            const ExactMatch: boolean = false): boolean;
var I: integer;
    strTemp: string;
    ExcludeFound: boolean;
begin
    Result := false;
    if InText.IsEmpty then exit;
    if Length(exclArr) = 0 then exit;
     ExclVal := '';

    strTemp := InText.ToLower;
    for I := 0 to High(exclArr) do
    begin
        ExcludeFound := false;

        if ExactMatch = false
        then begin
                 if strTemp.IndexOf(exclArr[I]) > -1 then ExcludeFound := true;
                 ExclVal := exclArr[I];
             end
        else begin
                 if strTemp.ToLower = exclArr[I] then ExcludeFound := true;
                 ExclVal := exclArr[I];
             end;

        if ExcludeFound = true {strTemp.IndexOf(excludesArray[I]) > -1} then
        begin
            //---здесь отлавливаем домен верхнего уровня
            if exclArr[I].StartsWith('.') = true then
                if strTemp.EndsWith(exclArr[I], true) = true then
                begin
                    Result := true;
                    break;
                end;

            if exclArr[I].StartsWith('.') = false
            then begin
                     Result := true;
                     break;
                 end;
        end;
    end;
end;

function FillTargetsArray(const inpSL: TStringList; var OutArray: TTargetsArr; var outTreshold: integer): string;
var I: integer;
    equalPos, commaPos: integer;
begin
    Result := '';
    for I := 0 to inpSL.Count - 1 do
    begin
        if inpSL[I].Length = 0 then continue;

        if inpSL[I].StartsWith(';') then continue;

        equalPos := inpSL[I].LastIndexOf('=');
        if equalPos = -1 then continue;

        commaPos := inpSL[I].LastIndexOf(',');
        equalPos := inpSL[I].LastIndexOf('=');

        if commaPos > -1 then
            if equalPos > commaPos then
                begin
                    Result := Format('Wrong input format: "%s"', [inpSL[I]]);
                    continue;
                end;

        SetLength(OutArray, Length(OutArray) + 1);

        OutArray[High(OutArray)].RecordType := inpSL[I].Substring(0, equalPos);

        try
            if commaPos > -1 then  //if K = -1 then continue;
            begin
                OutArray[High(OutArray)].RecordName := inpSL[I].Substring(equalPos + 1, commaPos - equalPos - 1);
                OutArray[High(OutArray)].Score := inpSL[I].Substring(commaPos + 1).Trim.ToInteger;
            end
            else begin
                OutArray[High(OutArray)].RecordName := inpSL[I].Substring(equalPos + 1, MaxInt);
                //OutArray[High(OutArray)].Score := inpSL[I].Substring(equalPos + 1).ToInteger;
            end;
        except
            Result := Format('Wrong input format: "%s"', [inpSL[I]]);
        end;
    end;
end;
//function ClearParsingResults(const InData: TJSONparsingResults;
//                             const excludesUrlArray, excludesNamesArray: TStringDynArray): TJSONparsingResults;
function ClearParsingResults(const InData: TArray<TJSONparsingResults>{TJSONresultsArray};
                             const excludesUrlArray, excludesNamesArray, excludesKeyArray: TArray<string>;
                             var ExcludedDomains: string): TArray<TJSONparsingResults>{TJSONresultsArray};
var i, xCount, intCounter: integer;
    //tempArr: TJSONresultsArray;
    boolGoodDomain, boolKey, boolUrl, boolName: boolean;
    arrDomains, arrKeys: TArray<string>;
    strTemp: string;
    ExcludeValue: string;
begin
    ExcludedDomains := '';
    xCount := 10;
    intCounter := 0;
    for I := 0 to High(InData) do
    begin
        boolGoodDomain := false;
        boolKey := false;
        boolUrl := false;
        boolName := false;
        if ((InData[I].displayUrl.Length = 0) and (InData[I].arrSnippet.Length = 0) and (InData[I].arrWebName.Length = 0))
        then continue;

//        if IsThereAnyExcludes(excludesUrlArray, InData[I].domainName {arrUrl}, ExcludeValue, true) = false
//        then begin
//                 if IsThereAnyExcludes(excludesKeyArray, InData[I].domainName {displayUrl}, ExcludeValue) = false
//                 then begin
//                          if IsThereAnyExcludes(excludesNamesArray, InData[I].arrWebName, ExcludeValue) = false
//                          then begin
//                                   inc(intCounter);
//                                   //SetLength(Result, Length(Result) + 1);
//                                   //Result[High(Result)] := InData[I];
//                                   Result := Result + [InData[I]];
//                                   boolGoodDomain := true;
//                               end;
//                      end else boolKey := true;
//             end else boolUrl := true;
        boolUrl := IsThereAnyExcludes(excludesUrlArray, InData[I].domainName {arrUrl}, ExcludeValue, true);
        if boolUrl = true then ArrAddUniqueValue(arrDomains, Format('{%s | %s}', [ExcludeValue, InData[I].domainName]));

        boolKey := IsThereAnyExcludes(excludesKeyArray, InData[I].domainName {displayUrl}, ExcludeValue);
        if boolKey = true then ArrAddUniqueValue(arrKeys, Format('{%s | %s}', [ExcludeValue, InData[I].domainName]));

        boolName := IsThereAnyExcludes(excludesNamesArray, InData[I].arrWebName, ExcludeValue);

        if (boolUrl = false) and (boolKey = false) and (boolName = false)
        then begin
                 inc(intCounter);
                 Result := Result + [InData[I]];
                 boolGoodDomain := true;
             end;

        if I = 9
        then xCount := I - intCounter + 1;

//        if boolGoodDomain = false
//        then begin
//                 //if boolUrl = true then ArrAddUniqueValue(arrDomains, InData[I].domainName);
//                 if boolUrl = true then ArrAddUniqueValue(arrDomains, Format('{%s | %s}', [ExcludeValue, InData[I].domainName]));
//                 //if boolKey = true then ArrAddUniqueValue(arrKeys, InData[I].domainName);
//                 if boolKey = true then ArrAddUniqueValue(arrKeys, Format('{%s | %s}', [ExcludeValue, InData[I].domainName]));
//             end;
    end;

    if Length(Result) > 0 then Result[0].xCount := xCount;
    if Length(arrDomains) > 0
    then begin
             ExcludedDomains := Format('excl=%s',[string.Join(';', arrDomains)]);
         end;

    if Length(arrKeys) > 0
    then begin
             //strTemp := string.Join(';', arrKeys);
             ExcludedDomains := ExcludedDomains + ' ' + Format('keyexcl=%s',[string.Join(';', arrKeys)]);
         end;
    ExcludedDomains := ExcludedDomains.Trim;
    //ExcludedDomains := string.Join(';', arrDomains);
    SetLength(arrDomains, 0);
    SetLength(arrKeys, 0);
end;

procedure MarkDuplicatesInSearchResults(var A: TArray<TJSONparsingResults>; const LowBorder: integer = 0);
var I: integer;
    //DuplicatesCatcherSL: TStringList;
    DuplicatesCatcherSL: TArray<string>;
begin
//    DuplicatesCatcherSL := TStringList.Create;
//    DuplicatesCatcherSL.Duplicates := dupError;
//    DuplicatesCatcherSL.Sorted := true;
    //for I := High(A) downto 0 do
    for I := LowBorder{0} to High(A) do
    begin
        if IndexStr(A[I].domainName, DuplicatesCatcherSL) = -1 then
            DuplicatesCatcherSL := DuplicatesCatcherSL + [A[I].domainName]
        else
        //try
        //    DuplicatesCatcherSL.Add(A[I].domainName);
        //except
            //Delete(A, I, 1);
            A[I].score := THE_VERY_MIN;
        //end;
    end;

    for I := High(A) downto LowBorder{0} do
    begin
        if A[I].score = THE_VERY_MIN then Delete(A, I, 1);
    end;

    //DuplicatesCatcherSL.Free;
    SetLength(DuplicatesCatcherSL, 0);
end;

procedure SortArray(var A: TArray<TJSONparsingResults>{TJSONresultsArray}; n: Integer);
var i,j: Integer;
    x: TJSONparsingResults;
begin
    for i := Pred(N) downto 1 do
//    for i := N downto 1 do
        for j := 0 to Pred(i) do
           if a[j].score < a[j+1].score then
           begin
               x := a[j+1];
               a[j+1] := a[j];
               a[j] := x;
           end;
end;

function CountPageScore(const InPage: string;
                        const InBingResponse: TBingResponse;
                        const InScoreArr: TTargetsArr): integer;
var I, WordCount: integer;
    dblName, dblState, dblCity, dblAddr, dblZip, dblPhone, dblAC: double;
    //dblTemp: double;
begin
    Result := 0;
    dblName := GetPercentage(InPage, InBingResponse.Name, WordCount);
    //dblName := dblName * WordCount;
    dblState := GetPercentage(InPage, InBingResponse.State, WordCount);
    //dblState := dblState * WordCount;
    dblCity := GetPercentage(InPage, InBingResponse.City, WordCount);
    //dblCity := dblCity * WordCount;
    dblAddr := GetPercentage(InPage, InBingResponse.Addr, WordCount);
    //dblAddr := dblAddr * WordCount;
    dblZip := GetPercentage(InPage, InBingResponse.Zip, WordCount);
    //dblZip := dblZip * WordCount;
    dblPhone := GetPercentage(InPage, InBingResponse.Phone, WordCount);
    //dblPhone := dblPhone * WordCount;
    dblAC := GetPercentage(InPage, InBingResponse.AC, WordCount);
    //dblAC := dblAC * WordCount;
    for I := 0 to High(InScoreArr) do
    begin
        if InScoreArr[I].RecordName.ToLower = 'company' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblName / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'state' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblState / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'city' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblCity / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'address' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblAddr / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'zip' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblZip / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'phone' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblPhone / 100, 0));
        if InScoreArr[I].RecordName.ToLower = 'ac' then
            Result := Result + Trunc(RoundTo(InScoreArr[I].Score * dblAC / 100, 0));
    end;
end;

//---получаем данные справа от разделителя--------------------------------------
function ExtractSubParameter(const InValue, Delim: string): string;
begin
    Result := '';
    if InValue.IndexOf(Delim) = -1 then Exit;

    Result := Copy(InValue, Pos(Delim,InValue) + Length(Delim), MaxInt);
end;

//---получаем данные слева от разделителя---------------------------------------
function ExtractParameter(const InValue, Delim: string): string;
begin
    Result := '';
    if InValue.IndexOf(Delim) = -1 then Exit;

    Result := Copy(InValue, 1, Pos(Delim,InValue) - 1);
end;

function CSVfromSL(const InSL: TStringList): string; overload;
var i: integer;
    s: string;
begin
    Result := SetQuotesI(InSL[0]);
    //Result := s{InSL.Strings[0]};
    for i := 1 to InSL.Count - 1 do
    begin
        s := SetQuotesI(InSL[i]);
        Result := Result + ',' + s;
    end;
end;

function SetQuotes(const InStr: string): string;
var s: string;
begin
    s := InStr;

    if (Pos(',',s) > 0)
    and (s.StartsWith('"') = false)
    and (s.EndsWith('"') = true)
    then s := '"' + s;

    if ((Pos(',',s) > 0)
    or (Pos('"',s) > 0))
    and not MatchesMask(s,'"*"')
    then s := '"' + s + '"';

    Result := s;
end;

function SetQuotesI(const InValue: string): string;
begin
    Result := InValue;
    if Result.Contains(',') = true
    then begin
             if Result.StartsWith('"') = false then Result := '"' + Result;
             if Result.EndsWith('"') = false then Result := Result + '"';
         end;
end;

function GetCPUCount: integer;
var
  s: TSystemInfo;
begin
  GetSystemInfo(s);
  Result := s.dwNumberOfProcessors;
end;

function GetNsymbolsBeforeDelim(const N: integer; const InText, Delim: string): string;
var I, Len, StartPos: integer;
begin
    Result := '';

    if InText.Length = 0 then exit;
    if N < 1 then exit;

    I := InText.LastDelimiter(Delim);
    if I = -1 then exit;

    if (I - N) < 0
    then begin
             StartPos := 0;
             Len := I
         end
    else begin
             StartPos := I - N;
             Len := N;
         end;

    Result := InText.Substring(StartPos, Len);
end;

function XPos( const cSubStr, cString :string ) :integer;
var
  nLen0, nLen1, nCnt, nCnt2 :integer;
  cFirst :Char;
begin
  nLen0 := Length(cSubStr);
  nLen1 := Length(cString);

  if nLen0 > nLen1 then
    begin
      // the substr is longer than the cString
      result := 0;
    end

  else if nLen0 = 0 then
    begin
      // null substr not allowed
      result := 0;
    end

  else

    begin

      // the outer loop finds the first matching character....
      cFirst := UpCase( cSubStr[1] );
      result := 0;

      for nCnt := 1 to nLen1 - nLen0 + 1 do
        begin

          if UpCase( cString[nCnt] ) = cFirst then
            begin
              // this might be the start of the substring...at least the first
              // character matches....
              result := nCnt;

              for nCnt2 := 2 to nLen0 do
                begin

                  if UpCase( cString[nCnt + nCnt2 - 1] ) <> UpCase( cSubStr[nCnt2] ) then
                    begin
                      // failed
                      result := 0;
                      break;
                    end;

                end;

            end;


          if result > 0 then
            break;
        end;


    end;
end;

//procedure TForm1.Button1Click(Sender : TObject);
//var
//  P, Len : Integer;
//...
//begin
//...
//  //Длина шаблона.
//  Len := Length('<шаблон, который ищем>');
//  P := PosEx('<шаблон, который ищем>', '<Строка в которой ищем шаблон>', 1);
//  while P > 0 do begin
//    //Здесь обрабатываем очередной найденный шаблон.
//    //...
//    //Перескакиваем через текущий найденный шаблон и ищем следующий шаблон.
//    P := PosEx('<шаблон, который ищем>', '<Строка в которой ищем шаблон>', P + Len);
//  end;
//end;

function FindAllEntries(const AText, ASubText: string): TArray<TDomainRec>;
var P, Len: integer;
    //AText
begin
    SetLength(Result, 0);
    Len := Length(ASubText);
    P := PosEx(AnsiUpperCase(ASubText), AnsiUpperCase(AText), 1);
    while P > 0 do
    begin
        Result := Result + [TDomainRec.Create(ASubText, P)];
        P := PosEx(AnsiUpperCase(ASubText), AnsiUpperCase(AText), P + Len);
    end;
end;

function FindAllEntriesCS(const AText, ASubText: string): TArray<TDomainRec>;
var P, Len: integer;
begin
    SetLength(Result, 0);
    Len := Length(ASubText);
    P := PosEx(ASubText, AText, 1);
    while P > 0 do
    begin
        Result := Result + [TDomainRec.Create(ASubText, P)];
        P := PosEx(ASubText, AText, P + Len);
    end;
end;

function SearchStringsInText(const ValuesToSearch: TArray<string>;
                             const InText: string;
                             const CS: boolean = false): string;
var //Pool: TThreadPool;
    II: integer;
    Results: TArray<string>;
    strTemp: string;
begin
    Result := '';
    if Length(ValuesToSearch) = 0 then exit;
    if Length(InText) = 0 then exit;

    //SetLength(Results, Length(ValuesToSearch));
//    Pool := TThreadPool.Create;
//    I := GetCPUCount;
//    Pool.SetMinWorkerThreads(I * 2);
//    Pool.SetMaxWorkerThreads(I * 2);
//    Pool.SetMinWorkerThreads(1);
//    Pool.SetMaxWorkerThreads(1);
//    TParallel.For(0, High(ValuesToSearch), procedure (II: integer)
//    var strTemp: string;
    for II := 0 to High(ValuesToSearch) do
    begin
        if CS = false
        then begin
                 if ContainsText(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ') = true
                 then begin
                          strTemp := ValuesToSearch[II];
                          Results := Results + [strTemp];
                      end;
             end
        else begin
                 if ContainsStr(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ') = true
                 then begin
                          strTemp := ValuesToSearch[II];
                          Results := Results + [strTemp];
                      end;
             end;
    end;
//    end, Pool);
//    Pool.Free;

    for II := 0 to High(Results) do
        if Results[II].Length > 0 then Result := Result + Results[II] + ';';

//    for I := 0 to High(Results) do
//        if Results[I].Length > 0 then Result := Result + [Results[I]];

    SetLength(Results, 0);

end;

function SearchStringsInText2(const ValuesToSearch: TArray<string>;
                             const InText: string;
                             const CS: boolean = false): TArray<TDomainRec>;
var //Pool: TThreadPool;
    II, J: integer;
    Results: TArray<TDomainRec>;
begin
    SetLength(Result, 0);
    if Length(ValuesToSearch) = 0 then exit;
    if Length(InText) = 0 then exit;

    //SetLength(Results, Length(ValuesToSearch));
//    Pool := TThreadPool.Create;
//    I := GetCPUCount;
//    Pool.SetMinWorkerThreads(I * 2);
//    Pool.SetMaxWorkerThreads(I * 2);
//    Pool.SetMinWorkerThreads(1);
//    Pool.SetMaxWorkerThreads(1);
//    TParallel.For(0, High(ValuesToSearch), procedure (II: integer)
    //var strTemp: string;
    //begin
        for II := 0 to High(ValuesToSearch) do
        begin
        if CS = false
        then begin
                 Results := Results + FindAllEntries(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ');
//                 if ContainsText(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ') = true
//                 then begin
//                          strTemp := ValuesToSearch[II];
//                          Results := Results + [strTemp];
//                      end;
             end
        else begin
                 Results := Results + FindAllEntriesCS(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ');
//                 if ContainsStr(' ' + InText + ' ', ' ' + ValuesToSearch[II] + ' ') = true
//                 then begin
//                          strTemp := ValuesToSearch[II];
//                          Results := Results + [strTemp];
//                      end;
             end;
        end;
//    end, Pool);
//    Pool.Free;
    SetLength(Result, Length(Results));
    for J := 0 to High(Results) do
        Result[J] := Results[J];
    //Result := Results;

    SetLength(Results, 0);

    TArray.Sort<TDomainRec>(Result, TComparer<TDomainRec>.Construct(      //сортировка массива
                                 function (const Left, Right: TDomainRec): integer
                                 begin
                                     Result := Left.Count - Right.Count; //по количеству слов
                                 end
                                 ));
end;

function ClearStr2(const InStr: string): string; overload;
var s: string;
    //i: integer;
begin
    Result := '';
    if InStr.Length = 0 then Exit;
    s := NormalizeString(InStr);
    s := DeleteUselessSpaces(s);
    Result := Trim(s);
end;

function ClearStr2(const InStr: string; const A: array of string): string; overload;
var s: string;
    //i: integer;
begin
    Result := '';
    if InStr.Length = 0 then Exit;
    s := NormalizeString(InStr, A);
    s := DeleteUselessSpaces(s);
    Result := Trim(s);
end;

function NormalizeString(const InText: string; const ToLower: boolean = false): string; overload;
var I: integer;
begin
    Result := '';
    if InText.Length = 0 then Exit;

    for I := 1 to InText.Length do
    begin   //filter letters
        if (IsLetterOrDigit(InText[I]) = true)
        then Result := Result + InText[I]
        else Result := Result + ' ';
    end;
    if ToLower = true then Result := Result.ToLower;
end;

function NormalizeString(const InText: string;
                         const A: array of string; //---массив символов которые просто удаляются-------
                         const ToLower: boolean = false): string; overload;
var I: integer;
begin
    Result := '';
    if InText.Length = 0 then Exit;

    for I := 1 to InText.Length do
    begin   //filter letters
        if IndexStr(InText[I], A) > -1 then continue;

        if (IsLetterOrDigit(InText[I]) = true)
        then Result := Result + InText[I]
        else Result := Result + ' ';
    end;
    if ToLower = true then Result := Result.ToLower;
end;
//---получение данных из дерева--------------------------------
function GetDataFromTree(const StringWithDelimiters: string;      //строка с исходными данными
                         const DataTree: TAVLtree;                //дерево - справочник
                         const Delimiter: string = ';'): string;  //разделитель данных в строке
var TempParsingArray: TArray<string>;
    I: integer;
    DataFromTree: string;
begin
    Result := '';
    if StringWithDelimiters.Length = 0 then exit;

    TempParsingArray := StringWithDelimiters.Split([Delimiter], ExcludeEmpty);

    for I := 0 to High(TempParsingArray) do
    begin
        DataFromTree := DataTree.FindData(TempParsingArray[I].ToLower);
        if DataFromTree.Length > 0 then
            Result := Result + DataFromTree + Delimiter;
    end;
    SetLength(TempParsingArray, 0);
end;

function SearchDataInText(const ControlInfo, InText: string;
                          const DictArray: TArray<string>;
                          var DataFound: TArray<TDomainRec>;
                          const CS: boolean = false): string;
var strData: string;
    //arrData: TArray<TDomainRec>;
    I: integer;
begin
    Result := NODATAFOUND;
    SetLength(DataFound, 0);
    if ControlInfo.Length = 0 then exit;
    if InText.Length = 0 then exit;

    //strData := SearchStringsInText(DictArray, ClearStr2(InText), CS); //ищем названия городов в тексте
    //DataFound := SearchStringsInText2(DictArray, ClearStr2(InText, ['`', '''', '&#8217;', '’']), CS);
    DataFound := SearchStringsInText2(DictArray, InText, CS);
    for I := 0 to High(DataFound) do
        strData := strData + DataFound[I].DomainName + ';';
    if strData.Length = 0 then exit;
    //DataFound := strData;
    Result := ContainsText(strData, ControlInfo).ToString;
end;

//---получение данных о городах и штатах из текста------------------------------
function GetStatesAndCitiesFromSnippet(const Response: TBingResponse;
                                       //const JsonResults: TJSONparsingResults;
                                       const InText: string;
                                       const CitiesArray: TArray<string>;
                                       const CityTree: TAVLTree;
                                       const StatesFullNameArray: TArray<string>;
                                       const StatesAbbrNameArray: TArray<string>;
                                       const StatesTree: TAVLTree;
                                       const WorkAnyWay: boolean = false): TArray<string>;
var strTemp: string;
    WorkText: string;
begin
    WorkText := InText;
    //---ищем город---------
    SetLength(Result, 0);
    if Response.City.Length > 0 //если у нас есть название города
    then begin
             strTemp := SearchStringsInText(CitiesArray, ClearStr2(WorkText){, True }); //ищем названия городов в тексте
             if strTemp.Length = 0
             then Result := Result + [NODATAFOUND] //если данные не найдены
             else begin
                      //strTemp := GetDataFromTree(strTemp, CityTree); //получаем даннные о штатах в которых есть данные города
                      Result := Result + [ContainsText(strTemp, Response.City).ToString]; //совпадение названия штата
                  end;

         end
    else Result := Result + [NODATAFOUND];
    //---ищем штат----------
    if (Result[High(Result)] <> '-1') //<> '0'
    or (WorkAnyway = true)
    then begin
             if Response.State.Length > 0 //если у нас есть название штата
             then begin
                      strTemp := SearchStringsInText(StatesFullNameArray, ClearStr2(WorkText)); //ищем названия штатов в тексте
                      if strTemp.Length = 0 //если совпадений с полным названием штата не найдено
                      then begin
                               strTemp := SearchStringsInText(StatesAbbrNameArray, ClearStr2(WorkText), True);
                               if strTemp.Length = 0  //нет совпадений с аббревиатурой штата
                               then Result := Result + [NODATAFOUND]
                               else begin
                                        strTemp := GetDataFromTree(strTemp, StatesTree);
                                        Result := Result + [ContainsStr(strTemp, Response.State).ToString]; //совпадение аббревиатуры штата
                                    end;
                           end
                      else Result := Result + [ContainsText(strTemp, Response.State).ToString]; //совпадение названия штата
                  end
                  else Result := Result + [NODATAFOUND] //если название города не дано
         end;
end;

function FormSimpleHeader(const InResultsCount: integer; const OriginalHeader: string): string;
var I: integer;
    HeaderSL: TStringList;
begin
    //outputHeaderSL.Clear;
    HeaderSL := TStringList.Create;
    for I := 1 to InResultsCount do
    begin
        HeaderSL.Add(Format('%d%s',[I, 'Score']));
        HeaderSL.Add(Format('%d%s',[I, 'URL']));
    end;
    //---переводим заголовок из списка в строчку---
    Result := OriginalHeader + ',' + HeaderSL.CommaText;
    HeaderSL.Free;
end;

function FormSimpleOutputString(const Response: TBingResponse;
                                const SourceString: string;
                                const ResponseLimit: integer): string;
var K: integer;
begin
    Result := SourceString + ',';
    for K := Low(Response.topResultArr) to ResponseLimit do
    begin
        //if Response.topResultArr[K].arrUrl.Length > 0
        //then begin
                 Result := Result + Response.topResultArr[K].score.ToString + ',';
                 Result := Result + Response.topResultArr[K].displayUrl;
                 if K < ResponseLimit then Result := Result + ',';
        //     end;
    end;
end;

function FormOutputString(const Response: TBingResponse;
                          const SourceString: string;
                          const ResponseLimit: integer;
                          const URL_QA_modifier: boolean): string;
var K: integer;
begin
    Result := {Response.topResultArr[0].filed + ',' + SourceString + ',' +}
              Response.topResultArr[0].d1MS + ',' +
              '"' + Response.topResultArr[0].score.ToString.Replace('"',' ',[rfReplaceAll]) + '",' + //s1
              Response.topResultArr[0].phone1 + ',' +
              Response.topResultArr[0].phone2 + ',';

    for K := Low(Response.DirectoriesArr) to High(Response.DirectoriesArr) do
              begin
                  Result := Result + Response.DirectoriesArr[K] + ',';
              end;

    Result := Result + Response.topResultArr[0].calc + ',' +   //calc1
              Response.UsedQuery + ',' +              //SearchQuery
              Response.sResult.ToString + ',' +       //sResult
              Response.xCount.ToString + ',' +        //xCount
              Response.Name.Length.ToString + ',' +   //cLen
              
              //Response.topResultArr[0].phone_snippet + ',' +
              //Response.topResultArr[0].phone_website + ',' +
              '"' + Response.topResultArr[0].phone_source + '",';

              Result := Result + '"' + Response.topResultArr[0].domain.Replace('"',' ',[rfReplaceAll]) + '",';
              Result := Result + Response.ExcludedDomains + ',';

              for K := 2 to 3 do
              begin
                  Result := Result + '"' + Response.topResultArr[K - 1].domain.Replace('"',' ',[rfReplaceAll]) + '",' +         //domainN
                                     '"' + Response.topResultArr[K - 1].score.ToString.Replace('"',' ',[rfReplaceAll]) + '",' + //sN
                                           //Response.topResultArr[K - 1].ResNumber.ToString + ',' +                              //rN
                                           Response.topResultArr[K - 1].calc + ',';                                             //calcN
              end;

//              Result := Result + '"' + Response.facebook.Replace('"',' ',[rfReplaceAll]) + '",' +
//                                       Response.FBscore.ToString + ',' +
//                                 '"' + Response.linkedin.Replace('"',' ',[rfReplaceAll]) + '",' +
//                                       Response.LIscore.ToString + ',';

              for K := 4 to ResponseLimit do
              begin
                  Result := Result + '"' + Response.topResultArr[K - 1].domain.Replace('"',' ',[rfReplaceAll]) + '",' +    //domainN
                                     '"' + Response.topResultArr[K - 1].score.ToString.Replace('"',' ',[rfReplaceAll]) + '",'; // + //sN
                                           //Response.topResultArr[K - 1].ResNumber.ToString + ','        //rN
                                           //ResponseArray[I].topResultArr[K - 1].calc + ',';                                 //calcN
              end;

//              Result := Result + '"' + Response.twitter.Replace('"',' ',[rfReplaceAll]) + '",' +
//                                       Response.TWscore.ToString + ',' +
//                                 '"' + Response.instagram.Replace('"',' ',[rfReplaceAll]) + '",' +
//                                       Response.IGscore.ToString + ','; // +
                                 //'"' + Response.UsedCondition.Trim(['"']) + '",';

              Result := Result + Response.JSONfile + ',';
              if URL_QA_modifier = true then
                  for K := 1 to ResponseLimit do
                      Result := Result + Response.topResultArr[K - 1].URLqaMatch + ',';  //m

              Result := Result + '"' + Response.topResultArr[0].displayUrl.Replace('"',' ',[rfReplaceAll]) + '",' +        // url1
                                       Response.topResultArr[0].urlScore.ToString + ',' +                              // url1Score

                                 '"' + Response.topResultArr[0].arrWebName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[0].arrEntityName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[0].arrSnippet.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[0].arrDateLastCrawled.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[0].arrDateLastCached.Replace('"',' ',[rfReplaceAll]) + '",' +

                                 '"' + Response.topResultArr[1].displayUrl.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[1].arrWebName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[1].arrEntityName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[1].arrSnippet.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[1].arrDateLastCrawled.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[1].arrDateLastCached.Replace('"',' ',[rfReplaceAll]) + '",' +

                                 '"' + Response.topResultArr[2].displayUrl.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[2].arrWebName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[2].arrEntityName.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[2].arrSnippet.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[2].arrDateLastCrawled.Replace('"',' ',[rfReplaceAll]) + '",' +
                                 '"' + Response.topResultArr[2].arrDateLastCached.Replace('"',' ',[rfReplaceAll]) + '"';

end;
//---формирует список дублированных доменов-------------------------------------
procedure CreateDomainDuplicatesList(var ParsingResults: TArray<TJSONparsingResults>{TJSONresultsArray};
                                     const ddGroup, ddTreshold: integer;
                                     var DomainDuplicatesArr: TArray<string>);
var I, J: integer;
    intScoreArray: TArray<integer>;
begin
    for I := 0 to Min(ddGroup - 1, High(ParsingResults)) do
    begin
        if Length(DomainDuplicatesArr) = 0
        then J := -1
        else J := IndexStr(ParsingResults[I].domainName, DomainDuplicatesArr);

        if J = -1
        then begin
                 DomainDuplicatesArr := DomainDuplicatesArr + [ParsingResults[I].domainName];
                 intScoreArray := intScoreArray + [1];
             end
        else begin
                 intScoreArray[J] := intScoreArray[J] + 1;
             end;
    end;
    for I := High(intScoreArray) downto 0 do
        if intScoreArray[I] < ddTreshold then Delete(DomainDuplicatesArr, I, 1);

    SetLength(intScoreArray, 0);
end;

function CalculateScoreField(const parsingResults: TJSONparsingResults): integer;
begin
    Result := parsingResults.score +        //общий счёт
              parsingResults.deepLinksArr + //если есть ссылки deepLinks в json
              parsingResults.snippetScore +
              parsingResults.urlScore +
              parsingResults.osScore +
              parsingResults.ddbScore +
              parsingResults.nsScore +
              parsingResults.pos_N_Score +   //баллы за место в поисковой выдаче
              parsingResults.siuScore +      //state-in-url
              parsingResults.ciuScore +      //city-in-url
              //----------------------------------
              parsingResults.scsmmScore +
              //----------------------------------
              parsingResults.wcsmScore +
              parsingResults.wsmScore +
              parsingResults.wcsmmScore +
              parsingResults.wsmmScore +
              parsingResults.cowfnScore +
              parsingResults.cow1zScore +
              parsingResults.cow2zScore +
              parsingResults.cowfwmScore +
              parsingResults.aowScore +
              parsingResults.powScore +
              parsingResults.iwScore +
              parsingResults.iwerScore +
              parsingResults.f1wmScore +
              parsingResults.f2wmScore +
              parsingResults.f3wmScore
              ;
end;

function FormCalcFieldForOutput(const parsingResults: TJSONparsingResults): string;
const
CALC_FIELD_FORMAT = 'url+%d; cdem+%d; isd+%d; cid+%d; ddb+%d; os+%d; dl+%d; ' +
                        's+%d; ns+%d; pos%d+%d; siu+%d; ciu+%d; scsmm+%d; ' +
                        'wcsm+%d; wsm+%d; wcsmm+%d; wsmm+%d; cowfn+%d; cow1z+%d; cow2z+%d; ' +
                        'cowfwm+%d; aow+%d; pow+%d; input+%d; iwer+%d; ' +
                        'f1wm+%d; f2wm+%d; f3wm+%d;';
begin
    Result := Format(CALC_FIELD_FORMAT,[
                  {1}   parsingResults.onlyURLscore, //url+%d
                  {2}   parsingResults.cdemScore,    //cdem+%d
                  {3}   parsingResults.isdScore,     //isd+%d
                  {4}   parsingResults.cidScore,     //cid+%d
                  {5}   parsingResults.ddbScore,     //ddb+%d
                  {6}   parsingResults.osScore,      //os+%d
                  {7}   parsingResults.deepLinksArr, //dl+%d  //direct links from request
                  {8}   parsingResults.snippetScore, //s+%d
                  {9}   parsingResults.nsScore,      //ns+%d
                  {11}  parsingResults.ResNumber,    //pos%d+%d//KK + 1,   //для вывода № места в поисковой выдаче
                  {12}   parsingResults.pos_N_Score, //pos%d+%d            //баллы за место в поисковой выдаче
                  {13}   parsingResults.siuScore,    //siu+%d
                  {14}   parsingResults.ciuScore,    //ciu+%d
                     //------------------------------------
                  {15}   parsingResults.scsmmScore,  //scsmm+%d
                     //------------------------------------
                  {16}   parsingResults.wcsmScore,   //wcsm+%d
                  {17}   parsingResults.wsmScore,    //wsm+%d
                  {18}   parsingResults.wcsmmScore,  //wcsmm+%d
                  {19}   parsingResults.wsmmScore,   //wsmm+%d
                  {20}   parsingResults.cowfnScore,  //cowfn+%d
                  {21}   parsingResults.cow1zScore,  //cow1z+%d
                  {22}   parsingResults.cow2zScore,  //cow2z+%d
                  {23}   parsingResults.cowfwmScore, //cowfwm+%d
                  {24}   parsingResults.aowScore,    //aow+%d
                  {25}   parsingResults.powScore,    //pow+%d
                  {26}   parsingResults.iwScore,     //iw+%d
                  {27}   parsingResults.iwerScore,   //iwer+%d
                         parsingResults.f1wmScore,
                         parsingResults.f2wmScore,
                         parsingResults.f3wmScore
                     ]);
    Result := Result.Replace('+-','-',[rfReplaceAll]);
end;

function CountWords(const InText: string): integer;
var SplittedText: TArray<string>;
begin
    Result := 0;
    if InText.Length = 0 then exit;

    SplittedText := InText.Split([' '], ExcludeEmpty);
    Result := Length(SplittedText);
    SetLength(SplittedText, 0);
end;

procedure SortStringArray(var InArray: TArray<string>);
begin
    TArray.Sort<string>(InArray, TComparer<string>.Construct(      //сортировка массива
                                 function (const Left, Right: string): integer
                                 begin
                                     Result := CountWords(Right) - CountWords(Left); //по количеству слов

                                     if Result = 0 then Result := AnsiCompareStr(Left, Right);  //по длине строки
                                 end
                                 ));
end;

function NormalizeCompanyName(const InText: string;
                              const LengthInWords: integer;
                              const ModifiersArray: TArray<string>): string;
var I: integer;
    strWork: string;
begin
    Result := '';
    if LengthInWords = 0 then exit;
    if InText.Length = 0 then exit;

    strWork := ' ' + InText + ' ';
    strWork := strWork.Replace('&', ' ', [rfReplaceAll]);
    strWork := strWork.Replace(' and ', ' ', [rfReplaceAll]);

    if CountWords(InText) > LengthInWords
    then begin
             for I := 0 to High(ModifiersArray) do
                 strWork := strWork.Replace(' ' + ModifiersArray[I] + ' ', ' ', [rfReplaceAll, rfIgnoreCase]);
         end;
    Result := DeleteUselessSpaces(strWork).Trim;
end;

function GetNumbers(const Value: string): string;
var
    ch: char;
    Index, Count: integer;
begin
    Result := '';
    SetLength(Result, Length(Value));
    Count := 0;
    for Index := 1 to length(Value) do
    begin
        ch := Value[Index];
        if (ch >= '0') and (ch <='9') then
        begin
            inc(Count);
            Result[Count] := ch;
        end;
    end;
    SetLength(Result, Count);
end;

function FindCityStatePairs(const CityArr, StateArr: TArray<TDomainRec>): TArray<TPairRec>;
var I, J: integer;
    StartBorder, EndBorder: integer;
    //arrTemp: TArray<TPairRec>;
begin
    SetLength(Result, 0);
    for I := 0 to High(CityArr) do
    begin
        for J := 0 to High(StateArr) do
        begin
            if CityArr[I].Count < StateArr[J].Count then
            begin
                StartBorder := CityArr[I].Count;
                //EndBorder := StartBorder + StateArr[J].DomainName.Length + 5;
                EndBorder := StartBorder + CityArr[I].DomainName.Length + 5;
                if ((StartBorder <= StateArr[J].Count) and (EndBorder >= StateArr[J].Count))
                then begin
                         Result := Result + [TPairRec.Create(CityArr[I].DomainName, StateArr[J].DomainName)];
//                         SetLength(Result, Length(Result) + 1);
//                         Result[High(Result)].City := CityArr[I].DomainName;
//                         Result[High(Result)].State := StateArr[J].DomainName;
                     end;
            end;

            if StateArr[J].Count < CityArr[I].Count then
            begin
                StartBorder := StateArr[I].Count;
                //EndBorder :=  StartBorder + CityArr[J].DomainName.Length + 5;
                EndBorder :=  StartBorder + StateArr[J].DomainName.Length + 5;
                if ((StartBorder <= CityArr[J].Count) and (EndBorder >= CityArr[J].Count))
                then begin
                         Result := Result + [TPairRec.Create(CityArr[I].DomainName, StateArr[J].DomainName)];
//                         SetLength(Result, Length(Result) + 1);
//                         Result[High(Result)].City := CityArr[I].DomainName;
//                         Result[High(Result)].State := StateArr[J].DomainName;
                     end;
            end;
        end;
    end;
end;

procedure NormalizeStatesArr(var StateArr: TArray<TPairRec>; const StatesTree: TAVLTree);
var I: integer;
    strTemp: string;
begin
    for I := 0 to High(StateArr) do
    begin
        if StateArr[I].State.Trim.Length > 2 then continue; //обрабатываем только аббревиатуру

        strTemp := StatesTree.FindData(StateArr[I].State.Trim.ToLower);
        if Length(strTemp) > 0
        then StateArr[I].State := strTemp;
    end;
end;

function DetectAndExtractPhoneNumber(const InText: string): TArray<string>;
var
    regex: TRegEx;
    match: TMatch;
    matches: TMatchCollection;
    i: Integer;
begin
    Result := nil;
    i := 0;
    //regex := TRegEx.Create('((\(\d{3}\)?)|(\d{3}))([\s-./]?)(\d{3})([\s-./]?)(\d{4})',[roCompiled, roSingleLine]);
    regex := TRegEx.Create('\b((\(\d{3}\)?)|(\d{3}))([\s-.\/]?)(\d{3})([\s-.\/]?)(\d{4})\b',[roCompiled, roSingleLine]);
    matches := regex.Matches(InText);
    if matches.Count > 0 then
    begin
        SetLength(Result, matches.Count);
        for match in matches do
        begin
            Result[i] := match.Value;
            Inc(i);
            //ArrAddUniqueValue(Result, match.Value);
        end;
    end;
end;

function RemoveFromLeft(const InValue: string;
                        const A: array of string;
                        const IgnoreCase: boolean = true): string;
var partWasFound: boolean;
    I: integer;
    strWork: string;
begin
    Result := '';
    if InValue.Length = 0 then exit;
    strWork := InValue;

    repeat
        partWasFound := false;
        for I := Low(A) to High(A) do
        begin
            if strWork.StartsWith(A[I], IgnoreCase) = true then
            begin
                strWork := strWork.Remove(0, A[I].Length);
                partWasFound := true;
            end;
        end;
    until partWasFound = false;
    Result := strWork;
end;
(*
function DetectAndExtractPhoneNumber(const InText: string{; var OriginalText: TArray<string>}): TArray<string>;

const MaxInterval = 1;
      MinLength = 10;
      MaxLength = 12;
      PhonePossibleStart: TArray<string> = ['(', '+'];

var strWork, strTemp: string;
    I, J, Counter, SpaceCounter: integer;
    arrWork: TArray<Char>;
    arrResults, strPhoneComp: TArray<string>;
    ElementsLength: TArray<integer>;
    PhoneLength, PhoneStart, PhoneEnd: integer;
begin
    SetLength(Result, 0);
    if InText.Length = 0 then exit;
    arrWork := ClearStr(InText).ToCharArray;
    if Length(arrWork) = 0 then exit;

    Counter := 0;
    SpaceCounter := 0;
    strWork := '';
    //SetLength(arrResults, 1);
    //---собираем что-нибудь похожее на телефонные номера----
    for I := Low(arrWork) to High(arrWork) do
    begin
        if arrWork[I].IsDigit = true
        then begin
                 inc(Counter);
                 if SpaceCounter = MaxInterval then strWork := strWork + ' ';

                 strWork := strWork + arrWork[I];
                 SpaceCounter := 0;
             end
        else begin
                 inc(SpaceCounter);

                 if strWork.Length > MaxLength then strWork := '';

                 if (SpaceCounter > MaxInterval)
                 and (strWork.Length > 0)
                 and (strWork.Length <= MaxLength)
                 then begin
                          arrResults := arrResults + [strWork];
                          ElementsLength := ElementsLength + [Counter];
                          Counter := 0;
                          strWork := '';
                      end;
             end;

    end;
    if strWork.Length > 0
    then begin
             arrResults := arrResults + [strWork];
             ElementsLength := ElementsLength + [Counter];
             Counter := 0;
             strWork := '';
         end;

    SetLength(arrWork, 0);
    //---очистка данных от предполагаемых нетелефонных номеров
    for I := 0 to High(arrResults) do
    begin
        SetLength(strPhoneComp, 0);

        strPhoneComp := arrResults[I].Split([' ']);  //---пытаемся разделить номер на части--

        if ElementsLength[I] > MaxLength  //---если количество найденных связанных цифр больше чем---
        then begin                        //---максимальная длина телефонного номера-----------------
                 if Length(strPhoneComp) = 1 then continue;  //если часть всего одна и её длина больше максимальной - игнорируем

                 if Length(strPhoneComp) > 1   //если частей несколько проверяем их длины
                 then begin
                          for J := High(strPhoneComp) downto 0 do
                          begin
                              if Length(strPhoneComp) = 0 then break;

                              if Length(strPhoneComp[J]) >= 5 //если длина части больше 5ти - удаляем её
                              then begin
                                       ElementsLength[I] := ElementsLength[I] - strPhoneComp[J].Length;
                                       Delete(strPhoneComp, J, 1);
                                       arrResults[I] := string.Join(' ', strPhoneComp);
                                       strPhoneComp := arrResults[I].Split([' ']);  //---пытаемся разделить номер на части--
                                   end;
                          end;
                      end;

             end;
        if Length(strPhoneComp) = 0 then continue;


        //---если длина последнего элемента < 4 - это не телефон----------------
        if strPhoneComp[High(strPhoneComp)].Length < 4 then continue;

        //---если не отделяется от текста пробелами или знаками препинания - значит это не телефон
        PhoneStart := InText.IndexOf(strPhoneComp[0]);
        PhoneEnd := InText.IndexOf(strPhoneComp[High(strPhoneComp)]) +
                                               strPhoneComp[High(strPhoneComp)].Length + 1;

        if IsLetterOrDigit(InText[PhoneEnd]) = true then continue;
            if PhoneStart > 0 then
                if IsLetterOrDigit(InText[PhoneStart]) = true then continue;

        //strTemp := InText[PhoneStart];
//        if PhoneStart > 0 then
//            if IndexStr(InText[PhoneStart], PhonePossibleStart) > -1
//            then PhoneStart := PhoneStart - 1;
//
//        OriginalText := OriginalText + [InText.Substring(PhoneStart, PhoneEnd - PhoneStart)];

        if (ElementsLength[I] >= MinLength)
        and (ElementsLength[I] <= MaxLength)
        then Result := Result + [arrResults[I]];

        SetLength(strPhoneComp, 0);
    end;
    SetLength(ElementsLength, 0);
    SetLength(arrResults, 0);
end;  *)

function DeleteDuplicatesFromPhoneArray(const InArray: TArray<string>; const Normalize: boolean = true): TArray<string>;
var I: integer;
    strTemp: string;
begin
    for I := 0 to High(InArray) do
    begin
        strTemp := InArray[I];
        if Normalize = true then strTemp := GetNumbers(strTemp);

        if IndexStr(strTemp, Result) = -1 then
            Result := Result + [strTemp];
    end;
end;

function StandartizePhone(const InPhone: string): string;
begin
    Result := InPhone;
    Insert('-', Result, InPhone.Length - 3);
    INsert('-', Result, InPhone.Length - 6);
    if InPhone.Length > 10 then
        INsert('-', Result, InPhone.Length - 9);
end;

function FindBingDescr(const BingCode: integer): string;
var I: integer;
    strTemp: string;
begin
    Result := '';
    for I := 0 to High(BingAPIanswers) do
    begin
        strTemp := BingAPIanswers[I];
        if BingCode = strTemp.Substring(0, strTemp.IndexOf('=')).ToInteger
        then begin
                 Result := strTemp.Substring(strTemp.IndexOf('=') + 1, MaxInt);
                 if Result.IndexOf(',') > -1 then
                 begin
                     if Result.StartsWith('"') = false then Result := '"' + Result;
                     if Result.EndsWith('"') = false then Result := Result + '"';
                 end;
                 break;
             end;
    end;
end;

//---добавление в строковый массив уникального значения-------------------------
function ArrAddUniqueValue(var InArray: TArray<string>; Value: string): boolean;
begin
    Result := false;
    if Value.Length > 0 then
        if IndexText(Value, InArray) = - 1
        then begin
                 InArray := InArray + [Value];
                 Result := true;
             end;
end;

//---вычисление баллов для названия страницы (или названия сайта)---------------
//---url и имя компании должны быть в нормализованном виде----------------------
function WordMatchCount(const InUrl, InCompanyName: string): integer;
var Words: TArray<string>;
    WordPos: TArray<integer>;
    I: integer;
begin
    Result := 0;
    if InUrl.Length = 0 then exit;
    if InCompanyName.Length = 0 then exit;
    //---разделяем строку на массив--------------------
    Words := InCompanyName.Split([' '], ExcludeEmpty);
    SetLength(WordPos, Length(Words));
    for I := Low(Words) to High(Words) do
    begin
        WordPos[I] := InUrl.IndexOf(Words[I]);
        if WordPos[I] > -1
        then Inc(Result)
        else Exit;
    end;
    SetLength(Words, 0);
    SetLength(WordPos, 0);
end;

function SortPageName(const InValue: string): string;
var PagesArr: TArray<string>;
begin
    Result := InValue;
    if InValue.Length = 0 then exit;

    PagesArr := InValue.Split([';'], '{', '}', ExcludeEmpty);

    if Length(PagesArr) = 1
    then begin
             SetLength(PagesArr, 0);
             Exit;
         end;

    TArray.Sort<string>(PagesArr, TComparer<string>.Construct(      //сортировка массива
                                 function (const Left, Right: string): integer
                                 var LeftScore, RightScore: integer;
                                     strTemp: string;
                                 begin
                                     strTemp := Left.Substring(Left.LastIndexOf(',') + 1).Trim(['{','}']);
                                     LeftScore := strTemp.ToInteger;
                                     strTemp := Right.Substring(Right.LastIndexOf(',') + 1).Trim(['{','}']);
                                     RightScore := strTemp.ToInteger;

                                     Result := RightScore - LeftScore; //по количеству слов

                                     //if Result = 0 then Result := AnsiCompareStr(Left, Right);  //по длине строки
                                 end
                                 ));
    Result := string.Join(';', PagesArr);
end;

//---поиск страничек в социальных сетях-----------------------------------------
function ProcessDirectories(exclDirArr: TArray<string>;
                            var A: TArray<TJSONparsingResults>;
                            const NormCompName: string;
                            SR: TScoreRecord
                           ): TArray<string>;
var I, J, K, M: integer;
    Score: integer;
    firstLevDom, clrDomain, clrURL, strTemp: string;
    EmptyElement: TJSONparsingResults;
    clrDomainArr: TArray<string>;
begin
    SetLength(Result, 0);
    SetLength(Result, Length(exclDirArr));
    if Length(exclDirArr) = 0 then exit;

    for I := 0 to High(exclDirArr) do
    begin
//        J := exclDirArr[I].LastIndexOf('.');
//        if J > -1
//        then begin
                 //firstLevDom := exclDirArr[I].Substring(J + 1);
                 //if ((firstLevDom.Length = 2) or (firstLevDom.Length = 3))
                 //then begin
                          //clrDomain := exclDirArr[I].Substring(0, J);
                          //clrDomain := ClearStr2(clrDomain).ToLower;
                          clrDomainArr := exclDirArr[I].Split([','], '{', '}', ExcludeEmpty);
                          for J := 0 to High(clrDomainArr) do
                          begin
                              clrDomain := ClearStr2(clrDomainArr[J]).ToLower;
                              for K := Low(A) to High(A) do
                              begin
                                  clrURL := ClearStr2(A[K].displayUrl).ToLower;
                                  if clrURL.Contains(clrDomain) = true
                                  then begin
                                           //Result := Result + [clrDomain + ':' + A[K].arrUrl];
                                           Score := 0;
                                           strTemp := RemoveFromLeft(A[K].url{displayUrl}, ['http://', 'https://', 'www.'], true);
                                           M := WordMatchCount(ClearStr2(strTemp).ToLower.Replace(clrDomain,'') , NormCompName.ToLower);
                                           case M of
                                               1: Score := SR.f1wmScore;
                                               2: Score := SR.f2wmScore;
                                               3..99: Score := SR.f3wmScore;
                                           end;

                                           Result[I] := Result[I] + Format('{%s,%d};', [strTemp, Score]);
                                       end;
                              end;
                          end;
                          SetLength(clrDomainArr, 0);
                      //end;
//             end;
        Result[I] := SortPageName(Result[I]);
        Result[I] := SetQuotesI(Result[I]);
    end;

//    for I := 0 to High(exclDirArr) do
//    begin
//        Result[I] := SetQuotesI(Result[I]);
//    end;
end;

//---загрузка файла с исключениями--------------------------------------
procedure UploadExcludesConfig(const InFile: string;
                               var exclUrlArr: TArray<string>;  //---массив с исключениями урл
                               var exclDirArr: TArray<string>;  //---массив с доменами социальных сетей
                               var exclNamArr: TArray<string>;  //---массив с исключениями в имени
                               var exclKeyArr: TArray<string>   //---массив с исключениями-ключевыми словами
                              );
const Delim = '=';
var I: integer;
    TempSL: TStringList;
    strParam, strSubParam: string;
begin
    TempSL := TStringList.Create;
    TempSL.LoadFromFile(EXCLUDESFILECONST);
    for I := 0 to TempSL.Count - 1 do
    begin
        if Length(TempSL[I]) = 0 then continue;
        if Pos(';', TempSL[I]) = 1 then continue;
        if TempSL[I].Contains(Delim) = false then continue;

        strParam := ExtractParameter(TempSL[I], Delim);
        strSubParam := ExtractSubParameter(TempSL[I], Delim);

        if strParam = URL_EXCLUDENAME then exclUrlArr := exclUrlArr + [strSubParam];

        if strParam = DIR_EXCLUDENAME then exclDirArr := exclDirArr + [strSubParam];

        if strParam = NAME_EXCLUDENAME then exclNamArr := exclNamArr + [strSubParam];

        if strParam = KEY_EXCLUDENAME then exclKeyArr := exclKeyArr + [strSubParam];
    end;
    TempSL.Free;
end;

//---загрузка файла с ключами-------------------------------------------
function UploadFillerConfig(const InFile: string): TFillerConfigSettings;

function GetInteger(const InStr: string; const DefValue: integer): integer;
begin
    try
        Result := ExtractSubParameter(InStr, '=').Trim.ToInteger;
    except
        Result := DefValue;
    end;
end;

var I: integer;
    TargetsSL: TStringList;
begin
    TargetsSL := TStringList.Create;
    TargetsSL.LoadFromFile(InFile);
    for I := 0 to TargetsSL.Count - 1 do
    begin
        if Length(TargetsSL[I]) = 0 then continue;
        if Pos(';', TargetsSL[I]) = 1 then continue;
        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('ApplicationID', True) = true then
            Result.AppID := ExtractSubParameter(TargetsSL[I], '=').Trim([' ']);
        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('URIBASE', True) = true  then
            Result.BaseURL := ExtractSubParameter(TargetsSL[I], '=').Trim([' ']);

        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('MaxAPICallsPerSecond', True) = true
        then Result.MaxPerSecond := GetInteger(TargetsSL[I], CICLECOUNTER);

        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('MaxThreads', True) = true
        then Result.MaxThreads := GetInteger(TargetsSL[I], MAXTHREAD);

        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('MaxPagesPerSite', True) = true
        then Result.MaxPagesPerSite := GetInteger(TargetsSL[I], MAX_PAGES_PER_SITE);

        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('MaxDepthPerSite', True) = true
        then Result.MaxDepthPerSite := GetInteger(TargetsSL[I], MAX_DEPTH_PER_SITE);

        //----------------------------------------------------------------------
        if TargetsSL[I].StartsWith('MaxPageSize', True) = true
        then begin
                 Result.MaxPageSize := GetInteger(TargetsSL[I], MAX_PROC_PAGE_SIZE);
                 Result.MaxPageSize := Result.MaxPageSize * 1024;
             end;
    end;
    TargetsSL.Free;
end;

//---загрузка файла с телефонными зонами--------------------------------
procedure UploadAreaCodes(const InFile: string; var PhoneCodesTree: TAVLTree);
var I: integer;
    TempSL: TStringList;
    TempParsingArray: TArray<string>;
    SearchTreeNode: TAVLTreeNode;
begin
    TempSL := TStringList.Create;
    TempSL.LoadFromFile(AREACODES);
    PhoneCodesTree := TAVLTree.Create(false);

    for I := 0 to TempSL.Count - 1 do
    begin
        if Length(TempSL[I]) = 0 then continue;
        if Pos(';', TempSL[I]) = 1 then continue;

        TempParsingArray := TempSL[I].Split([','], ExcludeEmpty); //0 - код, 1 - штат, 2 - город
        SearchTreeNode := PhoneCodesTree.FindOrInsert(TempParsingArray[0], TempParsingArray[1]);
    end;
    TempSL.Free;
    SearchTreeNode := nil;
    SetLength(TempParsingArray, 0);
end;

end.

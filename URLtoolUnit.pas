unit URLtoolUnit;

interface

uses
    Definitions,
    mAVLTree,
    UILessUnit,
    Tools,
    System.SysUtils,
    System.Classes,
    System.Variants,
    System.Threading,
    System.Types,
    System.StrUtils,
    RegularExpressions,
    MSHTML,
    ComObj,
    ActiveX,
    Winapi.Windows,
    IdHTTP,
    IdSSLOpenSSL, IdSSLOpenSSLHeaders,
    IdCookieManager,
    IdExceptionCore,
    IdException,
    IdStack,
    IdURI,
    System.IOUtils;


function GetURL(const InURL, InUserAgent: string;
                const InHTTPcodes: TStringList;
                const WriteLog: boolean = false): THttpResponse;
function GetUrlLight(const InURL, InUserAgent: string; const WriteLog: boolean = false): string;
function ParseHTML(const InURL, InBody: string;
                   const InTargetsArr: TTargetsArr;
                   var OutLinksArray: TArray<string>;
                   var OutInnerText: string;
                   const WriteLog: boolean = false
                   ): boolean;

//---извлекаем текст с html страницы-------------------
function ParseHTMLlight(const InBody: string; const WriteLog: boolean = false): string;

//---извлекаем текст с html странички и нормализуем----
function ParseHTMLlightNorm(RawHTMLstring: string;
                            const A: array of string;
                            const WriteLog: boolean = false): string;

type
  TIdHTTPRedirect = class
  public
      class procedure IdHTTPRedirect(Sender: TObject; var dest: string; var
                                      NumRedirect: Integer; var Handled: Boolean; var VMethod: string);
  end;

var URLToolUnitErrorLogDir: string;

implementation

class procedure TIdHTTPRedirect.IdHTTPRedirect(Sender: TObject; var dest: string; var
    NumRedirect: Integer; var Handled: Boolean; var VMethod: string);
begin
   Handled := True;
   //WriteLn(dest);
end;

function ProcessMessage(var Msg: TMsg): Boolean;
var
    //Handled: Boolean;
    Unicode: Boolean;
    MsgExists: Boolean;
begin
    Result := False;
    if PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE) = true then
    begin
        Unicode := (Msg.hwnd = 0) or IsWindowUnicode(Msg.hwnd);
        if Unicode then
            MsgExists := PeekMessageW(Msg, 0, 0, 0, PM_REMOVE)
        else
            MsgExists := PeekMessageA(Msg, 0, 0, 0, PM_REMOVE);

        if MsgExists then
        begin
            Result := True;
            TranslateMessage(Msg);
            if Unicode then
                DispatchMessageW(Msg)
            else
                DispatchMessageA(Msg);
        end;
    end;

end;

function OccurrencesEx(const Substring, Text: string; const Count: integer): boolean;
var
    i, offset: integer;
begin
    i := 0;
    result := true;
    offset := PosEx(Substring, Text, 1);
    while offset <> 0 do
    begin
        inc(i);
        if i > Count then
        begin
            result := false;
            exit;
        end;
        offset := PosEx(Substring, Text, offset + length(Substring));
    end;
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

function GetURL(const InURL, InUserAgent: string;
                const InHTTPcodes: TStringList;
                const WriteLog: boolean = false): THttpResponse;
const TIME_LIMIT = 180000; {240000  120000}
var
    TimeStart, TimeEnd: double;
    RespTime, strTemp, strIP, VerificationTime{, strTempURL}: string;
    WorkURL, {InURLforIP, }isSecure, HTMLtext: string;
    //ContentSL: TStringList;
    i, NumOfAttempts: integer;
    HTTP: TIdHTTP;
    HandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    CookieMgr: TIdCookieManager;
    task: ITask;
begin
    //try
    Result := CHttpResponse; //---обнуление
    if InURL.Length = 0 then exit;

    VerificationTime := FormatDateTime('dd.mm.yyyy hh.nn.ss', Now);
    isSecure := '';
    NumOfAttempts := 0;

//    WorkURL := InURL.Trim(['"']);
//    i := Pos('/', WorkURL);
//    if i > 0
//        then InURLforIP := Copy(WorkURL, 1, i - 1)
//        else InURLforIP := WorkURL;
//    strIP := GetIP(InURLforIP);

    Result.Position := -1;
    Result.URL := WorkURL;
    Result.IP := IPNULL;
    Result.Verified := VerificationTime;
    Result.StatusCode := -1;
    //Result.RedirectsCount := 0;
    //Result.FullURL := '';
    //Result.LastStatus := '';
    Result.TimeMS := '-1';
    Result.SizeFromHeader := -1;
    Result.SizeFromCalc := -1;
    Result.IP := strIP;
//==============================================================================
//    strTempURL := StringReplace(WorkURL , 'www.', '', [rfIgnoreCase]);
//    strTempURL := 'http://www.' + strTempURL;
    try
        TimeStart := Now;

        HTTP := TIdHTTP.Create(nil);
        HTTP.Name := 'IdHTTP';
        IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));
        //HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        HandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        HandlerSocket.SSLOptions.SSLVersions := [sslvSSLv23];
        //HandlerSocket.SSLOptions.SSLVersions := [sslvSSLv3]; ---не работает---
        //HandlerSocket.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
//        with HandlerSocket do
//        begin
//            SSLOptions.Method := sslvSSLv23;
//            SSLOptions.Mode := sslmClient;
//            //SSLOptions.VerifyMode := [sslvrfPeer];
//            SSLOptions.VerifyDepth := 0;
//            //OnVerifyPeer := SSLIOHandlerVerifyPeer;
//        end;

        HTTP.IOHandler := HandlerSocket;

        CookieMgr := TIdCookieManager.Create(nil);
        HTTP.AllowCookies := True;
        HTTP.CookieManager := CookieMgr;
        //HTTP.CookieManager := TIdCookieManager.Create(nil);

        HTTP.HandleRedirects := True;
        HTTP.RedirectMaximum := 35;
        HTTP.Request.UserAgent := InUserAgent;
            //'Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) Gecko/20100101 Firefox/4.0b8';
        HTTP.Request.AcceptLanguage := 'en-US,en;q=0.5';
        HTTP.HTTPOptions := [hoForceEncodeParams];
        HTTP.OnRedirect := TIdHTTPRedirect.IdHTTPRedirect;

        HTTP.ConnectTimeout := TIME_LIMIT {180000 120000};
        HTTP.ReadTimeout := TIME_LIMIT{180000 120000};
        HTTP.Request.Connection := 'close';  //'keep alive'
        HTTP.Request.CustomHeaders.Add('Upgrade-Insecure-Requests: 1');
//        task := TTask.Create(procedure ()
//        begin
//            //Выполняем задачу 3 секунды.
//            Sleep(TIME_LIMIT);
//            //Задача выполнена!
//            raise EIdReadTimeout.Create('Error Read TimeOut');
//        end);
//        task.Start;

        //ContentSL := TStringList.Create;
        try
            try
                //ContentSL.Text := HTTP.Get(strTempURL);
                //for I := 1 to MAX_NUMBER_OF_ATTEMPTS do
                //begin
                    //HTTP.Head(InURL);
                    //Result.SizeFromHeader := HTTP.Response.ContentLength;
                    //if HTTP.Response.ContentLength <= 524288
                    {then} HTMLtext := HTTP.Get(InURL);
                    //else Result.Error := Format('Maximum page size exceeded: %s', [InURL]);
                    //if Length(HTMLtext{ContentSL.Text}) > 0 then
                    //begin
                        if HTMLtext.Length > 524288 then Result.Error := Format('Maximum page size exceeded: %s', [InURL]);
                        if Result.SizeFromHeader = -1 then Result.SizeFromHeader := HTTP.Response.ContentLength;

                        Result.Server := HTTP.Response.Server;
                        Result.StatusCode  := HTTP.ResponseCode;
                        //Result.RawHTMLstring := LowerCase(ContentSL.Text);
                        Result.RawHTMLstring := HTMLtext{ContentSL.Text};


                    //end;
                    inc(NumOfAttempts);
//                    if Pos('<head>', ContentSL.Text) > 0 then break;
//                    if Pos('<body>', ContentSL.Text) > 0 then break;
//                    if Pos('<script>', ContentSL.Text) > 0 then break;
//                    sleep(500);
                    //ContentSL.Clear;
                //end;

                Result.RedirectsCount := HTTP.RedirectCount;
                Result.FullURL := HTTP.URL.GetFullURI;
                if (HTTP.ResponseCode >= 200) and (HTTP.ResponseCode < 400) then
                    Result.LastStatus := 'T';
            except
                on E: EIdHTTPProtocolException do
                    Result.StatusCode := http.ResponseCode;

                on E: EIdSocketError do
                    Result.Error := '"Indy raised a socket error! Error code: '
                                    + IntToStr(E.LastError) +
                                    ' Error message: ' + E.Message + '"';

                on E: EIdReadTimeout do
                    Result.Error := '"Indy reports, Error Read TimeOut"';

                on E: EIdConnectTimeout do
                    Result.Error := '"Indy reports, Error Connect TimeOut"';

                on E: EIdConnClosedGracefully do
                    Result.Error := '"Indy reports, that connection was closed gracefully!"';

                on E: EIdException do
                    Result.Error := '"Indy raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';

                on E: Exception do
                    Result.Error := '"A non-Indy related exception has been raised! ' +
                                    'Error message: ' + E.Message + '"';

                on E: EIdOSSLCouldNotLoadSSLLibrary do
                    Result.Error := '"Indy raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';
                on E: EIdOSSLConnectError do
                    Result.Error := '"Indy raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';
                on E: EIdUnknownProtocol do
                    Result.Error := '"Indy raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';
                on E: EIdURIException do
                    Result.Error := '"Indy raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';

                on E: EConvertError do
                    Result.Error := '"GET function raised an exception! ' +
                                    ' Exception class: ' + E.ClassName +
                                    ' Error message: ' + E.Message + '"';
            end;
            Result.Error := StringReplace(Result.Error, #13#10,' ',[rfReplaceAll]);

        finally
            if HTMLtext.Length > 0 then
                strTemp := HTTP.URL.GetFullURI; //IdHTTP1.Response.Location
            if Pos('https:', strTemp) = 1 then isSecure := 'T';
            Result.Secure := isSecure;

            //if HTTP.Connected then  HTTP.Disconnect;
            if Assigned(HandlerSocket) then HandlerSocket.Free;
            if Assigned(CookieMgr) then CookieMgr.Free;
            if Assigned(HTTP) then HTTP.Free;
        end;

        TimeEnd := Now;
//==============================================================================
        RespTime := FormatDateTime('ss.zzz', TimeEnd - TimeStart);
        Result.Attempts := NumOfAttempts;
        Result.TimeMS := RespTime;

//        if Length(Result.RawHTMLstring) > 0 then
//        begin
//            Result.DistrictName := GetPercentage(Result.RawHTMLstring, InText.Values['DN'], Result.fNAME);
//            Result.City := GetPercentage(Result.RawHTMLstring, InText.Values['C'], Result.fCity);
//            Result.State := GetPercentage(Result.RawHTMLstring, InText.Values['S'], Result.fST);
//            Result.Phone := GetPercentage(Result.RawHTMLstring, InText.Values['P'], Result.fPHONE);
//            Result.Address1 := GetPercentage2(Result.RawHTMLstring, InText.Values['A1'], Result.fADDR);
            Result.SizeFromCalc := Length(Result.RawHTMLstring);
//        end;

        if Pos(',', Result.Server) > 0 then
        begin
            Result.Server := StringReplace(Result.Server,'"',' ',[rfReplaceAll]);
            Result.Server := '"' + Result.Server + '"';
        end;

    finally
        //if Assigned(ContentSL) then ContentSL.Free;

        if ((Result.StatusCode <> -1) and (Result.StatusCode <> 200)) then
            if Length(Result.Error) = 0 then
                Result.Error := '"' + InHTTPcodes.Values[IntToStr(Result.StatusCode)] + '"';

        if WriteLog = true then
            if Result.Error.Length > 0 then
                if Result.StatusCode = -1 then
                    TFile.WriteAllText(URLToolUnitErrorLogDir + PrepareFileName(InURL)+ ' ' + Random(1000).ToString + '.uu_errlog', Format('%d: %s', [Result.StatusCode, Result.Error]), TEncoding.UTF8);
    end;
end;

function GetUrlLight(const InURL, InUserAgent: string; const WriteLog: boolean = false): string;
var
    HTTP: TIdHTTP;
    //HTML: TIdHTML;
    HandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    CookieMgr: TIdCookieManager;
    i{, NumOfAttempts}: integer;
    ContentString, ErrorString: string;
    Done: boolean;
begin
    Result := '';
    //NumOfAttempts := 0;
    HTTP := TIdHTTP.Create(nil);
    HTTP.Name := 'IdHTTP1';

    HandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    HandlerSocket.SSLOptions.SSLVersions := [sslvSSLv23];
    //HandlerSocket.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
    HTTP.IOHandler := HandlerSocket;

    CookieMgr := TIdCookieManager.Create(nil);
    HTTP.AllowCookies := True;
    HTTP.CookieManager := CookieMgr;
    //HTTP.CookieManager := TIdCookieManager.Create(nil);

    HTTP.HandleRedirects := True;
    HTTP.RedirectMaximum := 10;
    //HTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) Gecko/20100101 Firefox/4.0b8';
    HTTP.Request.UserAgent := InUserAgent;
    HTTP.HTTPOptions := [hoForceEncodeParams];
    HTTP.OnRedirect := TIdHTTPRedirect.IdHTTPRedirect;

    HTTP.ConnectTimeout := 120000{240000};
    HTTP.ReadTimeout := 120000{240000};
    HTTP.Request.Connection := 'close';

    try
        try
            for I := 1 to MAX_NUMBER_OF_ATTEMPTS do
            begin
                Done := false;
                ContentString := HTTP.Get(InURL);
                //if HTTP.Connected = true then HTTP.Disconnect;
                //inc(NumOfAttempts);

                if Pos('<head>', ContentString) > 0 then Done := true;
                if Pos('<body>', ContentString) > 0 then Done := true;
                if Pos('<script>', ContentString) > 0 then Done := true;

                if Done = true then begin
                    //ContentString := ContentString.ToLower;
                    //ContentString := DeleteBetween('<','>',ContentString);
                    //ContentString := ClearStr(ContentString);
                    Result := ContentString;
                    break;
                end;

                sleep(500);
                ContentString := '';
                Result := '';
            end;
        except
            on E: EIdHTTPProtocolException do
                ErrorString := '"Indy raised a protocol error! HTTP status code: '
                               + IntToStr(E.ErrorCode) +
                               ' Error message: ' + E.Message + '"';

            on E: EIdSocketError do
                ErrorString := '"Indy raised a socket error! Error code: '
                               + IntToStr(E.LastError) +
                               ' Error message: ' + E.Message + '"';

            on E: EIdReadTimeout do
                ErrorString := '"Indy reports, Error Read TimeOut"';

            on E: EIdConnClosedGracefully do
                ErrorString := '"Indy reports, that connection was closed gracefully!"';

            on E: EIdException do
                ErrorString := '"Indy raised an exception! ' +
                               ' Exception class: ' + E.ClassName +
                               ' Error message: ' + E.Message + '"';

            on E: Exception do
                ErrorString := '"A non-Indy related exception has been raised! ' +
                               'Error message: ' + E.Message + '"';

            on E: EIdOSSLCouldNotLoadSSLLibrary do
                ErrorString := '"Indy raised an exception! ' +
                               ' Exception class: ' + E.ClassName +
                               ' Error message: ' + E.Message + '"';

            on E: EIdOSSLConnectError do
                ErrorString := '"Indy raised an exception! ' +
                               ' Exception class: ' + E.ClassName +
                               ' Error message: ' + E.Message + '"';

            on E: EIdUnknownProtocol do
                ErrorString := '"Indy raised an exception! ' +
                               ' Exception class: ' + E.ClassName +
                               ' Error message: ' + E.Message + '"';

        end;
        ErrorString := StringReplace(ErrorString, #13#10,' ',[rfReplaceAll]);
//            inc(NumOfAttempts);
    finally
        if HTTP.Connected = true then HTTP.Disconnect;
        HandlerSocket.Free;
        CookieMgr.Free;
        HTTP.Free;

        if WriteLog = true then
            if ErrorString.Length > 0 then
                TFile.WriteAllText(PrepareFileName(InURL) + '.uu_errlog', Format('%d: %s', [0, ErrorString]), TEncoding.UTF8);
    end;
    //Result := true;
end;

function ParseHTML(const InURL, InBody: string;
                   const InTargetsArr: TTargetsArr;
                   var OutLinksArray: TArray<string>;
                   var OutInnerText: string;
                   const WriteLog: boolean = false
                   ): boolean;

var //TempSL: TStringList;
    i, j: integer;
    iDoc: IHTMLDocument2;
    v: OleVariant;
    Element:IHTMLElement;
    MetaTag: IHTMLMetaElement;
    //{DocAll,} DocHTML{, DocTD}: IHTMLElementCollection;
    strTemp, strTempTxt, strURL, strtemp1: string;

    Msg : TMsg;
    DocClientSite: TUILess;
    CicleCounterLocal: integer;
    //idisp:IDispatch;
    //iElement : IHTMLElement;
    //HTMLWindow: IHTMLWindow2; // parent window of current HTML document

    iColl: IHTMLElementCollection;

    links : OleVariant;
    docURL : string;
    aHref, aText : string;
    aTextArr: TArray<string>;
    this_link: IHTMLAnchorElement;
    RegEx: TRegEx;
    RegExMatches: TMatchCollection;

    strPage: string;
    UrlSL{, WordSL}: TStringList;

    ResultsArr: TTargetsArr;////////////
    Pool: TThreadPool;
    URI : TidURI;

    UrlArray: TStringDynArray;
    SearchTree: TAVLTree;
    SearchNode: TAVLTreeNode;

    //s:string;
    //idisp:IDispatch;
    //iElement : IHTMLElement;
    //els: IHTMLDivElement;
    ErrorMsg: string;
begin
    //TFile.WriteAllText('home.txt', InBody);
    Result := true;
    SetLength(OutLinksArray, 0);
    try
        try
            DocClientSite := TUILess.Create(nil);
    //        OleCheck(CoCreateInstance(CLASS_HTMLDocument, nil,
    //                 CLSCTX_INPROC_SERVER, IID_IHTMLDocument2, Doc));
            //doc := CreateComObject(Class_HTMLDOcument) as IHTMLDocument2;
            iDoc := coHTMLDocument.Create as IHTMLDocument2;
            //if Supports(iDoc, IHTMLDocument2) = true then
            if iDoc = nil then
            begin
                exit;
            end;
            (iDoc as IOleObject).SetClientSite(DocClientSite);
            (iDoc as IOleControl).OnAmbientPropertyChange(DISPID_AMBIENT_DLCONTROL); // Invoke
            //HTMLWindow := Doc.parentWindow;
            iDoc.designMode := 'on';
            //while Doc.readyState <> 'complete' do sleep(1000);
            CicleCounterLocal := 0;

            while iDoc.readyState <> 'complete' do
            begin
                if CicleCounterLocal >= 2400 then //break;   //задается время цикла не более 2минут
                    raise Exception.Create('Parsing error') at @ParseHTML;
                ProcessMessage(Msg);
                sleep(100);
                inc(CicleCounterLocal);
            end;

            //OutInnerText := iDoc.body.innerText;

            v := VarArrayCreate([0,0],VarVariant);
            v[0] := InBody;
            iDoc.write(PSafeArray(System.TVarData(v).VArray));
            iDoc.designMode := 'off';

            CicleCounterLocal := 0;
            while iDoc.readyState <> 'complete' do
            begin
                if CicleCounterLocal >= 2400 then //break;  //задается время цикла не более 2минут
                    raise Exception.Create('Parsing error') at @ParseHTML;
                ProcessMessage(Msg);
                sleep(100);
                inc(CicleCounterLocal);
            end;
            //OutInnerText := iDoc.body.innerText;
            if Supports(iDoc.body, IHTMLBodyElement) = true
            then OutInnerText := (iDoc.body as IHTMLBodyElement).createTextRange.text
            else OutInnerText := iDoc.body.innerText;

            if OutInnerText.Length = 0 then OutInnerText := iDoc.body.outerHTML;

//==============================================================================
            //try
            //if pDeepDigging = true then
            //begin
                SearchTree := TAVLTree.Create(false);
                SetLength(ResultsArr, Length(InTargetsArr));
                //iColl := Doc.anchors;

//                URI := TidURI.Create(InURL.Trim(['"'])) ;
//                try
//                    docURL := 'http://' + URI.Host;
//                    if URI.Path <> '/' then docURL := docURL + URI.Path;
//                finally
//                    URI.Free;
//                end;
                docURL := InURL;

                links := iDoc.all.tags('A');
                if links.Length > 0 then
                begin
                    for i := 0 to links.Length - 1 do
                    begin
                        //try
                            aHref := links.Item(i).href;
                            aText := links.Item(i).innerHTML;
                        //except
                        //    continue;
                        //end;
                        //aTextArr := aTextArr + [aText];
                        if Length(aHref) = 0 then continue;
                        //UrlArray := UrlArray + [aHref];
                        //aTextArr := aTextArr + [aText];
                        //------------------------------------------------------
                        if aHref.StartsWith('about:') = true then   //2019.08.14
                            aHref := Copy(aHref, 7, Length(aHref));

                        if aHref.StartsWith('about:') = false then
                            if aHref.StartsWith('/') = false then
                                if aHref.StartsWith('https:') = false then
                                    if aHref.StartsWith('http:') = false then
                                        aHref := '/' + aHref;
                        //------------------------------------------------------

                        if (aHref[1] = '/') then
                            aHref := docURL + aHref
                        else if Pos('about:', aHref) = 1
                             then aHref := docURL + Copy(aHref, 7, Length(aHref));

                        if Pos(InURL.Trim(['"']), aHref) > 0 then
                            if OccurrencesEx('/', aHref, 5) then
                                if RegEx.IsMatch(aHref, URLREGEXP,[roCompiled, roExplicitCapture]) = true then
                                begin
                                    if aHref.EndsWith('.pdf') = true then continue;
                                    if aHref.EndsWith('.jpg') = true then continue;
                                    if aHref.EndsWith('.doc') = true then continue;

                                    SearchNode := SearchTree.FindOrInsert(aHref, '');
                                    if SearchNode = nil then
                                    begin
                                        //SetLength(UrlArray, Length(UrlArray) + 1);
                                        //UrlArray[High(UrlArray)] := aHref;
                                        UrlArray := UrlArray + [aHref];
                                        aTextArr := aTextArr + [aText];
                                    end;
                                end;
                    end;
                end;

                if Length(UrlArray) > 0 then
                begin
                    for I := 0 to High(UrlArray) do
                    begin
                        strTemp := ClearStr(UrlArray[I]);
                        strTempTxt := ClearStr(aTextArr[I]);
                        strURL := UrlArray[I];
                        for J := 0 to High(InTargetsArr) do
                        begin
                            if ContainsText(' ' + strTemp + ' ', ' ' + InTargetsArr[J].RecordName + ' ') = true //если в ссылке содержится целевое слово
                            then begin
                                     ArrAddUniqueValue(OutLinksArray, strURL);
                            end;

                            if ContainsText(' ' + strTempTxt + ' ', ' ' + InTargetsArr[J].RecordName + ' ') = true //если в ссылке содержится целевое слово
                            then begin
                                     ArrAddUniqueValue(OutLinksArray, strURL);
                            end;
                        end;
                    end;
                end;

//                SetLength(UrlArray, 0);
//                SetLength(aTextArr, 0);
//                SearchTree.Free;
            //end;

        except
            on E: Exception do begin
                Result := false;
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;

            on E: EOleException do begin
                Result := false;
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;

            on E: EOleSySError do begin
                Result := false;
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;
        end;

    finally
        SetLength(UrlArray, 0);
        SetLength(aTextArr, 0);
        if Assigned(SearchTree) then SearchTree.Free;

        SearchNode := nil;

        (iDoc as IOleObject).SetClientSite(nil);
        iDoc.close;
        iDoc.clear;
        iDoc := nil;//под вопросом
        VarClear(v);
        v := null;
        if Assigned(DocClientSite) then DocClientSite.Free;

        if WriteLog = true then
            if Result = false then
                TFile.WriteAllText(PrepareFileName(InURL) + '.uu_errlog', Format('ParseHTML error: %s', [ErrorMsg]), TEncoding.UTF8);
    end;
end;

function ParseHTMLlight(const InBody: string; const WriteLog: boolean = false): string;
var iDoc: IHTMLDocument2;
    v: OleVariant;
    Msg : TMsg;
    DocClientSite: TUILess;
    CicleCounterLocal: integer;
    //iColl: IHTMLElementCollection;
//    SelObj: IHTMLSelectionObject;
//    SelRange: IHtmlTxtRange;
//
//    Range : MSHTML.IHTMLTxtRange;
//    BodyElem: IHTMLBodyElement;
    ErrorMsg: string;
begin
    Result := '';

    try
        try
            DocClientSite := TUILess.Create(nil);

            iDoc := coHTMLDocument.Create as IHTMLDocument2;
            if iDoc = nil then
            begin
                exit;
            end;
            (iDoc as IOleObject).SetClientSite(DocClientSite);
            (iDoc as IOleControl).OnAmbientPropertyChange(DISPID_AMBIENT_DLCONTROL); // Invoke

            iDoc.designMode := 'on';
            CicleCounterLocal := 0;

            while iDoc.readyState <> 'complete' do
            begin
                if CicleCounterLocal >= 2400 then //break;   //задается время цикла не более 2минут
                    raise Exception.Create('Parsing error') at @ParseHTML;
                ProcessMessage(Msg);
                sleep(100);
                inc(CicleCounterLocal);
            end;

            //OutInnerText := iDoc.body.innerText;

            v := VarArrayCreate([0,0],VarVariant);
            v[0] := InBody;
            iDoc.write(PSafeArray(System.TVarData(v).VArray));
            iDoc.designMode := 'off';

            CicleCounterLocal := 0;
            while iDoc.readyState <> 'complete' do
            begin
                if CicleCounterLocal >= 2400 then //break;  //задается время цикла не более 2минут
                    raise Exception.Create('Parsing error') at @ParseHTML;
                ProcessMessage(Msg);
                sleep(100);
                inc(CicleCounterLocal);
            end;
            //Result := iDoc.body.innerText;
            //Result := iDoc.body.outerText;
            if iDoc.readyState = 'complete' then
                if Supports(iDoc.body, IHTMLBodyElement) then
                    Result := (iDoc.body as IHTMLBodyElement).createTextRange.text;
        //==============================================================================
        except
            on E: Exception do begin
                Result := '';
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;

            on E: EOleException do begin
                Result := '';
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;

            on E: EOleSySError do begin
                Result := '';
                ErrorMsg := E.ClassName + ' ' + E.Message;
            end;
        end;

    finally
        (iDoc as IOleObject).SetClientSite(nil);
        iDoc.close;
        iDoc.clear;
        iDoc := nil;//под вопросом
        VarClear(v);
        v := null;
        if Assigned(DocClientSite) then DocClientSite.Free;

        if WriteLog = true then
            if ErrorMsg.Length > 0 then
                TFile.WriteAllText(URLToolUnitErrorLogDir + PrepareFileName('ParseHTMLlight') + '.uu_errlog',
                                   Format('ParseHTMLlight error: %s', [ErrorMsg]),
                                   TEncoding.UTF8);
    end;
end;

//---извлекаем текст с html странички и нормализуем----
function ParseHTMLlightNorm(RawHTMLstring: string;
                            const A: array of string;
                            const WriteLog: boolean = false): string;
begin
    //---выделяем текст с html странички---
    Result := ParseHTMLlight(RawHTMLstring, WriteLog);   //HttpResponse.RawHTMLstring
    //---нормализуем полученный текст------
    Result := ClearStr2(Result, A);
end;

end.

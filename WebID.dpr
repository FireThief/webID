program WebID;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM4,
  DateUtils,
  System.Classes,
  System.SysUtils,
  System.IniFiles,
  System.Types,
  System.Threading,
  System.SyncObjs,
  System.IOUtils,
  System.Hash,
  System.Math,
  System.StrUtils,
  ActiveX,
  ComObj,
  RegularExpressions,
  Generics.Collections,
  Generics.Defaults,
  Definitions in 'Definitions.pas',
  Tools in 'Tools.pas',
  CRT in 'CRT.pas',
  BingSearchUnit in 'BingSearchUnit.pas',
  httpClientUnit in 'httpClientUnit.pas',
  mAVLTree in 'mAVLTree.pas',
  JsonUnit in 'JsonUnit.pas',
  URLtoolUnit in 'URLtoolUnit.pas',
  UserAgentUnit in 'UserAgentUnit.pas',
  UILessUnit in 'UILessUnit.pas',
  ArrayHolderUnit in 'ArrayHolderUnit.pas';

procedure  PrintAllTreeToArray(AVLSearchTree: TAVLTree;
                               var OutArray: TArray<TDomainRec>);

    procedure _Print_R(ANode: TAVLTreeNode);
    var intCounter: Cardinal;
        //intTemp: integer;
        {strTemp, }strWork: string;

    begin
        if not Assigned(ANode) then Exit;

        if Assigned(ANode.Left) then _Print_R(ANode.Left);

        if Assigned(ANode.Right) then _Print_R(ANode.Right);

        strWork := ANode.Key;               //получаем ключ. в ключе находится код года (номер файла для выгрузки) и данные
        intCounter := ANode.Data.ToInteger; //получаем счётчик данных

        OutArray := OutArray + [TDomainRec.Create(strWork, intCounter)];
    end;

begin
    _Print_R(AVLSearchTree.Root);
end;

var
    i, j, k, m: integer;
    strTemp, FileNameIn, strHeader, SourceString, strTime: string;
    OutputDirectory, AppDirectory, ErrorLogDirectory: string;
    strCondition, strQuery, strQuerySummary, strHash: string;
    ErrorSL, InputSL: TStringList;
    OriginalHeaderSL, outputHeaderSL, FieldMapSL, TargetsSL, HTTPcodesSL: TStringList;
    ExcludeColumnsArr: TArray<string>;
    TempSL, ContentSL, HashSL : TStringList;
    pStop, pBing, pHelp, pURLqa, pQuoted, pCrawl, pSimple, pSearchOn, pSearchOff, pWebSite: boolean;
    pUuLog, pJuLog: boolean;
    timeStart, timeEnd, timeCurrBegin, timeCurrEnd, timeTemp: double;
    houres, minutes, seconds, mseconds: word;
    NumberOfLines: Int64;
    CursPosY, FieldsCount, linesprocessed, BingCallsWereUsed: integer;
    myEncoding: TEncoding;
    Reader: TStreamReader;
    Writer: TStreamWriter;
    URLcnDynArrIsAdditional: array of integer;
    URLcnDynArrInp: array of array of integer;
    StrToScrArray{, SearchKeysArray, OutputStrArray}: TArray<string>;
    TempQuery, TempCondition: TArray<string>;
    //--------------------------------------------------------------------------
    AppSettings: TIniFile;
    iniFileName{, strTempFile}: string;
    intCounter: integer;
    total: Int64;
    UserAnswer: Char;
    //--------------------------------------------------------------------------
    Pool: TThreadPool;
    task: ITask;
    ResponseArray: array of TBingResponse;
    SearchTree: TAVLTree;
    SearchTreeNode: TAVLTreeNode;
    excludesUrlArray, excludesNamesArray, excludesKeyArray, excludesDirArray: TArray<string>{TStringDynArray};

    //excludesUrlSL: TStringList;
    ColNum, OutColNum: TBodyMatches_cn;  //---Column numbers---------
    TargetsArr, FindScoreArr: TTargetsArr;
    searchPositionScoreArr: TArray<integer>;

    RegEx: TRegEx;
    RegExMatches: TMatchCollection;
    crawlExitThreshold: integer;

    //HTTPuserAgent: string;
    NameScore, filedScore, ddGroup, ddTreshold, ddBump, nsScore, siuScore, ciuScore, scsmmScore: integer;
    wcsmScore, wsmScore, wcmScore: integer;     //WebCityStateMatch  //WebStateMatch  //WebCityMatch
    wcsmmScore, wsmmScore: integer;             //WebCityStateMisMatch  //WebStateMisMatch
    cowfnScore, cow1zScore, cow2zScore, aowScore, cowfwmScore, powScore: integer;
    pisScore, pohScore, pmsScore, inputScore, iwerScore: integer;
    SR: TScoreRecord;

    resultsCount: integer;

    domainStats: TAVLTree;
    domainStatsArr: TArray<TDomainRec>;
    domainWriter: TStreamWriter;
    MaxPosVariable: integer;
    Position_not_in_top10, MinimumTopScore: integer;
    StatesTree, StatesAbbrTree, CityTree, PhoneCodes: TAVLTree;
    {AppID, BaseURL: string; }//---ключ для работы с поисковыми запросами---
    {MaxPerSecond, }TimeInterval{, MaxThreads}: integer; //---временной интервал запуска потоков, максимальное число потоков

    FCS: TFillerConfigSettings; //FillerConfigSettings

    StatesFullNameArray, StatesAbbrNameArray, TempParsingArray, CitiesArray: TArray<string>;
    boolTemp: boolean;
    //CityMatch, StateMatch, StateAbbrMatch, DataFound: string;
    //NormalizedCompanyName: string;
    ModifierArray: TArray<string>;
    SimpleCounters: integer;
//                JJ: integer;
//                _SearchKey, _strJSON, InnerText, _strTemp{, _strCount}: string;
//                II, KK, MM, NN, OO, percentage: integer;
//                //_Saver: TStringList;
//                parsingResults, ClearedParsingResults: TJSONresultsArray;
//                EmptyElement: TJSONparsingResults;
//                HttpResponse: THttpResponse;
//                _IsSocialNw: boolean;
//                _ReqStatus: integer;
//                _DomainDuplicatesArr, UsefulLinks, TempArr: TArray<string>;
//                //_domainsSL: TStringList;
//                ParseResult: string;
//                HTTPuserAgent: string;
//                RightCondition, _TempParsingArray: TArray<string>;
//                NormalizedCompanyNameArr: TArray<string>;
//                CityMatch, StateMatch, StateAbbrMatch: string;
//                CityDataFound, StateDataFound, StateAbbrDataFound: TArray<TDomainRec>;
//                DigitsFromText: string;
//                PairCityState: TArray<TPairRec>;
    //SearchKey, strJSON: string;
    //ReqStatus: integer;
    WebsiteArr: TArray<string>;
    strSubParam: string;
    WebSiteFieldName: string;
    strErrorMsg: string;
    INSERT_HERE: integer; //позиция для вставки текста в выходной строке
    BingUserAgent: string;
begin
    try
      { TODO -oUser -cConsole Main : Insert code here }
        //AppID := '';
        //BaseURL := '';
        WriteLn(Format('%s.  build 2.%s, Copyright 2018, 2019 Data|Z. All rights reserved.',[APPNAME, '20200912']));
        WriteLn('Patents Pending. Licensed use only.');
        WriteLn;
        BingUserAgent := GenerateUserAgent();
        CursPosY := 0;
        linesprocessed := 0;
        BingCallsWereUsed := 0;
        crawlExitThreshold := 0;
        resultsCount := 10;
        pHelp := false;
        pStop := false;
        pBing := false;
        pURLqa := false;
        pQuoted := false;
        pCrawl := false;
        pSimple := false;
        pSearchOn := false;
        pSearchOff := false;
        pWebSite := false;
        pUuLog := false;
        pJuLog := false;

        fileNameIn := '';
        WebSiteFieldName := '';

        SetLength(StrToScrArray, 14);
        //MaxPerSecond := CICLECOUNTER;
        //MaxThreads := MAXTHREAD;
        //---базовые настроеки приложения (начальные установки)-----------
        FCS := CFillerConfigSettings;
        ColNum := CBodyMatches_cn;
        OutColNum := CBodyMatches_cn;

        TimeInterval := 1000;
        ErrorSL := TStringList.Create;
//---detect parameters----------------------------------------------------------
        if ParamCount = 0 then
        begin
//            ErrorSL.Add(Format('Usage: %s filein',[ExtractFileName(ParamStr(0))]));
//            ErrorSL.Add('    filein    -path to input file(s)');
            pHelp := true;
        end;

        for I := 1 to ParamCount do
        begin
            if ParamStr(I).ToLower = HELPPARAM then pHelp := true;
            if ParamStr(I).ToLower = STOPPARAM then pStop := true;
            if ParamStr(I).ToLower = BINGPARAM then pBing := true;
            if ParamStr(I).ToLower = QUOTEPARAM then pQuoted := true;
            if ParamStr(I).ToLower = CRAWLPARAM then pCrawl := true;
            if ParamStr(I).ToLower = URL_UNIT_LOG then pUuLog := true;
            if ParamStr(I).ToLower = JSON_UNIT_LOG then pJuLog := true;

            if ParamStr(I).StartsWith(WEBSITE, true) = true
            then begin
                     strSubParam := ExtractSubParameter(ParamStr(I), ':');
                     pWebSite := true;
                     if strSubParam.Length = 0 then ErrorSL.Add(Format('Wrong parameter format: %s',[WEBSITE]))
                     else begin
                              WebsiteArr := strSubParam.Split([','], '"', '"', ExcludeEmpty);
                              if Length(WebsiteArr) < 2 then ErrorSL.Add(Format('Wrong parameter format: %s',[WEBSITE]))
                              else begin
                                       WebSiteFieldName := WebsiteArr[0];
                                       if WebsiteArr[1].StartsWith(WEB_SEARCH_ON, true) = true then pSearchOn := true;
                                       if WebsiteArr[1].StartsWith(WEB_SEARCH_OFF, true) = true then pSearchOff := true;
                                   end;
                          end;
                 end;

            if ParamStr(I).StartsWith(SIMPLEPARAM, true) = true
            then begin
                     pSimple := true;
//                     strTemp := ParamStr(i).Substring(ParamStr(i).IndexOf(':') + 1).Trim;
//                     try
//                         SimpleCounters := strTemp.ToInteger;
//                     except
//                         ErrorSL.Add(Format('Wrong parameter format: %s',[COUNTPARAM]));
//                     end;
                 end;
            if ParamStr(I).ToLower.Contains(COUNTPARAM + ':') = true
            then begin
                     strTemp := ParamStr(i).Substring(ParamStr(i).IndexOf(':') + 1).Trim;
                     try
                         resultsCount := strTemp.ToInteger;
                     except
                         ErrorSL.Add(Format('Wrong parameter format: %s',[COUNTPARAM]));
                     end;
                 end;

            strTemp := ParamStr(i);
            if (Pos('-', strTemp) <> 1) and (Pos('.', strTemp) <> 0)
                then fileNameIn := ParamStr(i);
        end;

        if pHelp = true then
        begin
            WriteLn(Format('%s options:',[APPNAME]));
            WriteLn(Format('Sample: %s.exe inputfile.csv ',[APPNAME]));
            WriteLn;
            WriteLn(Format('%s - force the app to make Bing API call, and does not upload JSON file from HDD',[BINGPARAM]));
            WriteLn;
            WriteLn(Format('%s - force the app to crawl homepage and then target pages ',[CRAWLPARAM]));
            WriteLn;
            WriteLn(Format('%s - put search request in quotes - ""',[QUOTEPARAM]));
            WriteLn;
            WriteLn(Format('%s:X  - show top X matches, by default = 10',[COUNTPARAM]));
            WriteLn;
            WriteLn(Format('%s - show requested data in simple mode without scoring',[SIMPLEPARAM]));
            WriteLn;
            WriteLn(Format('%s - specify website field',[WEBSITE]));
            WriteLn;
            WriteLn(Format('%s - this help',[HELPPARAM]));
            WriteLn;
            WriteLn('Press Enter...');
            ReadLn;
            Exit;
        end;

        if Length(filenamein) = 0 then ErrorSL.Add('Input file does not specified');

        if Length(filenamein) > 0 then
            if FileExists(filenamein) = false then
                ErrorSL.Add(Format('Input file: "%s" not found', [filenamein]));

        //---загрузка файла с ключами-------------------------------------------
        if FileExists(BINGAPIKEYS) = true
        then FCS := UploadFillerConfig(BINGAPIKEYS)
        else ErrorSL.Add(Format('Input file: "%s" not found', [BINGAPIKEYS]));

        if ErrorSL.Count > 0 then
        begin
            for I := 0 to ErrorSL.Count - 1 do
                WriteLn(ErrorSL[I]);

            WriteLn('Press Enter...');
            ReadLn;
            Exit;
        end;

        //ErrorSL.Free;

//---окончание проверки входных данных------------------------------------------
//---старт обработки------------------------------------------------------------

        timestart := Now;
        intCounter := 0;
        //----------------------------------------------------------------------
        iniFileName := ExtractFilePath(Paramstr(0)) + ChangeFileExt(ExtractFileName(filenamein),'') + '-' + LowerCase(ChangeFileExt(ExtractFileName(Paramstr(0)),'.dzc'));
        AppSettings := TIniFile.Create(iniFileName);
        if FileExists(iniFileName) = false then
        begin
            AppSettings.WriteDateTime('Basic', 'TimeStart', Now());
            AppSettings.WriteDateTime('Basic', 'TimeNow', Now());
            AppSettings.WriteInteger('Basic', 'LinesProcessed',intCounter);  //номер страницы, на которой призошла остановка
        end;
        intCounter := AppSettings.ReadInteger('Basic','LinesProcessed',0);
        timestart := AppSettings.ReadDateTime('Basic','TimeStart', Now());
        AppSettings.Free;
        //----------------------------------------------------------------------

        WriteLn('Start at: ' + FormatDateTime('hh:nn:ss', timestart));
        WriteLn('Input file size: ' + IntToStr(_GetFileSize(filenamein)) + ' bytes');
        NumberOfLines := LinesCount(filenamein);
        WriteLn('Number of lines: ' + IntToStr(NumberOfLines));

        UserAnswer := 'n';
        //----------------------------------------------------------------------
        if (intCounter > 0) then
        begin
            WriteLn('===========================================');
            WriteLn('Previous task is not finished.');
            WriteLn(Format('Input file:      %s', [filenamein]));
            WriteLn(Format('Lines processed: %d', [intCounter]));
            WriteLn('===========================================');
            Write('Do you want to continue? (y/n)');
            ReadLn(UserAnswer);
        end;
        //----------------------------------------------------------------------
        CursPosY := WhereY;

        InputSL := TStringList.Create;
        InputSL.CaseSensitive := false;
        myEncoding := GetFileEnoding(filenamein);
        Reader := TStreamReader.Create(filenamein, myEncoding); //
        strHeader := Reader.ReadLine();                            //---читаем заголовок
        strHeader :=StringReplace(strHeader,#0,' ',[rfReplaceAll]);//---на всякий случай

        ReadCSVRecord(strheader, InputSL);
        FieldsCount := InputSL.Count;

        OriginalHeaderSL := TStringList.Create;    //---сохраняем оригинальный заголовок на будущее
        OriginalHeaderSL.CaseSensitive := false;
        OriginalHeaderSL.AddStrings(InputSL);

        outputHeaderSL := TStringList.Create;
        outputHeaderSL.CaseSensitive := false;

        TempSL := TStringList.Create;   //список для поиска
        TempSL.CaseSensitive := false;
        TempSL.StrictDelimiter := true;

        //---находим столбик с именем 'URL-QA'----------------------------------
        //---и так же ищем столбик с адресом сайта------------------------------
        for I := 0 to InputSL.Count - 1 do
        begin
            if InputSL[I].ToLower = URL_QA_NAME.ToLower
            then begin
                     pURLqa := true;
                     ColNum.URLqa := I;
                 end;
            if InputSL[I].ToLower = WebSiteFieldName.ToLower then ColNum.WebSite := I;
            if InputSL[I].ToLower = PriorFields[0].ToLower then ColNum.OO_ID := I;
        end;
        //======================================================================
        //---если поле website задано но не найдено----
        if WebSiteFieldName.Length > 0 then
            if ColNum.WebSite = -1 then
                ErrorSL.Add(Format('There is no %s field in the input file',[WebSiteFieldName]));

        TimeInterval := 1000 div FCS.MaxPerSecond;
        //======================================================================
        //---загузка файла с исключениями---------------------------------------
        if FileExists(EXCLUDESFILECONST) = True then
        begin
            UploadExcludesConfig(EXCLUDESFILECONST,
                                 excludesUrlArray,  //---массив с исключениями урл
                                 excludesDirArray,  //---массив с доменами социальных сетей
                                 excludesNamesArray,  //---массив с исключениями в имени
                                 excludesKeyArray   //---массив с исключениями-ключевыми словами
                                );

        end
        else ErrorSL.Add(Format('File %s not found',[EXCLUDESFILECONST]));
        strTemp := '';
        //======================================================================
        if FileExists(STATEABBREVIATIONS) = true  //файл с аббревиатурами и названиями штатов
        then begin                                //подготавливаем дерево с аббревиатурами штатов
                 TargetsSL := TStringList.Create;
                 TargetsSL.LoadFromFile(STATEABBREVIATIONS);
                 StatesTree := TAVLTree.Create(false);
                 StatesAbbrTree := TAVLTree.Create(false);
                 for I := 0 to TargetsSL.Count - 1 do
                 begin
                     if Length(TargetsSL[I]) = 0 then continue;
                     if Pos(';', TargetsSL[I]) = 1 then continue;
                     //дерево для заполнеия поискового запроса------------------
                     StatesTree.FindOrInsert(ExtractParameter(TargetsSL[I], ','), ExtractSubParameter(TargetsSL[I], ','));
                     StatesAbbrTree.FindOrInsert(ExtractSubParameter(TargetsSL[I], ','), ExtractParameter(TargetsSL[I], ','));
                     //StatesFullNameArray := StatesFullNameArray + [ExtractSubParameter(TargetsSL[I], ',').Trim.ToLower.Replace(' ','',[rfReplaceAll])];
                     StatesFullNameArray := StatesFullNameArray + [ExtractSubParameter(TargetsSL[I], ',').Trim{.ToLower}];
                     StatesAbbrNameArray := StatesAbbrNameArray + [ExtractParameter(TargetsSL[I], ',').Trim.ToUpper];
                 end;
                 SortStringArray(StatesFullNameArray);
             end
        else ErrorSL.Add(Format('File %s not found',[STATEABBREVIATIONS]));
        if Assigned(TargetsSL) then TargetsSL.Free;
        //======================================================================
        if FileExists(AREACODES) = true
        then begin
                 PhoneCodes := TAVLTree.Create(false); //---дерево для хранения телефонных кодов---
                 UploadAreaCodes(AREACODES, PhoneCodes);
             end
        else ErrorSL.Add(Format('File %s not found',[AREACODES]));
        //======================================================================
        if FileExists(CITYSTATEZIP) = true        //подготавливаем дерево горордов и массив городов
        then begin
                 TargetsSL := TStringList.Create;
                 TargetsSL.LoadFromFile(CITYSTATEZIP);
                 CityTree := TAVLTree.Create(false);

                 for I := 0 to TargetsSL.Count - 1 do
                 begin
                     if Length(TargetsSL[I]) = 0 then continue;
                     if Pos(';', TargetsSL[I]) = 1 then continue;

                     TempParsingArray := TargetsSL[I].Split([','], ExcludeEmpty); //0 - город, 1 - штат, 2 - индекс
                     strTemp := StatesTree.FindData(TempParsingArray[1].Trim.ToLower); //ищем полное название штата
                     SearchTreeNode := CityTree.FindOrInsert(TempParsingArray[0].Trim, strTemp);
                     if SearchTreeNode <> nil 
                     then begin
                              if ContainsText(SearchTreeNode.Data, strTemp) = false
                              then SearchTreeNode.Data := SearchTreeNode.Data + ';' + strTemp
                          end
                     else CitiesArray := CitiesArray + [TempParsingArray[0].Trim];
                     SetLength(TempParsingArray, 0);
                 end;
                 SortStringArray(CitiesArray);
             end
        else ErrorSL.Add(Format('File %s not found',[CITYSTATEZIP]));
        if Assigned(TargetsSL) then TargetsSL.Free; 
        //======================================================================
        if FileExists(TARGETSFILECONST) = true  //---загрузка списка слов------
        then begin                              //---для поиска на страничке---
                 TargetsSL := TStringList.Create;
                 TargetsSL.LoadFromFile(TARGETSFILECONST);
                 strTemp := FillTargetsArray(TargetsSL, TargetsArr, crawlExitThreshold);
                 if strTemp.Length > 0 then
                     ErrorSL.Add(Format('Error in %s file. ' + strTemp,[TARGETSFILECONST]));
             end
        else ErrorSL.Add(Format('File %s not found',[TARGETSFILECONST]));
        if Assigned(TargetsSL) then TargetsSL.Free;
        //======================================================================
        if FileExists(URLFINDSCOREFILECONST) = true then  //---справочник с баллами---
        begin                                             //---для определения рейтинга страниц---
            TargetsSL := TStringList.Create;
            TargetsSL.LoadFromFile(URLFINDSCOREFILECONST);
            FillTargetsArray(TargetsSL, FindScoreArr, crawlExitThreshold);
            if strTemp.Length > 0 then
                ErrorSL.Add(Format('Error in %s file. ' + strTemp,[URLFINDSCOREFILECONST]));

            for I := 0 to High(FindScoreArr) do
            begin     //read parameters for scoring
                if FindScoreArr[I].RecordName.ToLower = 'company' then
                    NameScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = MINSCORE then
                    filedScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = DOMAINDENGROUP then
                    ddGroup := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = DOMAINDENTHRES then
                    ddTreshold := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = DOMAINDENBUMP then
                    ddBump := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = NOSUBFOLDER then
                    nsScore := FindScoreArr[I].Score;
                //---новые переменные-------------------------------------------
                if FindScoreArr[I].RecordName.ToLower = NOT_IN_TOP10.ToLower then
                    Position_not_in_top10 := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = MINTOPSCORE.ToLower then
                    MinimumTopScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = STATEINURL.ToLower then
                    siuScore := FindScoreArr[I].Score;  //state-in-url
                if FindScoreArr[I].RecordName.ToLower = CITYINURL.ToLower then
                    ciuScore := FindScoreArr[I].Score;  //city-in-url
                if FindScoreArr[I].RecordName.ToLower = SCSMM.ToLower then
                    scsmmScore := FindScoreArr[I].Score;
                //---переменные для анализа страницы----------------------------
                if FindScoreArr[I].RecordName.ToLower = WCSM.ToLower then
                    wcsmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = WSM.ToLower then
                    wsmScore := FindScoreArr[I].Score;
//                if FindScoreArr[I].RecordName.ToLower = WSM.ToLower then
//                    wcmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = WCSMM.ToLower then
                    wcsmmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = WSMM.ToLower then
                    wsmmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = COWFN.ToLower then
                    cowfnScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = COW1Z.ToLower then
                    cow1zScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = COW2Z.ToLower then
                    cow2zScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = AOW.ToLower then
                    aowScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = COWFWM.ToLower then
                    cowfwmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = POW.ToLower then
                    powScore := FindScoreArr[I].Score;
                //---новые переменные для подчёта счёта телефона--------
                if FindScoreArr[I].RecordName.ToLower = PHONE_IN_SNIPPET.ToLower then
                    pisScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = PHONE_ON_HOMEPAGE.ToLower then
                    pohScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = PHONE_MATCH_STATE.ToLower then
                    pmsScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = PROVIDED_WEBSITE.ToLower then
                    inputScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = INPUT_WEB_EQUALS.ToLower then
                    iwerScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = FIRST_1_WORDS.ToLower then
                    SR.f1wmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = FIRST_2_WORDS.ToLower then
                    SR.f2wmScore := FindScoreArr[I].Score;
                if FindScoreArr[I].RecordName.ToLower = FIRST_3_WORDS.ToLower then
                    SR.f3wmScore := FindScoreArr[I].Score;

                if FindScoreArr[I].RecordType = MODIFIERTAG   //собираем массив модификаторов
                then ModifierArray := ModifierArray + [FindScoreArr[I].RecordName];
            end;

            MaxPosVariable := 0;
            SetLength(searchPositionScoreArr, 50);  //50 - максимальное кол-во данных в выдаче по запросу
            for I := 0 to High(searchPositionScoreArr) do
                searchPositionScoreArr[I] := Position_not_in_top10;

            for I := 0 to High(FindScoreArr) do
                for J := 0 to High(searchPositionScoreArr) do
                    if FindScoreArr[I].RecordName.ToLower = POS_N + J.ToString
                    then begin
                             if J > MaxPosVariable then MaxPosVariable := J; //ловим максимальное значение для переменной pos
                             searchPositionScoreArr[J - 1] := FindScoreArr[I].Score; //заполняем массив баллов для pos
                         end;
//            if FindScoreArr[I].RecordType = MODIFIERTAG   //собираем массив модификаторов
//                then ModifierArray := ModifierArray + [FindScoreArr[I].RecordName];
        end
        else ErrorSL.Add(Format('File %s not found',[URLFINDSCOREFILECONST]));
        if Assigned(TargetsSL) then TargetsSL.Free;
        //======================================================================
        if FileExists(FIELDMAPFILECONST) = true then   //---файл с шаблонами для поиска---
        begin
            SetLength(URLcnDynArrInp, 0);
            FieldMapSL := TStringList.Create;
            FieldMapSL.LoadFromFile(FIELDMAPFILECONST);
            for I := 0 to FieldMapSL.Count - 1 do
            begin
                if Length(FieldMapSL[I]) = 0 then continue;
                if Pos(';', FieldMapSL[I]) = 1 then continue;
                if not IsRightField(FieldMapSL.Names[I]) then
                begin
                    M := OriginalHeaderSL.IndexOf(FieldMapSL.ValueFromIndex[I]);
                    if M >= 0 then
                    begin
                        //if LowerCase(FieldMapSL.Names[I]) = 'districtname' then BodyMatches_cn.DistrictName_cn := M;
                        if LowerCase(FieldMapSL.Names[I]) = 'searchname' then ColNum.SearchName := M;
                        if LowerCase(FieldMapSL.Names[I]) = 'city' then ColNum.City := M;
                        if LowerCase(FieldMapSL.Names[I]) = 'state' then ColNum.State := M;
                        if LowerCase(FieldMapSL.Names[I]) = 'zip' then ColNum.ZIP := M;
                        if LowerCase(FieldMapSL.Names[I]) = 'phone' then ColNum.Phone := M;
                    end else
                    begin
                        //ErrorSL.Add(Format('Field "%s" not found in input file - %s', [FieldMapSL.ValueFromIndex[I], fileNameIn]));
                        //ErrorSL.Add(Format('Please check "%s" file', [FIELDMAPFILECONST]));
                        //ErrorSL.Add('');
                    end;
                    continue;
                end;
                if Length(FieldMapSL.ValueFromIndex[I]) = 0 then continue;

                TempSL.Clear;
                TempSL.CommaText := FieldMapSL.ValueFromIndex[I];
                //if pWebSite = true then TempSl.Add(WebSiteFieldName);

                if TempSL.Count = 0 then continue;

                SetLength(URLcnDynArrInp, Length(URLcnDynArrInp) + 1);

                    for j := 0 to TempSL.Count - 1 do
                    begin
                        k := OriginalHeaderSL.IndexOf(Trim(TempSL[j]));
                        if k = -1 then begin
                            ErrorSL.Add(Format('Field "%s" not found in input file - %s', [TempSL[j].Trim, fileNameIn]));
                            ErrorSL.Add(Format('Line: "%s"',[FieldMapSL[I]]));
                            ErrorSL.Add(Format('Please check "%s" file', [FIELDMAPFILECONST]));
                            ErrorSL.Add('');
                        end
                        else
                        begin
                            SetLength(URLcnDynArrInp[High(URLcnDynArrInp)], Length(URLcnDynArrInp[High(URLcnDynArrInp)]) + 1);
                            URLcnDynArrInp[High(URLcnDynArrInp), High(URLcnDynArrInp[High(URLcnDynArrInp)])] := k;
                        end;
                    end;
            end;
            //==================================================================
            //------------------------------------------------------------------
            //---здесь создаём заголовок----------------------------------------
            //------------------------------------------------------------------
            //==================================================================
            //---Простой режим, просто с URL---------------
            if pSimple = true
            then begin
//                     outputHeaderSL.Clear;
//                     for I := 1 to resultsCount do
//                     begin
//                         outputHeaderSL.Add(Format('%d%s',[I, 'Score']));
//                         outputHeaderSL.Add(Format('%d%s',[I, 'URL']));
//                     end;
//                     //---переводим заголовок из списка в строчку---
//                     strHeader := OriginalHeaderSL.CommaText + ',' + outputHeaderSL.CommaText;
                     strHeader := FormSimpleHeader(resultsCount, OriginalHeaderSL.CommaText);
                 end;
            //---Не простой режим с баллами и рейтингами---
            if pSimple = false
            then begin
                     //---формируем массив названий столбиков, которые не будем выводить
                     for I := resultsCount + 1 to 50 do
                     begin
                         ExcludeColumnsArr := ExcludeColumnsArr + ['domain' + I.ToString];
                         ExcludeColumnsArr := ExcludeColumnsArr + ['s' + I.ToString];
//                         ExcludeColumnsArr := ExcludeColumnsArr + ['r' + I.ToString];
                     end;

                     outputHeaderSL.Clear;
                     for I := 0 to InputSL.Count - 1 do
                     begin
                         if not IsAdditionalField(InputSL[I]) then outputHeaderSL.Add(InputSL[I])
                         else begin
                                  SetLength(URLcnDynArrIsAdditional, Length(URLcnDynArrIsAdditional) + 1);   //записывам номера дополнительных полей выходного файла
                                  URLcnDynArrIsAdditional[High(URLcnDynArrIsAdditional)] := I;   //записывам номера дополнительных полей выходного файла
                              end;
                     end;

                     for I := 0 to FieldMapSL.Count - 1 do
                     begin
                         if Length(FieldMapSL[I]) = 0 then continue;
                         if Pos(';', FieldMapSL[I]) = 1 then continue;
                         if not IsRightField(FieldMapSL.Names[I]) then
                         begin
                             M := outputHeaderSL.IndexOf(FieldMapSL.ValueFromIndex[I]);
                             if M >= 0 then
                             begin
                                 //if LowerCase(FieldMapSL.Names[I]) = 'districtname' then BodyMatches_cn.DistrictName_cn := M;
                                 if LowerCase(FieldMapSL.Names[I]) = 'searchname' then OutColNum.SearchName := M;
                                 if LowerCase(FieldMapSL.Names[I]) = 'city' then OutColNum.City := M;
                                 if LowerCase(FieldMapSL.Names[I]) = 'state' then OutColNum.State := M;
                                 if LowerCase(FieldMapSL.Names[I]) = 'zip' then OutColNum.ZIP := M;
                                 if LowerCase(FieldMapSL.Names[I]) = 'phone' then OutColNum.Phone := M;
                             end;
                         end
                     end;
//                     //---вставка полей перед полем "company"-------------------
//                     //---поля Quality Assurance--------------------------------
//                     for I := 0 to InputSL.Count - 1 do //add new fields before "company" field
//                     begin
//                         if OutColNum.SearchName = I
//                         then begin
//                                  for J := High(BeforeCompanyFields) downto 0 do
//                                  begin
//                                      outputHeaderSL.Insert(I, BeforeCompanyFields[J]);
//                                  end;
//                              end;
//                     end;
                     INSERT_HERE := MaxIntValue([ColNum.SearchName, ColNum.WebSite, ColNum.State]);

                     //for I := Low(AdditionalFields) to High(AdditionalFields) do
                     for I := High(AdditionalFields) downto Low(AdditionalFields) do
                     begin
                         if AdditionalFields[I] = 'm' then
                             if pURLqa = false then continue
                             else begin
                                      for J := 1 to resultsCount do
                                          outputHeaderSL.Add('m' + J.ToString);
                                      continue;
                                  end;

                         if IndexText(AdditionalFields[I], ExcludeColumnsArr) > -1 then continue;
                       {  if AdditionalFields[I] = 's'
                         then begin
                                  for J := 4 to resultsCount do
                                      outputHeaderSL.Add('s' + J.ToString);
                                  continue;
                              end;

                         if AdditionalFields[I] = 'r'
                         then begin
                                  for J := 4 to resultsCount do
                                      outputHeaderSL.Add('r' + J.ToString);
                                  continue;
                              end;

                         if AdditionalFields[I] = 'domain'
                         then begin
                                  for J := 4 to resultsCount do
                                      outputHeaderSL.Add('domain' + J.ToString);
                                  continue;
                              end;    }

                         //outputHeaderSL.Add(AdditionalFields[I]);
                         outputHeaderSL.Insert(INSERT_HERE + 1, AdditionalFields[I]);
                     end;
                     SetLength(ExcludeColumnsArr, 0);
                    //---вставляем поля в самое начало заголовка----------------
                    if ColNum.OO_ID = -1 then
                        for I := High(PriorFields) downto Low(PriorFields) do
                        begin
                            outputHeaderSL.Insert(0, PriorFields[I]);
                        end;
                    //---вставляем поля из массива directories--------------------
//                    J := MaxIntValue([ColNum.SearchName, ColNum.WebSite, ColNum.State]);
                    for I := 0 to outputHeaderSL.Count - 1 do
                        if outputHeaderSL[I] = 'calc1' then  J := I;

                    for I := High(excludesDirArray) downto Low(excludesDirArray) do
                    begin
                        strTemp := excludesDirArray[I].Replace(',', ' ').Trim(['{', '}']).Substring(0, excludesDirArray[I].IndexOf('.') - 1);
                        outputHeaderSL.Insert(J, strTemp{excludesDirArray[I].Replace(',', ' ')});
                    end;

                    strHeader := outputHeaderSL[0]; //---переводим заголовок из списка в строчку---
                    for I := 1 to outputHeaderSL.Count-1 do
                        strHeader := strHeader + ',' + outputHeaderSL[I];
                end;

        end else ErrorSL.Add(Format('File %s not found',[FIELDMAPFILECONST]));
       //-----------------------------------------------------------------------
       //---всё, закончили формировать заголовок--------------------------------
       //-----------------------------------------------------------------------

        if Assigned(FieldMapSL) then FieldMapSL.Free;

        if ErrorSL.Count > 0 then
        begin
            for I := 0 to ErrorSL.Count - 1 do
                WriteLn(ErrorSL[I]);

            WriteLn('Press Enter...');
            ReadLn;
            Exit;
        end;
        ErrorSL.Free;
        //----------------------------------------------------------------------

        if LowerCase(UserAnswer) <> 'y' then
        begin
            //Writer := TStreamWriter.Create(ChangeFileExt(filenamein,'') + '_urlfinder.csv', false, myEncoding);
            Writer := TStreamWriter.Create(Format('%s_%s.csv',[ChangeFileExt(filenamein,''), APPNAME]), false, myEncoding);

            Writer.WriteLine(strheader);        //пишем заголовок выходного файла
            linesprocessed := 1;
            System.SysUtils.DeleteFile(iniFileName);
            //WriteLn(Format('Lines processed: %d ' ,[linesprocessed]));
        end;

        CursPosY := WhereY;
        if LowerCase(UserAnswer) = 'y' then
        begin
            //Writer := TStreamWriter.Create(ChangeFileExt(filenamein,'') + '_urlfinder.csv', true, myEncoding);
            Writer := TStreamWriter.Create(Format('%s_%s.csv',[ChangeFileExt(filenamein,''), APPNAME]), false, myEncoding);
            while linesprocessed <= intCounter - 1 do
            begin
                SourceString := ReadString(Reader, FieldsCount, InputSL);
                inc(linesprocessed);
                Write('Searching record #: ' + IntToStr(intCounter) + ': ' + IntToStr(linesprocessed));
                GotoXY(0,CursPosY);
            end;
            WriteLn('Record #: ' + IntToStr(intCounter) + ' found'.PadRight(20));
        end;
        CursPosY := WhereY;
        WriteLn(Format('Lines processed: %d ' ,[linesprocessed]));
        StrToScrArray[0] := Format('Lines processed: %d ' ,[linesprocessed]);
        //----------------------------------------------------------------------
        AppDirectory := ExtractFilePath(ParamStr(0)); //---получаем имя рабочей директории---
        TDirectory.CreateDirectory(BASEDIRECTORY);
        //---имя директории для json файлов (файловый кэш с результатами поисковых запросов)---
        OutputDirectory := BASEDIRECTORY + TPath.GetFileNameWithoutExtension(filenamein) + '\';
        //---создаём директорию для файлового кэша---
        TDirectory.CreateDirectory(OutputDirectory);
        //---имя директории для лог файлов---
        ErrorLogDirectory := BASELOGDIR + TPath.GetFileNameWithoutExtension(filenamein) + '\';
        URLToolUnitErrorLogDir := ErrorLogDirectory;
        //---если включен режим логирования
        if ((pJuLog = true) or (pUuLog = true))
        then begin
                 if TDirectory.Exists(ErrorLogDirectory) = false then
                     TDirectory.CreateDirectory(ErrorLogDirectory);
                 //---удаляем файлы старше 7ми дней---
                 for strTemp in TDirectory.GetFiles(ErrorLogDirectory, '*.*errlog') do
                 begin
                     if TFile.GetCreationTime(strTemp) <= (Date - 7) 
                     then TFile.Delete(strTemp);
                 end;
             end;    

        ContentSL := TStringList.Create;     //для сохранения прочитанных строк
        HashSL := TStringList.Create;

        Pool := TThreadPool.Create;
        Pool.SetMinWorkerThreads(FCS.MaxThreads div 2);
        Pool.SetMaxWorkerThreads(FCS.MaxThreads);

        SourceString := '';
        //CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
        //CoInitializeEx(nil, COINIT_MULTITHREADED);
        //CoInitialize(nil);

        GotoXY(0, CursPosY + 1);
        StrToScrArray[1] := '0 % batch completed'.PadRight(22);

//------------------------------------------------------------------------------
//---Вывод информации на экран--------------------------------------------------
        task := TTask.Create(procedure ()
        var ii, jj: integer;
            ss, _strOut: string;
        begin
            ii := 0;
            repeat
                Sleep(1000);

                inc(ii);
                ss := string.Create('.',ii).PadRight(10) ;
                GotoXY(0, CursPosY);
                for jj := Low(StrToScrArray) to High(StrToScrArray) do
                begin
                    if Length(StrToScrArray[jj]) > 0 then
                    begin
                        _strOut := StrToScrArray[jj];
                        if jj = 1 then _strOut := _strOut + ss;
                        WriteLn(_strOut);
                    end;
                end;
                if ii = 10 then ii := 0;

            until task.Status = TTaskStatus.Canceled;
        end);
        task.Start;
        //---подготовим http string list------------------------------------------------
        HTTPcodesSL := TStringList.Create;
        HTTPcodesSL.Sorted := true;
        for I := 0 to High(ServerAnswers) do
            HTTPcodesSL.Add(ServerAnswers[I]);
        //------------------------------------------------------------------------------
        domainStats := TAVLTree.Create(false);
        //------------------------------------------------------------------------------
        //if CoInitializeEx(nil, COINIT_APARTMENTTHREADED) <> S_OK then Exit;
        repeat
            timeCurrBegin := Now;
            //TempSL.Clear;
            ContentSL.Clear;
            HashSL.Clear;
            //---обнуляем массив результатов------------------------------------
            //for I := Low(ResponseArray) to High(ResponseArray) do
            TParallel.For(0, High(ResponseArray), procedure(II: integer)
            begin
                if Assigned(ResponseArray[II].SearchCondition) then SetLength(ResponseArray[II].SearchCondition, 0);
                if Assigned(ResponseArray[II].SearchQuery) then SetLength(ResponseArray[II].SearchQuery, 0);
                if Assigned(ResponseArray[II].DirectoriesArr) then SetLength(ResponseArray[II].DirectoriesArr, 0);
            end);

            ResponseArray := nil;
            //------------------------------------------------------------------
            SearchTree := TAVLTree.Create(false);

            repeat
                SourceString := ReadString(Reader, FieldsCount, InputSL);

                if Length(SourceString) > 0 then
                begin
                    //ContentSL.Add(SourceString);
                    if ColNum.State > -1
                    then begin   //---проводим нормализацию-подставляем полное имя штата--
                             if InputSL[ColNum.State].Length > 0
                             then begin
                                      strTemp := InputSL[ColNum.State];
                                      strTemp := StatesTree.FindData(strTemp.ToLower);
                                      if strTemp.Length > 0 then
                                          InputSL[ColNum.State] := strTemp;
                                  end;
                         end;

                    ContentSL.Add(CSVfromSL(InputSL));
                    //SetLength(RespArr, Length(RespArr) + 1);
                    inc(linesprocessed);
                    strQuerySummary := '';

                    for I := 0 to High(URLcnDynArrInp) do
                    begin
                        strQuery := '';
                        strCondition := '';
                        for J := Low(URLcnDynArrInp[I]) to High(URLcnDynArrInp[I]) do
                        begin
//                            if BodyMatches_cn.State_cn = URLcnDynArrInp[I, J] then
//                            begin
//                                strTemp := InputSL[URLcnDynArrInp[I, J]];
//                                strTemp := StatesTree.FindData(strTemp.ToLower);
//                                InputSL[URLcnDynArrInp[I, J]] := strTemp;
//                            end;
                            strQuery := strQuery + InputSL[URLcnDynArrInp[I, J]] + ' ';
                            strCondition := strCondition + OriginalHeaderSL[URLcnDynArrInp[I, J]] + ';';
                        end;
                        strQuery := DeleteUselessSpaces(Trim(strQuery));
                        strQuerySummary := strQuerySummary + strQuery + ' ';

                        if ArrAddUniqueValue(TempQuery, strQuery) = true
                        then begin
                                 SetLength(TempCondition, Length(TempCondition) + 1);
                                 TempCondition[High(TempCondition)] := strCondition;
                             end;
                    end;

                    strHash := THashSHA2.GetHashString(strQuerySummary);
                    HashSL.Add(strHash);

                    SearchTreeNode := SearchTree.FindOrInsert(strHash, strQuerySummary);

                    if SearchTreeNode = nil then
                    begin
                        SetLength(ResponseArray, Length(ResponseArray) + 1);
                        I := High(ResponseArray);
                        ResponseArray[I].OO_ID := linesprocessed - 1;
                        ResponseArray[I].SearchQuery := TempQuery;
                        ResponseArray[I].SearchCondition := TempCondition;
                        ResponseArray[I].QueryHash := strHash;
                        //------------------------------------------------------
                        if ColNum.SearchName > -1
                        then begin
                                 ResponseArray[I].Name := InputSL[ColNum.SearchName];
                                 ResponseArray[I].NormalizedName := NormalizeCompanyName(InputSL[ColNum.SearchName],
                                                                                         2,     //---количество слов при котором остаются модификаторы
                                                                                         ModifierArray);  //---массив модификаторов, например INC или LLC
                                 ResponseArray[I].NormalizedName := ClearStr2(ResponseArray[I].NormalizedName, ['`', '''', '&#8217;', '’', '"']);
                             end;                                                      //ClearStr2(InnerText, ['`', '''', '&#8217;', '’']);
                        if ColNum.State > -1
                        then begin
                                 if InputSL[ColNum.State].Length > 0 //если есть название штата
                                 then begin
                                          ResponseArray[I].State := InputSL[ColNum.State];
                                          //---ищем название штата по аббревиатуре---
                                          //strTemp := StatesTree.FindData(ResponseArray[I].State.ToLower);
                                          //---ищем аббревиатуру штата---------------
                                          strTemp := StatesAbbrTree.FindData(ResponseArray[I].State.ToLower);
                                          //---если найдено, то записываем в поисковый массив---
                                          if strTemp.Length > 0
                                          then begin
                                                   ResponseArray[I].StateAbbr := strTemp;
                                                   //ResponseArray[I].State := strTemp;
                                               end;
                                      end;
                             end;
                        if ColNum.City > -1 then ResponseArray[I].City := InputSL[ColNum.City];

                        if ColNum.Address > -1 then ResponseArray[I].Addr := InputSL[ColNum.Address];

                        if ColNum.Zip > -1 then ResponseArray[I].Zip := InputSL[ColNum.Zip];

                        if ColNum.Phone > -1 then
                        begin
                            ResponseArray[I].Phone := InputSL[ColNum.Phone];
                            ResponseArray[I].NormalizedPhone := GetNumbers(InputSL[ColNum.Phone]);
                            ResponseArray[I].AC := ExtractAreaCode(InputSL[ColNum.Phone]);
                        end;
                        if ColNum.URLqa > -1 then ResponseArray[I].URL_QA := InputSL[ColNum.URLqa];
                        if ColNum.WebSite > -1 then ResponseArray[I].WebSite := InputSL[ColNum.WebSite];
                    end;
                    SetLength(TempQuery, 0);     //----
                    SetLength(TempCondition, 0); //----
                end;
            until (((linesprocessed - 1) mod FCS.MaxThreads {FCS.MaxPerSecond} = 0) or Reader.EndOfStream);
            FreeAndNil(SearchTree);
            //TempSL.SaveToFile(IntToStr(linesprocessed));  // для тестов

            total := 0;
            //Sleep(1000); //for testing with free Bing Search Key

            TParallel.For(0, High(ResponseArray), procedure(JJ: integer)
            var _SearchKey, _strJSON, InnerText, RawHTMLString, _strTemp{, _strCount}: string;
                InnerTextArr, ThreadInnerTextArr: TArray<string>;
                II, KK, MM, NN, OO, percentage: integer;
                //_Saver: TStringList;
                parsingResults, ClearedParsingResults, ThreadClearedParsingResults: TArray<TJSONparsingResults>{TJSONresultsArray};
                EmptyElement: TJSONparsingResults;
                HttpResponse: THttpResponse;
                HttpResponseArr, ThreadHttpResponseArr: TArray<THttpResponse>;
                _IsSocialNw: boolean;
                _ReqStatus: integer;
                _DomainDuplicatesArr, UsefulLinks, ThreadUsefulLinks{, TempArr}: TArray<string>;
                //_domainsSL: TStringList;
                ParseResult: string;
                HTTPuserAgent: string;
                RightCondition: TArray<string>;
                NormalizedCompanyNameArr: TArray<string>;
                CityMatch, StateMatch, StateAbbrMatch: string;
                CityDataFound, StateDataFound, StateAbbrDataFound: TArray<TDomainRec>;
                DigitsFromText: string;
                PairCityState: TArray<TPairRec>;
                arrPhoneFromSnippet, arrPhoneFromWeb: TArray<string>;
                _PhonesTree: TAVLtree;
                _TempNode, _PhoneTempNode: TAVLTreeNode;
                _PhoneScoreArr: TArray<TPhoneScoreRec>;
                _AreaCode: string;
                ExcludedDomains: string;
                _doBingSearch: boolean;
            //for JJ := 0 to High(ResponseArray) do
                //NormResult: string;
                //InnerHttpResponse: THttpResponse;
                //PP, pageSize: integer;
                strWorkWebsite, strWorkDomain: string;
                _ErrorText: string;
            begin
                //CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                //---поиск включен
                if ((pSearchOff = true) and (ResponseArray[JJ].WebSite.Length > 0))
                then _doBingSearch := false
                else _doBingSearch := true;

                if pSearchOn = true then _doBingSearch := true;

                if pWebsite = false then _doBingSearch := true;

                if _doBingSearch = true then
                    Sleep(JJ * TimeInterval); //1000 for testing with free Bing Search Key

                //try
                    TInterlocked.Increment(total); //блокируем и увеличиваем счётчик
                                                   //в последствии счётчик показывается пользователю
                    //---супер поисковая процедура--------------------------
                    //if CoInitializeEx(nil, COINIT_APARTMENTTHREADED) = S_OK then  //включаем ActiveX
                    //if CoInitialize(nil) = S_OK then
                    //begin
                    if _doBingSearch = true then
                    begin
                        try
                            if Length(ResponseArray[JJ].SearchQuery) > 0
                            then begin
                                     //---цикл по запросам----------------------
                                     CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                                     for II := Low(ResponseArray[JJ].SearchQuery) to High(ResponseArray[JJ].SearchQuery) do
                                     begin
                                         Sleep((JJ{ + II}) * TimeInterval); //1000 for testing with free Bing Search Key
                                         _SearchKey := ResponseArray[JJ].SearchQuery[II];
                                         //поставить запрос в кавычки========================
                                         if pQuoted = true then
                                         begin
                                             _SearchKey := _SearchKey.Trim(['"']);
                                             _SearchKey := '"' + _SearchKey + '"';
                                         end;
                                         //==================================================
                                         if _SearchKey.ToLower.IndexOf('out of business') > -1 then continue;

                                         //try
                                         if pBing = true  //---принудительно делаем поисковый запрос
                                         then begin
                                                  _ReqStatus := GetBingInfo(_SearchKey, BingUserAgent, FCS.AppID, FCS.BaseURL, ResponseArray[JJ].SearchResults, _ErrorText, SEARCHCOUNTER);
                                                  inc(BingCallsWereUsed);
                                                  ResponseArray[JJ].Source := 'web';
                                              end;

                                         if pBing = false then  //---если нет параметра принудительного запроса
                                         begin  //---если в кеше есть файл----
                                             strTemp := OutputDirectory + PrepareFileName(_SearchKey) + '.json';
                                             if TFile.Exists(OutputDirectory + PrepareFileName(_SearchKey) + '.json') = true
                                             then begin  //---берём данные из файла---
                                                      ResponseArray[JJ].SearchResults := TFile.ReadAllText(OutputDirectory + PrepareFileName(_SearchKey) + '.json');
                                                      if ResponseArray[JJ].SearchResults.Length > 0 then _ReqStatus := BING_OK;
                                                      ResponseArray[JJ].Source := 'file';
                                                  end
                                             else begin  //---если в кеше файла нет-делаем запрос в Bing-------
                                                      _ReqStatus := GetBingInfo(_SearchKey, BingUserAgent, FCS.AppID, FCS.BaseURL, ResponseArray[JJ].SearchResults, _ErrorText, SEARCHCOUNTER);
                                                      inc(BingCallsWereUsed);
                                                      ResponseArray[JJ].Source := 'web';
                                                  end;
                                         end;

                                         ResponseArray[JJ].BingErrorCode := _ReqStatus;

                                         //---Обработка ошибок, если они были---
                                         if _ErrorText.Length > 0
                                         then ResponseArray[JJ].BingErrorDescr := Format('%d: %s', [_ReqStatus, _ErrorText])
                                         else ResponseArray[JJ].BingErrorDescr := Format('%d: %s', [_ReqStatus, FindBingDescr(_ReqStatus)]);

                                         ResponseArray[JJ].UsedQuery := ResponseArray[JJ].SearchQuery[II];
                                         ResponseArray[JJ].UsedCondition := ResponseArray[JJ].SearchCondition[II];

                                         if pQuoted = true
                                         then ResponseArray[JJ].UsedQuery := '""' + ResponseArray[JJ].UsedQuery.Trim(['"']) + '""'
                                         else ResponseArray[JJ].UsedQuery := '"' + ResponseArray[JJ].UsedQuery.Trim(['"']) + '"';

                                         _strJSON := ResponseArray[JJ].SearchResults;

                                         if _strJSON.Length = 0 then continue;      //---если размер json данных = 0
                                         if IsJSON(_strJSON) = false then continue; //---если данные не являются json
                                         if _ReqStatus <> BING_OK then  continue;   //---если произошла ошибка во время обращения к Bing

                                         _strTemp := OutputDirectory + PrepareFileName(_SearchKey) + '.json';   //---нормализуем имя файла----------

                                         ParseResult := ParseJSON2(_strJSON, ResponseArray[JJ].URL_QA, parsingResults);
                                         if ParseResult <> RESULT_OK
                                         then begin
                                                  ResponseArray[JJ].BingErrorCode := 0;
                                                  //ResponseArray[JJ].BingErrorDescr := Format(ParseResult + ' Search key: %s', [ResponseArray[JJ].Source, _SearchKey]);
                                                  ResponseArray[JJ].BingErrorDescr := Format(ParseResult + ' Source: %s; Search key: %s',[ResponseArray[JJ].Source, _SearchKey]);
                                                  //StrToScrArray[5] := Format(ParseResult + ' Search key: %s', [ResponseArray[JJ].Source, _SearchKey]);
                                                  if FileExists(_strTemp) = true then TFile.Delete(_strTemp);
                                              end;

                                         if ResponseArray[JJ].Source = 'web' //если json взят из запроса, а не из файла - сохраняем файл на диск
                                             then TFile.WriteAllText(_strTemp, _strJSON, myEncoding);

                                         ResponseArray[JJ].JSONfile := '"file://' + AppDirectory + _strTemp + '"';
                                         //except
                                         //    ResponseArray[JJ].BingErrorDescr := 'Ouch!!!';
                                         //end;
                                         //--------------------------------------------------
                                         //---ищем урл из массива directories----------------
                                         ResponseArray[JJ].DirectoriesArr := ProcessDirectories(excludesDirArray,
                                                                                                parsingResults,
                                                                                                ResponseArray[JJ].NormalizedName,
                                                                                                SR);
                                         SetLength(parsingResults, resultsCount);
                                         ResponseArray[JJ].sResult := resultsCount;

                                         ClearedParsingResults := ClearParsingResults(parsingResults,
                                                                                      excludesUrlArray + excludesDirArray,
                                                                                      excludesNamesArray,
                                                                                      excludesKeyArray, ExcludedDomains);

//                                         SetLength(ClearedParsingResults, resultsCount);
//                                         ResponseArray[JJ].sResult := resultsCount;

                                         SetLength(parsingResults, 0);
                                         ResponseArray[JJ].ExcludedDomains := ExcludedDomains;
                                         if Length(ClearedParsingResults) = 0 then continue;

                                         //---если есть результаты - переходим к следующему этапу
                                         if Length(ClearedParsingResults) > 0 then break;
                                     end; //---окончание цикла по SearchQuery------------
                                     CoUninitialize;
                                 end;
                                //---если поисковые запросы пустые - выдаём сообщение об ошибке---
                                if Length(ResponseArray[JJ].SearchQuery) = 0 then ResponseArray[JJ].BingErrorDescr := FindBingDescr(0);
                        except
                            on E:EOleException do
                            begin
                                ResponseArray[JJ].BingErrorDescr := FormatDateTime('yyyy.mm.dd hh:nn:ss', Now) +
                                Format('|EOleException %s %x', [E.Message,E.ErrorCode]) +
                                Format('|Line# %d , SearchStr: %s',[JJ, _SearchKey]);
                                if pJuLog = true
                                then begin
                                         if TDirectory.Exists(ErrorLogDirectory) = true
                                         then TFile.WriteAllText(ErrorLogDirectory + PrepareFileName(_SearchKey) + '.ju_errlog', Format('BING error: %s', [ResponseArray[total].BingErrorDescr]), TEncoding.UTF8);
                                     end;
                                //WriteLn(ResponseArray[total].BingErrorDescr);
                            end;

                            on E:Exception do
                            begin
                                ResponseArray[JJ].BingErrorDescr := FormatDateTime('yyyy.mm.dd hh:nn:ss', Now) +
                                Format('|BingSearch ThreadError: %s %s ', [E.Message,E.ClassName]) +
                                Format('|Line# %d , SearchStr: %s',[JJ, _SearchKey]);
                                if pJuLog = true 
                                then begin
                                         if TDirectory.Exists(ErrorLogDirectory) = true
                                         then TFile.WriteAllText(ErrorLogDirectory + PrepareFileName(_SearchKey) + '.ju_errlog', Format('BING error: %s', [ResponseArray[total].BingErrorDescr]), TEncoding.UTF8);
                                     end;
                                //WriteLn(ResponseArray[total].BingErrorDescr);
                            end;
                        end;
                    end;  //---end doBingSearch---

                    //---отработка параметра WebSite----------------------------
                    if pWebsite = true then
                    if ResponseArray[JJ].WebSite.Length > 0
                    then begin
                             SetLength(ClearedParsingResults, Length(ClearedParsingResults) + 1);
                             ClearedParsingResults[High(ClearedParsingResults)].displayUrl := ResponseArray[JJ].WebSite;
                             ClearedParsingResults[High(ClearedParsingResults)].domain := ExtractDomain(ResponseArray[JJ].WebSite, true);
                             ClearedParsingResults[High(ClearedParsingResults)].domainName := GetDomainName(ResponseArray[JJ].WebSite, URL_DOMAIN_PATTERN);
                             ClearedParsingResults[High(ClearedParsingResults)].iwScore := inputScore;
                         end;

                    if Length(ResponseArray[JJ].DirectoriesArr) = 0 then SetLength(ResponseArray[JJ].DirectoriesArr, Length(excludesDirArray));

                    for KK := 0 to High(ClearedParsingResults) do
                    begin
                        //---после удаления исключений присваиваем новые порядковые номера
                        ClearedParsingResults[KK].ResNumber := KK + 1;
                        //---
//                      if ((pWebsite = true) and (ResponseArray[JJ].WebSite.Length > 0))
//                      then ClearedParsingResults[KK].iwScore := inputScore;
                    end;
                    //------------------------------------------
                    //---поищем телефоны-в сниппете-------------
                    //------------------------------------------
                    _PhonesTree := TAVLTree.Create(false);
                    for KK := 0 to High(ClearedParsingResults) do
                    begin
                        //---если текста нет - значит и нечего обрабатывать---
                        if ClearedParsingResults[KK].arrSnippet.Length = 0 then continue;

                        arrPhoneFromSnippet := DetectAndExtractPhoneNumber(ClearedParsingResults[KK].arrSnippet);
                        if Length(arrPhoneFromSnippet) = 0 then continue;

                        ClearedParsingResults[KK].strPhonesFromSnippet := ClearedParsingResults[KK].strPhonesFromSnippet + string.Join(';', arrPhoneFromSnippet);
                        for NN := 0 to High(arrPhoneFromSnippet) do
                            _PhonesTree.IncrementOrInsert('snippet:' + GetNumbers(arrPhoneFromSnippet[NN]));
                        SetLength(arrPhoneFromSnippet, 0);
                    end;

                try
                    if Length(ClearedParsingResults) > 0
                    then begin
                             //---собственно подсчёт числа повторений----
                             CreateDomainDuplicatesList(ClearedParsingResults, ddGroup, ddTreshold, _DomainDuplicatesArr);

                             if pSimple = true then pCrawl := false;
                             if pCrawl = true
                             then begin
                                      //---получаем все домашние страницы, адреса которых нашли на предыдущих этапах---
                                      SetLength(ThreadHttpResponseArr, Length(ClearedParsingResults));
                                      ThreadClearedParsingResults := ThreadClearedParsingResults + ClearedParsingResults;
                                      TParallel.For(0, High(ThreadClearedParsingResults), procedure(PP: integer)
                                      var ThreadHTTPuserAgent: string;
                                          //InnerHttpResponse: THttpResponse;
                                      begin
                                          //CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                                          ThreadHTTPuserAgent := GenerateUserAgent();
                                          ThreadHttpResponseArr[PP] := GetURL(ThreadClearedParsingResults[PP].domain, ThreadHTTPuserAgent, HTTPcodesSL, pUuLog);
                                          //TFile.WriteAllText(PP.ToString + '_' + NormalizeString(ThreadClearedParsingResults[PP].domain) + '_home.txt', ThreadHttpResponseArr[PP].RawHTMLstring);
                                          //CoUninitialize;
                                      end, Pool);
                                      HttpResponseArr := HttpResponseArr + ThreadHttpResponseArr;
                                      SetLength(ThreadHttpResponseArr, 0);
                                      SetLength(ThreadClearedParsingResults, 0);
                                  end;

                                  //------------------------------------------
                                  //---подсчёт баллов результатов поиска------
                                  //---а также загрузка html страниц

                                             CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                                             for KK := 0 to High(ClearedParsingResults) do
                                             begin
                                                 if pSimple = true then pCrawl := false;

                                                 if pCrawl = true
                                                 then begin
                                                          InnerText := '';

                                                          CityMatch := NODATAFOUND;
                                                          StateMatch := NODATAFOUND;
                                                          StateAbbrMatch := NODATAFOUND;
                                                          //---Получим данные из интернета------------
                                                          //---генерируем название браузера-----------
                                                      //    HTTPuserAgent := GenerateUserAgent(); //BROWSERS = '{Firefox|Chrome|Internet Explorer|Edge}';
                                                          if HttpResponseArr[KK].RawHTMLstring.Length > FCS.MaxPageSize
                                                          then begin
                                                                   HttpResponseArr[KK].RawHTMLstring := '';
                                                                   HttpResponseArr[KK].Error := Format('Maximum page size exceeded: %s', [ClearedParsingResults[KK].displayUrl]);
                                                               end;
                                                          //---получаем главную страницу--------------
                                                      //    HttpResponse := GetURL(ClearedParsingResults[KK].domain, HTTPuserAgent, HTTPcodesSL);
                                                          if Length(HttpResponseArr[KK].RawHTMLstring) > 0  //---парсинг главной страницы
                                                          then begin
                                                              //CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                                                              ParseHTML(ClearedParsingResults[KK].domain, HttpResponseArr[KK].RawHTMLstring,
                                                                        TargetsArr, UsefulLinks, InnerText, pUuLog);
                                                              //CoUninitialize;
                                                              //---ограничим количество найденных ссылок---------------------------------------------------
                                                              if Length(UsefulLinks) > FCS.MaxPagesPerSite then SetLength(UsefulLinks, FCS.MaxPagesPerSite);
                                                              //---нормализуем полученный текст---
                                                              InnerText := ClearStr2(InnerText, ['`', '''', '&#8217;', '’']);
                                                              //InnerText := InnerText.Replace('&', ' ', [rfReplaceAll]);
                                                              InnerText := InnerText.Replace(' and ', ' ', [rfReplaceAll]);
                                                              //---тест тест тест---
                                                              RawHTMLString := NormalizeString(HttpResponseArr[KK].RawHTMLstring) + ' ' + InnerText + ' ' + HttpResponseArr[KK].RawHTMLstring;
                                                          //    TFile.WriteAllText('home.txt', RawHTMLString, myEncoding);
                                                          //    InnerText := HttpResponseArr[KK].RawHTMLstring;
                                                              //---здесь начинается тест---------------------------------
                                                              //---попробуем получить текст со всех ссылок---------------
                                                              //SetLength(InnerTextArr, Length(UsefulLinks) + 1);
                                                          //    InnerTextArr := InnerTextArr + [InnerText];
                                                              //---------------------------------------------------------
                                                              //---исключительно только для главной страницы-------------
                                                              //---------------------------------------------------------
                                                              NormalizedCompanyNameArr := ResponseArray[JJ].NormalizedName.Split([' '], ExcludeEmpty);
                                                              if Length(NormalizedCompanyNameArr) > 1
                                                              then begin
                                                                       if ((ContainsText(' ' + RawHTMLString{InnerText} + ' ', ' ' + NormalizedCompanyNameArr[0] + ' ') = false)
                                                                       and (ContainsText(' ' + RawHTMLString{InnerText} + ' ', ' ' + NormalizedCompanyNameArr[1] + ' ') = true))
                                                                       then ClearedParsingResults[KK].cow1zScore := cow1zScore;

                                                                       if ((ContainsText(' ' + RawHTMLString{InnerText} + ' ', ' ' + NormalizedCompanyNameArr[0] + ' ') = true)
                                                                       and (ContainsText(' ' + RawHTMLString{InnerText} + ' ', ' ' + NormalizedCompanyNameArr[1] + ' ') = false))
                                                                       then ClearedParsingResults[KK].cow2zScore := cow2zScore;
                                                                   end;
                                                              //---------------------------------------------------------
                                                          //    InnerText := HttpResponseArr[KK].RawHTMLstring;
                                                              //---здесь начинается тест---------------------------------
                                                              //---попробуем получить текст со всех ссылок---------------
                                                              //SetLength(InnerTextArr, Length(UsefulLinks) + 1);
                                                              InnerTextArr := InnerTextArr + [RawHTMLString{InnerText}];
                                                              //---------------------------------------------------------
                                                              SetLength(ThreadInnerTextArr, Length(UsefulLinks));
                                                              ThreadUsefulLinks := ThreadUsefulLinks + UsefulLinks;
                                                              //for PP := 0 to High(UsefulLinks) do
                                                              TParallel.For(0, High(ThreadUsefulLinks), procedure(PP: integer)
                                                              var NormResult: string;
                                                                  InnerHttpResponse: THttpResponse;
                                                              begin
                                                                  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
                                                                  InnerHttpResponse := GetURL(ThreadUsefulLinks[PP], HTTPuserAgent, HTTPcodesSL, pUuLog);

                                                                  if InnerHttpResponse.RawHTMLstring.Length <= FCS.MaxPageSize
                                                                  then
                                                                      NormResult := ParseHTMLlightNorm(InnerHttpResponse.RawHTMLstring, ['`', '''', '&#8217;', '’'], pUuLog);
                                                                  //NormResult := InnerHttpResponse.RawHTMLstring;
                                                                  ThreadInnerTextArr[PP] := NormResult + ' ' + NormalizeString(InnerHttpResponse.RawHTMLstring) + InnerHttpResponse.RawHTMLstring;
                                                                  //TFile.WriteAllText(NormalizeString(ThreadUsefulLinks[PP]) + PP.ToString + 'home.txt', ThreadInnerTextArr[PP], myEncoding);
                                                                  CoUninitialize;
                                                              end, Pool);
                                                              //end;
                                                              InnerTextArr := InnerTextArr + ThreadInnerTextArr;
                                                              SetLength(ThreadInnerTextArr, 0);
                                                              SetLength(ThreadUsefulLinks, 0);

                                                              //for MM := 0 to High(UsefulLinks) do
                                                              for MM := 0 to High(InnerTextArr) do
                                                              begin
                                                              //    HttpResponse := GetURL(UsefulLinks[MM], HTTPuserAgent, HTTPcodesSL);
                                                                  //InnerText := ParseHTMLlight(HttpResponse.RawHTMLstring);
                                                                  //InnerText := ClearStr2(InnerText, ['`', '''', '&#8217;', '’']);
                                                              //    InnerText := ParseHTMLlightNorm(HttpResponse.RawHTMLstring, ['`', '''', '&#8217;', '’']);
                                                                  //---поищем телефон на страничке---------------------------
                                                                  arrPhoneFromWeb := DetectAndExtractPhoneNumber(InnerTextArr[MM]);
                                                                  //---если нашли телефоны-----------------------------------
                                                                  if Length(arrPhoneFromWeb) > 0
                                                                  then begin
                                                                           ClearedParsingResults[KK].strPhonesFromWeb := ClearedParsingResults[KK].strPhonesFromWeb + ';' + string.Join(';', arrPhoneFromWeb);

                                                                           //for NN := 0 to Min(High(arrPhoneFromWeb),20) do
                                                                           for NN := 0 to High(arrPhoneFromWeb) do
                                                                               _PhonesTree.IncrementOrInsert('homepage:' + GetNumbers(arrPhoneFromWeb[NN]));

                                                                           SetLength(arrPhoneFromWeb, 0);
                                                                       end;
                                                                  //---------------------------------------------------------

                                                                  if ClearedParsingResults[KK].powScore = 0
                                                                  then begin
                                                                           DigitsFromText := GetNumbers(InnerTextArr[MM]);
                                                                           if ContainsText(DigitsFromText, ResponseArray[JJ].NormalizedPhone) = true
                                                                           then ClearedParsingResults[KK].powScore := powScore;
                                                                       end;

                                                                  if ClearedParsingResults[KK].cowfnScore = 0
                                                                  then begin
                                                                           if ContainsText(' ' + InnerTextArr[MM] + ' ', ' ' + ResponseArray[JJ].NormalizedName + ' ') = true
                                                                           then ClearedParsingResults[KK].cowfnScore := cowfnScore;
                                                                       end;

                                                                  if ((ClearedParsingResults[KK].f1wmScore = 0)
                                                                  and (ClearedParsingResults[KK].f2wmScore = 0)
                                                                  and (ClearedParsingResults[KK].f2wmScore = 0))
                                                                  then begin
                                                                           //strTemp := RemoveFromLeft(ClearedParsingResults[KK].arrUrl, ['http://', 'https://', 'www.'], true);
                                                                           strTemp := RemoveFromLeft(ClearedParsingResults[KK].domain, ['http://', 'https://', 'www.'], true);
                                                                           M := WordMatchCount(ClearStr2(strTemp).ToLower, ResponseArray[JJ].NormalizedName.ToLower);
                                                                           case M of
                                                                               1: ClearedParsingResults[KK].f1wmScore := SR.f1wmScore;
                                                                               2: ClearedParsingResults[KK].f2wmScore := SR.f2wmScore;
                                                                               3..99: ClearedParsingResults[KK].f3wmScore := SR.f3wmScore;
                                                                           end;
                                                                       end;

                                                                  if ClearedParsingResults[KK].cowfwmScore = 0
                                                                  then begin
                                                                       if Length(NormalizedCompanyNameArr) >= 1
                                                                           then begin
                                                                                    if (ContainsText(' ' + InnerTextArr[MM] + ' ', ' ' + NormalizedCompanyNameArr[0] + ' ') = true)
                                                                                    then ClearedParsingResults[KK].cowfwmScore := cowfwmScore;
                                                                                end;
                                                                       end;

                                                                  if ((ClearedParsingResults[KK].wcsmScore = 0)
                                                                  and (ClearedParsingResults[KK].wsmScore = 0)
                                                                  and (ClearedParsingResults[KK].wcsmmScore = 0)
                                                                  and (ClearedParsingResults[KK].wsmmScore = 0))
                                                                  then boolTemp := true
                                                                  else booltemp := false;

                                                                  if boolTemp = false then continue;

                                                                  //---ищем совпадение с названием города-------------------------
                                                                  CityMatch := SearchDataInText(ResponseArray[JJ].City, InnerTextArr[MM], CitiesArray, CityDataFound);
                                                                  //---ищем совпадение с названием штата--------------------------
                                                                  StateMatch := SearchDataInText(ResponseArray[JJ].State, InnerTextArr[MM], StatesFullNameArray {+ StatesAbbrNameArray}, StateDataFound);
                                                                  //---ищем совпадение с аббревиатурой штата----------------------
                                                                  StateAbbrMatch := SearchDataInText(ResponseArray[JJ].StateAbbr , InnerTextArr[MM], StatesAbbrNameArray, StateAbbrDataFound, True); //---Case sensitive search ---

                                                                  StateDataFound := StateDataFound + StateAbbrDataFound;
                                                                  if StateAbbrMatch = True.ToString then StateMatch := True.ToString;
                                                                  if StateMatch = NODATAFOUND then StateMatch := StateAbbrMatch;

                                                                  if ((CityMatch = '-1') and (StateMatch = '-1')) then
                                                                  begin
                                                                      CityMatch := NODATAFOUND;
                                                                      //SetLength(PairCityState, 0);
                                                                      PairCityState := FindCityStatePairs(CityDataFound, StateDataFound);

                                                                      if Length(PairCityState) > 0
                                                                      then begin
                                                                               NormalizeStatesArr(PairCityState, StatesTree); //приводим все названия штатов к полному имени
                                                                               for OO := 0 to High(PairCityState) do
                                                                               begin
                                                                                   if ((ResponseArray[JJ].City = PairCityState[OO].City)
                                                                                   and (ResponseArray[JJ].State = PairCityState[OO].State))
                                                                                   then begin
                                                                                            CityMatch := '-1';
                                                                                            break;
                                                                                        end;
                                                                               end;
                                                                               SetLength(PairCityState, 0);
                                                                           end;
                                                                  end;
                                                                  SetLength(CityDataFound, 0);
                                                                  SetLength(StateDataFound, 0);
                                                                  SetLength(StateAbbrDataFound, 0);

                                                                  if ((CityMatch = '-1') and (StateMatch = '-1'))
                                                                  then ClearedParsingResults[KK].wcsmScore := wcsmScore; //WebCityStateMatch

                                                                  if ((CityMatch = '0') or{and} (StateMatch = '0'))
                                                                  and ((ResponseArray[JJ].City.Length > 0) and (ResponseArray[JJ].State.Length > 0))
                                                                  then ClearedParsingResults[KK].wcsmmScore := wcsmmScore; //WebCityStateMisMatch

//                                                          if (((CityMatch = '0') or (CityMatch = NODATAFOUND))
//                                                          and (StateMatch = '-1'))
                                                                  if StateMatch = '-1'
                                                                  then ClearedParsingResults[KK].wsmScore := wsmScore; //WebStateMatch

                                                                  if (((CityMatch = '-1') or (CityMatch = NODATAFOUND))
                                                                  and (StateMatch = '0'))
                                                                  then ClearedParsingResults[KK].wsmmScore := wsmmScore; //WebStateMisMatch
                                                              end;
                                                              SetLength(UsefulLinks, 0);
                                                              SetLength(NormalizedCompanyNameArr, 0);
                                                              SetLength(InnerTextArr, 0);
                                                          end;
                                                      end; //---pCrawl-----------------------
                                                 //------------------------------------------
                                                 if ClearedParsingResults[KK].wcsmScore <> 0 then
                                                     if ClearedParsingResults[KK].cowfnScore <> 0 then
                                                         ClearedParsingResults[KK].aowScore := aowScore; //AllOnWebsite
//                                                 //------------------------------------------
//                                                 //---поищем телефоны-в сниппете-------------
//                                                 //------------------------------------------
//                                                 arrPhoneFromSnippet := DetectAndExtractPhoneNumber(ClearedParsingResults[KK].arrSnippet);
//                                                 if Length(arrPhoneFromSnippet) > 0
//                                                 then begin
//                                                          ClearedParsingResults[KK].strPhonesFromSnippet := string.Join(';', arrPhoneFromSnippet);
//                                                          SetLength(arrPhoneFromSnippet, 0);
//                                                      end;

                                                 //------------------------------------------
                                                 //---Domain-Density-Bump--------------------
                                                 //------------------------------------------
                                                 //if pSimple = false
                                                 //then begin
                                                          if Length(_DomainDuplicatesArr) > 0 then
                                                          if IndexStr(ClearedParsingResults[KK].domainName, _DomainDuplicatesArr) > -1
                                                          then ClearedParsingResults[KK].ddbScore := ddBump;  //domain-density-bump
                                                      //end;
                                                 //-----------------------------
                                                 //---State-In-Url--------------
                                                 //-----------------------------
                                                 if ResponseArray[JJ].State.Length > 0
                                                 then begin
                                                          //---ищем полное название штата в имени домена---
                                                          if ClearedParsingResults[KK].domain.Contains(ResponseArray[JJ].State.ToLower.Replace(' ','',[rfReplaceAll])) = true
                                                          then ClearedParsingResults[KK].siuScore := siuScore
                                                          else begin
                                                                   //---берём две последние буквы в названии домена (аббревиатура штата)---
                                                                   _strTemp := GetNsymbolsBeforeDelim(2, ClearedParsingResults[KK].domain, '.');
                                                                   //---получаем полное имя штата по аббревиатуре-----
                                                                   _strTemp := StatesTree.FindData(_strTemp);
                                                                   //---если данные найдены---------------------------
                                                                   if _strTemp.Length > 0
                                                                   then begin
                                                                            if _strTemp.ToLower = ResponseArray[JJ].State.ToLower
                                                                            then ClearedParsingResults[KK].siuScore := siuScore;
                                                                        end;
                                                               end;
                                                      end;

                                                 //-----------------------------
                                                 //---City-In-Url---------------
                                                 //-----------------------------
                                                 if ClearedParsingResults[KK].domain.Contains(ResponseArray[JJ].City.ToLower) = true
                                                 then ClearedParsingResults[KK].ciuScore := ciuScore;

                                                 //-----------------------------
                                                 //---SnippetCityStateMisMatch--
                                                 //-----------------------------
                                                 if (scsmmScore <> 0)  //если переменная = 0,  //то не имеет смысла проводить обработку
                                                 and ((ResponseArray[JJ].City.Length > 0) and (ResponseArray[JJ].State.Length > 0))
                                                 then begin
                                                          RightCondition := GetStatesAndCitiesFromSnippet(ResponseArray[JJ],
                                                                                                 ClearedParsingResults[KK].arrSnippet,
                                                                                                 CitiesArray,
                                                                                                 CityTree,
                                                                                                 StatesFullNameArray,
                                                                                                 StatesAbbrNameArray,
                                                                                                 StatesTree);
                                                          if RightCondition[High(RightCondition)] = '0' then ClearedParsingResults[KK].scsmmScore := scsmmScore;
                                                          SetLength(RightCondition, 0);
                                                      end;

                                                 //-----------------------------
                                                 //---Official-Site-------------
                                                 //-----------------------------
                                                 ClearedParsingResults[KK].osScore := CountNameScore(ClearedParsingResults[KK].arrWebName, ResponseArray[JJ].Name, FindScoreArr);

                                                 //-----------------------------
                                                 //---URL-Result-No-Subfolder---
                                                 //-----------------------------
                                                 if ClearedParsingResults[KK].displayUrl.ToLower.Contains(ClearedParsingResults[KK].domainName + '/') = false
                                                 then ClearedParsingResults[KK].nsScore := nsScore;

                                                 //-----------------------------
                                                 //---InputWebsiteEqualsResult--
                                                 //-----------------------------
                                                 if ResponseArray[JJ].WebSite.Length > 0 then
                                                     if ClearedParsingResults[KK].domain.Length > 0 then
                                                     begin
                                                         strWorkWebsite := RemoveFromLeft(ResponseArray[JJ].WebSite, ['http://', 'https://', 'www.'], true);
                                                         strWorkWebsite := strWorkWebsite.TrimRight(['/']);

                                                         strWorkDomain := RemoveFromLeft(ClearedParsingResults[KK].domain, ['http://', 'https://', 'www.'], true);
                                                         strWorkDomain := strWorkDomain.TrimRight(['/']);

                                                         if strWorkWebsite.ToLower = strWorkDomain.ToLower then
                                                             ClearedParsingResults[KK].iwerScore := iwerScore;
                                                     end;

                                                 _IsSocialNw := false;
                                                 if ResponseArray[JJ].Name.Length > 0 then
                                                     ClearedParsingResults[KK].urlScore := CountURLScore(ClearedParsingResults[KK], ResponseArray[JJ].Name, FindScoreArr, _IsSocialNw, pSimple);

                                                 if _IsSocialNw = true then
                                                     GetSocialNetworks(ResponseArray[JJ], ClearedParsingResults[KK], NameScore);

                                                 if pSimple = false
                                                 then
                                                     if _IsSocialNw = false
                                                     then begin
                                                              ClearedParsingResults[KK].snippetScore := CountPageScore(ClearedParsingResults[KK].arrSnippet, ResponseArray[JJ], FindScoreArr);
                                                          end
                                                 else ClearedParsingResults[KK].snippetScore := CountPageScore(ClearedParsingResults[KK].arrSnippet, ResponseArray[JJ], FindScoreArr);

                                                 //---добавляем баллы по позиции в изначальном(за исключением исключений) списке---
                                                 ClearedParsingResults[KK].pos_N_Score := searchPositionScoreArr[KK];      //баллы за место в поисковой выдаче

                                                 ClearedParsingResults[KK].score := CalculateScoreField(ClearedParsingResults[KK]);
                                                 ClearedParsingResults[KK].calc := FormCalcFieldForOutput(ClearedParsingResults[KK]);

                                                 if ClearedParsingResults[KK].score < filedScore then ClearedParsingResults[KK].filed := 'F';

                                                 if ClearedParsingResults[KK].domain.StartsWith('http://', true) = true then
                                                     ClearedParsingResults[KK].domain := ClearedParsingResults[KK].domain.Replace('http://', '');
                                                 if ClearedParsingResults[KK].domain.StartsWith('https://', true) = true then
                                                     ClearedParsingResults[KK].domain := ClearedParsingResults[KK].domain.Replace('https://', '');
                                             end;
                                             CoUninitialize;
                         end;

                                             SetLength(_DomainDuplicatesArr, 0); //не переносить!!!
                                             SetLength(HttpResponseArr, 0);
                                             //_TempSL.Free;  //не переносить!!!

                                             //==========================================
                                             //---сортировка списка результатов в соответствии с баллами---------
                                             //==========================================
                                             if Length(ClearedParsingResults) > 1 then
                                                 SortArray(ClearedParsingResults, Length(ClearedParsingResults));

                                             //==========================================
                                             //---обработка поддоменов будет находится здесь-------
                                             //==========================================
                                             //---определяем, является ли адрес основным доменом---
                                             if Length(ClearedParsingResults) > 0
                                             then begin
                                                      strTemp := RemoveFromLeft(ClearedParsingResults[0].domain, ['http://', 'https://', 'www.'], true).TrimRight(['/']);
                                                      if strTemp <> ClearedParsingResults[0].domainName
                                                      then begin
                                                               strTemp := ClearedParsingResults[0].domainName;
                                                               for KK := 1 to High(ClearedParsingResults) do
                                                               begin
                                                                   if strTemp = ClearedParsingResults[KK].domainName then
                                                                       if strTemp = RemoveFromLeft(ClearedParsingResults[KK].domain, ['http://', 'https://', 'www.'], true).TrimRight(['/'])
                                                                       then begin
                                                                                //Insert(ClearedParsingResults[KK + 1], ClearedParsingResults, 0);
                                                                                Insert(EmptyElement, ClearedParsingResults, 0);
                                                                                ClearedParsingResults[0] := ClearedParsingResults[KK + 1];
                                                                                Delete(ClearedParsingResults, KK + 1, 1);
                                                                                ResponseArray[JJ].subDomain := 'T';
                                                                            end;
                                                               end;
                                                           end;
                                                  end;

                                             if pSimple = false
                                             then begin
                                                      //---удаляем домены дубликаты--------------------------------
                                                      //---те которые после сортировки получились в конце списка---
                                                      if Length(ClearedParsingResults) > 1 then
                                                          if ResponseArray[JJ].subDomain = 'T'
                                                          then MarkDuplicatesInSearchResults(ClearedParsingResults, 1)
                                                          else MarkDuplicatesInSearchResults(ClearedParsingResults);
                                                      //---сортируем после удалениния дубликатов-------------------
                                                      //if Length(ClearedParsingResults) > 1 then
                                                      //    SortArray(ClearedParsingResults, Length(ClearedParsingResults));
                                                  end;
                                             //ClearedParsingResults := ClearParsingResults(parsingResults, excludesUrlArray, excludesNamesArray);
                                         //end;  //---pSimple---------------------
                                         //-------------------------------------

                                             if Length(ClearedParsingResults) > 0 then
                                             begin
                                                 //-------------------------------------------------
                                                 //---Обработка телефонов---------------------------
                                                 //---записываем все номера телефонов в один ахив---
                                                 //-------------------------------------------------
                                                 //---сначала запишем номера телефонов из сниппета--
                                                 //---проверим - есть ли в топовых результатах номера телефонов---
                                                 if ClearedParsingResults[0].strPhonesFromSnippet.Length > 0
                                                 then begin
                                                          arrPhoneFromSnippet := ClearedParsingResults[0].strPhonesFromSnippet.Split([';']);
                                                          arrPhoneFromSnippet := DeleteDuplicatesFromPhoneArray(arrPhoneFromSnippet);
                                                          for KK := 0 to High(arrPhoneFromSnippet) do
                                                          begin
                                                              _AreaCode := arrPhoneFromSnippet[KK].Substring(arrPhoneFromSnippet[KK].Length - 10, 3);
                                                              _PhoneTempNode := PhoneCodes.FindNode(_AreaCode);
                                                              if _PhoneTempNode <> nil
                                                              then begin
                                                                       _TempNode := _PhonesTree.FindNode('snippet:' + arrPhoneFromSnippet[KK]);
                                                                       if _TempNode <> nil
                                                                       then begin
                                                                                if ResponseArray[JJ].StateAbbr.Length > 0
                                                                                then begin
                                                                                         strTemp := pmsScore.ToString;
                                                                                     end else strTemp := '0';

                                                                                _PhoneScoreArr := _PhoneScoreArr + [TPhoneScoreRec.Create(arrPhoneFromSnippet[KK], 'snippet', '',
                                                                                                                                          _TempNode.Data.ToInteger,
                                                                                                                                          _TempNode.Data.ToInteger * pisScore + strTemp.ToInteger)]; //---временно 0
                                                                            end;
                                                                       _PhoneTempNode := nil;
                                                                       _TempNode := nil;
                                                                   end;
                                                          end;
                                                          SetLength(arrPhoneFromSnippet, 0);
                                                      end;

                                                 if ClearedParsingResults[0].strPhonesFromWeb.Length > 0
                                                 then begin
                                                          arrPhoneFromWeb := ClearedParsingResults[0].strPhonesFromWeb.Split([';'], ExcludeEmpty);
                                                          arrPhoneFromWeb := DeleteDuplicatesFromPhoneArray(arrPhoneFromWeb);
                                                          for KK := 0 to High(arrPhoneFromWeb) do
                                                          begin
                                                              _AreaCode := arrPhoneFromWeb[KK].Substring(arrPhoneFromWeb[KK].Length - 10, 3);
                                                              _PhoneTempNode := PhoneCodes.FindNode(_AreaCode);
                                                              if _PhoneTempNode <> nil
                                                              then begin
                                                                       _TempNode := _PhonesTree.FindNode('homepage:' + arrPhoneFromWeb[KK]);
                                                                       if _TempNode <> nil
                                                                       then begin
                                                                                if ResponseArray[JJ].StateAbbr.Length > 0
                                                                                then begin
                                                                                         strTemp := pmsScore.ToString;
                                                                                     end else strTemp := '0';
                                                                                _PhoneScoreArr := _PhoneScoreArr + [TPhoneScoreRec.Create(arrPhoneFromWeb[KK], 'homepage', '',
                                                                                                                                          _TempNode.Data.ToInteger,
                                                                                                                                          _TempNode.Data.ToInteger * pohScore + strTemp.ToInteger)]; //---временно 0
                                                                            end;
                                                                       _PhoneTempNode := nil;
                                                                       _TempNode := nil;
                                                                   end;
                                                          end;
                                                          SetLength(arrPhoneFromWeb, 0);
                                                      end;
                                                 //ClearedParsingResults[0].strPhonesFromSnippet := '';
                                                 //ClearedParsingResults[0].strPhonesFromWeb := '';

                                                 if Length(_PhoneScoreArr) > 1
                                                 then begin
                                                          TArray.Sort<TPhoneScoreRec>(_PhoneScoreArr, TComparer<TPhoneScoreRec>.Construct(      //сортировка массива
                                                          function (const Left, Right: TPhoneScoreRec): integer
                                                          begin
                                                              Result := Right.Total - Left.Total; //по количеству слов
                                                              //if Result = 0 then Result := AnsiCompareStr(Left, Right);  //по длине строки
                                                          end
                                                          ))
                                                      end;

                                                 for KK := 0 to High(_PhoneScoreArr) do
                                                 begin
                                                     if KK = 0 then ClearedParsingResults[0].phone1 := StandartizePhone(_PhoneScoreArr[KK].Phone);
                                                     if KK = 1 then ClearedParsingResults[0].phone2 := StandartizePhone(_PhoneScoreArr[KK].Phone);
                                                     //p={###-###-####,score} w={###-###-####,score}
                                                     if _PhoneScoreArr[KK].ScoreType = 'snippet' then strTemp := 'p';
                                                     if _PhoneScoreArr[KK].ScoreType = 'homepage' then strTemp := 'w';

                                                     ClearedParsingResults[0].phone_source := ClearedParsingResults[0].phone_source +
                                                                                                   Format('%s={%s,%d};',[strTemp, StandartizePhone(_PhoneScoreArr[KK].Phone),_PhoneScoreArr[KK].Total]);

//                                                     if _PhoneScoreArr[KK].ScoreType = 'homepage'
//                                                     then ClearedParsingResults[0].phone_source := ClearedParsingResults[0].phone_source +
//                                                                                                   Format('w={%s,%d}',[StandartizePhone(_PhoneScoreArr[KK].Phone),_PhoneScoreArr[KK].Total]) + ';';
                                                 end;
//                                                 //---раздельный формат выода телефонов---
//                                                 for KK := 0 to High(_PhoneScoreArr) do
//                                                 begin
//                                                     if KK = 0 then ClearedParsingResults[0].phone1 := StandartizePhone(_PhoneScoreArr[KK].Phone);
//                                                     if KK = 1 then ClearedParsingResults[0].phone2 := StandartizePhone(_PhoneScoreArr[KK].Phone);
//
//                                                     if _PhoneScoreArr[KK].ScoreType = 'snippet'
//                                                     then ClearedParsingResults[0].phone_snippet := ClearedParsingResults[0].phone_snippet +
//                                                                                                           Format('{%s}{%d}',[StandartizePhone(_PhoneScoreArr[KK].Phone),_PhoneScoreArr[KK].Total]) + ';';
//                                                     if _PhoneScoreArr[KK].ScoreType = 'homepage'
//                                                     then ClearedParsingResults[0].phone_website := ClearedParsingResults[0].phone_website +
//                                                                                                           Format('{%s}{%d}',[StandartizePhone(_PhoneScoreArr[KK].Phone),_PhoneScoreArr[KK].Total]) + ';';
//                                                 end;
                                                 SetLength(_PhoneScoreArr, 0);
                                                 //---обработка переменной MinimumTopScore---
                                                 //---если соотетствует условиям-сдвигаем ---
                                                 //---все результаты на одну позицию вниз----
                                                 if ClearedParsingResults[0].score <  MinimumTopScore
                                                 then begin  //добавляем сообщение об ошибке в calc1
                                                          //Insert(EmptyElement, ClearedParsingResults, 0);
                                                          //ClearedParsingResults[0].calc := Format('score=(%d)',[ClearedParsingResults[1].score]);
                                                          ClearedParsingResults[0].d1MS := 'F';
                                                      end;
                                                 //------------------------------------------
                                                 ResponseArray[JJ].xCount := ClearedParsingResults[0].xCount;

                                                 //SortArray(ClearedParsingResults, Length(ClearedParsingResults));

                                                 MM := Min(High(ResponseArray[JJ].topResultArr), High(ClearedParsingResults));
                                                 for KK := 0 to MM do
                                                 begin
                                                     ResponseArray[JJ].topResultArr[KK] := ClearedParsingResults[KK]; //move processed results to the output array

                                                     for OO := 0 to MM do
                                                     begin
                                                         if ResponseArray[JJ].QAm = 0
                                                         then if ResponseArray[JJ].topResultArr[OO].URLqaMatch = 'Y'
                                                              then  begin
                                                                        ResponseArray[JJ].QAm := OO + 1;
                                                                        ResponseArray[JJ].QAcalc := ResponseArray[JJ].topResultArr[OO].calc;
                                                                    end;
                                                         if ResponseArray[JJ].QAm > 0
                                                         then if ResponseArray[JJ].topResultArr[OO].URLqaMatch = 'Y'
                                                              then if (OO + 1) < ResponseArray[JJ].QAm
                                                                   then begin
                                                                            ResponseArray[JJ].QAm := OO + 1;
                                                                            ResponseArray[JJ].QAcalc := ResponseArray[JJ].topResultArr[OO].calc;
                                                                        end;
                                                     end
                                                 end;
                                             end; //Length(ClearedParsingResults) > 0

                                             //---добавляем обработку исключения------
//                                             if Length(ClearedParsingResults) = 0 then
//                                                 ResponseArray[JJ].topResultArr[0].calc := Format('excl=%s',['domain']);
                                    _PhonesTree := nil;         //end;
                        //        end;
                            //if Length(ClearedParsingResults) > 0 then break;
                    //end;
                    //---если url представляет собой поддомен---
                    if ResponseArray[JJ].subDomain = 'T' then
                        ResponseArray[JJ].topResultArr[0].calc := 'sub=T; ' + ResponseArray[JJ].topResultArr[0].calc;

                    //---добавляем обработку исключения------
                    if Length(ClearedParsingResults) = 0 then
                        ResponseArray[JJ].topResultArr[0].calc := ResponseArray[JJ].ExcludedDomains;

                    //---если были ошибки при выполнении bing запроса----
                    if ResponseArray[JJ].BingErrorCode <> BING_OK
                    then begin
                             ResponseArray[JJ].topResultArr[0].calc := SetQuotes(Format('Bing API error: %s',[ResponseArray[JJ].BingErrorDescr]));
                             ResponseArray[JJ].ExcludedDomains := ResponseArray[JJ].topResultArr[0].calc;
                         end;
                    //CoUninitialize;

                              //httpSendMultipart(ResponseArray[JJ].UsedQuery, ResponseArray[JJ].SearchResults);

//                            _SearchKey := StringReplace(_SearchKey, '"', '',[rfReplaceAll]);
//                            _SearchKey := StringReplace(_SearchKey, '\', '',[rfReplaceAll]);
//                            _SearchKey := StringReplace(_SearchKey, '/', '',[rfReplaceAll]);
//
//                            _Saver := TStringList.Create;   //включить для теста
//                            _Saver.Add(_SearchKey);         //включить для теста
//                            _Saver.SaveToFile(_SearchKey);  //включить для теста
//                            _Saver.Free;                    //включить для теста

                    //---вывод данных на экран------------------------------
                    //if TInterlocked.Read(total) mod 3 = 0
                    if total mod 3 = 0
                    then begin
                             percentage := total * 100 div High(ResponseArray);
                             if percentage > 100 then percentage := 100;
                             StrToScrArray[1] := Format('%d %% batch completed', [percentage]).Remove(21).PadRight(21);
                         end;
                //end;

                except
                    on E:EOleException do
                    begin
                        strErrorMsg := 'Unknown error:' + FormatDateTime('yyyy.mm.dd hh:nn:ss', Now) +
                                       Format('|EOleException %s %x', [E.Message,E.ErrorCode]) +
                                       Format('|Line# %d , SearchStr: %s',[JJ, _SearchKey]);
                        if pJuLog = true 
                        then begin
                                 if TDirectory.Exists(ErrorLogDirectory) = true
                                 then TFile.WriteAllText(ErrorLogDirectory + PrepareFileName(_SearchKey) + '.un_errlog', strErrorMsg, TEncoding.UTF8);
                             end;
                    end;

                    on E:Exception do
                    begin
                        strErrorMsg := 'Unknown error:' + FormatDateTime('yyyy.mm.dd hh:nn:ss', Now) +
                                       Format('|Processing ThreadError: %s %s ', [E.Message,E.ClassName]) +
                                       Format('|Line# %d , SearchStr: %s',[JJ, _SearchKey]);
                        //WriteLn(ResponseArray[total].BingErrorDescr);
                        if pJuLog = true 
                        then begin
                                 if TDirectory.Exists(ErrorLogDirectory) = true                                 
                                 then TFile.WriteAllText(ErrorLogDirectory + PrepareFileName(_SearchKey) + '.un_errlog', strErrorMsg, TEncoding.UTF8);
                             end;
                    end;
                end;
            //end;
            //CoUninitialize;
            end, Pool);  //---большой основной цикл---
            //---обработка результатов------------------------------------------
            for I := 0 to High(ResponseArray) do
            begin
                repeat
                    J := HashSL.IndexOf(ResponseArray[I].QueryHash);
                    if J > -1 then
                    begin
                        HashSL[J] := '-----';

                        TempSL.Clear; //TempSL := TStringList.Create;
                        ReadCSVRecord(ContentSL[J], TempSL); //insert columns into original string
                        for K := High(URLcnDynArrIsAdditional) downto Low(URLcnDynArrIsAdditional) do
                            TempSL.Delete(URLcnDynArrIsAdditional[K]);

//                        //---Вставляем дополнительные значения перед названием компании---
//                        try
//                            TempSL.Insert(OutColNum.SearchName, ResponseArray[I].QAcalc);
//                            TempSL.Insert(OutColNum.SearchName, ResponseArray[I].QAm.ToString);
//                        except
//                        end;
                        //подготовка данных к выводу в файл---------------------+
//                        if pQuoted = true
//                        then ResponseArray[I].UsedQuery := '""' + ResponseArray[I].UsedQuery.Trim(['"']) + '""'
//                        else ResponseArray[I].UsedQuery := '"' + ResponseArray[I].UsedQuery.Trim(['"']) + '"';

                        if pSimple = false
                        then begin
                                 strTemp := FormOutputString(ResponseArray[I], ContentSL[J], resultsCount, pURLqa);
                                 TempParsingArray := strTemp.Split([','], '{', '}');
                                 for K := High(TempParsingArray) downto Low(TempParsingArray) do
                                     TempSL.Insert(INSERT_HERE + 1, TempParsingArray[K]);
                                 SetLength(TempParsingArray, 0);
                                 if ColNum.OO_ID = -1 then
                                     ContentSL[J] := ResponseArray[I].OO_ID.ToString + ',' + CSVfromSL(TempSL) //TempSL.CommaText;
                                 else ContentSL[J] := CSVfromSL(TempSL);
                             end;
                        TempSL.Clear;
                        //---переносим данные о доменах в дерево----------------
                        K := 0;
                        repeat
                            domainStats.IncrementOrInsert(ResponseArray[I].topResultArr[K].domainName);
                            inc(K);
                        until ResponseArray[I].topResultArr[K].domainName.Length = 0;
                        //подготовка данных к выводу в файл---------------------
//                        if pQuoted = true
//                        then ResponseArray[I].UsedQuery := '""' + ResponseArray[I].UsedQuery.Trim(['"']) + '""'
//                        else ResponseArray[I].UsedQuery := '"' + ResponseArray[I].UsedQuery.Trim(['"']) + '"';

                        //------------------------------------------------------
                        //---формирование строки для вывода в файл--------------
//                        if pSimple = false then
//                            ContentSL[J] := FormOutputString(ResponseArray[I], ContentSL[J], resultsCount, pURLqa);
                        if pSimple = true then
                            ContentSL[J] := FormSimpleOutputString(ResponseArray[I], ContentSL[J], resultsCount);
                    end;
                until J = -1;
            end;

            for I := 0 to ContentSL.Count - 1 do
                Writer.WriteLine(ContentSL[I]);

            //OutputStrArray := nil;
            //SetLength(OutputStrArray, 0);

            StrToScrArray[0] := Format('Lines processed: %d ' ,[linesprocessed]);

//---расчет времени-------------------------------------------------------------
            if linesprocessed = FCS.MaxThreads{FCS.MaxPerSecond} then strTime := 'First' else strTime := 'Previous';
            timeCurrEnd := Now;
            timeTemp := ((NumberOfLines - linesprocessed) * (timeCurrEnd - timeStart)) / linesprocessed;
            minutes := MinutesBetween(0, timeTemp);
            //StrToScrArray[1] := '100 % batch completed'.PadRight(22);
            StrToScrArray[2] := Format('%s %d lines took %s minutes. Approx completion in %d minutes             ',
                                      [strTime,
                                      FCS.MaxThreads{FCS.MaxPerSecond},
                                      FormatDateTime('nn.ss', timeCurrEnd - timeCurrBegin),
                                      minutes]);
            StrToScrArray[3] := 'Last update at: ' + FormatDateTime('yyyy.mm.dd hh:nn:ss', Now);
            StrToScrArray[4] := Format('Bing API calls were used: %d',[BingCallsWereUsed]);
//------------------------------------------------------------------------------
            AppSettings:=TIniFile.Create(iniFileName);
            AppSettings.WriteString('Basic', 'TimeNow', FormatDateTime('yyyy.mm.dd hh:nn:ss', Now()));
            AppSettings.WriteInteger('Basic','LinesProcessed',LinesProcessed);
            AppSettings.Free;


        until Reader.EndOfStream = true;   //включить для работы
        //until (((linesprocessed - 1) mod CICLECOUNTER = 0) or Reader.EndOfStream); //включить для тестирования
        //----------------------------------------------------------------------

        //CoUninitialize;
        //---обработка массива доменов------------------------------------------
        PrintAllTreeToArray(domainStats, domainStatsArr);  //---перенос данных из дерева в массив
        TArray.Sort<TDomainRec>(domainStatsArr, TComparer<TDomainRec>.Construct(      //сортировка массива
                                 function (const Left, Right: TDomainRec): integer
                                 begin
                                     Result := Right.Count - Left.Count;

                                     if Result = 0 then Result := AnsiCompareStr(Left.DomainName, Right.DomainName);
                                 end
                                 ));
        //---вывод массива доменов в файл---------------------------------------
        domainWriter := TStreamWriter.Create(ChangeFileExt(filenamein, '') + '-domain-frequency.csv', False, myEncoding);
        domainWriter.WriteLine('Domain, Frequency');
        for I := 0 to High(domainStatsArr) do
            domainWriter.WriteLine(domainStatsArr[I].DomainName + ',' + domainStatsArr[I].Count.ToString);
        domainWriter.Free;
        SetLength(domainStatsArr, 0);
        //if Assigned(ResponseArray) then ResponseArray := nil;
        TParallel.For(0, High(ResponseArray), procedure(II: integer)
        begin
            if Assigned(ResponseArray[II].SearchCondition) then SetLength(ResponseArray[II].SearchCondition, 0);
            if Assigned(ResponseArray[II].SearchQuery) then SetLength(ResponseArray[II].SearchQuery, 0);
            if Assigned(ResponseArray[II].DirectoriesArr) then SetLength(ResponseArray[II].DirectoriesArr, 0);
        end);
        ResponseArray := nil;
        //if Assigned(SearchKeysArray) then SearchKeysArray := nil;
        if Assigned(URLcnDynArrInp) then URLcnDynArrInp := nil;
        if Assigned(URLcnDynArrIsAdditional) then URLcnDynArrIsAdditional := nil;
        SetLength(excludesUrlArray, 0);
        SetLength(excludesDirArray, 0);
        SetLength(excludesNamesArray, 0);
        SetLength(excludesKeyArray, 0);
        SetLength(FindScoreArr, 0);
        SetLength(StatesFullNameArray, 0);
        SetLength(StatesAbbrNameArray, 0);
        SetLength(CitiesArray, 0);
        SetLength(searchPositionScoreArr, 0);
        SetLength(WebsiteArr, 0);

        Pool.Free;
        System.SysUtils.DeleteFile(iniFileName);
        //if Assigned(excludesSearchTree) then excludesSearchTree.Free;
        //if Assigned(excludesUrlSL) then excludesUrlSL.Free;
        if Assigned(StatesTree) then FreeAndNil(StatesTree);
        if Assigned(StatesAbbrTree) then FreeAndNil(StatesAbbrTree);
        if Assigned(CityTree) then FreeAndNil(CityTree);
        if Assigned(PhoneCodes) then FreeAndNil(PhoneCodes);

        FreeAndNil(domainStats);
        Reader.Free;
        Writer.Free;
        InputSL.Free;
        ContentSL.Free;
        HashSL.Free;
        if Assigned(TempSL) then TempSL.Free;
        outputHeaderSL.Free;
        OriginalHeaderSL.Free;
        HTTPcodesSL.Free;
        //TempSL.Free;
        SetLength(TargetsArr, 0);
        timeend := Now;
        StrToScrArray[10] := 'End at: ' + FormatDateTime('hh:nn:ss', timeEnd);
        StrToScrArray[11] := 'Elapsed time: ' + FormatDateTime('hh:nn:ss',timeEnd - timeStart);
        StrToScrArray[12] := 'Done.';
        if Assigned(task) and (task.Status = TTaskStatus.Running) then task.Cancel;

        sleep(2000);
        GotoXY(0, CursPosY);
        for j := Low(StrToScrArray) to High(StrToScrArray) do
        begin
            if Length(StrToScrArray[j]) > 0 then
            begin
                strTemp := StrToScrArray[j];
                WriteLn(strTemp);
            end;
        end;

    except
        on E: Exception do
            Writeln(E.ClassName, ': ', E.Message);
    end;

    if pStop then
    begin
        WriteLn('Press Enter...');
        ReadLn;
    end;
end.

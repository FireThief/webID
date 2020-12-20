unit Definitions;

interface

//uses
//    System.Types;

//type
//  TTopResult = record
//      webName: string;       //(name)
//      URL: string;
//      entityName: string;   // (about:name)
//      snippet: string;
//      dateLastCrawled: string;  //(truncate to date/time)
//      dateLastCached: string;   //(date we got it)
//      score: integer;
//  end;

type
  TJSONparsingResults = record
      filed: string;
      jsonParseError: string;
      ResNumber: integer;  // rN
      xCount: integer;
      //webSearchUrl: string;
      //originalQuery: string;
      Url: string;         // полный адрес, полученный из json
      displayUrl: string;  // отображаемый в поисковике url
      domain: string;      // имя домена с протоколом
      domainName: string;  // имя домена без протокола
      URLqaMatch: string;
      //--------------------------------
      linkedin: string;   //sn
      //isMainLN: boolean;
      twitter: string;    //sn
      //isMainTW: boolean;
      facebook: string;   //sn
      //isMainFB: boolean;
      Instagram: string;  //sn
      //isMainIG: boolean;
      //--------------------------------
      arrWebName: string;
      arrEntityName: string; //new
      arrSnippet: string;
      arrDateLastCrawled, arrDateLastCached: string;
      strPhonesFromWeb, strPhonesFromSnippet: string;

      deepLinksArr: integer;//если есть deepLink ссылки в json
      urlScore: integer;    //общий счёт URL
      snippetScore: integer;//общий счёт сниппета (текста)
      score: integer;       //общий счёт
      cdemScore: integer;   //company-domain-exact-match , входит в URL
      //mds: integer;         //minimum-domain-score, для расчёта столбца F, никуда не входит
      isdScore: integer;      //is-sub-domain, входит в URL
      onlyURLscore: integer; //входит в URL
      cidScore: integer;    //company-is-domain, входит в URL
      ddbScore: integer;    //domain-density-bump,
      osScore: integer;     //oficial-site-score
      nsScore: integer;     //url-result-no-subfolder
      calc: string;
      //---новые переменные 2019 07 08-------------------
      d1MS: string;
      iwScore: integer;     //InputWebsite
      iwerScore: integer;   //InputWebsiteEqualsResult
      minTopScore: integer; //if score<MinimumTopScore, then leave domain1 empty, shift results to domain2,3 etc
      f3wmScore: integer;        //company-first-3-words-match domain match first 3 words in company name
      f2wmScore: integer;        //company-first-2-words-match
      f1wmScore: integer;        //company-first-1-words-match
      swmScore: integer;         //company-second-word-match
      twmScore: integer;         //company-third-word-match
//      pos1Score, pos2Score, pos3Score, pos4Score, pos5Score,
//      pos6Score, pos7Score, pos8Score, pos9Score, pos10Score: integer; //позиция в результатах поиска
      pos_N_Score: integer; //позиция в результатах поиска
      ciuScore: integer; //city-in-url
      siuScore: integer; //state-in-url
      scsmmScore: integer;    //SnippetCityStateMisMatch:
      //---баллы полученные при загрузке и анализе страниц---
      wcsmScore: integer;     //WebCityStateMatch
      wsmScore: integer;      //WebStateMatch
      //wcmScore: integer;      //WebCityMatch
      wcsmmScore: integer;    //WebCityStateMisMatch
      wsmmScore: integer;     //WebStateMismatch
      cowfnScore: integer;    //cow-full-name //cow = company-on-website
      cow1zScore: integer;    //cow-first-word-ZeroMatch
      cow2zScore: integer;    //cow-second-word-ZeroMatch
      cowfwmScore: integer;   //cow-first-word-match
      aowScore: integer;      //AllOnWebsite
      powScore: integer;      //PhoneOnWebsite
      //---новые переменные 2019 11 02-------
      phone1, phone2: string;
      phone_snippet, phone_website, phone_source: string;
      //areaCode: string;
  end;

type
  TBingResponse = record
      OO_ID: integer;
      Source: string;
      SearchCondition: TArray<string>;
      SearchQuery: TArray<string>;
      DirectoriesArr: TArray<string>;
      QueryHash: string;
      UsedCondition: string;
      UsedQuery: string;
      SearchResults: string;
      ResponseHeaders: string;
      URL_QA: string;
      QAm: integer;
      QAcalc: string;
      BingErrorDescr: string;
      BingErrorCode: integer;
      JSONfile: string;
      //-----------------------------
      sResult: integer;
      xCount: integer;
      LinkedIn: string;
      LIscore: integer;
      Instagram: string;
      IGscore: integer;
      Facebook: string;
      FBscore: integer;
      Twitter: string;
      TWscore: integer;
      //-----------------------------
      topResultArr: array [0..49] of TJSONparsingResults;
      //-----------------------------
      Name:  string;
      NormalizedName: string;
      State: string;
      StateAbbr: string;
      City:  string;
      Addr:  string;
      Zip:   string;
      Phone: string;
      NormalizedPhone: string;
      AC: string;
      WebSite: string;
      subDomain: string;
      //-----------------------------
//      fTarget: string;
//      fCount: string;
//      fTargetScore: string;
      //-----------------------------
//      fNAME: string;
//      fST: string;
//      fCity: string;
//      fADDR: string;
//      fZip: string;
//      fPHONE: string;
//      fAC: string;
//      fSCORE: string;
      ExcludedDomains: string;
  end;

type
  THttpResponse = record
      Position: integer;
      URL: string;
      IP: string;
      Attempts: integer;
      First: string;
      Verified: string;
      StatusCode: integer;
      RedirectsCount: integer;
      FullURL: string;
      LastStatus: string;
      TimeMS: string;
      SizeFromHeader: integer;
      SizeFromCalc: Integer;
      Server: string;
      Secure: string;
      Language: string;

      fNAME: integer;
      fST: integer;
      fCity: integer;
      fADDR: integer;
      fPHONE: integer;
      fSCORE: integer;
      //---from the tags of the response---
      //SiteTags: string;
      DescriptionTags: string;
      KeyTags: string;
      //TitleTags: string;
      OpenGraph: string;
      Error: string;
      //---from the body of the response---
      DistrictName: string;
      SearchName: string;
      Address1: string;
      Address2: string;
      City: string;
      State: string;
      ZIP: string;
      Phone: string;
      RawHTMLstring: string;
      ExtractedLinks: string;
      LinksScore: integer;
  end;

const CHttpResponse: THttpResponse =
(
      Position: 0;
      URL: '';
      IP: '';
      Attempts: 0;
      First: '';
      Verified: '';
      StatusCode: 0;
      RedirectsCount: 0;
      FullURL: '';
      LastStatus: '';
      TimeMS: '';
      SizeFromHeader: 0;
      SizeFromCalc: 0;
      Server: '';
      Secure: '';
      Language: '';

      fNAME: 0;
      fST: 0;
      fCity: 0;
      fADDR: 0;
      fPHONE: 0;
      fSCORE: 0;
      //---from the tags of the response---
      //SiteTags: string;
      DescriptionTags: '';
      KeyTags: '';
      //TitleTags: string;
      OpenGraph: '';
      Error: '';
      //---from the body of the response---
      DistrictName: '';
      SearchName: '';
      Address1: '';
      Address2: '';
      City: '';
      State: '';
      ZIP: '';
      Phone: '';
      RawHTMLstring: '';
      ExtractedLinks: '';
      LinksScore: 0;
);
//type
//TJSONresultsArray = array of TJSONparsingResults;

type
  TTargetsRec = record
      RecordType: string;
      RecordName: string;
      Count: integer;
      Score: integer;
  end;

  TTargetsArr = array of TTargetsRec;

type
  TBodyMatches_cn = record
      DistrictName: integer;
      SearchName: integer;
      Address: integer;
      City: integer;
      State: integer;
      ZIP: integer;
      Phone: integer;
      URLqa: integer;
      WebSite: integer;
      OO_ID: integer;
  end;

//---базовые настроеки приложения (начальные установки)-----------
const CBodyMatches_cn: TBodyMatches_cn =
(
      DistrictName: -1;
      SearchName: -1;
      Address: -1;
      City: -1;
      State: -1;
      ZIP: -1;
      Phone: -1;
      URLqa: -1;
      WebSite: -1;
      OO_ID: -1;
);

type TDomainRec = record
      DomainName: string;
      Count: integer;
      class function Create(const DomainName: string; const intCount: Word): TDomainRec; static;
end;

type TPairRec = record
      City, State: string;
      class function Create(const City, State: string): TPairRec; static;
end;

type TPhoneScoreRec = record
      Phone, ScoreType, StateCode: string;
      Count: integer;
      Total: integer;
      class function Create(const Phone, ScoreType, StateCode: string; const Count, Total: integer): TPhoneScoreRec; static;
end;

const
    APPNAME = 'WebID';//'URLfinder';
    CICLECOUNTER = 1;   //---BingAPI число вызовов в секунду (по умолчанию)---
    MAXTHREAD = 50;     //---максимальное количество потоков (по умолчанию)---
    MAX_PAGES_PER_SITE = 20;  //---максимальное количество ссылок, которое надо будет проверить---
    MAX_DEPTH_PER_SITE = 3;   //---максимальная глубина ссылки----------------
    MAX_PROC_PAGE_SIZE = 500; //---максимальный размер обрабатываемой страницы
//==============================================================================
//---для хранения базовых настроек приложения---------------------
type TFillerConfigSettings = record
    AppID: string;         //---AppID для доступа в BingAPI-------
    BaseURL: string;       //---базовый адрес для BingAPI---------
    MaxPerSecond: integer; //---BingAPI число вызовов в секунду---
    MaxThreads: integer;   //---максимальное количество потоков---
    MaxPagesPerSite: integer;
    MaxDepthPerSite: integer;
    MaxPageSize: integer;  //---максимальный размер обрабатываемой страницы
end;
//---базовые настройки приложения (начальные установки)-----------
const CFillerConfigSettings: TFillerConfigSettings =
(
    AppID: '';                  //---AppID для доступа в BingAPI-------
    BaseURL: '';                //---базовый адрес для BingAPI---------
    MaxPerSecond: CICLECOUNTER; //---BingAPI число вызовов в секунду---
    MaxThreads: MAXTHREAD;      //---максимальное количество потоков---
    MaxPagesPerSite: MAX_PAGES_PER_SITE;
    MaxDepthPerSite: MAX_DEPTH_PER_SITE;
    MaxPageSize: MAX_PROC_PAGE_SIZE;
);
//==============================================================================
//---запись для хранения баллов-----------------------------------
type TScoreRecord = record
    f1wmScore,
    f2wmScore,
    f3wmScore: integer;
end;
//---базовые настройки приложения (начальные установки)-----------
const CScoreRecord: TScoreRecord =
(
    f1wmScore: 0;
    f2wmScore: 0;
    f3wmScore: 0;
);
//==============================================================================
const
    HELPPARAM = '-help';
    STOPPARAM = '-stop';
    BINGPARAM = '-forcebing';
    QUOTEPARAM = '-quoted';
    CRAWLPARAM = '-crawl';
    URL_QA_NAME = 'URL-QA';
    COUNTPARAM = '-results-count';
    SIMPLEPARAM = '-simple';
    WEBSITE = '-website';
    WEB_SEARCH_OFF = 'SearchOff';
    WEB_SEARCH_ON = 'SearchOn';
    //---параметры для тестирования, логирования---
    URL_UNIT_LOG = '-uulog';
    JSON_UNIT_LOG = '-julog';

    FIELDMAPFILECONST = 'fieldmap.dzc';
    TARGETSFILECONST = 'crawl-targets.dzc';
    URLFINDSCOREFILECONST = 'urlfindscore.dzc';
    EXCLUDESFILECONST = 'website-excudes.dzc';
    STATEABBREVIATIONS = 'StateAbbreviations.dzc';
    CITYSTATEZIP = 'CityStateZip.dzc';
    BINGAPIKEYS = 'URLFillerConfig.dzc';//'BingAPIKeys.dzc';
    AREACODES = 'AreaCodes.dzc';
    //---базовые директории для файлов json и лог-файлов---
    BASEDIRECTORY = 'SearchResults\';
    BASELOGDIR = 'ErrorLogs\';
    //---переменные для подсчёта счёта------------------------------------------
    //---записываются в файле urlfindscore.dzc----------------------------------
    MODIFIERTAG = 'modifier';

    TRESHOLDNAME = 'crawl-exit-threshold';
    EXACTMATCH = 'company-domain-exact-match';
    MINSCORE = 'minimum-domain-score';
    ISSUBDOMAIN = 'is-sub-domain';
    COMPANYISDOMAIN = 'company-is-domain';
    DOMAINDENGROUP = 'domain-density-group';      //---сколько доменов должно быть в группе дубликатов---
    DOMAINDENTHRES = 'domain-density-threshold';  //---нижняя граница для начисления баллов за дублирующиеся домены в результатах поиска
    DOMAINDENBUMP = 'domain-density-bump';        //---баллы за повторяемость домена в результатах выборки---
    OFFICAILSITE = 'official-site';
    NOSUBFOLDER = 'url-result-no-subfolder';
    //---новый набор переменных-2019 07 08--------------------------------------
    FIRST_3_WORDS = 'company-first-3-words-match';  //(f3wm)   domain match first 3 words in company name
    FIRST_2_WORDS = 'company-first-2-words-match';  //(f2wm)   domain match first 2 words in company name
    FIRST_1_WORDS = 'company-first-1-words-match';  //(f1wm)   domain match first 1 word in company name
    SECOND_WORD = 'company-second-word-match';      //(swm)
    THIRD_WORD = 'company-third-word-match';        //(twm)
    //---новые переменные-2019 11 02--------------------------------------------
    PHONE_IN_SNIPPET = 'phone-in-snippet';
    PHONE_ON_HOMEPAGE = 'phone-on-homepage';
    PHONE_MATCH_STATE = 'phone-match-state';
    PROVIDED_WEBSITE = 'InputWebsite';            //---30.04.2020--------------------
    INPUT_WEB_EQUALS = 'InputWebsiteEqualsResult';//---14.05.2020--------------------

    POS_N = 'pos';
    NOT_IN_TOP10 = 'NotInTop10';
    MINTOPSCORE = 'MinimumTopScore';

    CITYINURL = 'city-in-url';
    STATEINURL = 'state-in-url';
    SCSMM = 'SnippetCityStateMisMatch';   //SnippetCityStateMisMatch
    WCSM = 'WebCityStateMatch'; //WebCityStateMatch
    WSM = 'WebStateMatch'; //WebStateMatch
    //WCM = 'WebCityMatch';  //WebCityMatch
    WCSMM = 'WebCityStateMismatch';
    WSMM = 'WebStateMismatch';
    COWFN = 'cow-full-name';
    COW1Z = 'cow-first-word-ZeroMatch';
    COW2Z = 'cow-second-word-ZeroMatch';
    COWFWM = 'cow-first-word-match';
    AOW = 'AllOnWebsite'; //AllOnWebsite
    POW = 'PhoneOnWebsite';
    //--------------------------------------------------------------------------
    URL_EXCLUDENAME = 'url';
    NAME_EXCLUDENAME = 'name';
    KEY_EXCLUDENAME = 'keyword';
    DIR_EXCLUDENAME = 'directory';
    //--------------------------------------------------------------------------
    BING_OK = 200;
    RESULT_OK = 'OK';
    NODATAFOUND = 'nodata';
    SEARCHCOUNTER = 50; // 10;
    MAX_NUMBER_OF_ATTEMPTS = 3;
    IPNULL = '0.0.0.0';
    THE_VERY_MIN = -100000;
    

    //URLREGEXP = '(((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp)://)|(www\.))+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(/[a-zA-Z0-9\&amp;%_\./-~-]*)?';
      URLREGEXP = '(((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp):\/\/)|(www\.))+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(\/{1,2}[a-zA-Z0-9\&'';%_\./-~-]*)?' +
    //URLREGEXP = '(((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp)://)|(www\.))+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(/[a-zA-Z0-9\&amp;%_\./-~-]*)?' +
                  '(?<!\.jpg|\.pdf|\.css|\.doc|\.jpg|\.pdf|\.css|\.doc|\.png|\.png)$';
                //'(?:(?<!\.(jpg|pdf|css|doc|png|jpg/|pdf/|css/|doc/|png/)))$';

    URL_DOMAIN_PATTERN = '\.?([-A-Za-z0-9]+)(\.[A-Za-z]{2,3})+\/';
    URL_SUBDOMAIN_PATTERN = '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,65}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}/';

    //PriorFields: TArray<string> = ['F'];
    PriorFields: TArray<string> = ['ID'];

    BeforeCompanyFields: TArray<string> = ['QAm', 'QAcalc'];

    //AdditionalFields: array [0..42] of string = (
    AdditionalFields: TArray<string> = [
                                               'd1MS',     //признак того что баллов недостаточно
                                               's1',       //счёт первого результата
                                               'phone1',
                                               'phone2',
                                               'calc1',    //расшифровка счёта первого результата
                                               'SearchQuery',
                                               'sResult',
                                               'xCount',
                                               'cLen',
                                               //-------------------
                                               'phone_source',
                                               //'phone-snippet',
                                               //'phone-website',
                                               //-------------------

                                               'domain1',  //0
                                               'ex1',
                                               //'r1',

                                               'domain2',
                                               's2',
                                               //'r2',
                                               'calc2',
                                               'domain3',
                                               's3',
                                               //'r3',
                                               'calc3',
                                               //'facebook1',
                                               //'FBscore',
                                               //'linkedin1',
                                               //'LIscore',

                                               'domain4',//domain4, domain5..
                                               's4', //'score4', s5, s6...
                                               //'r4',     //r4, r5, r6....

                                               'domain5',
                                               's5',
                                               //'r5',

                                               'domain6',
                                               's6',
                                               //'r6',

                                               'domain7',
                                               's7',
                                               //'r7',

                                               'domain8',
                                               's8',
                                               //'r8',

                                               'domain9',
                                               's9',
                                               //'r9',

                                               'domain10',
                                               's10',
                                               //'r10',

                                               //'twitter1',
                                               //'TWscore',
                                               //'instagram1',
                                               //'IGscore',
                                               //'SearchCondition',
                                               'json',
                                               'm',       //m1, m2, m3...

                                               'url1',
                                               'url1Score',
                                               'webName1',
                                               'entityName1',
                                               'snippet1',
                                               'dateLastCrawled1',
                                               'dateLastCached1',

                                               //-------------

                                               'url2',
                                               'webName2',
                                               'entityName2',
                                               'snippet2',
                                               'dateLastCrawled2',
                                               'dateLastCached2',

                                               //-------------

                                               'url3',
                                               'webName3',
                                               'entityName3',
                                               'snippet3',
                                               'dateLastCrawled3',
                                               'dateLastCached3'

                                               ];

    possibleNames: array [0..0] of string = ('search');

    CharsToReplace: array [0..12] of string = (
                                            ',',
                                            '"',
                                            //'''',
                                            '.',
                                            '\',
                                            '/',
                                            '(',
                                            ')',
                                            '-',
                                            '_',
                                            ':',
                                            '?',
                                            '&',
                                            '®'
                                           );

    UnacceptableChars: TArray<Char> = [    //   Unacceptable Chars in file name
                                         '\',     //   \ — разделитель подкаталогов
                                         '/',     //   / — разделитель ключей командного интерпретатора
                                         ':',     //   : — отделяет букву диска или имя альтернативного потока данных
                                         '*',     //   * — заменяющий символ (маска «любое количество любых символов»)
                                         '?',     //   ? — заменяющий символ (маска «один любой символ»)
                                         '"',     //   " — используется для указания путей, содержащих пробелы
                                         '<',     //   < — перенаправление ввода
                                         '>',     //   > — перенаправление вывода
                                         '|',     //   | — обозначает конвейер
                                         '+',     //   + — (в различных версиях) конкатенация
                                         '–'      //   – среднее тире UTF8
                                         ];

    CharsToRemove: array [0..0] of string = (
                                            ''''
                                            );

BingAPIanswers: TArray<string> = [
'0=Empty search query',
'200="Success."',
'400="One of the query parameters is missing or not valid."',
'401="The subscription key is missing or is not valid."',
'403="The user is authenticated (for example they used a valid subscription key) but they don’t have permission to the requested resource.' +
    'Bing may also return this status if the caller exceeded their queries per month quota."',
'410="The request used HTTP instead of the HTTPS protocol. HTTPS is the only supported protocol."',
'429="The caller exceeded their queries per second quota."',
'500="Unexpected server error."'
];

ServerAnswers: array [0..77] of string = (
'100=Continue',
'101=Switching Protocols',
'102=Processing',
'103=Checkpoint',
'200=OK.',
'201=Created. The request has been fulfilled, resulting in the creation of a new resource.',
'202=Accepted. The request has been accepted for processing, but the processing has not been completed.',
'203=Non-Authoritative Information',
'204=No Content. The server successfully processed the request and is not returning any content.',
'205=Reset Content. The server successfully processed the request, but is not returning any content.',
'206=Partial Content. The server is delivering only part of the resource (byte serving) due to a range header sent by the client.',
'207=Multi-Status. The message body that follows is an XML message and can contain a number of separate response codes',
'208=Already Reported. The members of a DAV binding have already been enumerated in a preceding part of the response, and are not being included again.',
'226=IM Used',
'300=Multiple Choices',
'301=Moved Permanently',
'302=Moved Temporarily',
'303=See Other',
'304=Not Modified',
'305=Use Proxy',
'306=Switch Proxy',
'307=Temporary Redirect (since HTTP/1.1)',
'308=Permanent Redirect (RFC 7538)',
'400=Bad Request. The server cannot or will not process the request due to an apparent client error',
'401=Unauthorized (RFC 7235).Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided',
'402=Payment Required.Reserved for future use.',
'403=Forbidden. The request was valid, but the server is refusing action. The user might not have the necessary permissions for a resource.',
'404=Not Found. The requested resource could not be found but may be available in the future.',
'405=Method Not Allowed. A request method is not supported for the requested resource.',
'406=Not Acceptable. The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.',
'407=Proxy Authentication Required. The client must first authenticate itself with the proxy.',
'408=Request Timeout. The server timed out waiting for the request. The client MAY repeat the request without modifications at any later time.',
'409=Conflict. Indicates that the request could not be processed because of conflict in the request.',
'410=Gone.Indicates that the resource requested is no longer available and will not be available again.',
'411=Length Required.The request did not specify the length of its content, which is required by the requested resource.',
'412=Precondition Failed. The server does not meet one of the preconditions that the requester put on the request.',
'413=Payload Too Large. The request is larger than the server is willing or able to process.',
'414=URI Too Long. The URI provided was too long for the server to process.',
'415=Unsupported Media Type. The request entity has a media type which the server or resource does not support.',
'416=Range Not Satisfiable. The client has asked for a portion of the file (byte serving), but the server cannot supply that portion.',
'417=Expectation Failed. The server cannot meet the requirements of the Expect request-header field.',
'418=I’m a teapot. This code was defined in 1998 as one of the traditional IETF April Fools jokes.',
'421=Misdirected Request. The request was directed at a server that is not able to produce a response.',
'422=Unprocessable Entity. The request was well-formed but was unable to be followed due to semantic errors.',
'423=Locked. The resource that is being accessed is locked.',
'424=Failed Dependency. The request failed due to failure of a previous request.',
'426=Upgrade Required. The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.',
'428=Precondition Required. The origin server requires the request to be conditional.',
'429=Too Many Requests. The user has sent too many requests in a given amount of time.',
'431=Request Header Fields Too Large.',
'440=Login Time-out. The clients session has expired and must log in again.',
'444=No Response. Used to indicate that the server has returned no information to the client and closed the connection.',
'449=Retry With. The server cannot honour the request because the user has not provided the required information.',
'451=Unavailable For Legal Reasons. A server operator has received a legal demand to deny access to a resource.',
'495=SSL Certificate Error. Used when the client has provided an invalid client certificate.',
'496=SSL Certificate Required. Used when a client certificate is required but not provided.',
'497=HTTP Request Sent to HTTPS Port. Used when the client has made a HTTP request to a port listening for HTTPS requests.',
'499=Client Closed Request. Used when the client has closed the request before the server could send a response.',
'500=Internal Server Error. A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.',
'501=Not Implemented. The server either does not recognize the request method, or it lacks the ability to fulfill the request.',
'502=Bad Gateway. The server was acting as a gateway or proxy and received an invalid response from the upstream server.',
'503=Service Unavailable. The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.',
'504=Gateway Timeout. The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.',
'505=HTTP Version Not Supported. The server does not support the HTTP protocol version used in the request.',
'506=Variant Also Negotiates. Transparent content negotiation for the request results in a circular reference.',
'507=Insufficient Storage. The server is unable to store the representation needed to complete the request.',
'508=Loop Detected. The server detected an infinite loop while processing the request.',
'509=Bandwidth Limit Exceeded. The server has exceeded the bandwidth specified by the server administrator; this is often used by shared hosting providers to limit the bandwidth of customers.',
'510=Not Extended. Further extensions to the request are required for the server to fulfil it.',
'511=Network Authentication Required. The client needs to authenticate to gain network access.',
'520=Unknown Error. The 520 error is used as a "catch-all response for when the origin server returns something unexpected.',
'521=Web Server Is Down. The origin server has refused the connection from Cloudflare.',
'522=Connection Timed Out. Cloudflare could not negotiate a TCP handshake with the origin server.',
'523=Origin Is Unreachable. Cloudflare could not reach the origin server.',
'524=A Timeout Occurred. Cloudflare was able to complete a TCP connection to the origin server, but did not receive a timely HTTP response.',
'525=SSL Handshake Failed. Cloudflare could not negotiate a SSL/TLS handshake with the origin server.',
'526=Invalid SSL Certificate. Cloudflare could not validate the SSL/TLS certificate that the origin server presented.',
'527=Railgun Error. Indicates that the request timed out or failed after the WAN connection had been established.'
);

implementation

class function TDomainRec.Create(const DomainName: string; const intCount: Word): TDomainRec;
begin
    Result.DomainName := DomainName;
    Result.Count := intCount;
end;

class function TPairRec.Create(const City, State: string): TPairRec;
begin
    Result.City := City;
    Result.State := State;
end;

class function TPhoneScoreRec.Create(const Phone, ScoreType, StateCode: string; const Count, Total: integer): TPhoneScoreRec;
begin
    Result.Phone := Phone;
    Result.ScoreType := ScoreType;
    Result.StateCode := StateCode;
    Result.Count := Count;
    Result.Total := Total;
end;

end.

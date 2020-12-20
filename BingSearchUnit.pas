unit BingSearchUnit;

{
Endpoints
https://api.cognitive.microsoft.com/bing/v7.0/suggestions
https://api.cognitive.microsoft.com/bing/v7.0/entities
https://api.cognitive.microsoft.com/bing/v7.0/images
https://api.cognitive.microsoft.com/bing/v7.0/news
https://api.cognitive.microsoft.com/bing/v7.0/spellcheck
https://api.cognitive.microsoft.com/bing/v7.0/videos
https://api.cognitive.microsoft.com/bing/v7.0/images/visualsearch
https://api.cognitive.microsoft.com/bing/v7.0

Name : URL-finder
Key 1: 2209eda4d58543d9af17df4249572362

Key 2: db0ced2f8ebd4fbba3a29b0dec44c346

https://api.cognitive.microsoft.com/bing/v7.0
}

interface

uses
  Definitions,
  System.SysUtils,
  System.NetEncoding,
  System.Classes,
  MSXML,
  ActiveX,
  ComObj,
  Variants;

function GetBingInfo(const SearchKey, UserAgent: string;
                     var AppID, BaseURL, OutResult: string;
                     var ErrorOut: string;
                     NumberOfResults:integer = 1
                     ): integer;

implementation

function UrlEncode(const S: string; const InQueryString: Boolean): string;
var
  I: Integer;
begin
  Result := EmptyStr;
  for i := 1 to Length(S) do
    case S[i] of
    // The NoConversion set contains characters as specificed in RFC 1738 and
    // should not be modified unless the standard changes.
    'A'..'Z', 'a'..'z', '*', '@', '.', '_', '-', '0'..'9',
    '$', '!', '''', '(', ')':
       Result := Result + S[i];
    '—': Result := Result + '%E2%80%94';
    ' ' :
      if InQueryString then
        Result := Result + '+'
      else
        Result := Result + '%20';
   else
     Result := Result + '%' + System.SysUtils.IntToHex(Ord(S[i]), 2);
   end;
end;

function GetBingInfo(const SearchKey, UserAgent: string;
                     var AppID, BaseURL, OutResult: string;
                     var ErrorOut: string;
                     NumberOfResults:integer = 1
                     ): integer;
const
    //ApplicationID = '768f715c738e4de79fed0848275f903e';  //старый Мой ключ
    ApplicationID = '2209eda4d58543d9af17df4249572362';   //Ключ Донато не работает
    //ApplicationID = '2216e6fcbea3463085f8c9d561e456c1';   //донато 2019 07 10
    //ApplicationID = '368d9e93f0a74c8c9992bf223241fa77';
    URIBASE ='https://api.cognitive.microsoft.com/bing/v7.0/search';
    //URIBASE ='https://ufinderapp.cognitiveservices.azure.com/bing/v7.0';
    //URIBASE = 'https://api.cognitive.microsoft.com/bing/v7.0';
    COMPLETED = 4;
    OK = 200;
    ANCHOR = '"message":';
var
    XMLHTTPRequest  : IXMLHTTPRequest;
    uriQuery{, strTemp}: string;
    //strError: string;
    I: integer;
    strTemp: string;
//    URLenc: TURLEncoding;
begin
    //Result.SearchString := SearchKey;
    //Result.SearchResults := '';
    //Result.Error := '';
    if AppID.Length = 0 then AppID := ApplicationID;
    if BaseURL.Length = 0 then BaseURL := URIBASE;
    ErrorOut := '';
    Result := 200;
//    uriQuery := BaseURL + '?q='  + TNetEncoding.URL.Encode(SearchKey) +
//                          '&count=' + IntToStr(NumberOfResults) +
//                          //'&customConfig=' + 'bingufindertest' +
//                          //'&mkt=en-US&responseFilter=Webpages,Computation';
//                          '&responseFilter=Webpages,Computation';
    strTemp := TNetEncoding.URL.Encode(SearchKey.DeQuotedString('"'));
    strTemp := strTemp.Replace('+', '%20', [rfReplaceAll]);
    uriQuery := BaseURL + '?q='  + strTemp{TNetEncoding.URL.Encode(SearchKey)} +
                          //'&customconfig=' + 'b0175a58-6b1a-4a4e-97bd-9326785845e2' +
                          '&count=' + IntToStr(NumberOfResults) +
                          //'&mkt=en-US&responseFilter=Webpages,Computation';
                          //'&form=QBLH' +
                          '&mkt=en-US' +
                          //'&safeSearch=Off' +
                          '&responseFilter=Webpages';

    //XMLHTTPRequest := CreateOleObject('MSXML2.XMLHTTP') As IXMLHTTPRequest;
    //XMLHTTPRequest := CreateOleObject('MSXML2.XMLHTTP.3.0') as IXMLHTTPRequest;
    XMLHTTPRequest := CoXMLHTTP60.Create;
    try
        XMLHTTPRequest.open('GET', uriQuery, False, EmptyParam, EmptyParam);
        XMLHTTPRequest.setRequestHeader('Ocp-Apim-Subscription-Key', AppID);
        XMLHTTPRequest.setRequestHeader('Accept', 'application/json');  //or  'application/ld+json'
        XMLHTTPRequest.setRequestHeader('BingAPIs-Market', 'en-US'); //2020_09_16
        XMLHTTPRequest.setRequestHeader('Pragma', 'no-cache'); //2020_09_16
        if UserAgent.Length > 0 then
            XMLHTTPRequest.setRequestHeader('User-Agent', UserAgent); //2020_09_16
        XMLHTTPRequest.send('');
        if (XMLHTTPRequest.readyState = COMPLETED) and (XMLHTTPRequest.status = OK) then
        begin
            OutResult := XMLHTTPRequest.responseText;
            //TempSL.Text := TNetEncoding.URL.Decode(XMLHTTPRequest.responseText);
            //Result.SearchResults := XMLHTTPRequest.responseText;
            //Result.ResponseHeaders := XMLHTTPRequest.getAllResponseHeaders;
        end;

        if (XMLHTTPRequest.readyState = COMPLETED) and (XMLHTTPRequest.status <> OK) then
        begin
            ErrorOut := TNetEncoding.URL.Decode(XMLHTTPRequest.responseText);
            //---получаем описание ошибки прямо из ответа---
            I := ErrorOut.IndexOf(ANCHOR);
            if I > -1
            then begin
                     ErrorOut := ErrorOut.Substring(I + ANCHOR.Length).TrimRight(['}']).TrimLeft;
                 end;
        end;

        Result := XMLHTTPRequest.status;
    finally
        XMLHTTPRequest := nil;
    end;
end;

end.

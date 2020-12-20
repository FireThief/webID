unit JsonUnit;

interface

uses
    System.JSON,
    //System.JSON.Readers,
    System.JSON.Types,
    System.Classes,
    System.Types,
    Tools,
    Definitions,
    System.SysUtils;

function IsJSON(strText: string): boolean;
//function ParseJSON2(strText: string): TJSONparsingResults;
function ParseJSON2(const strText, strURLqa: string; var OutArray: TArray<TJSONparsingResults>{TJSONresultsArray}): string;

implementation

function IsJSON(strText: string): boolean;
var objJSON: TJSONObject;
begin
    Result := false;
    try
        objJSON := TJSONObject.ParseJSONValue(strText) as TJSONObject;
        Result := true;
    finally
        if Assigned(objJSON) then objJSON.Free;
    end;
end;

//function ParseJSON2(strText: string): TJSONparsingResults;
function ParseJSON2(const strText, strURLqa: string; var OutArray: TArray<TJSONparsingResults>{TJSONresultsArray}): string;
var
    FJSONObject: TJSONObject;
    WebPagesObj: TJSONObject;
    AboutObj: TJSONObject;
    ValueObj: TJSONObject;
    //JPair: TJSONPair;
    pairName, pairValue, webSearchUrl, jsonParseError: string;
    strURLqaWork, strTemp: string;
    ValuesArr, AboutArr: TJSONArray;
    i, j: integer;
begin
    Result := RESULT_OK;
    webSearchUrl := '';
    jsonParseError := '';
    strURLqaWork := '';
    if strURLqa.Length > 0 then
        strURLqaWork := ExtractDomain(strURLqa);

    FJSONObject:=TJSONObject.ParseJSONValue(strText) as TJSONObject;
    if Assigned(FJSONObject) then //парсинг прошел успешно - считываем названия пар
    begin

        WebPagesObj := FJSONObject.GetValue('webPages') as TJSONObject;
        try
            if Assigned(WebPagesObj) then
            begin
                webSearchUrl := WebPagesObj.GetValue('webSearchUrl').ToString;
                ValuesArr := WebPagesObj.GetValue('value') as TJSONArray;
                if Assigned(ValuesArr) then
                begin
                    for I := 0 to ValuesArr.Count - 1 do
                    begin
                        SetLength(OutArray, Length(OutArray) + 1);
                        OutArray[High(OutArray)].ResNumber := I + 1;
                        ValueObj := ValuesArr.Items[I] as TJSONObject;
                        for J := 0 to ValueObj.Count - 1 do
                        begin
                            pairName := ValueObj.Pairs[J].JsonString.ToString.Trim(['"']);
                            //pairValue := '';
                            pairValue := ValueObj.Pairs[J].JsonValue.ToString.Trim(['"']);
                            if pairName = 'name'
                            then begin
                                     //pairValue := ValueObj.Pairs[J].JsonValue.ToString.Trim(['"']);
                                     OutArray[High(OutArray)].arrWebName := pairValue;
                                 end;

                            if pairName = 'url' then OutArray[High(OutArray)].Url := pairValue;

                            if pairName = 'displayUrl' 
                                then begin
                                    pairValue := ValueObj.Pairs[J].JsonValue.ToString.Trim(['"']);
                                    if pairValue.StartsWith('https://', true) = false then
                                        if pairValue.StartsWith('http://', true) = false then
                                            pairValue := 'http://' + pairValue;
                                    //OutArray[High(OutArray)].arrUrl := pairValue;
                                    OutArray[High(OutArray)].displayUrl := pairValue;
                                    OutArray[High(OutArray)].domain := ExtractDomain(pairValue, true);
                                    strTemp := ExtractDomain(pairValue);
                                    //OutArray[High(OutArray)].domainName := strTemp;
                                    OutArray[High(OutArray)].domainName := GetDomainName(pairValue, URL_DOMAIN_PATTERN);
                                    if strURLqaWork.Length > 0 then
                                        if strURLqaWork.ToLower = strTemp.ToLower then
                                            OutArray[High(OutArray)].URLqaMatch := 'Y'
                                        else if ('www.' + strURLqaWork.ToLower) = strTemp.ToLower then
                                            OutArray[High(OutArray)].URLqaMatch := 'Y'
                                        else
                                            OutArray[High(OutArray)].URLqaMatch := 'N';                                                   ;
                                end;
                                
                            if pairName = 'snippet' 
                                then begin
                                    pairValue := ValueObj.Pairs[J].JsonValue.ToString.Trim(['"']);
                                    OutArray[High(OutArray)].arrSnippet := pairValue;
                                end;
                                
                            if pairName = 'dateLastCrawled' 
                                then begin 
                                    pairValue := ValueObj.Pairs[J].JsonValue.ToString.Trim(['"']);
                                    pairValue := pairValue.Substring(0, pairValue.LastIndexOf('.'));
                                    OutArray[High(OutArray)].arrDateLastCrawled := pairValue;

                                    OutArray[High(OutArray)].arrDateLastCached := FormatDateTime('yyyy-mm-dd##hh:nn:00', Now).Replace('##','T');
                                end;

                            if pairName = 'about'
                                then begin
                                    AboutArr := ValueObj.GetValue('about') as TJSONArray;
                                    if AboutArr.Count > 0 then
                                    begin
                                        AboutObj := AboutArr.Items[0] as TJSONObject;
                                        if AboutObj.Count > 0 then
                                        begin
                                            pairValue := AboutObj.Pairs[0].JsonValue.ToString.Trim(['"']);
                                            OutArray[High(OutArray)].arrEntityName := pairValue;
                                        end;
                                    end;

                                end;

                            if pairName = 'deepLinks'
                               then begin
                                   AboutArr := ValueObj.GetValue('deepLinks') as TJSONArray;
                                   OutArray[High(OutArray)].deepLinksArr := AboutArr.Count * 10;
                               end;

                        end;
                    end;
                end else
                          jsonParseError := jsonParseError + 'no values array#';
            end else
                jsonParseError := jsonParseError + 'no webPages obj#';
        except    
            jsonParseError := jsonParseError + 'can''t parse#';
            //WriteLn('JSON unit parsing error');
        end;
    end else            
        jsonParseError := jsonParseError + 'not JSON#';

    //if Assigned(JPair) then JPair.Free;
//    if Assigned(ValuesArr) then ValuesArr.Free;
//    if Assigned(AboutArr) then AboutArr.Free;
//    if Assigned(ValueObj) then ValueObj.Free;
//    if Assigned(AboutObj) then AboutObj.Free;
     if Assigned(FJSONObject) then FJSONObject.Free;
//    if Assigned(WebPagesObj) then WebPagesObj.Free;

    //if Length(jsonParseError) > 0 then Result := 'Data taken from %s is corrupted: ' + jsonParseError;
    if Length(jsonParseError) > 0 then Result := 'Bing stautis is OK. But received answer in empty.';
end;

end.

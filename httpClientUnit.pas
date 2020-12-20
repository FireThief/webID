unit httpClientUnit;

interface

uses
  IdMultipartFormData,
  IdHTTP,
  System.SysUtils;

function httpSendMultipart(const sendHeader, sendContent: string): boolean;

implementation

function httpSendMultipart(const sendHeader, sendContent: string): boolean;
var
    PostData: TIdMultiPartFormDataStream;
    //FileName:string;
    HTTP: TidHTTP;
    strResponse: string;
begin
    Result := false;
    if (sendHeader='') and (sendContent='') then Exit;
    PostData := TIdMultiPartFormDataStream.Create;
    HTTP := TIdHTTP.Create(nil);
    HTTP.Name := 'IdHTTP1';
    try
        HTTP.Request.Referer := 'http://localhost:40000/sendfile'; //   http://www.link.net/download';
        HTTP.Request.ContentType := 'multipart/form-data';
        PostData.AddFormField('title', sendHeader, 'utf-8').ContentTransfer := '8bit';
        PostData.AddFormField('content', sendContent, 'utf-8').ContentTransfer := '8bit';

        strResponse := HTTP.Post('http://localhost:40000/sendfile', PostData);

    finally
        if(Assigned(HTTP)) then HTTP.Free;
        if(Assigned(PostData)) then PostData.Free;
        Result := true;
    end;
end;

end.

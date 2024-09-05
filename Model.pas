unit Model;

interface

uses
  System.Classes, Data.DB, Datasnap.DBClient, Vcl.Dialogs, System.SysUtils, System.NetEncoding, IdHTTP, IdSSLOpenSSL, System.JSON, Data.DBXJSON, xml.XMLIntf, xml.XMLDoc, Generics.Collections;

type
  TCep = record
    CEP,
    IBGE,
    Logradouro,
    Complemento,
    Bairro,
    Localidade,
    UF,
    DDD,
    GIA,
    Arquivo : string
  end;

type
  TParamnsPesq = record
    CEP,
    Logradouro,
    Localidade,
    UF : string
  end;

type
  TDataModel = class
  private
    FClientDataSet: TClientDataSet;
    FClientDataSetViaCep: TClientDataSet;
    FDataSource: TDataSource;
    FIdHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;


  public
    constructor Create;
    destructor  Destroy; override;
    function    fGetDataSet(pParams: TDictionary<string, string>; pbEndereco: boolean): TClientDataSet;
    function    fGetViaCep(pParams: TDictionary<string, string>; pbEndereco: boolean): TClientDataSet;
    function    fGetViaCepXML(pParams: TDictionary<string, string>; pbEndereco: Boolean): TClientDataSet;
    function    fGetDadosXML(const pXMLNode: IXMLNode; pbEndereco: Boolean): TClientDataSet;
    function    fGetDados(const pJsonResponse: string; pbEndereco: Boolean): TClientDataSet;
    function    fRemoverAcentuacao(pStr: string): string;
    function    fGetNumber(pStr: string): string;
    procedure   LoadData(const pFileName: string);
    procedure   pAddData(sCep, sIbge, sLogradouro, sComplemento, sBairro, sLocalidade, sUf, sDDD, sGia: string);
    procedure   pSaveDataToFile(const pFileName: string);
    procedure   PDeleteData;
    procedure   pAddClientDataSet(pCep: TCep; pClientDataSet: TClientDataSet);
  end;

implementation


procedure TDataModel.pAddData(sCep, sIbge, sLogradouro, sComplemento, sBairro, sLocalidade, sUf, sDDD, sGia: string);
begin
  if FClientDataSet.Locate('CEP', sCep, []) then
    FClientDataSet.Edit
  else
    FClientDataSet.Append;

  FClientDataSet.FieldByName('CEP').AsString := sCep;
  FClientDataSet.FieldByName('IBGE').AsString := sIbge;
  FClientDataSet.FieldByName('LOGRADOURO').AsString := sLogradouro;
  FClientDataSet.FieldByName('COMPLEMENTO').AsString := sComplemento;
  FClientDataSet.FieldByName('BAIRRO').AsString := sBairro;
  FClientDataSet.FieldByName('LOCALIDADE').AsString := sLocalidade;
  FClientDataSet.FieldByName('UF').AsString := sUf;
  FClientDataSet.FieldByName('DDD').AsString := sDDD;
  FClientDataSet.FieldByName('GIA').AsString := sGia;
  FClientDataSet.Post;
  FClientDataSet.Filtered := False;
end;

constructor TDataModel.Create;
begin
  FClientDataSet       := TClientDataSet.Create(nil);
  FClientDataSetViaCep := TClientDataSet.Create(nil);

  with FClientDataSet.FieldDefs do
  begin
    Add('CEP', ftString, 20);
    Add('IBGE', ftString, 20);
    Add('LOGRADOURO', ftString, 255);
    Add('COMPLEMENTO', ftString, 255);
    Add('BAIRRO', ftString, 255);
    Add('LOCALIDADE', ftString, 255);
    Add('UF', ftString, 3);
    Add('DDD', ftString, 3);
    Add('GIA', ftString, 20);
    Add('ARQUIVO', ftString, 2000);
  end;

  with FClientDataSetViaCep.FieldDefs do
  begin
    Add('CEP', ftString, 20);
    Add('IBGE', ftString, 20);
    Add('LOGRADOURO', ftString, 255);
    Add('COMPLEMENTO', ftString, 255);
    Add('BAIRRO', ftString, 255);
    Add('LOCALIDADE', ftString, 255);
    Add('UF', ftString, 3);
    Add('DDD', ftString, 3);
    Add('GIA', ftString, 20);
    Add('ARQUIVO', ftString, 2000);

  end;

  FClientDataSet.CreateDataSet;
  FClientDataSetViaCep.CreateDataSet;
end;

procedure TDataModel.pDeleteData;
begin
  FClientDataSet.Delete;
end;

destructor TDataModel.Destroy;
begin
  FClientDataSet.Free;
  inherited;
end;

function TDataModel.fGetDataSet(pParams: TDictionary<string, string>; pbEndereco: boolean): TClientDataSet;
var
  vParamsKey, vParamsValue: string;
  vParamsPesq: TParamnsPesq;
  vFiltro : string;
begin
  if pParams <> nil then
  begin
    for vParamsKey in pParams.Keys do
    begin
      if vParamsKey = 'logradouro' then
      begin
        vParamsValue := pParams[vParamsKey];
        vParamsPesq.Logradouro := pParams[vParamsKey];
        vFiltro := vFiltro  + ' and ' + vParamsKey + ' LIKE ' + QuotedStr('%' + vParamsPesq.Logradouro + '%')
      end;

      if vParamsKey = 'localidade' then
      begin
        vParamsPesq.Localidade := pParams[vParamsKey];
        vFiltro := vFiltro + ' and ' + vParamsKey + ' = ' + QuotedStr(vParamsPesq.Localidade);
      end;

      if vParamsKey = 'uf' then
      begin
        vParamsPesq.UF := pParams[vParamsKey];
        vFiltro := vFiltro + ' and ' + vParamsKey + ' = ' + QuotedStr(vParamsPesq.UF) ;
      end;

      if vParamsKey = 'cep' then
      begin
        vParamsPesq.CEP := pParams[vParamsKey];
        vFiltro := vFiltro +  ' and ' + vParamsKey + ' = ' + QuotedStr(vParamsPesq.CEP);
      end;
    end;
  end;

  FClientDataSet.Filtered := False;
  FClientDataSet.Filter   :=   copy(vFiltro, 5, Length(vFiltro));
  FClientDataSet.Filtered := True;

  Result := FClientDataSet;
end;

procedure TDataModel.LoadData(const pFileName: string);
var
  vLines : TStringList;
  vLine: string;
  vParts: TArray<string>;
  i: integer;
  vTextFile: TextFile;
begin

  try
    if not FileExists(pFileName) then
    begin
      try
        AssignFile(vTextFile, pFileName);
        Rewrite(vTextFile);
        CloseFile(vTextFile);

      except
        on E: Exception do
          Writeln('Erro ao criar o arquivo: ', E.Message);
      end;
    end;

    AssignFile(vTextFile, pFileName);
    Reset(vTextFile);
    FClientDataSet.EmptyDataSet;

    while not Eof(vTextFile) do
    begin

      ReadLn(vTextFile, vLine);
      vParts := vLine.Split([',']);

      if Length(vParts) = 9 then
      begin
        FClientDataSet.Append;
        FClientDataSet.FieldByName('CEP').AsString          := Trim(vParts[0]);
        FClientDataSet.FieldByName('IBGE').AsString         := Trim(vParts[1]);
        FClientDataSet.FieldByName('LOGRADOURO').AsString   := Trim(vParts[2]);
        FClientDataSet.FieldByName('COMPLEMENTO').AsString  := Trim(vParts[3]);
        FClientDataSet.FieldByName('BAIRRO').AsString       := Trim(vParts[4]);
        FClientDataSet.FieldByName('LOCALIDADE').AsString   := Trim(vParts[5]);
        FClientDataSet.FieldByName('UF').AsString           := Trim(vParts[6]);
        FClientDataSet.FieldByName('DDD').AsString          := Trim(vParts[7]);
        FClientDataSet.FieldByName('GIA').AsString          := Trim(vParts[8]);
        FClientDataSet.Post;
      end;
    end;

  finally
    CloseFile(vTextFile);
  end;

end;

procedure TDataModel.pSaveDataToFile(const pFileName: string);
var
  vFileStream: TFileStream;
  vLine: string;
begin
  vFileStream := TFileStream.Create(pFileName, fmCreate);
  try
    FClientDataSet.First;
    while not FClientDataSet.Eof do
    begin
      vLine := Format('%s, %s, %s, %s, %s, %s, %s, %s, %s', [
                               fGetNumber(FClientDataSet.FieldByName('CEP').AsString),
                               fGetNumber(FClientDataSet.FieldByName('IBGE').AsString),
                               fRemoverAcentuacao(FClientDataSet.FieldByName('LOGRADOURO').AsString),
                               fRemoverAcentuacao(FClientDataSet.FieldByName('COMPLEMENTO').AsString),
                               fRemoverAcentuacao(FClientDataSet.FieldByName('BAIRRO').AsString),
                               fRemoverAcentuacao(FClientDataSet.FieldByName('LOCALIDADE').AsString),
                               fRemoverAcentuacao(FClientDataSet.FieldByName('UF').AsString),
                               fGetNumber(FClientDataSet.FieldByName('DDD').AsString),
                               fGetNumber(FClientDataSet.FieldByName('GIA').AsString)
                                ]) + #10;

      vFileStream.Write(PAnsiChar(AnsiString(vLine))^, Length(vLine));

      FClientDataSet.Next;
    end;
  finally
    vFileStream.Free;
  end;
end;

function TDataModel.fGetViaCep(pParams: TDictionary<string, string>;
  pbEndereco: boolean): TClientDataSet;
const
  INVALID_CEP = '{'#$A'  "erro": true'#$A'}';
var
  LResponse: TStringStream;
  JsonArray: TJSONArray;
  JsonObject : TJSONObject;
  URL : string;
  vParamsKey, vParamsValue: string;
  vParamsPesq: TParamnsPesq;
begin
  if pParams <> nil then
  begin
    for vParamsKey in pParams.Keys do
    begin
      if vParamsKey = 'logradouro' then
        vParamsPesq.Logradouro := fRemoverAcentuacao(pParams[vParamsKey]);

      if vParamsKey = 'localidade' then
        vParamsPesq.Localidade := fRemoverAcentuacao(pParams[vParamsKey]);

      if vParamsKey = 'uf' then
        vParamsPesq.UF := pParams[vParamsKey];

      if vParamsKey = 'cep' then
        vParamsPesq.CEP := fGetNumber(pParams[vParamsKey]);
    end;
  end;

  if pbEndereco then
  begin
    URL := 'https://viacep.com.br/ws/' +
           vParamsPesq.UF + '/' +
           StringReplace(TNetEncoding.URL.Encode(vParamsPesq.Localidade), '+', '%20', [rfReplaceAll]) + '/' +
           StringReplace(TNetEncoding.URL.Encode(vParamsPesq.Logradouro), '+', '%20', [rfReplaceAll]) + '/json';
  end
  else
  begin
    URL := 'https://viacep.com.br/ws/' + vParamsPesq.CEP +'/json'
  end;

  FIdHTTP := TIdHTTP.Create;
  FIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
  FIdHTTP.IOHandler := FIdSSLIOHandlerSocketOpenSSL;
  FIdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];

  LResponse := TStringStream.Create;
  try

   FIdHTTP.Get(URL, LResponse);
    if (FIdHTTP.ResponseCode = 200) and (not (LResponse.DataString).Equals(INVALID_CEP)) then
    begin
      Result := fGetDados(LResponse.DataString, pbEndereco);

    end;


  finally
    LResponse.Free;
  end;
end;

function TDataModel.fGetViaCepXML(pParams: TDictionary<string, string>; pbEndereco: Boolean): TClientDataSet;
const
  INVALID_CEP = '<error>true</error>';
var
  LResponse: TStringStream;
  vXMLDocument: IXMLDocument;
  vXMLNode: IXMLNode;
  vURL: string;
  vParamsKey: string;
  vParamsPesq: TParamnsPesq;
  vXMLData: string;
begin
  if pParams <> nil then
  begin
    for vParamsKey in pParams.Keys do
    begin
      if vParamsKey = 'logradouro' then
        vParamsPesq.Logradouro := fRemoverAcentuacao(pParams[vParamsKey]);

      if vParamsKey = 'localidade' then
        vParamsPesq.Localidade := fRemoverAcentuacao(pParams[vParamsKey]);

      if vParamsKey = 'uf' then
        vParamsPesq.UF := pParams[vParamsKey];

      if vParamsKey = 'cep' then
        vParamsPesq.CEP := fGetNumber(pParams[vParamsKey]);
    end;
  end;

  if pbEndereco then
  begin
    vURL := 'https://viacep.com.br/ws/' +
           vParamsPesq.UF + '/' +
           StringReplace(TNetEncoding.URL.Encode(vParamsPesq.Localidade), '+', '%20', [rfReplaceAll]) + '/' +
           StringReplace(TNetEncoding.URL.Encode(vParamsPesq.Logradouro), '+', '%20', [rfReplaceAll]) + '/xml';
  end
  else
  begin
    vURL := 'https://viacep.com.br/ws/' + vParamsPesq.CEP + '/xml';
  end;

  FIdHTTP := TIdHTTP.Create(nil);
  FIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    FIdHTTP.IOHandler := FIdSSLIOHandlerSocketOpenSSL;
    FIdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];

    LResponse := TStringStream.Create;
    try
      FIdHTTP.Get(vURL, LResponse);
      vXMLData := LResponse.DataString;

      if (FIdHTTP.ResponseCode = 200) and (Pos(INVALID_CEP, vXMLData) = 0) then
      begin
        try
          vXMLDocument := LoadXMLData(LResponse.DataString);
          vXMLNode := vXMLDocument.DocumentElement;

          Result := fGetDadosXML(vXMLNode, pbEndereco);
        finally
          vXMLDocument := nil;
        end;
      end
      else
        Result := nil;
    finally
      LResponse.Free;
    end;
  finally
    FIdHTTP.Free;
    FIdSSLIOHandlerSocketOpenSSL.Free;
  end;
end;

function TDataModel.fGetDadosXML(const pXMLNode: IXMLNode; pbEndereco: Boolean): TClientDataSet;
var
  vXMLNode: IXMLNode;
  vCep : TCep;
  vUrl : string;
  i    : integer;
begin
  for i := 0 to pXMLNode.ChildNodes.Count - 1 do
  begin
    vXMLNode := pXMLNode.ChildNodes[i];

    if vXMLNode.NodeName = 'cep' then
    begin

      vCep.CEP         := pXMLNode.ChildNodes['cep'].Text;
      vCep.IBGE        := pXMLNode.ChildNodes['ibge'].Text;
      vCep.Logradouro  := UpperCase(pXMLNode.ChildNodes['logradouro'].Text);
      vCep.Complemento := UpperCase(pXMLNode.ChildNodes['complemento'].Text);
      vCep.Bairro      := UpperCase(pXMLNode.ChildNodes['bairro'].Text);
      vCep.Localidade  := UpperCase(pXMLNode.ChildNodes['localidade'].Text);
      vCep.UF          := UpperCase(pXMLNode.ChildNodes['uf'].Text);
      vCep.DDD         := pXMLNode.ChildNodes['ddd'].Text;
      vCep.GIA         := UpperCase(pXMLNode.ChildNodes['gia'].Text);
      pAddClientDataSet(vCep, FClientDataSetViaCep);
    end;
  end;

  result := FClientDataSetViaCep;

end;

function TDataModel.fGetDados(const pJsonResponse: string; pbEndereco: Boolean): TClientDataSet;
var
  i: Integer;
  vJsonArray: TJSONArray;
  vJsonObject: TJSONObject;
  vJsonValue: TJSONValue;
  vCep : TCep;
  vUrl : string;
  begin
    vJsonValue := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(UTF8ToString(pJsonResponse)), 0);

  if (vJsonValue is TJSONArray) then
  begin
    vJsonArray :=  TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(UTF8ToString(pJsonResponse)), 0) as TJSONArray;

    for i := 0 to vJsonArray.Count - 1 do
    begin
      vCep.CEP         := TJSONObject(vJsonArray.Get(i)).GetValue('cep').Value;
      vCep.IBGE        := TJSONObject(vJsonArray.Get(i)).GetValue('ibge').Value;
      vCep.Logradouro  := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('logradouro').Value);
      vCep.Complemento := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('complemento').Value);
      vCep.Bairro      := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('bairro').Value);
      vCep.Localidade  := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('localidade').Value);
      vCep.UF          := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('uf').Value);
      vCep.DDD         := TJSONObject(vJsonArray.Get(i)).GetValue('ddd').Value;
      vCep.GIA         := UpperCase(TJSONObject(vJsonArray.Get(i)).GetValue('gia').Value);
      vCep.Arquivo     := UTF8ToString(pJsonResponse);

      pAddClientDataSet(vCep, FClientDataSetViaCep);
    end;
  end
  else if (vJsonValue is TJSONObject) then
    begin
      vJsonObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(UTF8ToString(pJsonResponse)), 0) AS TJSONObject;
      vCep.CEP         := vJsonObject.GetValue('cep').Value;
      vCep.IBGE        := vJsonObject.GetValue('ibge').Value;
      vCep.Logradouro  := UpperCase(vJsonObject.GetValue('logradouro').Value);
      vCep.Complemento := UpperCase(vJsonObject.GetValue('complemento').Value);
      vCep.Bairro      := UpperCase(vJsonObject.GetValue('bairro').Value);
      vCep.Localidade  := UpperCase(vJsonObject.GetValue('localidade').Value);
      vCep.UF          := UpperCase(vJsonObject.GetValue('uf').Value);
      vCep.DDD         := vJsonObject.GetValue('ddd').Value;
      vCep.GIA         := vJsonObject.GetValue('gia').Value;
      vCep.Arquivo     := UTF8ToString(pJsonResponse);

      pAddClientDataSet(vCep, FClientDataSetViaCep);
    end
    else
    begin
      raise Exception.Create('Formato JSON inesperado.');
    end;

    result := FClientDataSetViaCep;

end;

function TDataModel.fRemoverAcentuacao(pStr: string): string;
var
  x: Integer;
const
  ComAcento = '‡‚ÍÙ˚„ı·ÈÌÛ˙Á¸¿¬ ‘€√’¡…Õ”⁄«‹';
  SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU';
begin
  for x := 1 to Length(pStr) do

    if Pos(pStr[x], ComAcento) <> 0 then
      pStr[x] := SemAcento[Pos(pStr[x], ComAcento)];

  Result := pStr;
end;

function TDataModel.fGetNumber(pStr: string): string;
var
  I : Byte;
begin
   Result := EmptyStr;
   for I := 1 To Length(pStr) do
       if CharInSet(pStr [I], ['0'..'9']) Then
            Result := Result + pStr [I];
end;

procedure TDataModel.pAddClientDataSet(pCep: TCep; pClientDataSet: TClientDataSet);
begin
  pClientDataSet.Append;
  pClientDataSet.FieldByName('CEP').AsString         := fGetNumber(pCep.CEP);
  pClientDataSet.FieldByName('IBGE').AsString        := fGetNumber(pCep.IBGE);
  pClientDataSet.FieldByName('Logradouro').AsString  := fRemoverAcentuacao(pCep.logradouro);
  pClientDataSet.FieldByName('Complemento').AsString := fRemoverAcentuacao(pCep.complemento);
  pClientDataSet.FieldByName('Bairro').AsString      := fRemoverAcentuacao(pCep.bairro);
  pClientDataSet.FieldByName('Localidade').AsString  := fRemoverAcentuacao(pCep.localidade);
  pClientDataSet.FieldByName('UF').AsString          := fRemoverAcentuacao(pCep.uf);
  pClientDataSet.FieldByName('DDD').AsString         := fGetNumber(pCep.DDD);
  pClientDataSet.FieldByName('GIA').AsString         := fGetNumber(pCep.GIA);
  pClientDataSet.FieldByName('Arquivo').AsString     := fRemoverAcentuacao(pCep.Arquivo);
  pClientDataSet.Post;
  pClientDataSet.Filtered := False;
end;
end.

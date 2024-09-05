unit Controller;

interface

uses
  Model, System.SysUtils, Data.DB, Datasnap.DBClient, Generics.Collections;

type
  TDataController = class
  private
    FDataModel: TDataModel;
  public
    constructor Create(const pFileName: string);
    destructor  Destroy; override;
    function    fFilterData(pParams: TDictionary<string, string>; pbEndereco: boolean): TClientDataSet;
    function    fFilterDataViaCep(pParams: TDictionary<string, string>; pbEndereco: boolean; pTipoArquivo :string): TClientDataSet;
    procedure   pSaveData(sEndereco, sCep, sIbge, sLogradouro, sComplemento, sBairro, sLocalidade, sUf, sDDD, sGia: string); // Método para salvar os dados
    procedure   pDeleteData(sEndereco: string);
  end;

implementation

constructor TDataController.Create(const pFileName: string);
begin
  FDataModel := TDataModel.Create;
  FDataModel.LoadData(pFileName);
end;

procedure TDataController.pDeleteData(sEndereco: string);
begin
  FDataModel.pDeleteData;
  FDataModel.pSaveDataToFile(sEndereco);
end;

destructor TDataController.Destroy;
begin
  FDataModel.Free;
  inherited;
end;

function TDataController.fFilterData(pParams: TDictionary<string, string>; pbEndereco: boolean): TClientDataSet;
begin
  result :=  FDataModel.fGetDataSet(pParams, pbEndereco);
end;

function TDataController.fFilterDataViaCep(pParams: TDictionary<string, string>; pbEndereco: boolean; pTipoArquivo :string ): TClientDataSet;
begin
  if pTipoArquivo = 'Json' then
    result := FDataModel.fGetViaCep(pParams, pbEndereco)
  else
    result := FDataModel.fGetViaCepXML(pParams, pbEndereco);

end;

procedure TDataController.pSaveData(sEndereco, sCep, sIbge, sLogradouro, sComplemento, sBairro, sLocalidade, sUf, sDDD, sGia: string);
begin
  FDataModel.pAddData(sCep, sIbge, sLogradouro, sComplemento, sBairro, sLocalidade, sUf, sDDD, sGia);
  FDataModel.pSaveDataToFile(sEndereco);

end;

end.


unit frmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Controller, Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids, Datasnap.DBClient,
  Vcl.DBGrids, Vcl.ComCtrls;

type
  TfrPrincipal = class(TForm)
    PathLabel: TLabel;
    DataSource1: TDataSource;
    pgDados: TPageControl;
    tsPesquisa: TTabSheet;
    tsDados: TTabSheet;
    GroupBox1: TGroupBox;
    edtConsultar: TEdit;
    btnPesquisar: TButton;
    dbDados: TDBGrid;
    cbFiltro: TComboBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edtCEP: TEdit;
    edtLogradouro: TEdit;
    edtComplemento: TEdit;
    edtBairro: TEdit;
    edtLocalidade: TEdit;
    edtUF: TEdit;
    edtDDD: TEdit;
    edtIBGE: TEdit;
    edtGIA: TEdit;
    edtJSON: TMemo;
    btnGravar: TButton;
    btnExcluir: TButton;
    cbUF: TComboBox;
    edtLocalidadePesq: TEdit;
    lblLocalidade: TLabel;
    lblLogradouro: TLabel;
    lblUF: TLabel;
    lblFiltro: TLabel;
    cbTipoArquivo: TComboBox;
    Label11: TLabel;
    procedure btnGravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure cbFiltroSelect(Sender: TObject);
    procedure dbDadosCellClick(Column: TColumn);
    procedure dbDadosDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure cbFiltroExit(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FController: TDataController;
    FParamsPesq : TDictionary<string, string>;
    sEndereco : string;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure pClearData;
    procedure pGetDataColumns;
    procedure pEnabledCons;
    function fCheckCons: boolean;

  end;
var
  frPrincipal: TfrPrincipal;

implementation

{$R *.dfm}


procedure TfrPrincipal.btnPesquisarClick(Sender: TObject);
var
  viCount: integer;
  vsResposta : integer;
  vClientDataset : TClientDataSet;
  vbEndereco : Boolean;
  vParamsPesq: TDictionary<string, string>;
  vSMensagem : string;
begin
  vbEndereco := cbFiltro.ItemIndex = 1;

  if not fCheckCons  then
  begin
    vParamsPesq := TDictionary<string, string>.Create;
    try
      if cbFiltro.ItemIndex = 0 then
      begin
        vParamsPesq.Add('cep', edtConsultar.Text);
      end
      else
      begin
        vParamsPesq.Add('uf',         Copy(cbUF.Text,1,2));
        vParamsPesq.Add('localidade', edtLocalidadePesq.Text);
        vParamsPesq.Add('logradouro', edtConsultar.Text);
      end;

      if FController.fFilterData(vParamsPesq, vbEndereco).RecordCount <= 0 Then
      begin
       vsResposta := MessageDlg(Format('Deseja Consultar o Cep OnLine? O Cep %s digitado não consta na base?',
                                [FController.fFilterData(vParamsPesq, vbEndereco).FieldByName('CEP').AsString]),
                                mtConfirmation, [mbYes, mbNo], 0);

      if vsResposta = mrYes then
      begin
       DataSource1.DataSet :=  FController.fFilterDataViaCep(vParamsPesq, vbEndereco, cbTipoArquivo.Text);
       btnExcluir.Enabled := False;
      end;
      end;

    finally
      vParamsPesq.Free;
    end;
  end;
end;

procedure TfrPrincipal.btnExcluirClick(Sender: TObject);
begin
  FController.pDeleteData(sEndereco);
  pClearData;
end;

procedure TfrPrincipal.btnGravarClick(Sender: TObject);
begin
  FController.pSaveData(sEndereco,
                       edtCEP.Text,
                       edtIBGE.Text,
                       edtLogradouro.Text,
                       edtComplemento.Text,
                       edtBairro.Text,
                       edtLocalidade.Text,
                       edtUF.Text,
                       edtDDD.Text,
                       edtGIA.Text);

  DataSource1.DataSet := FController.fFilterData(FParamsPesq, cbFiltro.ItemIndex = 1);
  pClearData;
end;

procedure TfrPrincipal.cbFiltroExit(Sender: TObject);
begin
  pEnabledCons;
end;

procedure TfrPrincipal.cbFiltroSelect(Sender: TObject);
begin
  edtConsultar.TextHint := 'Informe um ' + cbFiltro.Text + ' para ser consultado. '
end;

function TfrPrincipal.fCheckCons: boolean;
var
  vStr : string;
begin
  if cbFiltro.ItemIndex = 1 then
  begin
    if cbUF.ItemIndex = -1 then
    begin
      ShowMessage('A UF está em branco, favor escolher um estado. ');
      cbUF.SetFocus;
      result := True;
    end else
    if trim(edtLocalidadePesq.Text) = EmptyStr then
    begin
      ShowMessage('A Localidade está em branco, favor digitar nome da cidade completo. ');
      edtLocalidadePesq.SetFocus;
      result := True;
    end
    else if (trim(edtConsultar.Text) = EmptyStr) or ((length(edtConsultar.Text) < 3)) then
    begin
      ShowMessage('O Logradouro está em branco ou com menos de 3 caracteres, favor digitar o logradouro. ');
      edtConsultar.SetFocus;
      result := True;
    end;
  end
  else
  begin
    if trim(edtConsultar.Text) = EmptyStr then
    begin
      ShowMessage('O CEP esta em branco, favor digitar o número corretamente. ');
      edtConsultar.SetFocus;
      result := True;
    end;
  end;

end;

procedure TfrPrincipal.pClearData;
begin
  edtCEP.Text             := EmptyStr;
  edtIBGE.Text            := EmptyStr;
  edtLogradouro.Text      := EmptyStr;
  edtComplemento.Text     := EmptyStr;
  edtBairro.Text          := EmptyStr;
  edtLocalidade.Text      := EmptyStr;
  edtUF.Text              := EmptyStr;
  edtDDD.Text             := EmptyStr;
  edtGIA.Text             := EmptyStr;
  edtConsultar.Text       := EmptyStr;
  cbUF.ItemIndex          := -1;
  edtLocalidadePesq.Text  := EmptyStr;
  edtConsultar.Text       := EmptyStr;
  edtJSON.Text            := EmptyStr;
  pgDados.ActivePageIndex := 0;
  cbFiltro.SetFocus;
  DataSource1.DataSet := FController.fFilterData(FParamsPesq, cbFiltro.ItemIndex = 1);
  btnExcluir.Enabled := False;
end;

procedure TfrPrincipal.pEnabledCons;
begin
  cbUF.Enabled              := cbFiltro.ItemIndex = 1;
  edtLocalidadePesq.Enabled := cbFiltro.ItemIndex = 1;
end;

constructor TfrPrincipal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  sEndereco := ExtractFilePath(ParamStr(0)) + 'Base.txt';
  FController := TDataController.Create(sEndereco);
  DataSource1.DataSet := FController.fFilterData(FParamsPesq, cbFiltro.ItemIndex = 1);
  pgDados.ActivePageIndex := 0;
end;

procedure TfrPrincipal.dbDadosCellClick(Column: TColumn);
begin
  pGetDataColumns;
end;

procedure TfrPrincipal.dbDadosDblClick(Sender: TObject);
begin
  pGetDataColumns;
end;

destructor TfrPrincipal.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TfrPrincipal.FormCreate(Sender: TObject);
var
  ExecutablePath: string;
begin
  ExecutablePath := sEndereco;
  PathLabel.Caption := 'Caminho do executável: ' + ExecutablePath;
end;

procedure TfrPrincipal.FormKeyPress(Sender: TObject; var Key: Char);
begin

  if Key = #13 then
  begin
    Key := #0;

    if ActiveControl is TComboBox then
    begin
      if (ActiveControl as TComboBox).DroppedDown then
      begin
        (ActiveControl as TComboBox).DroppedDown := False;
      end
      else
      begin
        SelectNext(ActiveControl, True, True);
      end;
    end
    else
    begin
      SelectNext(ActiveControl, True, True);
    end;
  end;

end;

procedure TfrPrincipal.pGetDataColumns;
begin
  pgDados.ActivePageIndex := 1;
  edtCEP.Text         := DataSource1.DataSet.FieldByName('CEP').AsString;
  edtIBGE.Text        := DataSource1.DataSet.FieldByName('IBGE').AsString;
  edtLogradouro.Text  := DataSource1.DataSet.FieldByName('Logradouro').AsString;
  edtComplemento.Text := DataSource1.DataSet.FieldByName('Complemento').AsString;
  edtBairro.Text      := DataSource1.DataSet.FieldByName('Bairro').AsString;
  edtLocalidade.Text  := DataSource1.DataSet.FieldByName('Localidade').AsString;
  edtUF.Text          := DataSource1.DataSet.FieldByName('UF').AsString;
  edtDDD.Text         := DataSource1.DataSet.FieldByName('DDD').AsString;
  edtGIA.Text         := DataSource1.DataSet.FieldByName('GIA').AsString;
  edtJSON.Text        := DataSource1.DataSet.FieldByName('Arquivo').AsString;
  edtCEP.SetFocus;
  btnExcluir.Enabled := True;
end;

end.

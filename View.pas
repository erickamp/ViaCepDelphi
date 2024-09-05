unit View;

interface

uses
  Vcl.Forms, Vcl.StdCtrls, System.Classes, Controller;

type
  TMainForm = class(TForm)
    SaveButton: TButton;
    procedure SaveButtonClick(Sender: TObject);
  private
    FController: TDataController;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FController := TDataController.Create;
end;

destructor TMainForm.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TMainForm.SaveButtonClick(Sender: TObject);
begin
  //FController.SaveData('teste');
end;

end.


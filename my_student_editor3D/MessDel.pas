unit MessDel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TDeleteMessage = class(TForm)
    Delete: TButton;
    Cancel: TButton;
    TextOfMessage: TLabel;
    procedure TextOfMessageClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DeleteMessage: TDeleteMessage;

implementation

{$R *.dfm}

procedure TDeleteMessage.TextOfMessageClick(Sender: TObject);
begin
     TextOfMessage.Caption:= 'Удалить линию?';
end;

procedure TDeleteMessage.CancelClick(Sender: TObject);
begin
     close;
end;

end.

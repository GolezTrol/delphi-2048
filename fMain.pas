unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Generics.Collections, u2048GameRenderer, u2048Game;

type
  TForm6 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.FormCreate(Sender: TObject);
var
  Renderer: TGameRenderer;
begin
  Renderer := TGameRenderer.Create(Self);
  Renderer.Parent := Self;
  Renderer.Align := alClient;
  // Todo: proper life cycle management for the game object.
  Renderer.FGame := TGame.Create;
end;

end.

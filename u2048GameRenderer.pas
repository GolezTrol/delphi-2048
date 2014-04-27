unit u2048GameRenderer;

interface

uses
  Windows, Graphics, SysUtils, Classes, Controls, u2048Game;

type
  TGameRenderer = class(TCustomControl)
    FGame: TGame;
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  end;

implementation

{ TGameRenderer }

constructor TGameRenderer.Create(AOwner: TComponent);
begin
  inherited;
  TabStop := True;
end;

procedure TGameRenderer.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_UP: FGame.Move(dUp);
    VK_DOWN: FGame.Move(dDown);
    VK_LEFT: FGame.Move(dLeft);
    VK_RIGHT: FGame.Move(dRight);
  end;
  Invalidate;
end;

procedure TGameRenderer.Paint;
const
  // Todo: Make these numbers dynamic/scalable.
  OffsetX = 3;
  OffsetY = 100;
  LineWidth = 6;
  Inset = 3; // LineWidth / 2
  CellWidth = 60;
  TextOffset = 15; // Todo: Center text
  FontSize = 24; // Todo: Auto-adjust font size.
var
  X, Y: Integer;
  Cell: TCell;
begin
  with Canvas do
  begin
    // Background
    Brush.Color := clGray;
    FillRect(Rect(OffsetX, OffsetY, OffsetX + CellWidth * 4, OffsetY + CellWidth * 4));

    // Grid
    Pen.Color := clSilver;
    Pen.Width := LineWidth;
    for X := 0 to 4 do
    begin
      MoveTo(OffsetX + X * CellWidth, OffsetY);
      LineTo(OffsetX + X * CellWidth, OffsetY + CellWidth * 4);
      MoveTo(OffsetX, OffsetY + X * CellWidth);
      LineTo(OffsetX + CellWidth * 4, OffsetY + X * CellWidth);
    end;

    // Cells
    for X := 0 to 3 do
      for Y := 0 to 3 do
        if FGame.GetCell(X, Y, Cell) then
        begin
          Brush.Color := clWhite; // Todo : depend on color;
          Font.Size := FontSize - Length(IntToStr(Cell.Value)) * 3;
          Font.Color := clDkGray;

          FillRect(Rect(
            OffsetX+X*CellWidth+Inset,
            OffsetY+Y*CellWidth+Inset,
            OffsetX+X*CellWidth+CellWidth-Inset,
            OffsetY+Y*CellWidth+CellWidth-Inset));
          TextOut(
            OffsetX+X*CellWidth+TextOffset,
            OffsetY+Y*CellWidth+TextOffset,
            IntToStr(Cell.Value));
        end;

  end;
end;

end.

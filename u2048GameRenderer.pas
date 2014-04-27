unit u2048GameRenderer;

interface

uses
  Windows, Graphics, SysUtils, Classes, Controls, u2048Game, DateUtils;

type
  TGameRenderer = class(TCustomControl)
  protected
    FGame: TGame;
    FAnimationStep: Integer;
    procedure Paint; override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Game: TGame read FGame write FGame;
  end;

implementation

const
  AnimationSteps = 10;

{ TGameRenderer }

constructor TGameRenderer.Create(AOwner: TComponent);
begin
  inherited;
  TabStop := True;
  DoubleBuffered := True;
end;

procedure TGameRenderer.KeyUp(var Key: Word; Shift: TShiftState);
var
  i: Integer;
  AnimationStartTime: TDateTime;
  FrameTime: TDateTime;
begin
  inherited;
  case Key of
    VK_UP: FGame.Move(dUp);
    VK_DOWN: FGame.Move(dDown);
    VK_LEFT: FGame.Move(dLeft);
    VK_RIGHT: FGame.Move(dRight);
  end;

  AnimationStartTime := Now;
  FrameTime := 1 / 86400 / (AnimationSteps / (1/4 { 1/4 second } ));
  for i := 1 to AnimationSteps do
  begin
    FAnimationStep := i;
    Repaint();
    while Now < AnimationStartTime + i * FrameTime do
      Sleep(0);
    Repaint;
  end;
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
  AX, AY: Integer;
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

          AX := Round(
                  CellWidth * (
                    ( X * FAnimationStep +
                      Cell.OldPosition.X * (AnimationSteps - FAnimationStep)
                    ) / AnimationSteps));
          AY := Round(
                  CellWidth * (
                    ( Y * FAnimationStep +
                      Cell.OldPosition.Y * (AnimationSteps - FAnimationStep)
                    ) / AnimationSteps));

          FillRect(Rect(
            AX+OffsetX+Inset,
            AY+OffsetY+Inset,
            AX+OffsetX+CellWidth-Inset,
            AY+OffsetY+CellWidth-Inset));
          TextOut(
            AX+OffsetX+TextOffset,
            AY+OffsetY+TextOffset,
            IntToStr(Cell.Value));
        end;

  end;
end;

end.

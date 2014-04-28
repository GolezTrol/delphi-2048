unit u2048GameRenderer;

interface

uses
  Windows, Graphics, Forms, SysUtils, Classes, Controls, u2048Game, DateUtils;

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
  Moved: Boolean;
begin
  inherited;
  Moved := False;
  case Key of
    VK_UP: Moved := FGame.Move(dUp);
    VK_DOWN: Moved := FGame.Move(dDown);
    VK_LEFT: Moved := FGame.Move(dLeft);
    VK_RIGHT: Moved := FGame.Move(dRight);
  end;

  if not Moved then
    Exit;

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

  if FGame.State = gsLost then
    Application.MessageBox('You lost!', 'You lost!', MB_ICONERROR or MB_OK)
  else if FGame.State = gsWon then
    if Application.MessageBox('You won! Would you like to continue in sandbox mode?', 'You won!', MB_ICONEXCLAMATION or MB_YESNO) = ID_YES then
      FGame.Continue;
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
    FillRect(Rect(OffsetX, OffsetY, OffsetX + CellWidth * GridWidth, OffsetY + CellWidth * GridWidth));

    // Grid
    Pen.Color := clSilver;
    Pen.Width := LineWidth;
    for X := 0 to GridWidth do
    begin
      MoveTo(OffsetX + X * CellWidth, OffsetY);
      LineTo(OffsetX + X * CellWidth, OffsetY + CellWidth * GridWidth);
      MoveTo(OffsetX, OffsetY + X * CellWidth);
      LineTo(OffsetX + CellWidth * GridWidth, OffsetY + X * CellWidth);
    end;

    // Cells
    for X := 0 to GridMax do
      for Y := 0 to GridMax do
        if FGame.GetCell(X, Y, Cell) then
        begin
          Brush.Color := clCream; // Todo : depend on color;
          Font.Size := FontSize - Length(IntToStr(Cell.Value)) * 3;
          Font.Color := clDkGray;
          if Cell = FGame.NewCell then
            Brush.Color := clWebHoneydew;

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

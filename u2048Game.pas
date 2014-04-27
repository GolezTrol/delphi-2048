unit u2048Game;

interface

uses
  Windows, Generics.Collections, Types;

type
  TGameState = (gsPlaying, gsWon, gsLost);
  TDirection = (dLeft, dRight, dUp, dDown);

  TCell = class
  protected
    FValue: Integer;
    FPosition, FOldPosition: TPoint;
    procedure SetPosition(Point: TPoint);
  public
    property Value: Integer read FValue;
    property Position: TPoint read FPosition;
    property OldPosition: TPoint read FOldPosition;
  end;

  TCellList = TList<TCell>;
  TPointList = TList<TPoint>;

  TGame = class
  protected
    // The grid of cells.
    FBoard: array[0..3, 0..3] of TCell;
    // A list of free positions on the grid on which new values can be spawned.
    FFreeLocations: TPointList;
    FState: TGameState;
    // Get a cell from the board, based on the row and column positions in a given direction.
    function GetCell(Row, Column: Integer; Direction: TDirection; out Cell: TCell): Boolean; overload;
    // Collapse a list of cellsl
    function CollapseRow(Row: TCellList): Boolean;
    // Write a collapsed row back to the board and update the list of free cells.
    procedure UpdateBoard(Row: TCellList; RowIndex: Integer; Direction: TDirection);

    // Translate a row and column position in a given direction to absolute grid coordinates.
    procedure Normalize(Row, Column: Integer; Direction: TDirection; out X, Y: Integer);

    // Get a random value for a new cell.
    function GetSpawnValue: Integer;
    // Spawn a cell.
    procedure SpawnAt(Point: TPoint; Value: Integer);

    // Clear the board.
    procedure Clear;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // Start the game.
    procedure Start;
    // Slide the board in a given direction. Returns false if nothing moved or collapsed.
    function Move(Direction: TDirection): Boolean;
    // Get a cell at the given position. Returns false if that grid position is empty.
    function GetCell(X, Y: Integer; out Cell: TCell): Boolean; overload;
  end;

implementation

procedure Swap(var A, B: Integer);
var C: Integer;
begin
  C := A; A := B; B := C;
end;

{ TGame }

procedure TGame.Clear;
var
  X, Y: Integer;
begin
  for X := 0 to 3 do
    for Y := 0 to 3 do
    begin
      FBoard[X, Y].Free;
      FBoard[X, Y] := nil;
    end;
end;

function TGame.CollapseRow(Row: TCellList): Boolean;
var
  ColIndex: Integer;
begin
  // Collapse a row by adding up adjacent cells with the same value.
  Result := False;
  ColIndex := 1;
  while ColIndex < Row.Count do
  begin
    if Row[ColIndex].FValue = Row[ColIndex - 1].FValue then
    begin
      Result := True;
      // Todo: Keep the old value for animations.
      Row[ColIndex].FValue := Row[ColIndex].FValue shl 1;
      // Todo: Keep the cell for animations.
      Row[ColIndex - 1].Free;
      Row.Delete(ColIndex - 1);
    end;
    Inc(ColIndex);
  end;
end;

constructor TGame.Create;
begin
  FFreeLocations := TPointList.Create;
  Start;
end;

destructor TGame.Destroy;
begin
  Clear;
  FFreeLocations.Free;
  inherited;
end;

function TGame.GetCell(Row, Column: Integer; Direction: TDirection;
  out Cell: TCell): Boolean;
var
  X, Y: Integer;
begin
  Normalize(Row, Column, Direction, X, Y);
  Result := GetCell(X, Y, Cell);
end;

function TGame.GetCell(X, Y: Integer; out Cell: TCell): Boolean;
begin
  Cell := FBoard[X, Y];
  Result := Cell <> nil;
end;

function TGame.GetSpawnValue: Integer;
begin
  // One in ten will be a 4. The others will be 2.
  if Random(10) = 0 then
    Result := 4
  else
    Result := 2;
end;

function TGame.Move(Direction: TDirection): Boolean;
var
  Row: TCellList;
  Cell: TCell;
  RowIndex, ColIndex: Integer;
  EmptyCellFound: Boolean;
begin
  Result := False;

  FFreeLocations.Clear;

  Row := TCellList.Create;
  try
    for RowIndex := 0 to 3 do
    begin
      // Populate a list with all cells of the row.
      EmptyCellFound := False;
      for ColIndex := 0 to 3 do
      begin
        if GetCell(RowIndex, ColIndex, Direction, Cell) then
        begin
          Row.Add(Cell);
          // If there is an empty cell between two cells, then there will be movement
          // even if there is no collapse, so return true already.
          if EmptyCellFound then
            Result := True;
        end else
          EmptyCellFound := True;
      end;

      // Collapse each of the rows.
      if CollapseRow(Row) then
        Result := True;

      // Update the grid.
      UpdateBoard(Row, RowIndex, Direction);

      Row.Clear;
    end;

  finally
    Row.Free;
  end;

  if Result then
  begin
    // If there was movement or collapse, there should always be a free cell.
    Assert(FFreeLocations.Count > 0);
    // Spawn a new value.
    SpawnAt(FFreeLocations[Random(FFreeLocations.Count)], GetSpawnValue)
  end;
end;

procedure TGame.Normalize(Row, Column: Integer; Direction: TDirection; out X,
  Y: Integer);
begin
  // Direction is the direction in which stuff is moving, so we start counting
  // from that direction. That means that:
  // When moving down or right, inverse the column index to count from the far end.
  if Direction in [dDown, dRight] then
    Column := 3 - Column;
  // When moving up or down, swap row and column, to have vertical rows.
  if Direction in [dUp, dDown] then
    Swap(Row, Column);
  X := Column;
  Y := Row;
end;

procedure TGame.SpawnAt(Point: TPoint; Value: Integer);
begin
  // Create a cell at the given position and initialize it with the value.
  FBoard[Point.X, Point.Y] := TCell.Create;
  FBoard[Point.X, Point.Y].FValue := Value;
  FBoard[Point.X, Point.Y].SetPosition(Point);
  FBoard[Point.X, Point.Y].SetPosition(Point); // Twice, hack to also set oldposition
end;

procedure TGame.Start;
var
  Value: Integer;
begin
  // Clear any running game.
  Clear;
  // Todo: find out if both starting cells always have the same value in the
  // original game.
  Value := GetSpawnValue;
  // Todo: Choose random positions.
  SpawnAt(Point(0, 0), Value);
  SpawnAt(Point(0, 1), Value);
  FState := gsPlaying;
end;

procedure TGame.UpdateBoard(Row: TCellList; RowIndex: Integer;
  Direction: TDirection);
var
  ColIndex: Integer;
  X, Y: Integer;
begin
  // Update the board by simply resetting all cells in the board.
  // Todo: Remember the old positions for animations.
  for ColIndex := 0 to 3 do
  begin

    // Translate column and row to actual grid position.
    Normalize(RowIndex, ColIndex, Direction, X, Y);

    // Set the cell on the board, or make it empty if there are no more cells
    // in the row.
    if ColIndex >= Row.Count then
    begin
      FBoard[X, Y] := nil;
      FFreeLocations.Add(Point(X, Y));
    end else
    begin
      FBoard[X, Y] := Row[ColIndex];
      Row[ColIndex].SetPosition(Point(X, Y));
    end;
  end;
end;

{ TCell }

procedure TCell.SetPosition(Point: TPoint);
begin
  FOldPosition := FPosition;
  FPosition := Point;
end;

end.

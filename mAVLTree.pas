
unit mAVLTree;

interface

type
  TAVLTree = class;

  TAVLTreeNode = class (TObject)
  private
    //FKey: Cardinal;
    FKey: string;
    FNodeNumber: Cardinal;
    FData: string;

    FBalance,
    FLeftBalance,
    FRightBalance: Byte;

    FLeft,
    FRight,
    FParent: TAVLTreeNode;

    FOwner:  TAVLTree ;

    procedure RefreshBalance;
  public
    constructor Create(AOwner:  TAVLTree ; AKey: string{Cardinal}; ANodeNumber: Cardinal; AData: string; AParent: TAVLTreeNode);
    destructor Destroy; override;

    function GetNext(AKey: string{Cardinal}): TAVLTreeNode;

    //property Key: Cardinal read FKey write FKey;
    property Key: string read FKey write FKey;
    property NodeNumber: Cardinal read FNodeNumber write FNodeNumber;
    //property Data: TObject read FData write FData;
    property Data: string read FData write FData;

    property Parent: TAVLTreeNode read FParent write FParent;
    property Left: TAVLTreeNode read FLeft write FLeft;
    property Right: TAVLTreeNode read FRight write FRight;

    property Balance: Byte read FBalance;
    property LeftBalance: Byte read FLeftBalance;
    property RightBalance: Byte read FRightBalance;
  end;

   TAVLTree = class (TObject)
  private
    FRoot: TAVLTreeNode;
    FOwnedObjects: Boolean;

    FNodeNumber: Cardinal;
    procedure Balance(const ANode: TAVLTreeNode);
  public
    constructor Create(AOwnedObjects: Boolean);
    destructor Destroy; override;

    function IsEmpty: Boolean;
    function FindData(AKey: string{Cardinal}): string;
    function FindNode(AKey: string{Cardinal}): TAVLTreeNode;
    function FindOrInsert(AKey: string{Cardinal}; AData: string): TAVLTreeNode;
    function Delete(AKey: string{Cardinal}): Boolean;
    procedure IncrementOrInsert(AKey: string);
    procedure Clear;

    property Root: TAVLTreeNode read FRoot write FRoot;

    property NodeNumber: Cardinal read FNodeNumber write FNodeNumber;
  end;

implementation

uses SysUtils;

{ TAVLTreeNode }

procedure TAVLTreeNode.RefreshBalance;
begin
  if Assigned(Left) then
    FLeftBalance := Left.Balance
  else
    FLeftBalance := 0;

  if Assigned(Right) then
    FRightBalance := Right.Balance
  else
    FRightBalance := 0;

  if RightBalance > LeftBalance then
    FBalance := RightBalance + 1
  else
    FBalance := LeftBalance + 1;
end;

constructor TAVLTreeNode.Create(AOwner:  TAVLTree ;
                                AKey: string{Cardinal};
                                ANodeNumber: Cardinal;
                                AData: string; AParent: TAVLTreeNode);
begin
  inherited Create;

  FKey := AKey;
  FData := AData;
  Parent := AParent;
  FBalance := 1;
  FOwner := AOwner;
  FNodeNumber := ANodeNumber;
end;

destructor TAVLTreeNode.Destroy;
begin
  if FOwner.FOwnedObjects then
    FreeAndNil(FData);

  inherited;
end;

function TAVLTreeNode.GetNext(AKey: string{Cardinal}): TAVLTreeNode;
begin
  if Key > AKey then
    Result := Left
  else
    Result := Right;
end;

{  TAVLTree  }

procedure  TAVLTree .Balance(const ANode: TAVLTreeNode);
var
  NodeA,
  NodeB,
  NodeC,
  CurrentNode: TAVLTreeNode;
begin
  CurrentNode := ANode;

  while Assigned(CurrentNode) do
  begin
    CurrentNode.RefreshBalance;

    if Abs(CurrentNode.LeftBalance - CurrentNode.RightBalance) <= 1 then
      CurrentNode := CurrentNode.Parent
    else
      if CurrentNode.RightBalance > CurrentNode.LeftBalance then
      begin
        if CurrentNode.Right.LeftBalance > CurrentNode.Right.RightBalance then
        begin
          NodeA := CurrentNode;
          NodeB := NodeA.Right;
          NodeC := NodeB.Left;
          NodeC.Parent := NodeA.Parent;

          if Assigned(NodeC.Parent) then
            if NodeC.Parent.Right = NodeA then
              NodeC.Parent.Right := NodeC
            else
              NodeC.Parent.Left := NodeC;

          NodeA.Parent := NodeC;
          NodeB.Parent := NodeC;
          NodeA.Right := NodeC.Left;
          if Assigned(NodeA.Right) then
            NodeA.Right.Parent := NodeA;

          NodeC.Left := NodeA;
          NodeB.Left := NodeC.Right;
          if Assigned(NodeB.Left) then
            NodeB.Left.Parent := NodeB;

          NodeC.Right := NodeB;

          NodeA.RefreshBalance;
          NodeB.RefreshBalance;
          NodeC.RefreshBalance;

          if Root = NodeA then
            Root := NodeC;

          CurrentNode := NodeC.Parent;
        end
        else
        begin
          NodeA := CurrentNode;
          NodeB := NodeA.Right;
          NodeB.Parent := NodeA.Parent;

          if Assigned(NodeB.Parent) then
            if NodeB.Parent.Right = NodeA then
              NodeB.Parent.Right := NodeB
            else
              NodeB.Parent.Left := NodeB;

          NodeA.Parent := NodeB;
          NodeA.Right := NodeB.Left;

          if Assigned(NodeA.Right) then
            NodeA.Right.Parent := NodeA;

          NodeB.Left := NodeA;

          NodeA.RefreshBalance;
          NodeB.RefreshBalance;

          if Root = NodeA then
            Root := NodeB;

          CurrentNode := NodeB.Parent;
        end
      end
      else
      begin
        if CurrentNode.Left.RightBalance>CurrentNode.Left.LeftBalance then
        begin
          NodeA := CurrentNode;
          NodeB := NodeA.Left;
          NodeC := NodeB.Right;
          NodeC.Parent := NodeA.Parent;
          if Assigned(NodeC.Parent) then
            if NodeC.Parent.Right = NodeA then
              NodeC.Parent.Right := NodeC
            else
              NodeC.Parent.Left := NodeC;

          NodeA.Parent := NodeC;
          NodeB.Parent := NodeC;
          NodeA.Left := NodeC.Right;
          if Assigned(NodeA.Left) then
              NodeA.Left.Parent := NodeA;

          NodeC.Right := NodeA;
          NodeB.Right := NodeC.Left;
          if Assigned(NodeB.Right) then
            NodeB.Right.Parent := NodeB;
          NodeC.Left:=NodeB;

          NodeA.RefreshBalance;
          NodeB.RefreshBalance;
          NodeC.RefreshBalance;

          if Root = NodeA then
            Root := NodeC;

          CurrentNode := NodeC.Parent;
        end
        else
        begin
          NodeA := CurrentNode;
          NodeB := NodeA.Left;
          NodeB.Parent := NodeA.Parent;
          if Assigned(NodeB.Parent) then
            if NodeB.Parent.Right = NodeA then
            NodeB.Parent.Right := NodeB
          else
            NodeB.Parent.Left := NodeB;

          NodeA.Parent := NodeB;
          NodeA.Left := NodeB.Right;

          if Assigned(NodeA.Left) then
            NodeA.Left.Parent := NodeA;

          NodeB.Right := NodeA;

          NodeA.RefreshBalance;
          NodeB.RefreshBalance;

         if Root = NodeA then
           Root := NodeB;
          CurrentNode:=NodeB.Parent;
        end
      end;
  end;
end;

constructor  TAVLTree .Create(AOwnedObjects: Boolean);
begin
  inherited Create;

  FOwnedObjects := AOwnedObjects;
  FNodeNumber := 0;
end;

destructor  TAVLTree .Destroy;
begin
  Clear;

  inherited;
end;

function  TAVLTree .IsEmpty: Boolean;
begin
  Result := not Assigned(Root);
end;
 
function  TAVLTree .FindData(AKey: string{Cardinal}): string;
var
  Node: TAVLTreeNode;
begin
  Node := FindNode(AKey);
 
  if Assigned(Node) then
    Result := Node.Data
  else
    Result := '';
end;
 
function  TAVLTree .FindNode(AKey: string{Cardinal}): TAVLTreeNode;
begin
  Result := Root;
 
  while Assigned(Result) and (Result.Key <> AKey) do
    Result := Result.GetNext(AKey);
end;
 
function  TAVLTree .FindOrInsert(AKey: string{Cardinal}; AData: string): TAVLTreeNode;
var
  ParentNode,
  NewNode: TAVLTreeNode;
  LowKey: string;
begin
  Result := Root;
  LowKey := LowerCase(AKey);

  if Assigned(Result) then
  begin
    ParentNode := nil;
    Result := Root;

    while Assigned(Result) and (Result.Key <> LowKey{Akey}) do
    //while Assigned(Result) and (AnsiCompareText(Result.Key,Akey) <> 0) do
    begin
      ParentNode := Result;
      Result := Result.GetNext(LowKey{AKey});
    end;

    if Assigned(Result) then Exit;

    inc(FNodeNumber);
    NewNode := TAVLTreeNode.Create(Self, LowKey{AKey}, FNodeNumber, AData, ParentNode);
    //Result := NewNode;

    if ParentNode.Key > NewNode.Key then
      ParentNode.Left := NewNode
    else
      ParentNode.Right := NewNode;

    Balance(ParentNode);
  end
  else
  begin
    inc(FNodeNumber);
    Root := TAVLTreeNode.Create(Self, LowKey{AKey}, FNodeNumber, AData, nil);
    //Result := Root;
  end;
end;

procedure TAVLTree.IncrementOrInsert(AKey: string);
var CurrentNode: TAVLTreeNode;
begin
    CurrentNode := FindOrInsert(AKey, '1');
    if CurrentNode <> nil
    then begin
             CurrentNode.Data := (CurrentNode.Data.ToInteger + 1).ToString;
         end;
    CurrentNode := nil;
    FreeAndNil(CurrentNode);
end;
 
function  TAVLTree .Delete(AKey: string{Cardinal}): Boolean;
var
  CurrentNode,
  NodeA,
  NodeB: TAVLTreeNode;
begin
  CurrentNode := FindNode(AKey);
 
  Result := Assigned(CurrentNode);
 
  if Result then
  begin
    if CurrentNode.LeftBalance > CurrentNode.RightBalance then
    begin
      NodeA := CurrentNode.Left;
 
      while Assigned(NodeA.Right) do
        NodeA := NodeA.Right;
 
      NodeB := NodeA.Parent;
 
      if NodeB = CurrentNode then
      begin
        CurrentNode.Left := NodeA.Left;
        if Assigned(CurrentNode.Left) then
          CurrentNode.Left.Parent := CurrentNode;
      end
      else
      begin
        NodeB.Right := NodeA.Left;
        if Assigned(NodeB.Right) then
          NodeB.Right.Parent := NodeB;
      end;
 
      CurrentNode.Key := NodeA.Key;
      CurrentNode.Data := NodeA.Data;
      FreeAndNil(NodeA);
 
      Balance(NodeB);
    end
    else if CurrentNode.RightBalance > 0 then
    begin
      NodeA := CurrentNode.Right;
 
      while Assigned(NodeA.Left) do
        NodeA := NodeA.Left;
 
      NodeB := NodeA.Parent;
 
      if NodeB = CurrentNode then
      begin
        CurrentNode.Right := NodeA.Right;
        if Assigned(CurrentNode.Right) then
          CurrentNode.Right.Parent := CurrentNode;
      end
      else
      begin
        NodeB.Left:=NodeA.Right;
        if Assigned(NodeB.Left) then
          NodeB.Left.Parent := NodeB;
      end;
 
      CurrentNode.Key := NodeA.Key;
      CurrentNode.Data := NodeA.Data;
 
      FreeAndNil(NodeA);
 
      Balance(NodeB);
    end
    else
    begin
      if not Assigned(CurrentNode.Parent) then
        Root := nil
      else
        if (CurrentNode.Parent.Left = CurrentNode) then
          CurrentNode.Parent.Left := nil
        else
          CurrentNode.Parent.Right := nil ;
 
      {Parent of Current Node is Not Balanced ,so}
      Balance(CurrentNode.Parent);
 
      FreeAndNil(CurrentNode);
    end;
  end;
end;
 
procedure  TAVLTree .Clear;
 
  procedure _Clear_R(ANode: TAVLTreeNode);
  begin
    if not Assigned(ANode) then Exit;
 
    if Assigned(ANode.Left) then begin
      _Clear_R(ANode.Left);
    end;
 
    if Assigned(ANode.Right) then begin
      _Clear_R(ANode.Right);
    end;
 
    FreeAndNil(ANode);
  end;
 
begin
  _Clear_R(FRoot);
end;

end.
unit ArrayHolderUnit;

interface

//---примеры использования-----------
//    TreeNode := FUniqueWSamplesTree.FindOrInsert(strWork, TArrayHolder.Create(LineNo, InInputSL[FUniqWcaseFieldNumbers[I]], 2, false));
//    if TreeNode <> nil
//    then begin
//             TArrayHolder(TreeNode.Data).AddValue(LineNo, InInputSL[FUniqWcaseFieldNumbers[I]]);
//         end;
//----------------------------------
//    TreeNode := FUniqueWSamplesTree.FindNode(FUniqueWcaseArrDyn[J].Key);
//    arrSample := TArrayHolder(TreeNode.Data).ArrayObj;
//----------------------------------

type
  SamplesRecord = record
      LineNo: integer;
      Value: string;
  end;

type
  TArrayHolder = class
  private
    fArray: TArray<SamplesRecord>;
    fAllowDuplicates: boolean;
    fMaxArrayLength: integer;
    function GetArray: TArray<SamplesRecord>;
  public
    constructor Create(const LineNo: integer;
                       const aValue: string;
                       const ArrayLength: integer;
                       const AllowDuplicates: Boolean = False);
    destructor Destroy;

    procedure AddValue(const LineNo: integer;
                       const aValue: string);
    property ArrayObj: TArray<SamplesRecord> read GetArray write fArray;
  end;

implementation

constructor TArrayHolder.Create(const LineNo: integer;
                                const aValue: string;
                                const ArrayLength: integer;
                                const AllowDuplicates: Boolean = False);
begin
    fAllowDuplicates := AllowDuplicates;
    fMaxArrayLength := ArrayLength;
    if fMaxArrayLength < 1 then fMaxArrayLength := 1;

    SetLength(fArray, Length(fArray) + 1);
    fArray[High(fArray)].LineNo := LineNo;
    fArray[High(fArray)].Value := aValue;
end;

destructor TArrayHolder.Destroy;
begin
    SetLength(fArray, 0);
end;

function TArrayHolder.GetArray: TArray<SamplesRecord>;
begin
  if self <> nil
  then begin
           SetLength(Result, Length(fArray));
           Result := fArray;
       end
  else SetLength(Result, 0);
end;

procedure TArrayHolder.AddValue(const LineNo: integer; const aValue: string);
var AllowAddNewRecord: boolean;
begin
    AllowAddNewRecord := false;
    if Length(fArray) < fMaxArrayLength
    then begin
             if fAllowDuplicates = false then
                 if LineNo <> fArray[High(fArray)].LineNo
                 then AllowAddNewRecord := true
                 else AllowAddNewRecord := false
             else AllowAddNewRecord := true;
         end;

    if AllowAddNewRecord = true
    then begin
             SetLength(fArray, Length(fArray) + 1);
             fArray[High(fArray)].LineNo := LineNo;
             fArray[High(fArray)].Value := aValue;
         end;
end;

end.

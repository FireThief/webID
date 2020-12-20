unit TextSpinnerUnit;

interface

uses StrUtils,SysUtils,Classes;

function SpinText(LIN :String):string;

implementation

{********** SpinBtnClick ***********}
function SpinText(LIN :string):string;
var
  i:integer;
  PhraseCount,n,start,stop:integer;
  index, PhraseIndex:integer;
  line,lineout:string;
  Phrases:array [0..100] of string;
  id,idref:string;
  SpinSets:TStringList;
begin
//  Result := true;
  randomize;
  SpinSets := TStringList.Create;
  SpinSets.clear;
  line:=LIN + '{|}';
  {copy all of the input text into a single string}
//  with SLIN do  for i:=0 to Count-1 do line:=line+SLIN[i];
  lineout:='';
  n:=1;
//  if posex('{',line,n) = 0 then line := line + '{|}';
  repeat
    start:=n; {next start point for scanning the line}
    n:=posex('{',line,n); {find next phrase set}
    if n>0 then
    begin
      lineout:=lineout + copy(line,start, n-start);
      start:=n+1; {update next word start position}
      PhraseCount:=0;
      stop:=posex('}',line,n);
      if stop>0 then
      begin  {found the closing bracket }
        id:='';
        idref:='';
        if line[start]='%' then
        begin {"id" specified for this spinset}
          id:=line[start+1];
          inc(start,2);
        end
        else if line[start]='&' then
        begin {this is a reference to a previously defined spinset}
          idref:=line[start+1];
          inc(start,2);
        end;
        while (n>0) and (n<stop) do
        begin {Loop looking for phrase dividers}
          n:=posex('|',line,start);
          if (n=0) or (n>stop) then n:=stop; {didn't find one, use closing bracket as the last}
          Phrases[PhraseCount]:=copy(line,start,n-start); {save the phrase}
          inc(PhraseCount);
          start:=n+1; {next start index is right after the divider or closing bracket}
        end;
         PhraseIndex:=-1;
        if idref<>'' then
        begin {add the worded indexed by the referenced phrase's word index to the line}
          phraseindex:=-1;
          for i:=0 to spinsets.Count-1 do
          begin
            if spinsets[i][1]=idref then
            begin
              phraseindex:=strtoint(copy(spinsets[i],2,length(spinsets[i])-1));
              break;
            end;
          end;
          if phraseindex<0
          then Result := ''; //showmessage('The referenced item  &'+idref + ' is undefined');
        end
        else
        begin {add a random phrase to the output}
          {We have all the phrases, pick one randomly from those found}
          if PhraseCount>1 then PhraseIndex:=random(PhraseCount)
          {unles only one phrase found, select it half the time}
          //else if (PhraseCount=1) then if (random(2)=1) then PhraseIndex:=0;//origin
          else if (PhraseCount=1) then PhraseIndex:=0;
        end;
        //If PhraseIndex>=0 then //origin
          if Phrases[PhraseIndex]<>'b' then lineout:=lineout+ Phrases[PhraseIndex];
        if id<>'' then
        begin
          spinsets.add(id+ inttostr(PhraseIndex));
        end;
        n:=stop+1; {Update N just past the closing bracket}
      end
      else
      begin
//        showmessage('No closing ''}'' for choices phrase set');
        Result := '';
        n:=0; {to stop the loop}
      end;
    end;
  until n=0;
//  SLOUT.add(lineout);
//  SLOUT.Add('');
  Result := lineout;
  SpinSets.Free;
end;

end.

program Guess(Input, Output);

{ FPC supports ISO 7185, but not ISO 10206 }
{$IFDEF SUPPORTS_ISO_10206}
import
  libintl only(gettext, textdomain, bindtextdomain);

{ Change this if you install into another directory }
const
  DomainDir = '/usr/share/locale';
{$ELSE}
{$IFNDEF __GPC__}
  type
    String = array[0..255] of char;
{$ENDIF}

  function gettext(s: String): String;
  begin
    gettext := s;
  end;
{$ENDIF}


var
{$IFNDEF SUPPORTS_ISO_10206}
  i: integer;
{$ENDIF}
  fwidth: integer;
  gnumber: integer;
  level: integer{$IFDEF SUPPORTS_ISO_10206} value 1{$ENDIF};
  lives: integer{$IFDEF SUPPORTS_ISO_10206} value 5{$ENDIF};
  number: integer;
  rnumber: integer;

begin
{$IFDEF SUPPORTS_ISO_10206}
  textdomain('guess');
  bindtextdomain('guess', DomainDir);
{$ELSE}
  level := 1;
  lives := 3;
{$ENDIF}
  Randomize;

  repeat
  {$IFDEF SUPPORTS_ISO_10206}
    rnumber := 10 pow level;
  {$ELSE}
    rnumber := 1;
    for i := 1 to level do
    begin
      rnumber := rnumber * 10;
    end;
  {$ENDIF}
    number := Random(rnumber);

    repeat
      fwidth := level + 2;
      Write(gettext('Enter a number, from 0 to'), rnumber:fwidth, ': ');

      if Input^ in ['0'..'9'] then
      begin
        ReadLn(gnumber);
        if number = gnumber then
        begin
          WriteLn(gettext('Correct!'));
          { Using the standard Succ/Pred instead of Borland's Inc/Dec }
          level := Succ(level);
          lives := Succ(lives);
        end
        else
        begin
          lives := Pred(lives);
          if lives > 0 then
          begin
            Write(gettext('Try again!'));
            WriteLn(lives:fwidth - 1, gettext(' lives remaining'));
          end
          else
          begin
            WriteLn('You lose!');
            WriteLn(gettext('The correct solution was:'), number:fwidth);
          end;
        end;
      end
      else
      begin
        if Input^ = 'q' then
        begin
          lives := 0;
        end
        else
        begin
          Put(Input);
          WriteLn(gettext('That is not a number!'));
          Get(Input);
        end;
      end;
    until (lives = 0) or (number = gnumber);
  until lives = 0;
end.

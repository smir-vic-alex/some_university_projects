unit Editor3D;
    { Прошу прощения за ужасный код, дэдлайн был слишком близок,
        я боялся не успеть :D }
interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Menus, StdCtrls, Buttons, ExtCtrls;
const
    DX = 300;
    DY = 300;
    SHIFT = 10;
    dx2 = SHIFT;
    dy2 = 25;
    ddx = 5;
    ddy = 5;
    nmax = 50;

    // Свойства линии
    SSOLID = 1;  // Сплошная
    SDOT = 2;    // Пунктир, короткие штрихи
    SDASHDotDot = 3;  // Пунктир, один длинный штрих два маленьких
    SDASH = 4;  // Пунктир, длинные штрихи
    SDASHDot = 5; // Пунктир, один длинный штрих один маленький
    SClEAR = 6; // Линия не отображается
               //( т.е. если не надо отображать границу прямоугльника)

    MBLACK = 1; // Черный, не зависит от свойсва Pen.Color
    MCOPY = 2; // Цвет линиий определяется значением свойсва Pen.Color
    MNOT = 3; //  Цвет точки инверсный по отношению к холсту
    MWHITE = 4; // Белый, не зависит от свойсва Pen.Color
    MNOTCopy = 5; // Цвет линии инверсный по отношению к Pen.Color

    CBLACK = 1; // Черный
    CGREEN = 2; // Зеленый
    CNAVY = 3;  // Темно-синий
    CTEAL = 4;  // Зелено-голубой
    CSILVER = 5; // Серебристый
    CLIME = 6; // Салатный
    CFLUCHSIA = 7; // Ярко-розовый
    CMAROON = 8; // Каштановый
    COLIVE = 9; // Оливковый
    CPURPLE = 10; // Розовый
    CGRAY = 11; // Серый
    CRED = 12; // Красный
    CBLUE = 13; // Синий
    CWHITE = 14; // Белый
    CAQUA = 15; // Бирюзовый

    WSTANDARTWidth = 2;          // Толщина сплошной линии
    WSTANDARTWidthOfDash = 1;    // Толщина пунктирной линии
    WSTANDARTWidthOfFrame = 2;  // Толщина рамки
    COLORDotLine = CAQUA;
    COLORExcretoryFrame = CAQUA;
    COLOR3DFrame  = CLIME;
type
    TMainForm = class( TForm )
    Back: TSpeedButton;
    CloseProgram: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Panel1: TPanel;
      procedure FormMouseDown( Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X,Y: Integer );
      procedure FormMouseMove( Sender: TObject; Shift: TShiftState;
                                X,Y: Integer );
      procedure FormCreate( Sender: TObject );
      procedure FormMouseUp( Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer );
      procedure FormPaint( Sender: TObject );
      procedure BackClick( Sender: TObject );
      procedure CloseProgramClick( Sender: TObject );
      procedure SpeedButton1Click( Sender: TObject );
   
    private

      startX, startY, oldX, oldY: Integer;
      dragging: Boolean;
      { Private declarations }
    public
      oldPenMode: TPenMode;
      { Public declarations }
end;

var
    MainForm: TMainForm;

implementation

uses MessDel;

{$R *.dfm}
type
    tCoord = record
       x1,y1,z1: integer;
       x2,y2,z2: integer;
    end;

    tCoordInThreeAreas = record
       l: tCoord;
     end;

    tStack = record
       a: array [1..nmax] of tCoordInThreeAreas;
       sp: integer;
    end;

    tWasInArea = record
       xy, zy, xz: boolean;
    end;

    tDelChLine = record
       l: tCoord;
       Delete: Boolean;
       number: integer;
    end;
var
    s, selS: tStack;
    pointOfLine: tCoordInThreeAreas;
    deletePoint: tCoordInThreeAreas;
    delLine:  tCoordInThreeAreas;
    wasInArea: tWasInArea;
    ChekedLine: tDelChLine;
    countOfClickForSelLine: Integer;

procedure CoordInFirstArea( startX, startY: Integer; var x, y: Integer );
begin
   if ( x>=DX ) and ( y<=DY ) and ( y>DY2+SHIFT )  then
      x:= DX
   else if ( x>=DX ) and ( y<Dy ) and ( y<=DY2+SHIFT ) then begin
      x:= DX; y:= DY2+SHIFT;
      end
   else if ( x>=DX ) and ( y>=DY ) then begin
      x:= DX; y:= DY;
      end
   else if ( x<=DX ) and ( y<=DY2+SHIFT ) and ( x>DX2 ) then
      y:= dy2+SHIFT
   else if ( x<=DX ) and ( y<=DY2+SHIFT ) and ( x<=DX2 ) then begin
      y:= dy2+SHIFT; x:= dx2;
      end
   else if ( x<=DX ) and ( y>=DY ) and ( x>DX2 )   then
      y:= DY
   else if ( x<=DX ) and ( y>=DY ) and ( x<=DX2 )   then begin
      y:= DY; x:= dx2;
   end
   else if ( x<= dx2 ) and ( y<dy) and ( y> dy2+SHIFT) then
      x:= dx2;
end;

procedure CoordInSecondArea( startX, startY: Integer; var x, y: Integer );
begin
   if ( x<=DX+SHIFT ) and ( y<=DY ) and ( y>=dy2+SHIFT ) then
      x:= DX+SHIFT
   else if ( y>=DY ) and ( x>=DX ) and ( x<Dx*2) then
      y:= DY
   else if ( y>=DY ) and ( x<=DX+SHIFT ) then begin
      x:= DX+SHIFT; y:= DY;
      end
   else if ( x>=DX+SHIFT ) and ( y<=dy2+SHIFT ) and ( x<DX*2 ) then
      y:= dy2+SHIFT
   else if ( x<=DX+SHIFT ) and ( y<=dy2+SHIFT ) then begin
      x:= DX+SHIFT; y:= dy2+SHIFT;
      end
   else if ( y>=DY ) and ( x>=DX+SHIFT ) and ( x>=Dx*2)  then begin
      y:= DY; x:= DX*2;
      end
   else if ( y<=DY ) and ( x>=DX+SHIFT ) and ( x>=Dx*2) and ( y>dy2+SHIFT) then
       x:= DX*2
   else if ( y<=DY ) and ( x>=DX+SHIFT ) and ( x>=Dx*2)
                     and ( y<=dy2+SHIFT) then begin
       x:= DX*2; y:= dy2+SHIFT;
   end
end;

procedure CoordInThirdArea( startX, startY: Integer; var x, y: Integer );
begin
   if ( x<=DX ) and ( y<=DY+SHIFT ) and ( x>dx2 ) then
      y:= DY+SHIFT
   else if ( y>=DY+SHIFT ) and ( x>=DX ) and ( y<DY*2 ) then
      x:= DX
   else if ( y<=DY+SHIFT ) and ( x>=DX ) then begin
      x:= DX; y:= DY+SHIFT;
      end
   else if ( x<=DX ) and ( y<=DY+SHIFT ) and ( x<=dx2 ) then begin
      y:= DY+SHIFT; x:= dx2;
      end
   else if ( x>= Dx ) and ( y>= dy*2 ) then begin
      x:= dx; y:= dy*2;
   end
   else if ( x<DX ) and ( y>= dy*2 ) and ( x>dx2 ) then
      y:= dy*2
   else if ( x<dx ) and ( y>= dy*2 ) and ( x<=dx2 ) then begin
      x:= dx2; y:= dy*2;
      end
   else if ( x<=dx2 ) and ( y<dy*2 ) and ( y>dy ) then
      x:= dx2;

end;

function InAreaXY( x, y: integer ):boolean;
begin
   if ( x<DX ) and ( x>DX2 ) and ( y<DY ) and ( y>DY2+5 ) then
      InAreaXY:= true
   else
      InAreaXY:= false;
end;

function InAreaZY( x, y: integer ): boolean;
begin
   if ( x>DX ) and ( x<DX*2 ) and ( y<DY ) and ( y>DY2+5 ) then
      InAreaZY:= true
   else
      InAreaZY:= false;
end;

function InAreaXZ( x, y: integer ): boolean;
begin
   if ( x<DX ) and ( x>DX2 ) and ( y>DY+5 ) and ( y<DY*2 ) then
      InAreaXZ:= true
   else
      InAreaXZ:= false;
end;

procedure InitChekedLine( var l: tDelChLine ) ;
begin
   l.l.x1:= -1;   l.l.x2:= -1;
   l.l.y1:= -1;   l.l.y2:= -1;
   l.l.z1:= -1;   l.l.z2:= -1;
   l.Delete:= false;
   l.number:= -1;
end;

procedure InitBool( var b: tWasInArea );
begin
   b.xy:= false; b.zy:= false; b.xz:= false;
end;

procedure InitStack( var s: tStack );
begin
   s.sp:= 0;
end;

procedure Push( var s: tStack;  pointOfLine: tCoordInThreeAreas );
begin
   if s.sp<=50 then begin
      s.sp:= s.sp + 1;
      s.a[ s.sp ]:= pointOfLine
      end
   else
      s.sp:=1;
end;

procedure Pop( var s:tStack; var deletePoint: tCoordInThreeAreas );
begin
   deletePoint:= s.a[ s.sp ];
   s.sp:= s.sp - 1;
end;

function NotEmpty( s: tStack ): boolean;
begin
   NotEmpty:= s.sp>0;
end;

procedure InitPointOfLine( var p: tCoordInThreeAreas );
begin
   p.l.x1:= -1;   p.l.y1:= -1;
   p.l.z1:= -1;   p.l.x2:= -1;
   p.l.y2:= -1;   p.l.z2:= -1;
end;

function PointOfLineIsFull( p: tCoord ): boolean;
begin
   if ( p.x1<>-1 ) and ( p.y1<>-1) and ( p.z1<>-1 ) then
      PointOfLineIsFull:= true
   else
      PointOfLineIsFull:= false;
end;

procedure TMainForm.FormCreate( Sender: TObject );
begin
   dragging:= false;
   InitStack( s ); InitStack( selS );
   InitPointOfLine( pointOfLine );
   InitPointOfLine( deletePoint );
   InitPointOfLine ( DelLine );
   InitBool( wasInArea );
   countOfClickForSelLine:= 0;
end;

function distance ( x, y, x1, y1, x2, y2: integer ): real;
var
   A, B, C: integer;
begin
   A:= y2-y1; B:= -(x2-x1); C:= y1*(x2-x1) - x1*(y2-y1);
   if A*A+B*B<>0 then
      distance:= abs( A*x + B*y + C ) / ( sqrt(A*A+B*B) )
    else
        distance:= sqrt( sqr(x-x1) + sqr(y-y1) );
end;

procedure Line ( Canvas: tCanvas ; x1, y1, x2, y2: integer );
begin
   Canvas.MoveTo( x1, y1 ); Canvas.LineTo( x2, y2 );
   Canvas.Ellipse(x1-2,y1-2, x1+2,y1+2 );
   Canvas.Ellipse(x2-2,y2-2, x2+2,y2+2 );
end;

procedure Line2 ( Canvas: tCanvas ; x1, y1, x2, y2: integer );
begin
   Canvas.MoveTo( x1, y1 ); Canvas.LineTo( x2, y2 );
end;

procedure Proection( p: tCoord; Canvas: tCanvas );
var
   x1,y1,x2,y2: integer;
begin
   x1 := round (0.7*(p.x1 + round( p.z1 / 2.828 )));
   y1 := round(0.7*(p.y1 + round( p.z1 / 2.828 )));
   x2 := round(0.7*(p.x2 + round( p.z2 / 2.828 )));
   y2 := round(0.7*(p.y2 + round( p.z2 / 2.828 )));
   Line( Canvas, x1+DX, y1+DY, x2+DX, y2+DY );
end;

procedure StateOfPaint( style, mode, color, width: Integer; Canvas: tCanvas );
begin
   case style of
      1: Canvas.Pen.style:= psSolid;      4: Canvas.Pen.style:= psDash;
      2: Canvas.Pen.style:= psDot;        5: Canvas.Pen.style:= psDashDot;
      3: Canvas.Pen.style:= psDashDotDot; 6: Canvas.Pen.style:= psClear;
   else
      Canvas.Pen.style:= psSolid;
   end;

   case mode of
      1: Canvas.Pen.Mode:= pmBlack;       4: Canvas.Pen.Mode:= pmWhite;
      2: Canvas.Pen.Mode:= pmCopy;        5: Canvas.Pen.Mode:= pmNotCopy;
      3: Canvas.Pen.Mode:= pmNot;
   else
      Canvas.Pen.Mode:= pmBlack;
   end;

   case color of
      1: Canvas.Pen.Color:= clBlack;      8: Canvas.Pen.Color:= clMaroon;
      2: Canvas.Pen.Color:= clGreen;      9: Canvas.Pen.Color:= clOlive;
      3: Canvas.Pen.Color:= clNavy;       10: Canvas.Pen.Color:= clPurple;
      4: Canvas.Pen.Color:= clTeal;       11: Canvas.Pen.Color:= clGray;
      5: Canvas.Pen.Color:= clSilver;     12: Canvas.Pen.Color:= clRed;
      6: Canvas.Pen.Color:= clLime;       13: Canvas.Pen.Color:= clBlue;
      7: Canvas.Pen.Color:= clFuchsia;    14: Canvas.Pen.Color:= clWhite;
                                          15: Canvas.Pen.Color:= clAqua;
   else
      Canvas.Pen.Color:= clBlack;
   end;

   Canvas.Pen.Width:= width;

end;

procedure DrawFrame( x1,y1,x2,y2: integer; Color:Integer; Canvas: tCanvas );
begin
   StateOfPaint( SSOLID, MCOPY, color, WSTANDARTWidthOfFrame, Canvas );
   Canvas.Brush.style:= bsClear;
   Canvas.Rectangle( x1,y1,x2,y2);

   StateOfPaint( SSOLID, MCOPY, CBLACK, 1, Canvas  ) ;
   Line2 ( Canvas, Shift div 2,dy2+Shift div 2,30,dy2+Shift div 2 );
   Canvas.TextOut( 30,dy2-5,'x');
   Line2 ( Canvas, Shift div 2,dy2+Shift div 2,Shift div 2, 60 );
   Canvas.TextOut( Shift div 2-5,dy2+33,'y');

   Line2 ( Canvas, DX + Shift div 2,dy2+Shift div 2,DX + 30,dy2+Shift div 2 );
   Canvas.TextOut( DX+30,dy2-5,'z');
   Line2 ( Canvas,  DX+ Shift div 2,dy2+Shift div 2,DX + Shift div 2, 60 );
   Canvas.TextOut( DX+Shift div 2-5,dy2+33,'y');

   Line2 ( Canvas, Shift div 2,dy+Shift div 2,30,dy+Shift div 2 );
   Canvas.TextOut( 30,dy-3,'x');
   Line2 ( Canvas, Shift div 2,dy+Shift div 2,Shift div 2, DY+ 30 );
   Canvas.TextOut( Shift div 2-5, dy+25+shift div 2,'z');


   Line2 ( Canvas, Shift div 2+DX,dy+Shift div 2,DX+30,dy+Shift div 2 );
   Canvas.TextOut( DX+30,dy-3,'x');
   Line2 ( Canvas, DX+Shift div 2,dy+Shift div 2,DX+Shift div 2, DY+ 30 );
   Canvas.TextOut( DX+Shift div 2-5, dy+25+shift div 2,'y');

   Line2 ( Canvas, Shift div 2+DX,dy+Shift div 2,DX+15,DY+ 15);
   Canvas.TextOut( DX+15,dy+10,'z');
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas );

end;

procedure DrawInAreas( p: tCoord; Canvas: tCanvas );
begin
   Line( Canvas, p.x1, p.y1, p.x2, p.y2 );
   Line( Canvas, p.z1+DX, p.y1, p.z2+DX, p.y2 );
   Line( Canvas, p.x1, p.z1+DY, p.x2, p.z2+DY );
   Proection( p, Canvas );
end;

function FindLinesWithError(x11,x12,y11,y12,x21,x22,y21,y22: integer ):boolean;
const
   er = 0;
begin
   if ((x11=x21)and(x12=x22)) or ((y11=y21)and(y12=y22)) then
      FindLinesWithError:= true
   else
      FindLinesWithError:= false;
end;

procedure DrawDottedLinesXY(Canvas:tCanvas; Color: Integer);
begin
   StateOfPaint( SDASH, MCOPY, color, WSTANDARTWidthOfDash, Canvas  );
   Line( Canvas, pointOfLine.l.x1, pointOfLine.l.y1, pointOfLine.l.x1, 2*DY);
   Line( Canvas, pointOfLine.l.x2, pointOfLine.l.y2, pointOfLine.l.x2, 2*DY);
   Line( Canvas, pointOfLine.l.x1, pointOfLine.l.y1, 2*DX, pointOfLine.l.y1);
   Line( Canvas, pointOfLine.l.x2, pointOfLine.l.y2, 2*DX, pointOfLine.l.y2);
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  )
end;

procedure DrawDottedLinesZY(Canvas:tCanvas;Color: integer);
begin
   StateOfPaint( SDASH, MCOPY, color, WSTANDARTWidthOfDash, Canvas );
   Line( Canvas, pointOfLine.l.z1+DX, pointOfLine.l.y1, 0, pointOfLine.l.y1);
   Line( Canvas, pointOfLine.l.z2+DX, pointOfLine.l.y2, 0, pointOfLine.l.y2);
   Line( Canvas, pointOfLine.l.z1+DX, pointOfLine.l.y1, pointOfLine.l.z1+DX,DY);
   Line( Canvas, pointOfLine.l.z2+DX, pointOfLine.l.y2, pointOfLine.l.z2+DX,DY);
   Line( Canvas, DX,pointOfLine.l.z1+DY, 0, pointOfLine.l.z1+DY);
   Line( Canvas, DX,pointOfLine.l.z2+DY, 0, pointOfLine.l.z2+DY);
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas )
end;

procedure DrawDottedLinesXZ(Canvas:tCanvas;Color: integer);
begin
   StateOfPaint( SDASH, MCOPY, color, WSTANDARTWidthOfDash, Canvas  );
   Line( Canvas, pointOfLine.l.x1, pointOfLine.l.z1+DY, pointOfLine.l.x1, dy2);
   Line( Canvas, pointOfLine.l.x2, pointOfLine.l.z2+DY, pointOfLine.l.x2, dy2);
   Line( Canvas, pointOfLine.l.x1, pointOfLine.l.z1+DY,DX, pointOfLine.l.z1+DY);
   Line( Canvas, pointOfLine.l.x2, pointOfLine.l.z2+DY,DX, pointOfLine.l.z2+DY);
   Line( Canvas, pointOfLine.l.z1+DX, DY,pointOfLine.l.z1+DX, dy2);
   Line( Canvas, pointOfLine.l.z2+DX, DY,pointOfLine.l.z2+DX, dy2);
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  )
end;

procedure DrawAndClearDottedLines( Canvas: tCanvas );
var
   i: integer;
begin
   if WasInArea.xy = true then
      DrawDottedLinesXY( Canvas, COLORDotLine )
   else if WasInArea.zy = true then
      DrawDottedLinesZY( Canvas, COLORDotLine )
   else if WasInArea.xz = true then
      DrawDottedLinesXZ( Canvas, ColorDotLine );
   if pointOfLineIsFull( pointOfLine.l ) = true then begin
      DrawDottedLinesXY( Canvas, CWHITE );
      DrawDottedLinesZY( Canvas, CWHITE );
      DrawDottedLinesXZ( Canvas, CWHITE );
   end;
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
   for i:=1 to s.sp do
      DrawInAreas(s.a[i].l, Canvas);
   Line( Canvas, DX, Dy*0, DX, DY*2 );
   Line( Canvas, DX*0, Dy, DX*2, Dy );
end;

procedure DeleteLines( var deletePoint: tCoordInThreeAreas; Canvas: tCanvas );
begin
    if pointOfLineIsFull( deletePoint.l ) = true then begin
       StateOfPaint( SSOLID, MCOPY, CWHITE, WSTANDARTWidth, Canvas  );
       DrawInAreas( deletePoint.l, Canvas );
       InitPointOfLine( deletePoint );
    end;
    StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  )
end;

procedure SelectLineInXY( x, y: integer; Canvas: tCanvas );
var
   i, j: Integer;
   dmin, d: Real;
begin
   if ( delLine.l.x1=-1 ) and ( delLine.l.y1=-1 ) then begin
      dmin:= 10000;
      j:=1;
      for i:=1 to s.sp do begin
         d:=distance( x, y, s.a[i].l.x1, s.a[i].l.y1,
                            s.a[i].l.x2, s.a[i].l.y2 );
         if dmin>d then begin
            dmin:=d;
            j:=i;
         end;
      end;
      delLine.l.x1:= s.a[j].l.x1; delLine.l.x2:= s.a[j].l.x2;
      delLine.l.y1:= s.a[j].l.y1; delLine.l.y2:= s.a[j].l.y2;
      for i:= 1 to s.sp do
         if FindLinesWithError( delLine.l.x1, delLine.l.x2,
                                delLine.l.y1, delLine.l.y2,
                                s.a[i].l.x1, s.a[i].l.x2,
                                s.a[i].l.y1, s.a[i].l.y2 )
         then
            Push( selS, s.a[i] );
      countOfClickForSelLine:= countOfClickForSelLine + 1 ;
      StateOfPaint( SSOLID, MCOPY, CRED, WSTANDARTWidth, Canvas  );
      for i:=1 to selS.sp do
         DrawInAreas( selS.a[i].l,Canvas );
      end
   else
      if (( delLine.l.x1=-1 ) and ( delLine.l.z1<>-1 )) or
         (( delLine.l.y1=-1 ) and ( delLine.l.z1<>-1 ))
      then begin
         dmin:= 10000;
         for i:=1 to selS.sp do begin
            d:=distance( x, y, selS.a[i].l.x1, selS.a[i].l.y1,
                               selS.a[i].l.x2, selS.a[i].l.y2 );
            if dmin>d then begin
               dmin:=d;
               j:=i;
            end;
         end;
         StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
         for i:=1 to selS.sp do
            DrawInAreas( selS.a[i].l,Canvas );
         StateOfPaint( SSOLID, MCOPY, CAQUA, WSTANDARTWidth, Canvas  );
         DrawInAreas( selS.a[j].l,Canvas );
         ChekedLine.l:= selS.a[j].l;
         ChekedLine.Delete:= true;
         countOfClickForSelLine:= countOfClickForSelLine+1;
      end
end;

procedure SelectLineInZY( x, y: integer; Canvas: tCanvas );
var
   i, j: Integer;
   dmin, d: Real;
begin
   if ( delLine.l.z1=-1 ) and ( delLine.l.y1=-1 ) then begin
      dmin:= 10000;
      j:=1;
      for i:=1 to s.sp do begin
         d:=distance( x, y, s.a[i].l.z1+DX, s.a[i].l.y1,
                            s.a[i].l.z2+DX, s.a[i].l.y2 );
         if dmin>d then begin
            dmin:=d;
            j:=i;
         end;
      end;
      delLine.l.z1:= s.a[j].l.z1; delLine.l.z2:= s.a[j].l.z2;
      delLine.l.y1:= s.a[j].l.y1; delLine.l.y2:= s.a[j].l.y2;
      for i:= 1 to s.sp do
         if FindLinesWithError( delLine.l.z1, delLine.l.z2,
                                delLine.l.y1, delLine.l.y2,
                                s.a[i].l.z1, s.a[i].l.z2,
                                s.a[i].l.y1, s.a[i].l.y2 )
         then
            Push( selS, s.a[i] );
      countOfClickForSelLine:= countOfClickForSelLine + 1;
      StateOfPaint( SSOLID, MCOPY, CRED, WSTANDARTWidth, Canvas  );
      for i:=1 to selS.sp do
         DrawInAreas( selS.a[i].l,Canvas );
      end
   else if (( delLine.l.z1=-1 ) and ( delLine.l.x1<>-1 )) or
           (( delLine.l.y1=-1 ) and ( delLine.l.x1<>-1 ))
        then begin
           dmin:= 10000;
           for i:=1 to selS.sp do begin
              d:=distance( x, y, selS.a[i].l.z1+DX, selS.a[i].l.y1,
                                 selS.a[i].l.z2+DX, selS.a[i].l.y2 );
              if dmin>d then begin
                 dmin:=d;
                 j:=i;
              end;
           end;
           StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
           for i:=1 to selS.sp do
               DrawInAreas( selS.a[i].l,Canvas );
           StateOfPaint( SSOLID, MCOPY, CAQUA, WSTANDARTWidth, Canvas  );
           DrawInAreas( selS.a[j].l,Canvas );
           ChekedLine.l:= selS.a[j].l;
           ChekedLine.Delete:= true;
           countOfClickForSelLine:= countOfClickForSelLine+1;
        end;
end;

procedure SelectLineInXZ( x, y: integer; Canvas: tCanvas );
var
   i, j: Integer;
   dmin, d: Real;
begin
   if ( delLine.l.x1=-1 ) and ( delLine.l.z1=-1 ) then begin
      dmin:=10000;
      j:=1;
      for i:=1 to s.sp do begin
         d:= distance( x, y, s.a[i].l.x1, s.a[i].l.z1+DY,
                             s.a[i].l.x2, s.a[i].l.z2+DY );
         if dmin>d then begin
            dmin:=d;
            j:=i;
         end;
      end;
      delLine.l.x1:= s.a[j].l.x1; delLine.l.x2:= s.a[j].l.x2;
      delLine.l.z1:= s.a[j].l.z1; delLine.l.z2:= s.a[j].l.z2;
      for i:= 1 to s.sp do
         if FindLinesWithError( delLine.l.x1, delLine.l.x2,
                                delLine.l.z1, delLine.l.z2,
                                s.a[i].l.x1, s.a[i].l.x2,
                                s.a[i].l.z1, s.a[i].l.z2)
         then
            Push( selS, s.a[i] );
      countOfClickForSelLine:= countOfClickForSelLine+1;
      StateOfPaint( SSOLID, MCOPY, CRED, WSTANDARTWidth, Canvas  );
      for i:=1 to selS.sp do
         DrawInAreas( selS.a[i].l,Canvas );
      end
   else
      if (( delLine.l.x1=-1 ) and ( delLine.l.y1<>-1 )) or
         (( delLine.l.z1=-1 ) and ( delLine.l.y1<>-1 ))
      then begin
         dmin:= 10000;
         for i:=1 to selS.sp do begin
            d:=distance( x, y, selS.a[i].l.x1, selS.a[i].l.z1+DY,
                               selS.a[i].l.x2, selS.a[i].l.z2+DY );
            if dmin>d then begin
               dmin:=d;
               j:=i;
            end;
         end;
         StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
         for i:=1 to selS.sp do
              DrawInAreas( selS.a[i].l,Canvas );
         StateOfPaint( SSOLID, MCOPY, CAQUA, WSTANDARTWidth, Canvas  );
         DrawInAreas( selS.a[j].l,Canvas );
         ChekedLine.l:= selS.a[j].l;
         ChekedLine.Delete:= true;
         countOfClickForSelLine:= countOfClickForSelLine+1;
      end;
end;

procedure SelectLine( x, y: integer; var s :tStack; Canvas: tCanvas );
var
    i: Integer;

begin
   if countOfClickForSelLine <= 1 then  begin
      if ( x<DX ) and ( y<DY ) then
         SelectLineInXY( x, y, Canvas )
      else if ( x>DX ) and ( y<DY ) then
         SelectLineInZY( x, y, Canvas )
      else if ( x<DX ) and ( y>DY ) then
         SelectLineInXZ( x, y, Canvas ) ;
      end
   else if countOfClickForSelLine = 2 then begin
      StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  ) ;
      for i:=1 to s.sp do
         DrawInAreas( s.a[i].l, Canvas);
      InitChekedLine( ChekedLine );
      InitPointOfLine ( DelLine );
      InitStack( selS );
      countOfClickForSelLine:= 0;
   end;
end;

procedure TMainForm.FormMouseDown( Sender: TObject; Button: TMouseButton;
                                  Shift: TShiftState; x, y: Integer );
begin
   if Button = mbRight then
      SelectLine( x, y, s, Canvas )
   else if Button = mbLeft then begin
      Canvas.Pen.Mode:= pmNotXor;
      startX:= x;
      startY:= y;
      oldX:= x;
      oldY:= y;
      dragging:= true;
   end;
end;

procedure LineAndSaveCoord( startX, startY, x, y: Integer;
                            var oldX, oldY: Integer; Canvas: tCanvas );
begin
   Line( Canvas, startX, startY, x, y );
   oldX:= x;
   oldY:= y;
end;

procedure TMainForm.FormMouseMove( Sender: TObject; Shift: TShiftState;
                                   x,y: Integer );
var
   i: integer;
begin
   if dragging = false then
      exit;

   StateOfPaint( SSOLID, MCOPY, CWHITE, WSTANDARTWidth, Canvas  );
   Line( Canvas, startX, startY, oldX, oldY );
   StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );

   if InAreaXY( startX, startY ) and ( not WasInArea.xy ) then begin
      CoordInFirstArea( startX, startY, x, y );
      LineAndSaveCoord( startX, startY, x, y, oldX, oldY, Canvas );
      for i:=1 to s.sp do
         Line( Canvas, s.a[i].l.x1, s.a[i].l.y1, s.a[i].l.x2, s.a[i].l.y2 );
      DrawAndClearDottedLines( Canvas );
      end
   else if InAreaZY( startX, startY )and (not WasInArea.zy) then begin
      CoordInSecondArea( startX, startY, x, y );
      LineAndSaveCoord( startX, startY, x, y, oldX, oldY, Canvas );
      for i:=1 to s.sp do
         Line( Canvas, s.a[i].l.z1+DX, s.a[i].l.y1,
                       s.a[i].l.z2+DX, s.a[i].l.y2 );
      DrawAndClearDottedLines( Canvas );
      end
   else if InAreaXZ( startX, startY ) and ( not WasInArea.xz ) then begin
      CoordInThirdArea( startX, startY, x, y );
      LineAndSaveCoord( startX, startY, x, y, oldX, oldY, Canvas );
      for i:=1 to s.sp do
         Line( Canvas, s.a[i].l.x1, s.a[i].l.z1+DY,
                       s.a[i].l.x2, s.a[i].l.z2+DY );
      DrawAndClearDottedLines( Canvas );
   end;
end;

procedure TMainForm.FormMouseUp( Sender: TObject; Button: TMouseButton;
Shift: TShiftState; x, y: Integer );
begin
   if Button = mbLeft then begin
       dragging:= false ;

      if InAreaXY( StartX, StartY ) and ( not WasInArea.xy )
       then begin
          CoordInFirstArea( startX, startY, x, y );
          if pointOfLine.l.x1=-1 then begin
             pointOfLine.l.x1:= startX;
             pointOfLine.l.x2:= x;
             end;
          if pointOfLine.l.y1=-1 then begin
             pointOfLine.l.y1:= startY;
             pointOfLine.l.y2:= y;
             end;
          if not wasInArea.xy then begin
             Canvas.Pen.Mode:= pmNotCopy;
             Line( Canvas, startX, startY, x, y );
             StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
             wasInArea.xy:= true;
             DrawAndClearDottedLines( Canvas );
             Line( Canvas, pointOfLine.l.x1, pointOfLine.l.y1,
                           pointOfLine.l.x2, pointOfLine.l.y2 );
             DrawFrame(0, DY+1, DX-1, 2*DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(DX+1, dy2, 2*DX-1, DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(DX+1, DY+3, 2*DX-1, 2*DY+15, COLOR3DFrame, Canvas);
          end;
          end
      else if InAreaZY( startX, startY ) and ( not WasInArea.zy ) then begin
          CoordInSecondArea( startX, startY, x, y );
          if pointOfLine.l.z1=-1 then begin
             pointOfLine.l.z1:= startX - DX;
             pointOfLine.l.z2:= x - DX;
             end;
          if pointOfLine.l.y1=-1 then begin
             pointOfLine.l.y1:= startY;
             pointOfLine.l.y2:= y;
             end;
          if not wasInArea.zy then begin
             Canvas.Pen.Mode:= pmNotCopy;
             Line( Canvas, startX, startY, x, y );
             StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
             wasInArea.zy:= true;
             DrawAndClearDottedLines( Canvas );
             Line( Canvas, pointOfLine.l.z1+DX, pointOfLine.l.y1,
                           pointOfLine.l.z2+DX, pointOfLine.l.y2 );
             DrawFrame(0, dy2, DX-1, DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(0, DY+1, DX-1, 2*DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(DX+1, DY+3, 2*DX-1, 2*DY+15, COLOR3DFrame, Canvas);
          end;
          end
      else if InAreaXZ( startX, startY ) and ( not WasInArea.xz ) then begin
          CoordInThirdArea( startX, startY, x, y );
          if pointOfLine.l.x1=-1 then begin
             pointOfLine.l.x1:= startX;
             pointOfLine.l.x2:= x;
             end;
          if pointOfLine.l.z1=-1 then begin
             pointOfLine.l.z1:= startY - DY;
             pointOfLine.l.z2:= y - DY;
             end;
          if not wasInArea.xz then begin
             Canvas.Pen.Mode:= pmNotCopy;
             Line( Canvas, startX, startY, x, y );
             StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
             wasInArea.xz:= true;
             DrawAndClearDottedLines( Canvas );
              Line( Canvas, pointOfLine.l.x1, pointOfLine.l.z1+Dy,
                           pointOfLine.l.x2, pointOfLine.l.z2+DY );
             DrawFrame(0, dy2, DX-1, DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(DX+1, dy2, 2*DX-1, DY-1, COLORExcretoryFrame, Canvas);
             DrawFrame(DX+1, DY+3, 2*DX-1, 2*DY+15, COLOR3DFrame, Canvas);
         end;
      end;
      if pointOfLineIsFull( pointOfLine.l) = true then begin
          Push( s, pointOfLine );
          DrawInAreas( pointOfLine.l, Canvas );
          InitPointOfLine( pointOfLine );
          InitBool( wasInArea );
          DrawFrame( 0, dy2, DX-1, DY-1, CWHITE, Canvas);
          DrawFrame( 0, DY+1, DX-1, 2*DY-1, CWHITE, Canvas);
          DrawFrame( DX+1, dy2, 2*DX-1, DY-1, CWHITE, Canvas);
      end;
   end;
end;

procedure TMainForm.FormPaint( Sender: TObject );
begin
  // StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidthOFFrame, Canvas  );
   Line( Canvas, DX, Dy*0, DX, DY*2 );
   Line( Canvas, DX*0, Dy, DX*2, Dy );
   DrawFrame( DX+2, DY+3, 2*DX-1, 2*DY+1, COLOR3DFrame, Canvas);
   StateOfPaint( SSOLID, MCOPY, CBLACK, 1, Canvas  ) ;
   Line2 ( Canvas, Shift div 2,dy2+Shift div 2,30,dy2+Shift div 2 );
   Canvas.TextOut( 30,dy2-5,'x');
   Line2 ( Canvas, Shift div 2,dy2+Shift div 2,Shift div 2, 60 );
   Canvas.TextOut( Shift div 2-5,dy2+33,'y');

   Line2 ( Canvas, DX + Shift div 2,dy2+Shift div 2,DX + 30,dy2+Shift div 2 );
   Canvas.TextOut( DX+30,dy2-5,'z');
   Line2 ( Canvas,  DX+ Shift div 2,dy2+Shift div 2,DX + Shift div 2, 60 );
   Canvas.TextOut( DX+Shift div 2-5,dy2+33,'y');

   Line2 ( Canvas, Shift div 2,dy+Shift div 2,30,dy+Shift div 2 );
   Canvas.TextOut( 30,dy-3,'x');
   Line2 ( Canvas, Shift div 2,dy+Shift div 2,Shift div 2, DY+ 30 );
   Canvas.TextOut( Shift div 2-5, dy+25+shift div 2,'z');


   Line2 ( Canvas, Shift div 2+DX,dy+Shift div 2,DX+30,dy+Shift div 2 );
   Canvas.TextOut( DX+30,dy-3,'x');
   Line2 ( Canvas, DX+Shift div 2,dy+Shift div 2,DX+Shift div 2, DY+ 30 );
   Canvas.TextOut( DX+Shift div 2-5, dy+25+shift div 2,'y');

   Line2 ( Canvas, Shift div 2+DX,dy+Shift div 2,DX+15,DY+ 15);
   Canvas.TextOut( DX+15,dy+10,'z');

 {  x1 := p.x1+ round( p.z1 / 2.828);
   y1 := p.y1+ round( p.z1 / 2.828);
   x2 :=  p.x2+ round( p.z2 / 2.828);
   y2 := p.y2+ round( p.z2 / 2.828);
}end;

procedure TMainForm.BackClick( Sender: TObject );
var
   i: integer;
begin
   if NotEmpty( s )=true then begin
      Pop( s, deletePoint );
      DeleteLines( deletePoint, Canvas );
      StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  );
      for i:=1 to s.sp do
         DrawInAreas(s.a[i].l, Canvas);
   end;
end;

procedure TMainForm.CloseProgramClick(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.SpeedButton1Click( Sender: TObject );
var
   i, j: integer;
begin

   if ChekedLine.Delete = true then begin
      for i:= 1 to s.sp do begin
             if ( ChekedLine.l.x1=s.a[i].l.x1 )
                 and ( ChekedLine.l.y1=s.a[i].l.y1 )
                 and (ChekedLine.l.z1=s.a[i].l.z1 )
             then
                 ChekedLine.number:= i;
          end;
      StateOfPaint( SSOLID, MCOPY, CWHITE, WSTANDARTWidth, Canvas  ) ;
      DrawInAreas( ChekedLine.l, Canvas );
      for j:= ChekedLine.number to s.sp do
         s.a[j]:= s.a[j+1] ;
      s.sp:= s.sp - 1;
      StateOfPaint( SSOLID, MCOPY, CBLACK, WSTANDARTWidth, Canvas  ) ;
      for i:=1 to s.sp do
         DrawInAreas( s.a[i].l, Canvas);
      InitChekedLine( ChekedLine );
      InitPointOfLine ( DelLine );
      InitStack( selS );
      countOfClickForSelLine:= 0;
   end;
end;

end.







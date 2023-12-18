unit FMX.UCEMailForm_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TUCEMailForm = class(TForm)
    img: TImage;
    lbStatus: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UCEMailForm: TUCEMailForm;

implementation

{$R *.fmx}

end.

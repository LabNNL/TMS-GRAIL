function write_TMS_excel(T,filepath)

%{
Writes T to an .xlsx file and, via Excel COM automation, freezes the
header row and colour-codes the error columns with fixed thresholds.

TargetError: <=3 mm green, 3-5 mm orange, >5 mm red.
AngularError and TwistError: <=10° green, 10-15° orange, >15° red.
%}

filepath=char(filepath);
[~,~,ext]=fileparts(filepath);
if ~strcmpi(ext,'.xlsx')
    error('write_TMS_excel:badExtension','filepath must end in .xlsx, got : %s',filepath);
end
if exist(filepath,'file')
    delete(filepath);
end
writetable(T,filepath);

nRows=height(T);
nCols=width(T);
varNames=T.Properties.VariableNames;

green=rgb2ole(99,190,123);
orange=rgb2ole(255,192,0);
red=rgb2ole(248,105,107);

% name, green_max, red_min, signed
thresholds={
    "TargetError",  3, 5,  false;
    "AngularError", 10,15, false;
    "TwistError",   10,15, true;
    };

excel=actxserver('Excel.Application');
excel.Visible=false;
excel.DisplayAlerts=false;

try
    wb=excel.Workbooks.Open(filepath);
    ws=wb.Sheets.Item(1);

    ws.Range(sprintf('A1:%s1',col_letter(nCols))).Font.Bold=true;
    ws.Range('A2').Select;
    excel.ActiveWindow.FreezePanes=true;
    ws.Columns.AutoFit;
    time_col_idx=find(strcmp(varNames,"Time"));
    for c=1:nCols
        if c==time_col_idx
            continue
        end
        col=ws.Columns.Item(c);
        col.ColumnWidth=col.ColumnWidth+3;
    end

    if ~isempty(time_col_idx)
        letter=col_letter(time_col_idx);
        ws.Range(sprintf('%s2:%s%d',letter,letter,nRows+1)).NumberFormat='hh:mm:ss';
        ws.Columns.Item(time_col_idx).AutoFit;
    end

    for i=1:size(thresholds,1)
        col_idx=find(strcmp(varNames,thresholds{i,1}));
        if isempty(col_idx)
            continue
        end
        letter=col_letter(col_idx);
        rng=ws.Range(sprintf('%s2:%s%d',letter,letter,nRows+1));
        anchor=sprintf('%s2',letter);
        set_error_colors(rng,anchor,thresholds{i,2},thresholds{i,3},thresholds{i,4},green,orange,red);
    end

    wb.Save;
    wb.Close(false);
    excel.Quit;
    delete(excel);
catch ME
    if exist('wb','var')
        wb.Close(false);
    end
    excel.Quit;
    delete(excel);
    rethrow(ME);
end

end

function set_error_colors(rng,anchor,green_max,red_min,signed,green,orange,red)
xlCellValue=1;
xlExpression=2;
xlBetween=1;
xlGreater=5;
xlLessEqual=8;

if signed
    xlEqual=3;
    fc=rng.FormatConditions.Add(xlExpression,xlEqual,sprintf('=ABS(%s)<=%g',anchor,green_max));
    fc.Interior.Color=green;

    fc=rng.FormatConditions.Add(xlExpression,xlEqual,sprintf('=(ABS(%s)>%g)*(ABS(%s)<=%g)=1',anchor,green_max,anchor,red_min));
    fc.Interior.Color=orange;

    fc=rng.FormatConditions.Add(xlExpression,xlEqual,sprintf('=ABS(%s)>%g',anchor,red_min));
    fc.Interior.Color=red;
else
    fc=rng.FormatConditions.Add(xlCellValue,xlLessEqual,num2str(green_max));
    fc.Interior.Color=green;

    fc=rng.FormatConditions.Add(xlCellValue,xlBetween,num2str(green_max),num2str(red_min));
    fc.Interior.Color=orange;

    fc=rng.FormatConditions.Add(xlCellValue,xlGreater,num2str(red_min));
    fc.Interior.Color=red;
end
end

function v=rgb2ole(r,g,b)
v=r+g*256+b*65536;
end

function s=col_letter(idx)
s='';
while idx>0
    rem=mod(idx-1,26);
    s=[char(65+rem),s]; %#ok<AGROW>
    idx=floor((idx-1)/26);
end
end

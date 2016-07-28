function cell2latex(filename,cell_arr,with_title,with_color,big_title)
%CELL2LATEX Cell array to latex file.
%Writes a cell array of strings or numerics to a latex file.
%
% Syntax: cell2latex(filename,cell_arr,with_title,with_color,big_title)
%
% Inputs:
%   filename      output filename [string]
%   cell_arr      cell array to be written [cell]
%   with_title    [optional] 0        do nothing (default)
%                            1        add an hline below the first line
%   with_color    [optional] defines a background color for every odd line
%                            ''       do nothing (default)
%                            'color'  apply the given latex color
%   big_title     add a title to the document
%
% Outputs:
%   (none)

% check inputs
if(nargin<2)
    disp('Error - You must specify an output filename and a cell array!');
    return;
end
if(~ischar(filename))
    disp('Error - file should be a string !');
    return;
end
isnumber=cellfun(@isnumeric,cell_arr);
isstring=cellfun(@ischar,cell_arr);
if(~all(isnumber|isstring))
    disp('Error - cell_arr does not contain only string or numerics !');
    return;
end

if(nargin==2),  with_title=0;  with_color='';end
if(nargin==3),  with_color='';end

[nrows,ncols]=size(cell_arr);
if(~isempty(with_color))
    cmd=['\rowcolor{' with_color '}'];
    colorcell=cell(nrows,1);
    colorcell(1:2:end)={''};
    colorcell(2:2:end)={cmd};
    cell_arr(:,1)=strcat(colorcell,...
        cellfun(@num2str,cell_arr(:,1), 'UniformOutput',0));
end

tableformat=[repmat(...
    sprintf('|p{%2.3f\\linewidth}',(.8/ncols)),1,ncols) '|'];

% write latex file
outfile = fopen(filename,'w');
% packages
fprintf(outfile,'\\documentclass{article}\r\n');
fprintf(outfile,'\\usepackage[T1]{fontenc}\r\n');
fprintf(outfile,'\\usepackage[utf8]{inputenc}\r\n');
fprintf(outfile,'\\usepackage{longtable}\r\n');
fprintf(outfile,'\\usepackage [table]{xcolor}\r\n');
fprintf(outfile,'\\usepackage{fullpage}\r\n');
% margins
fprintf(outfile,'\\setlength{\\voffset}{-0.5cm}\r\n');
fprintf(outfile,'\\setlength{\\textheight}{24cm}\r\n');
fprintf(outfile,'\\setlength{\\footskip}{0cm}\r\n');
% begin document and print title (if any)
if(nargin==5)
    fprintf(outfile,'\\title{%s}\r\n',big_title);
    fprintf(outfile,'\\begin{document}\r\n');
    fprintf(outfile,'\\maketitle\r\n');
else
    fprintf(outfile,'\\begin{document}\r\n');
end
% dump table
fprintf(outfile,'\\begin{longtable}{%s}\r\n',tableformat);
fprintf(outfile,'\\hline\r\n');
fclose(outfile);
if(with_title)
    dlmcell(filename,cell_arr(1,:),' & ','a','\\\\');
    outfile = fopen(filename,'a');
    fprintf(outfile,'\\hline\r\n');
    fprintf(outfile,'\\endhead\r\n');
    fprintf(outfile,'\\hline\r\n');
    fprintf(outfile,'\\endfoot\r\n');
    fclose(outfile);
    dlmcell(filename,cell_arr(2:end,:),' & ','a','\\\\');
else
    outfile = fopen(filename,'a');
    fprintf(outfile,'\\endhead\r\n');
    fprintf(outfile,'\\hline\r\n');
    fprintf(outfile,'\\endfoot\r\n');
    fclose(outfile);
    dlmcell(filename,cell_arr,' & ','a','\\\\');
end
outfile = fopen(filename,'a');
fprintf(outfile,'\\end{longtable}\r\n');
fprintf(outfile,'\\end{document}\r\n');
fclose(outfile);

end

function DAIS_json_write(txt,fn)
% SL_json_write - write json file
% On input:
%     txt (string): text to save as json
%     fn (string): name of json file
% On output:
%     writes file named fn
% Call:
%     SL_json_write(txt,'r1');
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

fid = fopen(fn,"w");
fprintf(fid,"%s",txt);
fclose(fid);

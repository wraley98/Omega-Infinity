function txt = SL_json_encode(x)
% SL_json_encode - encode struct as json
% On input:
%     x (struct): struct to encode
% On output:
%     txt (string): json encoding of x
% Call:
%     txt = SL_json_encode(airways);
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

txt = jsonencode(x,PrettyPrint=true);
txt = regexprep(txt,',\s+(?=\d)',','); % , white-spaces digit
txt = regexprep(txt,',\s+(?=-)',','); % , white-spaces minussign
txt = regexprep(txt,'[\s+(?=\d)','['); % [ white-spaces digit
txt = regexprep(txt,'[\s+(?=-)','['); % [ white-spaces minussign
txt = regexprep(txt,'(?<=\d)\s+]',']'); % digit white-spaces ]


function x = SL_json_decode(json)
% SL_json_decode - decode from json to string
% On input:
%     json(json struct): json info
% On output:
%     x (string): decoded text
% Call:
%     x = SL_json_decode(j);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

x = jsondecode(json);

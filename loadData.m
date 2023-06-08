%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function sends a friction map to the TPaD
% note: you will need to connect to the TPaD separately for this to work
%
% Inputs:  port = name & info of open port, needed for PIC communication
%          DCfriction = a number, usually = 2^15
%          gradient = vector 19200 long 
%          roughness = vector 19200 long 
%
% Outputs: result = 'true' or 'false', depending if load was successful
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result] = loadData(port,DCfriction,gradient,roughness)

%% make sure DCfriction & roughness values are within accepted range
if DCfriction > 2^16-1; DCfriction = 2^16-1; end
if DCfriction < 0;      DCfriction = 0;      end

idx = find(roughness > 2^16-1 - DCfriction);
if ~isempty(idx); roughness(idx) = 2^16-1 - DCfriction; end

idx = find(roughness < 0 - DCfriction);
if ~isempty(idx); roughness(idx) = 0 - DCfriction; end

%% send data

%Tell TPaD I'm about to send it data
fwrite(port,'S');

%send DCfriction
bytes = fliplr(typecast(int16(DCfriction),'uint8'));
fwrite(port,bytes);

%send gradient array
chunk = 256; k=1;
for i=1:length(gradient)/chunk
    bytes = [];
    for j=1:chunk
        bytes = [bytes fliplr(typecast(int16(gradient(k)),'uint8'))];
        k=k+1;
    end
    fwrite(port,bytes);
end

%send roughness array
chunk = 256; k=1;
for i=1:length(roughness)/chunk
    bytes = [];
    for j=1:chunk
        bytes = [bytes fliplr(typecast(int16(roughness(k)),'uint8'))];
        k=k+1;
    end
    fwrite(port,bytes);
end

%line feed
fwrite(port,char(10));

%% receive data

%TPaD should respond 'F' if finished
response = char(fread(port,1));
if response == 'F'
    result = 'true';
else
    result = 'false';
end

flushinput(port);

end

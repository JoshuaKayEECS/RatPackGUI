function [nSamples, connected] = SerialDataSetup(mySerial,pulse_frequency,num_pulse,tx_en_delay,reset_delay,pMode)
% 
% delays = [1,3,5,7,9,11,15];
% pulse_frequency = 1800000;
% num_pulse = 5;
% tx_en_delay = 8000;
% reset_delay = 10000;


%%
startCommand = uint32(1);
parametersCommand = uint32(8);
samplesCommand = uint32(3);
gotIt = 0;
terminator = 13;
connected = 0;
nSamples = 0;

%Establish connection with Device


tic;
while(gotIt ~= 1)
     if(mySerial.bytesAvailable() > 0)
         gotIt = uint32(fread(mySerial,1,'uint32'));
         disp(['gotIt = ',num2str(gotIt)]);
     end
    sTime = toc;
    if(sTime > 10)
        disp('No Response Don''t Continue!!!');
        return;
    end
     pause(0.1);
 end



fwrite(mySerial,startCommand,'uint32');



% Send Parameters
% and wait until confirmation of received parameters
N_Parameters = 13;
parameters = zeros(1,N_Parameters);
delays = [1,3,5,7,9,11,15];
parameters(1:7) = delays;
parameters(8) = pulse_frequency;
parameters(9) = num_pulse;
parameters(10) = tx_en_delay;
parameters(11) = reset_delay;
parameters(12) = pMode;
parameters(13) = parametersCommand;
paraemeters = uint32(parameters);

%gotIt = 0;
i = 1;
while(i < N_Parameters+1)
        fwrite(mySerial,parameters(i),'uint32');
        %fprintf('Paramters\n');
        %fprintf('%i\n',parameters(i));
        i = i+1;
    pause(0.1);
end

nSamples = 0;
tic;
%Establish connection with Device


while(1)
    if(mySerial.bytesAvailable() > 0)
        rx = uint32(fread(mySerial,1,'uint32'));
        disp(['rx: ',num2str(rx)]);
        
        if(rx ~=1 )
            nSamples = rx;
            connected = 1;
            disp(['NSamples: ',num2str(nSamples)]);
            break;
        end
    end
    sTime = toc;
    if(sTime > 10)
        disp('No Response Don''t Continue!!!');
        break;
    end
        
    pause(0.1);
end

if(connected) 
    fwrite(mySerial,5,'uint32');
else
    fwrite(mySerial,5,'uint32');
end

end

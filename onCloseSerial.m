function [ output_args ] = onCloseSerial(mySerial)

    if exist('mySerial')
       flushinput(mySerial); % flush serial port
        fclose(mySerial);
       delete(mySerial);
       clear mySerial;
    end
    delete(instrfindall) % delete all instruments

end
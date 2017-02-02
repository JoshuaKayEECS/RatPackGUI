function closeSerial(mySerial)

    if exist('mySerial')
       flushinput(mySerial); % flush serial port
      fclose(mySerial);
    end
    delete(instrfindall) % delete all instruments
    figHandles = findall(0,'Type','figure');
    for n = 1:length(figHandles)
        clf(figHandles(n)) % clear figures, but don't close them
    end

end
using AudioIO

amen = af_open("audio/24940__vexst__the-winstons-amen-brother-full-solo-4-bars-mono.wav");
data = read(amen);
data_pad = vcat(data, zeros(Int16, length(data)%32));
beats = reshape(data_pad, int(length(data_pad)/32), 32);

function drums()
    while true
        for i in 1:16
            play(beats[:, i])
            sleep(0.3)
        end
    end
end

using AudioIO

# adding synth
vox(note::Real) = play(SinOsc(SinOsc(30)*100+note) * LinRamp(1, 0, 0.3) + WhiteNoise() * LinRamp(1, 0, 0.01));

# Using Map to play lists of AudioNodes
ss = [SinOsc(SinOsc(LinRamp(1, fmax, 20))*100 + 440) for fmax in [200, 205, 210, 215, 220]];
map(play, ss);

# Reading Files
amen = af_open("audio/24940__vexst__the-winstons-amen-brother-full-solo-4-bars-mono.wav");
data = read(amen);
play(data);
play(reverse(data));

# beat slicing
data_pad = vcat(data, zeros(Int16, length(data)%32));
beats = reshape(data_pad, int(length(data_pad)/32), 32);

type FuncSeq
    func::Function
    args::Array
    durs::Array
    stopped::Bool

    function FuncSeq(func, args, durs)
        @assert length(args) == length(durs)
        new(func, args, durs, false)
    end
end

function AudioIO.play(seq::FuncSeq)
    @spawn begin
        seq.stopped = false
        while true
            for i in 1:length(seq.durs)
                if seq.stopped
                    return
                end
                seq.func(seq.args[i])
                sleep(seq.durs[i])
            end
        end
    end
end

function AudioIO.stop(seq::FuncSeq)
    seq.stopped = true
end

mtof(note::Real) = 440 * 2^((note - 69)/12);

# playing drums
play_slice(idx::Int) = play(beats[:, idx]);
drumseq = FuncSeq(play_slice, [1:16], ones(16)*0.2);
synth = FuncSeq(vox, map(mtof, [60, 60, 72, 60, 60, 55]), [1, 1, 1, 1, 2, 2] * 0.2)
play(drumseq);
stop(drumseq);

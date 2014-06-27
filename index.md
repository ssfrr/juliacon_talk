% AudioIO.jl
% Spencer Russell; MIT Media Lab
% 2014-06-26

# How I Met Julia

<div class="notes">
* press 's' to pull up speaker notes
* introduced to Julia by Angel Pizarro in June 2012 at Philly Lambda
</div>

---

# Some History

---

# {data-background="images/PatchedCabinets.jpg"}

---

# {data-background="images/max_mathews_L_rosler_graphic1_1967.jpg"}

<div class="notes">
* MUSIC written in 1957 by Max Mathews at Bell Labs
* MUSIC 2-4 also at Bell Labs
* CSound still in wide use today
</div>

---

----------------   ----------
 Csound              Max/MSP
 PureData              ChucK
 SuperCollider      Overtone
----------------   ----------

---

# {data-background="images/maxmsp_tidspace.png"}

---

# {data-background="images/Meta-eX-web.png"}

---

# {data-background="images/Meta-eX-web.png"}

<p id="meta-ex-quote">"Our sound isn't hardcore, breakcore or speedcore - it's
multi-core and fully hyper-threaded."</p>

<div class="notes">
* But what do these systems have in common?
</div>

---

# UGens

---

# Unit Generators

---

# {data-background="images/pd_vcf.png"}

<div class="notes">
* Typically written in a lower-level language
* Who builds these UGens??
</div>

---

* CSound

> * C/C++

---

* Max/MSP, PD

> * C/C++

---

* SuperCollider

> * C++

---

* Clojure (Overtone)

> * C++

<div class="notes">
* I'm sure you're seeing a pattern here
</div>

---

* Julia

> * Julia

---

# {data-background="images/basset1.jpg"}

---

## AudioIO.jl

<div class="notes">
* Contributions from Howard Mao on File I/O
* Joris Kraak for audio Input
</div>
---

# Exported Functions

---

## af_open
## play
## stop

<div class="notes">
* Try to think in terms of conceptual methods
* In python you need different function names or a chain of "isinstance"
* don't add more methods than you have to
</div>

---

    arr = my_synth_alg()::Array{Float32}
    play(arr)

<div class="notes">
* Keeping this sort of use case simple is a big driving factor in AudioIO
* This is playing an array in native sample format
* What about playing an array in a different format?
</div>

---

    arr = my_synth_alg()::Array{Int16}
    play(arr)

<div class="notes">
* what is this wizardry?
* the magic of multiple dispatch!
* let's see how playing a Signed Int array is implemented
</div>

---

    function play{T <: Signed}(arr::Array{T}, args...)
        arr = arr / typemax(T)
        play(arr, args...)
    end

<div class="notes">
* we're just converting to a float array and playing that
* what happens when we play a float array?
</div>

---

    function play(arr::AudioBuf, args...)
        player = ArrayPlayer(arr)
        play(player, args...)
    end

<div class="notes">
* here we start to see some of the meat of AudioIO
* we create AudioNodes and play them
* how to audio nodes get played?
</div>

---

    function play(node::AudioNode)
        global _stream
        if _stream == nothing
            _stream = PortAudioStream()
        end
        play(node, _stream)
    end

<div class="notes">
* a stream is just a render tree and background task
</div>

---

    function play(node::AudioNode, stream::AudioStream)
        push!(stream.root, node)
        return node
    end

<div class="notes">
* here we get to the root of the play function
* we just add it to the render tree and return
* at every render block, N frames will be pulled from the AudioNode
* What other AudioNodes are there?
</div>

---

<div class="bigcode">
    play(SinOsc(440))
</div>

---

<div class="bigcode">
    play(WhiteNoise())
</div>

<div class="notes">
* what is an AudioNode?
</div>

---

# {data-background="images/basset2.jpg"}

---

    type AudioNode{T<:AudioRenderer}
        active::Bool
        end_cond::Condition
        renderer::T
        AudioNode(renderer::AudioRenderer) =
                new(true, Condition(), renderer)
        AudioNode(args...) = AudioNode{T}(T(args...))
    end

<div class="notes">
* this is not the first iteration of this type
* I started with AudioNode being an abstract type
* but then I needed fields!
</div>

---

<div class="dim">
    type AudioNode{T<:AudioRenderer}
</div>
        active::Bool
        end_cond::Condition
<div class="dim">
        renderer::T
        AudioNode(renderer::AudioRenderer) =
                new(true, Condition(), renderer)
        AudioNode(args...) = AudioNode{T}(T(args...))
    end
</div>

---

<div class="dim">
    type AudioNode{T<:AudioRenderer}
        active::Bool
        end_cond::Condition
</div>
        renderer::T
<div class="dim">
        AudioNode(renderer::AudioRenderer) =
                new(true, Condition(), renderer)
        AudioNode(args...) = AudioNode{T}(T(args...))
    end
</div>

---

<div class="dim">
    type AudioNode{T<:AudioRenderer}
        active::Bool
        end_cond::Condition
        renderer::T
</div>
        AudioNode(renderer::AudioRenderer) =
                new(true, Condition(), renderer)
<div class="dim">
        AudioNode(args...) = AudioNode{T}(T(args...))
    end
</div>

---

<div class="dim">
    type AudioNode{T<:AudioRenderer}
        active::Bool
        end_cond::Condition
        renderer::T
        AudioNode(renderer::AudioRenderer) =
                new(true, Condition(), renderer)
</div>
        AudioNode(args...) = AudioNode{T}(T(args...))
<div class="dim">
    end
</div>

---

    type MixRenderer <: AudioRenderer
        inputs::Vector{AudioNode}
        buf::AudioBuf

        MixRenderer(inputs) = new(inputs, AudioSample[])
        MixRenderer() = MixRenderer(AudioNode[])
    end

    typealias AudioMixer AudioNode{MixRenderer}
    export AudioMixer

    function render(node::MixRenderer,
                    device_input::AudioBuf,
                    info::DeviceInfo)
    ...


---

<div class="dim">
    type MixRenderer <: AudioRenderer
</div>
        inputs::Vector{AudioNode}
        buf::AudioBuf
<div class="dim">
        _
        MixRenderer(inputs) = new(inputs, AudioSample[])
        MixRenderer() = MixRenderer(AudioNode[])
    end

    typealias AudioMixer AudioNode{MixRenderer}
    export AudioMixer

    function render(node::MixRenderer,
                    device_input::AudioBuf,
                    info::DeviceInfo)
    ...
</div>

<div class="notes">
* I'm considering having the render function take the output buffer as an arg
* then it would need to return the number of samples copied
</div>

---

<div class="dim">
    type MixRenderer <: AudioRenderer
        inputs::Vector{AudioNode}
        buf::AudioBuf
        _
</div>
        MixRenderer(inputs) = new(inputs, AudioSample[])
        MixRenderer() = MixRenderer(AudioNode[])
<div class="dim">
    end

    typealias AudioMixer AudioNode{MixRenderer}
    export AudioMixer

    function render(node::MixRenderer,
                    device_input::AudioBuf,
                    info::DeviceInfo)
    ...
</div>

---

<div class="dim">
    type MixRenderer <: AudioRenderer
        inputs::Vector{AudioNode}
        buf::AudioBuf

        MixRenderer(inputs) = new(inputs, AudioSample[])
        MixRenderer() = MixRenderer(AudioNode[])
    end
    _
</div>
    typealias AudioMixer AudioNode{MixRenderer}
    export AudioMixer
<div class="dim">
    _
    function render(node::MixRenderer,
                    device_input::AudioBuf,
                    info::DeviceInfo)
    ...
</div>

---

<div class="dim">
    type MixRenderer <: AudioRenderer
        inputs::Vector{AudioNode}
        buf::AudioBuf

        MixRenderer(inputs) = new(inputs, AudioSample[])
        MixRenderer() = MixRenderer(AudioNode[])
    end

    typealias AudioMixer AudioNode{MixRenderer}
    export AudioMixer
    _
</div>
    function render(node::MixRenderer,
                    device_input::AudioBuf,
                    info::DeviceInfo)
    ...

---

<div class="mediumcode">
    SinOsc(440)
</div>

---

<div class="mediumcode">
    SinOsc(SinOsc(2))
</div>

---

<div class="mediumcode">
    SinOsc(SinOsc(2) * 10 + 440)
</div>

---

    type SinOscRenderer{
            T<:Union(Float32, AudioNode)} <: AudioRenderer
        freq::T
        phase::Float32
        buf::AudioBuf
    end

---

    function render(node::SinOscRenderer{Float32},
            device_input::AudioBuf,
            info::DeviceInfo)

---

    function render(node::SinOscRenderer{AudioNode},
            device_input::AudioBuf,
            info::DeviceInfo)

---

# Challenges

<div class="notes">
* garbage Collection
* incgc branch from Oscar Blumberg is awesome! Can't wait for 0.4
* Global variables from the REPL are problematic
</div>

---

# Demo

---

# {data-background="images/manta.jpg"}

---

# {data-background="images/izotope_rx3_denoise.jpg"}

---

# {data-background="images/hrtf_vis.png"}

---

## Future Work
<div class="smalllist">

> * More Nodes!
> * lower latency
> * multi-channel
> * easier install
> * music theory library
> * sequencing abstractions
> * better error handling
> * common utility functions

</div>

* some history
    * Xenakis / Stockhousen / etc.
    * Max Mathews (Bell Labs) / Music-N
    * Csound
    * Max / PD
    * PD
    * ChucK
    * SuperCollider
    * Overtone
* UGens (Unit Generators) / opcodes
    * typically written in C or C++
* type system
    * what I had before
    * common fields
    * subtyping
* features
* efficiency
* applications
    * live coding
        * meta-ex - "Our sound isn't hardcore, breakcore or speedcore - it's multi-core and fully hyper-threaded."
    * electronic music
    * DSP research
    * game audio (sound engine)
* some current nodes
    * SinOsc
    * Gain
* File IO
    * reading
    * writing
* operator overloading
    * +, *
* main methods
    * play
* challenges
    * Garbage Collection!

* Future Work
    * More Nodes! (bandlimited oscillators, filters, etc.)
    * lower latency
    * multi-channel
    * easier install (port shim.c to pure julia)
    * music thoeory library (notes, chords, intervals)
    * sequencing abstractions
    * better error handling (audio task shouldn't crash)

* optimization lessons
    * mathconsts allocate!
    * watch out for type conversions
    * really watch out for globals
    * @allocated gives different results than @time?

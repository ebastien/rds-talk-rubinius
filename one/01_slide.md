!SLIDE
# Rubinius #
## ##
<div class="title_desc">
  <ul>
    <li>Emmanuel Bastien</li>
    <li>Riviera.rb</li>
  </ul>
</div>

!SLIDE
## History ##
* 2006 Evan Phoenix inspired by Smalltalk
* 2007 Engine Yard sponsoring
* 2008 Runs Rails
* 2009 Quiet
* 2010 Release 1.0
* 2012 Release 2.0rc1

!SLIDE
## Architecture ##
* Rubinius VM, JIT and GC (C++ & LLVM)
* Language foundations (Ruby)
* Standard library (Ruby)

!SLIDE
## Key features ##
* Generational garbage collector
* MRI-compatible C extensions API
* No Global Interpreter Lock
* Concurrency: actors, fibers, threads
* Built-in debugger and profiler

!SLIDE
## Demo ##
* [Built-in debugger](https://github.com/ebastien/rds-talk-rubinius/tree/master/demo/bug.rb)
* [Built-in profiler](https://github.com/ebastien/rds-talk-rubinius/tree/master/demo/prof.rb)
* [A minimal viable compiler](https://github.com/ebastien/rds-talk-rubinius/tree/master/demo/scan.rb)

!SLIDE
## Project status ##
* Full support for Ruby 1.8
* Near complete support for 1.9
* Partial support for 2.0

!SLIDE
## Limitations ##
* Too much C++ (?)
* Unclear sponsoring
* JRuby still a tough contender


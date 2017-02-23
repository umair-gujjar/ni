#!/usr/bin/env perl
chomp($ni::license=<<'_');
ni: https://github.com/spencertipping/ni
Copyright (c) 2016-2017 Spencer Tipping

MIT license

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
_
BEGIN{eval($ni::boot=<<'_')}
use strict;
use warnings;
no warnings qw/redefine void/;
no strict 'refs';
use Errno;
use Fcntl;
use POSIX;
use Scalar::Util;
chomp $ni::boot;
$ni::self = bless {named => {}}, 'lib/ni';
sub ni(;$) {@_ ? ref($_[0]) ? $_[0] : $ni::self->resolve($_[0]) : $ni::self}
sub ni::eval {eval shift}
*{'lib/ni::def'} = sub {
  my ($self, %kvs) = @_;
  $$self{named}{$_} = $kvs{$_} for keys %kvs;
};
*{'lib/fn::OVERLOAD'} = {};
*{'lib/fn::(bool'} = sub {1};
*{'lib/fn::()'}    = sub {};
*{'lib/fn::(&{}'} = sub {
  my $self = shift;
  $$self{fn} ||= $self->compile;
};
*{'lib/fn::compile'} = sub {
  my $self = shift;
  my ($en) = ni::eval('__FILE__') =~ /eval (\d+)/;
  $$self{eval_number} = ++$en;
  Scalar::Util::weaken(${'lib/fn::evals'}{$en} = $self);
  $$self{fn} = ni::eval "sub{$$self{code}\n}";
  die "ni:/lib/fn failed to compile $$self{code}: $@\n" if $@;
  $$self{fn};
};
sub fn($);
_
$c=q#named#;$d=q#ni.doc:/class#;$e=q#doc#;$f=q#synopsis#;$g=q#
  ni('ni:/object')->child('/message')
    ->add('/behaviorname.b')          \# add existing behavior
    ->def('/message_init.b',          \# define new slice behavior
      instantiate => fn q{            \# called from ->new()
        my ($class, $message) = @_;
        +{message => $message};       \# return object to be blessed
      })
    ->def('/behaviorname.b',          \# define another behavior
      method1 => fn q{
        my $self = shift;
        print "message for you sir! '" . $$self{message} . "'\\n";
      });
  ni('ni:/child')->new('hello world!')->method1;
#;$h=[$f,$g];$i=q#description#;$j=q#ni:class is at the core of ni's object-oriented system, along with core
classes like ni:object and ni:metaclass. There are two layers of
abstraction involved here: Perl packages are modified by behaviors, and
classes encode the higher-level declarative features you'd expect from a
language like Ruby or Smalltalk. This documentation covers both layers.#;$k=[$i,$j];$l=q#behaviors#;$m=q#ni's objects are blessed Perl references, and behaviors are objects
that modify Perl packages in specific ways. The simplest is
ni:/lib/slice, which represents a set of methods you can add to a
package.#;$n=q#assertions#;$o=[];$p=q#error#;$q=undef;$r=q#outcome#;$s=q#test#;$t=q#annotations#;$u=[];$v=q#closure#;$w=q#code#;$x=q#my $fn = fn q{"hi"};
my $slice = ni('ni:/lib/slice')->new('myslice', f => $fn);
$slice->apply('foo');
now foo->f == 'hi';#;$y=q#proto#;$z=q##;$A=q#lib/fn#;$B=bless({$t,$u,$v,$q,$w,$x,$y,$z},$A);$C=q#lib/test_case#;$D=bless({$n,$o,$p,$q,$r,$q,$s,$B},$C);$E=q#TODO...#;$F=[$l,$m,$D,$E];$G=q#classes#;$H=q#ni implements a Smalltalk 80-style metaclass system with a couple of
differences. First, ni's classes are slice unions and as such don't
support colliding methods; and second, they support multiple inheritance.
These two points are related: method overriding isn't in the picture,
which makes multiple inheritance straightforward to implement.#;$I=[$G,$H,$E];$J=[$h,$k,$F,$I];$K=q#name#;$L=q#/class#;$M=q#lib/doc#;$N=bless({$e,$J,$K,$L},$M);$O=q#my $s = shift; ni->def($s->name, $s)#;$P=bless({$w,$O,$y,$z},$A);$Q=q#ni.doc:/fabric#;$R=q#Abstractions to bridge the gaps between separate machines and processes.
This module is designed to make it appear as though all resources are
local, or at least can be referred to locally -- even when they belong to
an external process (e.g. a Hadoop mapper) or another machine (e.g. a
file over SSH). If we can bidirectionally communicate with a remote ni
instance, then we can see its resources.#;$S=q#The fabric layer consists of a couple of things. First, we've got RMI
support code that proxies any method call and return value(s) over a
full-duplex data channel. Second, we have an async event loop that
handles multiplexed IO using a single thread.#;$T=[$i,$R,$S];$U=[$T];$V=q#/fabric#;$W=bless({$e,$U,$K,$V},$M);$X=q#ni.doc:/fabric/remote#;$Y=q#A local proxy for a remote object. All method calls are converted to RMI
wrappers and return futures of results.#;$Z=[$i,$Y];$c1=[$Z];$d1=q#/fabric/remote#;$e1=bless({$e,$c1,$K,$d1},$M);$f1=q#ni.doc:/fabric/rmi#;$g1=q#An open connection to another ni instance. This module provides the
ability to bootstrap a remote perl interpreter with an async RMI event
loop, and provides options about send/receive data encoding (which is
important for trust/security reasons).#;$h1=q#Method calls are proxied to named objects on the remote, and each one is
sent in a packet that contains the fully-serialized context for the
call.#;$i1=[$i,$g1,$h1];$j1=q#TODO#;$k1=q#The codec stuff is awful. Nothing about a codec is so global that it
should apply to all method calls; maybe a class has a per-method
codec disposition, or maybe we infer the best one by serialization
performance. Either way, global codecs don't make sense here.#;$l1=[$j1,$k1];$m1=[$i1,$l1];$n1=q#/fabric/rmi#;$o1=bless({$e,$m1,$K,$n1},$M);$p1=q#ni.doc:/io#;$q1=q#An implementation of IO in terms of system-level FDs. We need this for a
few reasons, three of them being that (1) old versions of Perl don't
correctly handle interrupted system calls, (2) we want tighter control
over which FDs are closed at what times, and (3) we want to be able to
"unread" things -- push back against the read buffer (or use a custom
read format in general).#;$r1=[$i,$q1];$s1=[$r1];$t1=q#/io#;$u1=bless({$e,$s1,$K,$t1},$M);$v1=q#ni.doc:/io/buffer#;$w1=q#
my $buf = ni("ni:/io/buffer")->new(8192);
$buf->write("foo");
$buf->read($_, 256);        \# reads "foo"#;$x1=[$f,$w1];$y1=q#A bounded, memory-backed FIFO data queue. In IO terms, this object
behaves like a nonblocking socket and sets errno accordingly.#;$z1=[];$A1=[];$B1=q#my $buf = ni('ni:/io/buffer')->new(128);
now [$buf->read_capacity, $buf->write_capacity] == [0, 128];
now $buf->write("foobarbif") == 9;
now [$buf->read_capacity, $buf->write_capacity] == [9, 119];
now [$buf->read($_, 5), $_] == [5, "fooba"];

now $buf->write(" " x 125) == 124;
now $buf->read($_, 120) == 120;
now [$buf->read($_, 100), $_, $buf->read_capacity] == [8, " " x 8, 0];
now [$buf->read($_, 100), 0 + $!] == [undef, Errno::EWOULDBLOCK];#;$C1=bless({$t,$A1,$v,$q,$w,$B1,$y,$z},$A);$D1=bless({$n,$z1,$p,$q,$r,$q,$s,$C1},$C);$E1=[$i,$y1,$D1];$F1=[$x1,$E1];$G1=q#/io/buffer#;$H1=bless({$e,$F1,$K,$G1},$M);$I1=q#ni.doc:/io/cat#;$J1=q#
  my $combined = ni('ni:/io/cat')->new($io1, $io2, ...);
  my $combined = $io1 + $io2 + $io3;
  $combined->into_sync($destination_io);
#;$K1=[$f,$J1];$L1=q#Concatenates multiple IO objects into a single read-only data source.
This is a mutable object that consumes its inputs and then loses its
references to them as quickly as possible, allowing their resources to be
freed. Once fully consumed, the cat object holds no references.#;$M1=[];$N1=[];$O1=q#my $cat = ni('str:foo') + ni('str:bar');
now [$cat->read($_, 16), $_] == [8, "foo\\nbar\\n"];#;$P1=bless({$t,$N1,$v,$q,$w,$O1,$y,$z},$A);$Q1=bless({$n,$M1,$p,$q,$r,$q,$s,$P1},$C);$R1=[$i,$L1,$Q1];$S1=[$K1,$R1];$T1=q#/io/cat#;$U1=bless({$e,$S1,$K,$T1},$M);$V1=q#ni.doc:/io/exec#;$W1=q#
my $pid = ni("ni:/io/exec")->new("ls", "-l")
  ->connect(1 => ni("file:foo")->w)
  ->env(ENV_VAR => "value", ENV2 => "val2")
  ->fork;
$? = $pid->await or die "ls -l failed: $?";#;$X1=[$f,$W1];$Y1=q#An object that represents a fork+exec operation that hasn't yet happened.
It allows you to incrementally specify the context of the process,
including environment variables and file descriptor mappings. It is also
an IO object and will set up pipes to stdin/out if you use it this way.#;$Z1=[];$c2=[];$d2=q#my $e   = ni('ni:/io/exec')->new('echo', 'hi');
my $out = $e->stdout;
my $pid = $e->fork;
now [$out->read_all, $pid->await] == ["hi\\n", 0];#;$e2=bless({$t,$c2,$v,$q,$w,$d2,$y,$z},$A);$f2=bless({$n,$Z1,$p,$q,$r,$q,$s,$e2},$C);$g2=[$i,$Y1,$f2];$h2=[$X1,$g2];$i2=q#/io/exec#;$j2=bless({$e,$h2,$K,$i2},$M);$k2=q#ni.doc:/io/fd#;$l2=q#
  open my $fh, ...;
  my $fd = ni('ni:/io/fd')->new($fh); \# from perl FH
  my $fd = ni('ni:/io/fd')->new(0);   \# from number
  my $fd = ni('fd:0');                \# same thing
  $fd->nonblock(1)->read($_, 100);
  $fd->be(10);                        \# move FD number
#;$m2=[$f,$l2];$n2=q#Represents a file descriptor as a child of /io/object (so the usual IO
methods like into_async are available), and provides some convenience
functions for things like setting up FDs for child processes. FDs are
closed when destroyed.#;$o2=[];$p2=[];$q2=q#my ($r, $w) = POSIX::pipe;
{
  my $fd = ni('ni:/io/fd')->new($r);
}
ni('ni:/io/fd')->new($w)->be($r);   \# fails unless $r was GC-closed#;$r2=bless({$t,$p2,$v,$q,$w,$q2,$y,$z},$A);$s2=bless({$n,$o2,$p,$q,$r,$q,$s,$r2},$C);$t2=[$i,$n2,$s2];$u2=[$m2,$t2];$v2=q#/io/fd#;$w2=bless({$e,$u2,$K,$v2},$M);$x2=q#ni.doc:/io/file#;$y2=q#
  my $f = ni('ni:/io/file')->new('/etc/passwd');
  my $f = ni('file:/etc/passwd');     \# same as above
  $f->into_sync(ni('fd:1'));          \# cat to stdout
#;$z2=[$f,$y2];$A2=q#warning#;$B2=q#Files overload the -X file test operators, but this feature wasn't
introduced until Perl 5.12 -- prior versions won't recognize this
overload. That means that using this overload in ni's base code will
reduce its portability and cause tests to fail.#;$C2=[$A2,$B2];$D2=q#Represents a file that may or may not exist, and stores/constructs file
descriptors for reading/writing. /io/files are one-shot objects: once
you've consumed them for reading or written to them, you should destroy
the object and start over (or close the file) if you want to operate on
the file further -- put differently, /io/file objects own the FDs they
create.#;$E2=[];$F2=[];$G2=q#my $ni = ni('file:/dev/zero');
now [$ni->read($_, 8), $_] == [8, "\\0" x 8];#;$H2=bless({$t,$F2,$v,$q,$w,$G2,$y,$z},$A);$I2=bless({$n,$E2,$p,$q,$r,$q,$s,$H2},$C);$J2=q#File objects also provide some useful functions like atomic-updating.
This lets you write a stream slowly into a tempfile, then rename over the
original once the tempfile is closed. ni uses this to update itself to
avoid race conditions.#;$K2=[];$L2=[];$M2=q#ni('file:tmp1')->write_all("original contents");
{
  my $updater = ni('file:tmp1')->atomic_update;
  $updater->write_all('foo bar');
  now ni('file:tmp1')->read_all == "original contents";
}
now ni('file:tmp1')->read_all == "foo bar";
ni('file:tmp1')->rm;#;$N2=bless({$t,$L2,$v,$q,$w,$M2,$y,$z},$A);$O2=bless({$n,$K2,$p,$q,$r,$q,$s,$N2},$C);$P2=[$i,$D2,$I2,$J2,$O2];$Q2=[$z2,$C2,$P2];$R2=q#/io/file#;$S2=bless({$e,$Q2,$K,$R2},$M);$T2=q#ni.doc:/io/file_update_fd#;$U2=q#A write fd that performs a file rename upon closing.#;$V2=[$i,$U2];$W2=[$V2];$X2=q#/io/file_update_fd#;$Y2=bless({$e,$W2,$K,$X2},$M);$Z2=q#ni.doc:/io/pid#;$c3=q#eg#;$d3=[];$e3=[];$f3=q#now [ni('sh:true')->await, ni('sh:false')->await] == [0, 1 << 8];#;$g3=bless({$t,$e3,$v,$q,$w,$f3,$y,$z},$A);$h3=bless({$n,$d3,$p,$q,$r,$q,$s,$g3},$C);$i3=[$c3,$h3];$j3=[];$k3=[];$l3=q#my $pid = ni('sh:seq 4');
my $data = $pid->read_all;
now [$pid->await, $data] == [0, "1\\n2\\n3\\n4\\n"];#;$m3=bless({$t,$k3,$v,$q,$w,$l3,$y,$z},$A);$n3=bless({$n,$j3,$p,$q,$r,$q,$s,$m3},$C);$o3=[$c3,$n3];$p3=[];$q3=[];$r3=q#my $seq = ni('sh:seq 10');
my $grep = ni('ni:/io/exec')->new('egrep', '[13579]$')
  ->connect(0 => $seq->stdout)
  ->fork;
now [$grep->read_all, $seq->await, $grep->await]
 == ["1\\n3\\n5\\n7\\n9\\n", 0, 0];#;$s3=bless({$t,$q3,$v,$q,$w,$r3,$y,$z},$A);$t3=bless({$n,$p3,$p,$q,$r,$q,$s,$s3},$C);$u3=[$c3,$t3];$v3=[$i3,$o3,$u3];$w3=q#/io/pid#;$x3=bless({$e,$v3,$K,$w3},$M);$y3=q#ni.doc:/lib#;$z3=q#Bootstrapping code for the core abstractions in ni, and almost everything
about its introspection. This includes definitions for documentation,
unit tests, classes, support for basic image generation, etc -- and when
possible, it's written with some awareness of downstream use cases (for
instance, image serialization and RMI share logic).#;$A3=q#/lib is the place where things don't quite work yet, so the code here is
written differently from other modules.#;$B3=[$i,$z3,$A3];$C3=[$B3];$D3=q#/lib#;$E3=bless({$e,$C3,$K,$D3},$M);$F3=q#ni.doc:/lib/doc#;$G3=q#
ni("ni:/some/class")->doc
  ->synopsis(...)
  ->description(...)
  ->eg(...)
  ...#;$H3=[$f,$G3];$I3=q#Associate documentation with the specified class. Documentation is stored
separately and in the "ni.doc" namespace; this way you can serialize
instances of the class and the class's code without bringing along all of
its documentation and unit tests.#;$J3=q#Documentation objects are internally represented as arrays of quoted
method calls:#;$K3=[];$L3=[];$M3=q#my $doc = ni("ni:/lib/doc")->new("foo");
now $doc->{doc} == [];
$doc->foo("bar bif baz");
now $doc->{doc} == [["foo", "bar bif baz"]];#;$N3=bless({$t,$L3,$v,$q,$w,$M3,$y,$z},$A);$O3=bless({$n,$K3,$p,$q,$r,$q,$s,$N3},$C);$P3=q#This documentation can later be compiled into things like manpages,
markdown, or HTML by target-specific conversion functions. Documentation
also stores unit tests, which are specified using "eg":#;$Q3=[];$R3=[];$S3=q#my $doc = ni("ni:/lib/doc")->new("foo");
my $passing_test = q{return 1};
my $failing_test = q{return 0};
$doc->eg($passing_test)
    ->description(q[Foo objects are contrived examples.],
                  eg $failing_test,
                  q[So there.]);
now scalar($doc->tests) == 2;#;$T3=bless({$t,$R3,$v,$q,$w,$S3,$y,$z},$A);$U3=bless({$n,$Q3,$p,$q,$r,$q,$s,$T3},$C);$V3=[$i,$I3,$J3,$O3,$P3,$U3];$W3=[$H3,$V3];$X3=q#/lib/doc#;$Y3=bless({$e,$W3,$K,$X3},$M);$Z3=q#ni.doc:/lib/future#;$c4=q#An expression that doesn't yet exist, but is finalized once it does
exist.#;$d4=[];$e4=[];$f4=q#my $f1 = ni('ni:/lib/future')->new;
my $f2 = $f1->map(fn q{$_[0] + 1});
now [$f1->v, $f2->v] == [undef, undef];
$f1->decide(5);
now [$f1->v, $f2->v] == [5, 6];#;$g4=bless({$t,$e4,$v,$q,$w,$f4,$y,$z},$A);$h4=bless({$n,$d4,$p,$q,$r,$q,$s,$g4},$C);$i4=q#You can combine multiple futures in different ways depending on what
you're trying to do.#;$j4=[];$k4=[];$l4=q#my $f1 = ni('ni:/lib/future')->new;
my $f2 = ni('ni:/lib/future')->new;
my $f3 = $f1->or($f2);
my $f4 = $f1->and($f2);
$f1->decide(1);
now [$f1->v, $f2->v, $f3->v, $f4->v] == [1, undef, 1, undef];
$f2->decide(2);
now [$f1->v, $f2->v, $f3->v, $f4->v] == [1, 2, 1, [1], [2]];#;$m4=bless({$t,$k4,$v,$q,$w,$l4,$y,$z},$A);$n4=bless({$n,$j4,$p,$q,$r,$q,$s,$m4},$C);$o4=[$i,$c4,$h4,$i4,$n4];$p4=[$o4];$q4=q#/lib/future#;$r4=bless({$e,$p4,$K,$q4},$M);$s4=q#ni.doc:/lib/image#;$t4=q#
my $image = ni("ni:/lib/image")->new;
my $gensym = $image->quote($value);
$image->io->into_sync($a_file);#;$u4=[$f,$t4];$v4=q#Generates Perl code that reconstructs the state of objects at the
behavior/slice level. Since classes are self-describing, this results in
a replica of the runtime object-oriented state.#;$w4=[$i,$v4];$x4=[$u4,$w4];$y4=q#/lib/image#;$z4=bless({$e,$x4,$K,$y4},$M);$A4=q#ni.doc:/lib/ni#;$B4=q#my $value = ni->resolve($name);
my $value = ni($name);   \# alias for ni->resolve($name)
my $self  = ni;#;$C4=[$f,$B4];$D4=q#The class for the currently-running ni instance. This includes all
instance state, the table of named objects, and a bit of logic to update
ni in place, for instance when adding extensions.#;$E4=[$i,$D4];$F4=[$C4,$E4];$G4=q#/lib/ni#;$H4=bless({$e,$F4,$K,$G4},$M);$I4=q#ni.doc:/lib/quote_simple#;$J4=q#A stateless object that serializes values with direct quotation; that
is, the serialization contains no variables. If your objects have
circular or shared references, you should probably use
/lib/quote_circular or similar.#;$K4=[];$L4=[];$M4=q#my $q = ni('ni:/lib/quote_simple')->new;
now $q->quote([1,2,3]) == "[1,2,3]";
now $q->quote({foo => 1, bar => [1, 2]}) == "{q\#bar\#,[1,2],q\#foo\#,1}";#;$N4=bless({$t,$L4,$v,$q,$w,$M4,$y,$z},$A);$O4=bless({$n,$K4,$p,$q,$r,$q,$s,$N4},$C);$P4=[$i,$J4,$O4];$Q4=[$P4];$R4=q#/lib/quote_simple#;$S4=bless({$e,$Q4,$K,$R4},$M);$T4=q#ni.doc:/lib/slice#;$U4=q#
ni('ni:/lib/slice')->new('/lib/foo',
  ctor => fn q{shift->say_hi},
  say_hi => fn q{print "hi from " . shift->name . "\\n"});
$some_class->add('/lib/foo');#;$V4=[$f,$U4];$W4=q#A slice of methods encoding some aspect of an object's behavior. Slices
are combined using tags and branches, and the set of slices used to
construct a class must be disjoint except for constructors and
destructors.#;$X4=q#Slices are objects that provide an ->apply method, which installs their
methods + ctors + dtors into a Perl package.#;$Y4=[];$Z4=[];$c5=q#my $slice = ni('ni:/lib/slice')->new('foo1', foo => fn q{"bar"});
$slice->apply('test::foo1');
now bless({}, 'test::foo1')->foo == 'bar';#;$d5=bless({$t,$Z4,$v,$q,$w,$c5,$y,$z},$A);$e5=bless({$n,$Y4,$p,$q,$r,$q,$s,$d5},$C);$f5=q#Slices automatically do the equivalent of using Perl's "overload" module
if any methods begin with an open-paren.#;$g5=q#Classes automatically incorporate some special low-level slices that are
used by others; one of these is /lib/instantiable.b, which implements
->new and ->DESTROY. These methods then call into the lists of
constructors and destructors implemented when slices are added to a
package.#;$h5=[];$i5=[];$j5=q#my $instances = 0;
my $class = ni('ni:/object')->child('test/foo2')
  ->def('test/foo2_init.b',
    instantiate => fn q{+{}},
    ctor => sub {++$instances},
    dtor => sub {--$instances});
now $instances == 0;
{
  my $i1 = $class->new;
  now $instances == 1;
  my $i2 = $class->new;
  now $instances == 2;
}
now $instances == 0;#;$k5=bless({$t,$i5,$v,$q,$w,$j5,$y,$z},$A);$l5=bless({$n,$h5,$p,$q,$r,$q,$s,$k5},$C);$m5=[$i,$W4,$X4,$e5,$f5,$g5,$l5];$n5=[$V4,$m5];$o5=q#/lib/slice#;$p5=bless({$e,$n5,$K,$o5},$M);$q5=q#ni.doc:/semantic#;$r5=q#Opportunities to assign real-world semantics to objects. This is a
collection of behaviors that don't necessarily imply a Perl-level
protocol, but which may end up meaning something at some point.#;$s5=[$i,$r5];$t5=[$s5];$u5=q#/semantic#;$v5=bless({$e,$t5,$K,$u5},$M);$w5=q#ni:/class#;$x5=q#applied_to#;$y5=q#class#;$z5=q#class.c#;$A5=q#fabric/remote.c#;$B5=q#fabric/rmi.c#;$C5=q#io/buffer.c#;$D5=q#io/cat.c#;$E5=q#io/exec.c#;$F5=q#io/fd.c#;$G5=q#io/file.c#;$H5=q#io/file_update_fd.c#;$I5=q#io/null.c#;$J5=q#io/object.c#;$K5=q#io/pid.c#;$L5=q#io/str.c#;$M5=q#io/transfer.c#;$N5=q#io/transfer_async.c#;$O5=q#io/transfer_sync.c#;$P5=q#lib/behavior.c#;$Q5=q#lib/branch.c#;$R5=q#lib/dataslice.c#;$S5=q#lib/doc.c#;$T5=q#lib/fn.c#;$U5=q#lib/future.c#;$V5=q#lib/image.c#;$W5=q#lib/ni.c#;$X5=q#lib/quote_simple.c#;$Y5=q#lib/slice.c#;$Z5=q#lib/tag.c#;$c6=q#lib/test_assert_eq.c#;$d6=q#lib/test_assertion.c#;$e6=q#lib/test_case.c#;$f6=q#lib/test_value.c#;$g6=q#metaclass.c#;$h6=q#module.c#;$i6=q#object.c#;$j6=q#semantic/dimension#;$k6=q#semantic/dimension.c#;$l6=q#semantic/task.c#;$m6={$y5,1,$z5,1,$A5,1,$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1,$M5,1,$N5,1,$O5,1,$P5,1,$Q5,1,$R5,1,$S5,1,$T5,1,$U5,1,$V5,1,$W5,1,$X5,1,$Y5,1,$Z5,1,$c6,1,$d6,1,$e6,1,$f6,1,$g6,1,$h6,1,$i6,1,$j6,1,$k6,1,$l6,1};$n6=q#slices#;$o6=q#metaclass#;$p6=q#module#;$q6={$y5,1,$z5,1,$A5,1,$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1,$M5,1,$N5,1,$O5,1,$P5,1,$Q5,1,$R5,1,$S5,1,$T5,1,$U5,1,$V5,1,$W5,1,$X5,1,$Y5,1,$Z5,1,$c6,1,$d6,1,$e6,1,$f6,1,$o6,1,$g6,1,$p6,1,$h6,1,$i6,1,$j6,1,$k6,1,$l6,1};$r6=q#/module#;$s6=q#/lib/perlbranch.b#;$t6={};$u6=q#ctor#;$v6=q#dtor#;$w6=q#methods#;$x6=q#add#;$y6=q#local $_;
my $self = shift;
my @s = map $self->resolve($_), @_;
push @{$$self{slices}}, @s;
for my $p (sort keys %{$$self{applied_to}}) {$_->apply($p) for @s}
$self;#;$z6=bless({$w,$y6,$y,$z},$A);$A6=q#apply#;$B6=q#local $_;
my ($self, $p) = @_;
$p = $p->package if ref $p;
$$self{applied_to}{$p} = 1;
$_->apply($p) for @{$$self{slices}};
$self;#;$C6=bless({$w,$B6,$y,$z},$A);$D6={$x6,$z6,$A6,$C6};$E6=q#/lib/branch.b#;$F6=q#lib/slice#;$G6=bless({$x5,$t6,$u6,$q,$v6,$q,$w6,$D6,$K,$E6},$F6);$H6=q#lib/branch#;$I6={};$J6=q#$_[0]->namespace . ":" . $_[0]->{name}#;$K6=bless({$w,$J6,$y,$z},$A);$L6={$K,$K6};$M6=q#/lib/named.b#;$N6=bless({$x5,$I6,$u6,$P,$v6,$q,$w6,$L6,$K,$M6},$F6);$O6=q#lib/tag#;$P6={};$Q6=q#namespace#;$R6=q#'ni'#;$S6=bless({$w,$R6,$y,$z},$A);$T6={$Q6,$S6};$U6=q#/lib/named_in_ni.b#;$V6=bless({$x5,$P6,$u6,$q,$v6,$q,$w6,$T6,$K,$U6},$F6);$W6={};$X6=q#package#;$Y6=q#(my $name = shift->{name}) =~ s/^\\///; $name#;$Z6=bless({$w,$Y6,$y,$z},$A);$c7={$X6,$Z6};$d7=q#/lib/namespaced.b#;$e7=bless({$x5,$W6,$u6,$q,$v6,$q,$w6,$c7,$K,$d7},$F6);$f7={};$g7=q#resolve#;$h7=q#ref $_[1] ? $_[1] : ni"ni:$_[1]"#;$i7=bless({$w,$h7,$y,$z},$A);$j7={$g7,$i7};$k7=q#/lib/resolver.b#;$l7=bless({$x5,$f7,$u6,$q,$v6,$q,$w6,$j7,$K,$k7},$F6);$m7=[$G6,$N6,$V6,$e7,$l7];$n7=bless({$K,$s6,$n6,$m7},$O6);$o7={};$p7=q#my $s = shift; $s->apply($s->package)#;$q7=bless({$w,$p7,$y,$z},$A);$r7=q#instantiate#;$s7=q#local $_;
my ($class, $name, @slices) = @_;
+{name   => $name,
  slices => [map $class->resolve($_), @slices]};#;$t7=bless({$w,$s7,$y,$z},$A);$u7={$r7,$t7};$v7=q#/lib/class_init.b#;$w7=bless({$x5,$o7,$u6,$q7,$v6,$q,$w6,$u7,$K,$v7},$F6);$x7=q#fabric/remote#;$y7=q#fabric/rmi#;$z7=q#io/buffer#;$A7=q#io/cat#;$B7=q#io/exec#;$C7=q#io/fd#;$D7=q#io/file#;$E7=q#io/file_update_fd#;$F7=q#io/null#;$G7=q#io/object#;$H7=q#io/pid#;$I7=q#io/str#;$J7=q#io/transfer#;$K7=q#io/transfer_async#;$L7=q#io/transfer_sync#;$M7=q#lib/behavior#;$N7=q#lib/dataslice#;$O7=q#lib/future#;$P7=q#lib/image#;$Q7=q#lib/ni#;$R7=q#lib/quote_simple#;$S7=q#lib/test_assert_eq#;$T7=q#lib/test_assertion#;$U7=q#lib/test_value#;$V7=q#object#;$W7=q#semantic/task#;$X7={$y5,1,$z5,1,$x7,1,$A5,1,$y7,1,$B5,1,$z7,1,$C5,1,$A7,1,$D5,1,$B7,1,$E5,1,$C7,1,$F5,1,$D7,1,$G5,1,$E7,1,$H5,1,$F7,1,$I5,1,$G7,1,$J5,1,$H7,1,$K5,1,$I7,1,$L5,1,$J7,1,$M5,1,$K7,1,$N5,1,$L7,1,$O5,1,$M7,1,$P5,1,$H6,1,$Q5,1,$N7,1,$R5,1,$M,1,$S5,1,$A,1,$T5,1,$O7,1,$U5,1,$P7,1,$V5,1,$Q7,1,$W5,1,$R7,1,$X5,1,$F6,1,$Y5,1,$O6,1,$Z5,1,$S7,1,$c6,1,$T7,1,$d6,1,$C,1,$e6,1,$U7,1,$f6,1,$o6,1,$g6,1,$p6,1,$h6,1,$V7,1,$i6,1,$j6,1,$k6,1,$W7,1,$l6,1};$Y7=q#/object#;$Z7={};$c8=q#DESTROY#;$d8=q#local $_;
my $self = shift;
defined($_) && $_->($self) for @{ref($self) . '::dtors'};#;$e8=bless({$w,$d8,$y,$z},$A);$f8=q#ni 'ni:/' . ref shift#;$g8=bless({$w,$f8,$y,$z},$A);$h8={$c8,$e8,$y5,$g8};$i8=q#/lib/instance.b#;$j8=bless({$x5,$Z7,$u6,$q,$v6,$q,$w6,$h8,$K,$i8},$F6);$k8=[$j8];$l8=bless({$x5,$X7,$K,$Y7,$n6,$k8},$i6);$m8={$y5,1,$z5,1,$A5,1,$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1,$M5,1,$N5,1,$O5,1,$M7,1,$P5,1,$H6,1,$Q5,1,$N7,1,$R5,1,$S5,1,$T5,1,$U5,1,$V5,1,$W5,1,$X5,1,$F6,1,$Y5,1,$O6,1,$Z5,1,$c6,1,$d6,1,$e6,1,$f6,1,$o6,1,$g6,1,$p6,1,$h6,1,$i6,1,$j6,1,$k6,1,$l6,1};$n8=q#/lib/behavior#;$o8={};$p8=q#my $self = shift;
(my $name = $self->name) =~ s/^[^:]*://;
return ni("ni.doc:$name") if ni->can('exists') && ni->exists("ni.doc:$name");
ni('ni:/lib/doc')->new($name);#;$q8=bless({$w,$p8,$y,$z},$A);$r8={$e,$q8};$s8=q#/lib/documentable.b#;$t8=bless({$x5,$o8,$u6,$q,$v6,$q,$w6,$r8,$K,$s8},$F6);$u8=[$l8,$t8];$v8=bless({$x5,$m8,$K,$n8,$n6,$u8},$P5);$w8={$y5,1,$z5,1,$A5,1,$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1,$M5,1,$N5,1,$O5,1,$P5,1,$H6,1,$Q5,1,$R5,1,$S5,1,$T5,1,$U5,1,$V5,1,$W5,1,$X5,1,$Y5,1,$Z5,1,$c6,1,$d6,1,$e6,1,$f6,1,$o6,1,$g6,1,$p6,1,$h6,1,$i6,1,$j6,1,$k6,1,$l6,1};$x8=q#/lib/definition.b#;$y8={};$z8=q#def#;$A8=q#my $self = shift;
my $name = shift;
$self->add(ni->exists("ni:$name")
  ? ni"ni:$name"
  : ni('ni:/lib/slice')->new($name, @_));
$self;#;$B8=bless({$w,$A8,$y,$z},$A);$C8={$z8,$B8};$D8=q#/lib/definition_def.b#;$E8=bless({$x5,$y8,$u6,$q,$v6,$q,$w6,$C8,$K,$D8},$F6);$F8={};$G8=q#ro#;$H8=q#my ($self, $slice, @rs) = @_;
$self->add(ni('ni:/lib/slice')->new(
  $slice,
  map +($_ => fn qq{shift->{'$_'}}), @rs));#;$I8=bless({$w,$H8,$y,$z},$A);$J8=q#rw#;$K8=q#my ($self, $slice, @as) = @_;
$self->add(ni('ni:/lib/slice')->new(
  $slice,
  map +($_ => fn qq{\\@_ == 2 ? \\$_[0]->{'$_'} = \\$_[1] : shift->{'$_'}}), @as));#;$L8=bless({$w,$K8,$y,$z},$A);$M8={$G8,$I8,$J8,$L8};$N8=q#/lib/accessor.b#;$O8=bless({$x5,$F8,$u6,$q,$v6,$q,$w6,$M8,$K,$N8},$F6);$P8={};$Q8=q#(""#;$R8=q#shift->name#;$S8=bless({$w,$R8,$y,$z},$A);$T8={$Q8,$S8};$U8=q#/lib/name_as_string.b#;$V8=bless({$x5,$P8,$u6,$q,$v6,$q,$w6,$T8,$K,$U8},$F6);$W8={};$X8=q#(eq#;$Y8=q#ref($_[0]) eq ref($_[1])
  and Scalar::Util::refaddr($_[0]) == Scalar::Util::refaddr($_[1]);#;$Z8=bless({$w,$Y8,$y,$z},$A);$c9={$X8,$Z8};$d9=q#/lib/ref_eq.b#;$e9=bless({$x5,$W8,$u6,$q,$v6,$q,$w6,$c9,$K,$d9},$F6);$f9={};$g9=q#defdata#;$h9=q#shift->add(ni('ni:/lib/dataslice')->new(@_))#;$i9=bless({$w,$h9,$y,$z},$A);$j9={$g9,$i9};$k9=q#/lib/definition_defdata.b#;$l9=bless({$x5,$f9,$u6,$q,$v6,$q,$w6,$j9,$K,$k9},$F6);$m9={};$n9=q#instantiate_with_defaults#;$o9=q#my ($class, @slots) = @_;
my $generator = pop @slots;
$class->def("$$class{name}_init.b",
  instantiate => fc(
    generator => $generator,
    '@slots'  => \\@slots,
    q{
      my %defaults = &$generator(@_);
      my $class    = shift;
      my %args     = @_;
      $defaults{$_} = $args{$_} for @slots;
      \\%defaults;
    }));#;$p9=bless({$w,$o9,$y,$z},$A);$q9={$n9,$p9};$r9=q#/lib/definition_init_with_defaults.b#;$s9=bless({$x5,$m9,$u6,$q,$v6,$q,$w6,$q9,$K,$r9},$F6);$t9=[$E8,$O8,$V8,$e9,$l9,$s9];$u9=bless({$x5,$w8,$K,$x8,$n6,$t9},$H6);$v9=[$n7,$w7,$l8,$v8,$u9];$w9=bless({$x5,$q6,$K,$r6,$n6,$v9},$h6);$x9={};$y9=q#new#;$z9=q#local $_;
my $class   = shift;
my $package = ref $class ? $class->package : $class;
my $self    = bless &{"$package\\::instantiate"}($class, @_), $package;
$_->($self) for @{ref($self) . "::ctors"};
$self;#;$A9=bless({$w,$z9,$y,$z},$A);$B9={$y9,$A9};$C9=q#/lib/instantiable.b#;$D9=bless({$x5,$x9,$w6,$B9,$K,$C9},$F6);$E9={};$F9=q#child#;$G9=q#my ($self, $name, @slices) = @_;
ni("ni:/metaclass")->new("$name.c", $self->class)
->new($name, $self, @slices);#;$H9=bless({$w,$G9,$y,$z},$A);$I9={$F9,$H9};$J9=q#/lib/subclass.b#;$K9=bless({$x5,$E9,$u6,$q,$v6,$q,$w6,$I9,$K,$J9},$F6);$L9=[$w9,$D9,$w7,$w9,$K9];$M9=bless({$x5,$m6,$K,$L,$n6,$L9},$z5);$N9=q#ni:/class.c#;$O9={$z5,1,$k6,1};$P9=q#/class.c#;$Q9={$z5,1,$h6,1,$k6,1};$R9=q#/module.c#;$S9={$z5,1,$A5,1,$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1,$M5,1,$N5,1,$O5,1,$P5,1,$Q5,1,$R5,1,$S5,1,$T5,1,$U5,1,$V5,1,$W5,1,$X5,1,$Y5,1,$Z5,1,$c6,1,$d6,1,$e6,1,$f6,1,$h6,1,$i6,1,$k6,1,$l6,1};$T9=q#/object.c#;$U9=[$M9];$V9=bless({$x5,$S9,$K,$T9,$n6,$U9},$o6);$W9={$z5,1,$P5,1,$Q5,1,$R5,1,$Y5,1,$Z5,1,$h6,1,$k6,1};$X9=q#/lib/behavior.c#;$Y9=[$V9];$Z9=bless({$x5,$W9,$K,$X9,$n6,$Y9},$o6);$ca=[$V9,$D9,$Z9];$da=bless({$x5,$Q9,$K,$R9,$n6,$ca},$o6);$ea=[$da];$fa=bless({$x5,$O9,$K,$P9,$n6,$ea},$o6);$ga=q#ni:/fabric/remote#;$ha={$x7,1};$ia={};$ja=[];$ka=q#my ($class, $rmi, $name) = @_;
+{rmi  => $rmi,
  name => $name};#;$la=bless({$t,$ja,$v,$q,$w,$ka,$y,$z},$A);$ma={$r7,$la};$na=q#/fabric/remote_init.b#;$oa=bless({$x5,$ia,$u6,$q,$v6,$q,$w6,$ma,$K,$na},$F6);$pa={};$qa=q#AUTOLOAD#;$ra=[];$sa=q#my $self = shift;
my $method = ${__PACKAGE__ . '::AUTOLOAD'};
$$self{rmi}->call($$self{name}, $method, @_);#;$ta=bless({$t,$ra,$v,$q,$w,$sa,$y,$z},$A);$ua={$qa,$ta};$va=q#/fabric/remote_proxy.b#;$wa=bless({$x5,$pa,$u6,$q,$v6,$q,$w6,$ua,$K,$va},$F6);$xa=[$l8,$oa,$wa];$ya=bless({$x5,$ha,$K,$d1,$n6,$xa},$A5);$za=q#ni:/fabric/remote.c#;$Aa={$A5,1};$Ba=q#/fabric/remote.c#;$Ca=[$V9];$Da=bless({$x5,$Aa,$K,$Ba,$n6,$Ca},$o6);$Ea=q#ni:/fabric/remote_init.b#;$Fa=q#ni:/fabric/remote_proxy.b#;$Ga=q#ni:/fabric/rmi#;$Ha={$y7,1};$Ia={$y7,1,$z7,1,$A7,1,$B7,1,$C7,1,$D7,1,$E7,1,$F7,1,$G7,1,$H7,1,$I7,1};$Ja=q#/io/object#;$Ka={};$La=q#(bool#;$Ma=[];$Na=bless({$t,$Ma,$v,$q,$w,1,$y,$z},$A);$Oa={$La,$Na};$Pa=q#/io/object_ops.b#;$Qa=bless({$x5,$Ka,$u6,$q,$v6,$q,$w6,$Oa,$K,$Pa},$F6);$Ra={};$Sa=q#die#;$Ta=[];$Ua=q#shift; die join " ", @_#;$Va=bless({$t,$Ta,$v,$q,$w,$Ua,$y,$z},$A);$Wa=q#io_check#;$Xa=[];$Ya=q#my $self  = shift;
my $check = shift;
my $fn    = shift;
my $r     = &$fn(@_);
$self->die($fn, $!) unless &$check($r);
$r;#;$Za=bless({$t,$Xa,$v,$q,$w,$Ya,$y,$z},$A);$cb=q#io_check_defined#;$db=[];$eb=q#shift->io_check(sub {defined shift}, @_)#;$fb=bless({$t,$db,$v,$q,$w,$eb,$y,$z},$A);$gb=q#io_check_true#;$hb=[];$ib=q#shift->io_check(sub {shift}, @_)#;$jb=bless({$t,$hb,$v,$q,$w,$ib,$y,$z},$A);$kb={$Sa,$Va,$Wa,$Za,$cb,$fb,$gb,$jb};$lb=q#/io/object_checks.b#;$mb=bless({$x5,$Ra,$u6,$q,$v6,$q,$w6,$kb,$K,$lb},$F6);$nb={};$ob=q#(+#;$pb=[];$qb=q#ni('ni:/io/cat')->new(@_[0, 1])#;$rb=bless({$t,$pb,$v,$q,$w,$qb,$y,$z},$A);$sb={$ob,$rb};$tb=q#/io/object_constructors.b#;$ub=bless({$x5,$nb,$u6,$q,$v6,$q,$w6,$sb,$K,$tb},$F6);$vb={};$wb=q#read_all#;$xb=[];$yb=q#shift->into_sync(ni('ni:/io/str')->new(my $data = ''));
$data;#;$zb=bless({$t,$xb,$v,$q,$w,$yb,$y,$z},$A);$Ab=q#write_all#;$Bb=[];$Cb=q#my $self = shift;
ni('ni:/io/str')->new($_[0])->into_sync($self);#;$Db=bless({$t,$Bb,$v,$q,$w,$Cb,$y,$z},$A);$Eb={$wb,$zb,$Ab,$Db};$Fb=q#/io/object_memory.b#;$Gb=bless({$x5,$vb,$u6,$q,$v6,$q,$w6,$Eb,$K,$Fb},$F6);$Hb={};$Ib=q#connect_sync#;$Jb=[];$Kb=q#my ($self, $rhs) = @_;
($self->into_sync($rhs),
 $rhs->into_sync($self));#;$Lb=bless({$t,$Jb,$v,$q,$w,$Kb,$y,$z},$A);$Mb=q#into_sync#;$Nb=[];$Ob=q#ni('ni:/io/transfer_sync')->new(@_)->run#;$Pb=bless({$t,$Nb,$v,$q,$w,$Ob,$y,$z},$A);$Qb={$Ib,$Lb,$Mb,$Pb};$Rb=q#/io/object_transfer_sync.b#;$Sb=bless({$x5,$Hb,$u6,$q,$v6,$q,$w6,$Qb,$K,$Rb},$F6);$Tb={};$Ub=q#connect_async#;$Vb=[];$Wb=q#my ($self, $rhs) = @_;
($self->into_async($rhs),
 $rhs->into_async($self));#;$Xb=bless({$t,$Vb,$v,$q,$w,$Wb,$y,$z},$A);$Yb=q#into_async#;$Zb=[];$cc=q#ni('ni:/io/transfer_async')->new(@_)->run#;$dc=bless({$t,$Zb,$v,$q,$w,$cc,$y,$z},$A);$ec={$Ub,$Xb,$Yb,$dc};$fc=q#/io/object_transfer_async.b#;$gc=bless({$x5,$Tb,$u6,$q,$v6,$q,$w6,$ec,$K,$fc},$F6);$hc=[$l8,$Qa,$mb,$ub,$Gb,$Sb,$gc,$gc,$Sb,$gc,$Sb];$ic=bless({$x5,$Ia,$K,$Ja,$n6,$hc},$J5);$jc={};$kc=[];$lc=q#@slots#;$mc=q#arg_codec#;$nc=q#return_codec#;$oc=q#image#;$pc=[$mc,$nc,$oc];$qc=q#generator#;$rc=[];$sc=q#(arg_codec    => ni('ni:/fabric/qperl')->new,
          return_codec => ni('ni:/fabric/qjson')->new,
          image        => 1)#;$tc=bless({$t,$rc,$v,$q,$w,$sc,$y,$z},$A);$uc={$lc,$pc,$qc,$tc};$vc=q#my %defaults = &$generator(@_);
my $class    = shift;
my %args     = @_;
$defaults{$_} = $args{$_} for @slots;
\\%defaults;#;$wc=bless({$t,$kc,$v,$uc,$w,$vc,$y,$z},$A);$xc={$r7,$wc};$yc=q#/fabric/rmi_init.b#;$zc=bless({$x5,$jc,$u6,$q,$v6,$q,$w6,$xc,$K,$yc},$F6);$Ac=[$ic,$zc];$Bc=bless({$x5,$Ha,$K,$n1,$n6,$Ac},$B5);$Cc=q#ni:/fabric/rmi.c#;$Dc={$B5,1};$Ec=q#/fabric/rmi.c#;$Fc={$B5,1,$C5,1,$D5,1,$E5,1,$F5,1,$G5,1,$H5,1,$I5,1,$J5,1,$K5,1,$L5,1};$Gc=q#/io/object.c#;$Hc={};$Ic=q#def_transfer_method#;$Jc=[];$Kc=q#my ($class, $transfer_class, $method_name) = @_;
my $transfer_name = $transfer_class->name;
$class->def("/io/object_transfer_$method_name.b",
  "into_$method_name" => fn qq{ni('$transfer_name')->new(\\@_)->run},
  "connect_$method_name" => fn qq{
    my (\\$self, \\$rhs) = \\@_;
    (\\$self->into_$method_name(\\$rhs),
     \\$rhs->into_$method_name(\\$self));
  });#;$Lc=bless({$t,$Jc,$v,$q,$w,$Kc,$y,$z},$A);$Mc={$Ic,$Lc};$Nc=q#/io/object.c_transfer_def.b#;$Oc=bless({$x5,$Hc,$u6,$q,$v6,$q,$w6,$Mc,$K,$Nc},$F6);$Pc=[$V9,$Oc];$Qc=bless({$x5,$Fc,$K,$Gc,$n6,$Pc},$o6);$Rc=[$Qc];$Sc=bless({$x5,$Dc,$K,$Ec,$n6,$Rc},$o6);$Tc=q#ni:/fabric/rmi_init.b#;$Uc=q#ni:/io/buffer#;$Vc={$z7,1};$Wc={};$Xc=[];$Yc=q#my ($class, $capacity) = @_;
$capacity ||= 65536;
$class->die("buffer capacity must be a power of two (got $capacity)")
  if $capacity & $capacity - 1;
+{capacity    => $capacity,
  data        => "\\0" x $capacity,
  read_point  => 0,
  write_point => 0};#;$Zc=bless({$t,$Xc,$v,$q,$w,$Yc,$y,$z},$A);$cd={$r7,$Zc};$dd=q#/io/buffer_init.b#;$ed=bless({$x5,$Wc,$u6,$q,$v6,$q,$w6,$cd,$K,$dd},$F6);$fd={};$gd=q#read#;$hd=[];$id=q#my $self = shift;
my $rcap = $self->read_capacity;
$! = Errno::EWOULDBLOCK, return undef unless $rcap;

my $length = $_[1];
my $offset = $_[2] || 0;
$length = $rcap if $length > $rcap;

my $capacity   = $$self{capacity};
my $read_index = $$self{read_point} & $capacity - 1;
if ($read_index + $length > $capacity) {
  my $read_size = $capacity - $read_index;
  if ($offset) {
    $_[0] ||= "\\0" x $length;
    substr $_[0], $offset, $read_size,
           substr $$self{data}, $read_index, $read_size;
    substr $_[0], $offset + $read_size, $length - $read_size,
           substr $$self{data}, 0, $length - $read_size;
  } else {
    $_[0] = substr($$self{data}, $read_index, $read_size)
          . substr($$self{data}, 0, $length - $read_size);
  }
  $$self{read_point} += $length;
  return $length;
} else {
  if ($offset) {
    substr $_[0], $offset, $length,
           substr $$self{data}, $read_index, $length;
  } else {
    $_[0] = substr $$self{data}, $read_index, $length;
  }
  $$self{read_point} += $length;
  return $length;
}#;$jd=bless({$t,$hd,$v,$q,$w,$id,$y,$z},$A);$kd=q#read_capacity#;$ld=[];$md=q#my $self = shift;
$$self{write_point} - $$self{read_point};#;$nd=bless({$t,$ld,$v,$q,$w,$md,$y,$z},$A);$od=q#write#;$pd=[];$qd=q#my $self = shift;
my $wcap = $self->write_capacity;
$! = Errno::EWOULDBLOCK, return undef unless $wcap;

my $length = @_ > 1 ? $_[1] : length $_[0];
my $offset = $_[2] || 0;
$length    = $wcap if $length > $wcap;

my $capacity    = $$self{capacity};
my $write_index = $$self{write_point} & $capacity - 1;
if ($write_index + $length > $capacity) {
  \# Two-part write
  my $write_size = $capacity - $write_index;
  substr $$self{data}, $write_index, $write_size,
         substr $_[0], 0, $write_size;
  substr $$self{data}, 0, $length - $write_size,
         substr $_[0], $offset + $write_size, $length - $write_size;
  $$self{write_point} += $length;
  return $length;
} else {
  \# One-part write
  substr $$self{data}, $write_index, $length,
         length $_[0] == $length && !$offset
           ? $_[0]
           : substr $_[0], $offset, $length;
  $$self{write_point} += $length;
  return $length;
}#;$rd=bless({$t,$pd,$v,$q,$w,$qd,$y,$z},$A);$sd=q#write_capacity#;$td=[];$ud=q#my $self = shift;
$$self{capacity} - $$self{write_point} + $$self{read_point};#;$vd=bless({$t,$td,$v,$q,$w,$ud,$y,$z},$A);$wd={$gd,$jd,$kd,$nd,$od,$rd,$sd,$vd};$xd=q#/io/buffer_io.b#;$yd=bless({$x5,$fd,$u6,$q,$v6,$q,$w6,$wd,$K,$xd},$F6);$zd=[$ic,$ed,$yd];$Ad=bless({$x5,$Vc,$K,$G1,$n6,$zd},$C5);$Bd=q#ni:/io/buffer.c#;$Cd={$C5,1};$Dd=q#/io/buffer.c#;$Ed=[$Qc];$Fd=bless({$x5,$Cd,$K,$Dd,$n6,$Ed},$o6);$Gd=q#ni:/io/buffer_init.b#;$Hd=q#ni:/io/buffer_io.b#;$Id=q#ni:/io/cat#;$Jd={$A7,1};$Kd={};$Ld=[];$Md=q#shift; +{fs => [@_]}#;$Nd=bless({$t,$Ld,$v,$q,$w,$Md,$y,$z},$A);$Od={$r7,$Nd};$Pd=q#/io/cat_init.b#;$Qd=bless({$x5,$Kd,$u6,$q,$v6,$q,$w6,$Od,$K,$Pd},$F6);$Rd={};$Sd=[];$Td=q#my $fs = shift->{fs};
my $length = $_[1];
my $offset = $_[2] || 0;
my $total_read = 0;
my $n;
while (@$fs && $total_read < $length) {
  $n = $$fs[0]->read($_[0], $length - $total_read, $offset + $total_read);
  return $total_read || undef unless defined $n;
  shift @$fs unless $n;
  $total_read += $n;
}
$total_read;#;$Ud=bless({$t,$Sd,$v,$q,$w,$Td,$y,$z},$A);$Vd={$gd,$Ud};$Wd=q#/io/cat_read.b#;$Xd=bless({$x5,$Rd,$u6,$q,$v6,$q,$w6,$Vd,$K,$Wd},$F6);$Yd=[$ic,$Qd,$Xd];$Zd=bless({$x5,$Jd,$K,$T1,$n6,$Yd},$D5);$ce=q#ni:/io/cat.c#;$de={$D5,1};$ee=q#/io/cat.c#;$fe=[$Qc];$ge=bless({$x5,$de,$K,$ee,$n6,$fe},$o6);$he=q#ni:/io/cat_init.b#;$ie=q#ni:/io/cat_read.b#;$je=q#ni:/io/exec#;$ke={$B7,1};$le={};$me=q#argv#;$ne=[];$oe=q#shift->{'argv'}#;$pe=bless({$t,$ne,$v,$q,$w,$oe,$y,$z},$A);$qe={$me,$pe};$re=q#/io/exec_ro.b#;$se=bless({$x5,$le,$u6,$q,$v6,$q,$w6,$qe,$K,$re},$F6);$te={};$ue=[];$ve=q#my ($class, @argv) = @_;
+{argv         => \\@argv,
  env          => {%ENV},
  internal_fds => {},
  external_fds => {}};#;$we=bless({$t,$ue,$v,$q,$w,$ve,$y,$z},$A);$xe={$r7,$we};$ye=q#/io/exec_init.b#;$ze=bless({$x5,$te,$u6,$q,$v6,$q,$w6,$xe,$K,$ye},$F6);$Ae={};$Be=q#connect#;$Ce=[];$De=q#my ($self, %fds) = @_;
@{$$self{internal_fds}}{keys %fds} = values %fds;
$self;#;$Ee=bless({$t,$Ce,$v,$q,$w,$De,$y,$z},$A);$Fe=q#in_pipe#;$Ge=[];$He=q#local $_;
my $self = shift;
for (@_) {
  my ($r, $w) = POSIX::pipe;
  $self->die($!) unless defined $r;
  $$self{internal_fds}{$_} = ni('ni:/io/fd')->new($r)->cloexec(0);
  $$self{external_fds}{$_} = ni('ni:/io/fd')->new($w)->cloexec(1);
}
$self;#;$Ie=bless({$t,$Ge,$v,$q,$w,$He,$y,$z},$A);$Je=q#out_pipe#;$Ke=[];$Le=q#local $_;
my $self = shift;
for (@_) {
  my ($r, $w) = POSIX::pipe;
  $self->die($!) unless defined $r;
  $$self{internal_fds}{$_} = ni('ni:/io/fd')->new($w)->cloexec(0);
  $$self{external_fds}{$_} = ni('ni:/io/fd')->new($r)->cloexec(1);
}
$self;#;$Me=bless({$t,$Ke,$v,$q,$w,$Le,$y,$z},$A);$Ne=q#setup_stdio#;$Oe=[];$Pe=q#my $self = shift;
$self->connect(0 => ni('null:')->fd->cloexec(0)) unless $self->binds_fd(0);
$self->out_pipe(1) unless $self->binds_fd(1);
$self->out_pipe(2) unless $self->binds_fd(2);
$self;#;$Qe=bless({$t,$Oe,$v,$q,$w,$Pe,$y,$z},$A);$Re={$Be,$Ee,$Fe,$Ie,$Je,$Me,$Ne,$Qe};$Se=q#/io/exec_io_setup.b#;$Te=bless({$x5,$Ae,$u6,$q,$v6,$q,$w6,$Re,$K,$Se},$F6);$Ue={};$Ve=q#binds_fd#;$We=[];$Xe=q#my ($self, $fd) = @_;
$$self{internal_fds}{$fd};#;$Ye=bless({$t,$We,$v,$q,$w,$Xe,$y,$z},$A);$Ze=q#fd#;$cf=[];$df=q#my ($self, $fd) = @_;
$$self{external_fds}{$fd};#;$ef=bless({$t,$cf,$v,$q,$w,$df,$y,$z},$A);$ff=q#stderr#;$gf=[];$hf=q#my $self = shift;
$self->binds_fd(2) ? $self->fd(2) : $self->out_pipe(2)->fd(2);#;$if=bless({$t,$gf,$v,$q,$w,$hf,$y,$z},$A);$jf=q#stdin#;$kf=[];$lf=q#my $self = shift;
$self->binds_fd(0) ? $self->fd(0) : $self->in_pipe(0)->fd(0);#;$mf=bless({$t,$kf,$v,$q,$w,$lf,$y,$z},$A);$nf=q#stdout#;$of=[];$pf=q#my $self = shift;
$self->binds_fd(1) ? $self->fd(1) : $self->out_pipe(1)->fd(1);#;$qf=bless({$t,$of,$v,$q,$w,$pf,$y,$z},$A);$rf={$Ve,$Ye,$Ze,$ef,$ff,$if,$jf,$mf,$nf,$qf};$sf=q#/io/exec_io_accessors.b#;$tf=bless({$x5,$Ue,$u6,$q,$v6,$q,$w6,$rf,$K,$sf},$F6);$uf={};$vf=q#env#;$wf=[];$xf=q#my ($self, %env) = @_;
return $$self{env} unless keys %env;
@{$$self{env}}{keys %env} = values %env;
$self;#;$yf=bless({$t,$wf,$v,$q,$w,$xf,$y,$z},$A);$zf={$vf,$yf};$Af=q#/io/exec_env.b#;$Bf=bless({$x5,$uf,$u6,$q,$v6,$q,$w6,$zf,$K,$Af},$F6);$Cf={};$Df=q#exec#;$Ef=[];$Ff=q#my $self = shift->setup_stdio->move_fds;
my @argv = (@{$$self{argv}}, @_);
$_->close for values %{$$self{external_fds}};
local %ENV = %{$$self{env}};
{ exec @argv };
$self->stderr("exec failed", $!);
1;#;$Gf=bless({$t,$Ef,$v,$q,$w,$Ff,$y,$z},$A);$Hf=q#fork#;$If=[];$Jf=q#my $self = shift->setup_stdio;
my $pid  = $self->io_check_defined(*main::fork);
exit $self->exec(@_) unless $pid;
$_->close for values %{$$self{internal_fds}};
delete $$self{internal_fds};
ni('ni:/io/pid')->new(
  $pid,
  [@{$$self{argv}}, @_],
  $$self{env},
  %{$$self{external_fds}});#;$Kf=bless({$t,$If,$v,$q,$w,$Jf,$y,$z},$A);$Lf=q#move_fds#;$Mf=[];$Nf=q#my $self = shift;
$$self{internal_fds}{$_}->be($_) for keys %{$$self{internal_fds}};
$self;#;$Of=bless({$t,$Mf,$v,$q,$w,$Nf,$y,$z},$A);$Pf={$Df,$Gf,$Hf,$Kf,$Lf,$Of};$Qf=q#/io/exec_fork.b#;$Rf=bless({$x5,$Cf,$u6,$q,$v6,$q,$w6,$Pf,$K,$Qf},$F6);$Sf=[$ic,$se,$ze,$Te,$tf,$Bf,$Rf];$Tf=bless({$x5,$ke,$K,$i2,$n6,$Sf},$E5);$Uf=q#ni:/io/exec.c#;$Vf={$E5,1};$Wf=q#/io/exec.c#;$Xf=[$Qc];$Yf=bless({$x5,$Vf,$K,$Wf,$n6,$Xf},$o6);$Zf=q#ni:/io/exec_env.b#;$cg=q#ni:/io/exec_fork.b#;$dg=q#ni:/io/exec_init.b#;$eg=q#ni:/io/exec_io_accessors.b#;$fg=q#ni:/io/exec_io_setup.b#;$gg=q#ni:/io/exec_ro.b#;$hg=q#ni:/io/fd#;$ig={$C7,1};$jg=q#read_fd_mask#;$kg={};$lg=[];$mg=q#shift->{'fd'}#;$ng=bless({$t,$lg,$v,$q,$w,$mg,$y,$z},$A);$og={$Ze,$ng};$pg=q#/io/fd_readers.b#;$qg=bless({$x5,$kg,$u6,$q,$v6,$q,$w6,$og,$K,$pg},$F6);$rg={};$sg=[];$tg=q#my ($class, $fd) = @_;
+{fd  => ref $fd ? fileno $fd : $fd,
  rfh => undef,
  wfh => undef};#;$ug=bless({$t,$sg,$v,$q,$w,$tg,$y,$z},$A);$vg={$r7,$ug};$wg=q#/io/fd_init.b#;$xg=bless({$x5,$rg,$u6,$q,$v6,$q,$w6,$vg,$K,$wg},$F6);$yg={};$zg=q#be#;$Ag=[];$Bg=q#my ($self, $new) = @_;
return $self if $new == $$self{fd};
$self->io_check_defined(*POSIX::dup2, $$self{fd}, $new);
$self->close_perl_ios;
POSIX::close $$self{fd};
$$self{fd} = $new;
$self;#;$Cg=bless({$t,$Ag,$v,$q,$w,$Bg,$y,$z},$A);$Dg={$zg,$Cg};$Eg=q#/io/fd_shell.b#;$Fg=bless({$x5,$yg,$u6,$q,$v6,$q,$w6,$Dg,$K,$Eg},$F6);$Gg={};$Hg=q#cloexec#;$Ig=[];$Jg=q#shift->fcntl_flag(Fcntl::FD_CLOEXEC, @_)#;$Kg=bless({$t,$Ig,$v,$q,$w,$Jg,$y,$z},$A);$Lg=q#fcntl_flag#;$Mg=[];$Ng=q#my ($self, $flag, $value) = @_;
$self->io_check_true(*main::open2, $$self{rfh}, "<&=$$self{fd}")
  unless $$self{rfh};
my $flags = $self->io_check_true(
  *main::fcntl, $$self{rfh}, Fcntl::F_GETFL, 0);
if (@_) {
  if (shift) {$flags |= $flag}
  else       {$flags &= ~$flag}
  $self->io_check_true(*main::fcntl, $$self{rfh}, Fcntl::F_SETFL, $flags);
  $self;
} else {
  !!($flags & $flag);
}#;$Og=bless({$t,$Mg,$v,$q,$w,$Ng,$y,$z},$A);$Pg=q#nonblock#;$Qg=[];$Rg=q#shift->fcntl_flag(Fcntl::O_NONBLOCK, @_)#;$Sg=bless({$t,$Qg,$v,$q,$w,$Rg,$y,$z},$A);$Tg={$Hg,$Kg,$Lg,$Og,$Pg,$Sg};$Ug=q#/io/fd_fcntl.b#;$Vg=bless({$x5,$Gg,$u6,$q,$v6,$q,$w6,$Tg,$K,$Ug},$F6);$Wg={};$Xg=[];$Yg=q#shift->close#;$Zg=bless({$t,$Xg,$v,$q,$w,$Yg,$y,$z},$A);$ch=q#close#;$dh=[];$eh=q#my $self = shift;
if (defined $$self{fd}) {
  $self->close_perl_ios;
  POSIX::close $$self{fd};
  $$self{fd} = undef;
}
$self;#;$fh=bless({$t,$dh,$v,$q,$w,$eh,$y,$z},$A);$gh={$ch,$fh};$hh=q#/io/fd_gc.b#;$ih=bless({$x5,$Wg,$u6,$q,$v6,$Zg,$w6,$gh,$K,$hh},$F6);$jh={};$kh=q#close_perl_ios#;$lh=[];$mh=q#my $self = shift;
close $$self{rfh} if $$self{rfh};
close $$self{wfh} if $$self{wfh};
ni('ni:/io/fd')->clear_fd($$self{fd});
$$self{rfh} = $$self{wfh} = undef;
$self;#;$nh=bless({$t,$lh,$v,$q,$w,$mh,$y,$z},$A);$oh=[];$ph=q#my $self = shift;
unless ($$self{rfh}) {
  open $$self{rfh}, "<&=$$self{fd}" or return undef;
  ni('ni:/io/fd')->read_fd($$self{fd});
}
sysread $$self{rfh}, $_[0], $_[1], $_[2] || 0;#;$qh=bless({$t,$oh,$v,$q,$w,$ph,$y,$z},$A);$rh=[];$sh=q#my $self = shift;
unless ($$self{wfh}) {
  open $$self{wfh}, ">&=$$self{fd}" or return undef;
  ni('ni:/io/fd')->write_fd($$self{fd});
}
syswrite $$self{wfh}, $_[0], $_[1] || length $_[0], $_[2] || 0;#;$th=bless({$t,$rh,$v,$q,$w,$sh,$y,$z},$A);$uh={$kh,$nh,$gd,$qh,$od,$th};$vh=q#/io/fd_perlio.b#;$wh=bless({$x5,$jh,$u6,$q,$v6,$q,$w6,$uh,$K,$vh},$F6);$xh=[$ic,$qg,$xg,$Fg,$Vg,$ih,$wh];$yh=q#write_fd_mask#;$zh=bless({$x5,$ig,$K,$v2,$jg,$z,$n6,$xh,$yh,$z},$F5);$Ah=[];$Bh=q#my $self = shift;
$$self{read_fd_mask} = '';
$$self{write_fd_mask} = '';#;$Ch=bless({$t,$Ah,$v,$q,$w,$Bh,$y,$z},$A);$Dh=q#ni:/io/fd.c#;$Eh={$F5,1};$Fh=q#/io/fd.c#;$Gh={};$Hh=q#clear_fd#;$Ih=[];$Jh=q#my ($self, $fd) = @_;
vec($$self{read_fd_mask}, $fd, 1) = 0;
vec($$self{write_fd_mask}, $fd, 1) = 0;#;$Kh=bless({$t,$Ih,$v,$q,$w,$Jh,$y,$z},$A);$Lh=q#read_fd#;$Mh=[];$Nh=q#my ($self, $fd) = @_;
vec($$self{read_fd_mask}, $fd, 1) = 1;#;$Oh=bless({$t,$Mh,$v,$q,$w,$Nh,$y,$z},$A);$Ph=q#select#;$Qh=[];$Rh=q#my ($self, $timeout) = @_;
my $n = select my $rbits = $$self{read_fd_mask},
               my $wbits = $$self{write_fd_mask},
               my $ebits = $$self{read_fd_mask} | $$self{write_fd_mask},
               $timeout || 0;
wantarray ? ($n, $rbits, $wbits) : $n;#;$Sh=bless({$t,$Qh,$v,$q,$w,$Rh,$y,$z},$A);$Th=q#write_fd#;$Uh=[];$Vh=q#my ($self, $fd) = @_;
vec($$self{write_fd_mask}, $fd, 1) = 1;#;$Wh=bless({$t,$Uh,$v,$q,$w,$Vh,$y,$z},$A);$Xh={$Hh,$Kh,$Lh,$Oh,$Ph,$Sh,$Th,$Wh};$Yh=q#/io/fd.c_selector.b#;$Zh=bless({$x5,$Gh,$u6,$Ch,$v6,$q,$w6,$Xh,$K,$Yh},$F6);$ci=[$Qc,$Zh];$di=bless({$x5,$Eh,$K,$Fh,$n6,$ci},$o6);$ei=q#ni:/io/fd.c_selector.b#;$fi=q#ni:/io/fd_fcntl.b#;$gi=q#ni:/io/fd_gc.b#;$hi=q#ni:/io/fd_init.b#;$ii=q#ni:/io/fd_perlio.b#;$ji=q#ni:/io/fd_readers.b#;$ki=q#ni:/io/fd_shell.b#;$li=q#ni:/io/file#;$mi={$D7,1};$ni={};$oi=[];$pi=q#shift->{'name'}#;$qi=bless({$t,$oi,$v,$q,$w,$pi,$y,$z},$A);$ri={$K,$qi};$si=q#/io/file_readers.b#;$ti=bless({$x5,$ni,$u6,$q,$v6,$q,$w6,$ri,$K,$si},$F6);$ui={};$vi=q#mode#;$wi=[];$xi=q#@_ == 2 ? $_[0]->{'mode'} = $_[1] : shift->{'mode'}#;$yi=bless({$t,$wi,$v,$q,$w,$xi,$y,$z},$A);$zi={$vi,$yi};$Ai=q#/io/file_accessors.b#;$Bi=bless({$x5,$ui,$u6,$q,$v6,$q,$w6,$zi,$K,$Ai},$F6);$Ci={};$Di=[];$Ei=q#my ($class, $name, $mode) = @_;
+{name => $name,
  mode => $mode || 0644,
  r    => undef,
  w    => undef};#;$Fi=bless({$t,$Di,$v,$q,$w,$Ei,$y,$z},$A);$Gi={$r7,$Fi};$Hi=q#/io/file_init.b#;$Ii=bless({$x5,$Ci,$u6,$q,$v6,$q,$w6,$Gi,$K,$Hi},$F6);$Ji={};$Ki=q#(-X#;$Li=[];$Mi=q#my ($self, $test) = @_;
&{"-$test"}($$self{name});#;$Ni=bless({$t,$Li,$v,$q,$w,$Mi,$y,$z},$A);$Oi=q#mv#;$Pi=[];$Qi=q#my ($self, $dest) = @_;
$dest = $dest->name if ref $dest;
$self->io_check_true(*main::rename, $self->name, $dest);
$$self{name} = $dest;
$self;#;$Ri=bless({$t,$Pi,$v,$q,$w,$Qi,$y,$z},$A);$Si=q#rm#;$Ti=[];$Ui=q#my $self = shift;
$self->io_check_true(*main::unlink, $self->name);
$self;#;$Vi=bless({$t,$Ti,$v,$q,$w,$Ui,$y,$z},$A);$Wi={$Ki,$Ni,$Oi,$Ri,$Si,$Vi};$Xi=q#/io/file_fns.b#;$Yi=bless({$x5,$Ji,$u6,$q,$v6,$q,$w6,$Wi,$K,$Xi},$F6);$Zi={};$cj=q#atomic_update#;$dj=[];$ej=q#my $self = shift;
my $suffix = 0;
++$suffix while -e $self->name . ".$suffix";
ni('ni:/io/file_update_fd')->new(
  $self,
  $self->class->new($self->name . ".$suffix", $self->mode));#;$fj=bless({$t,$dj,$v,$q,$w,$ej,$y,$z},$A);$gj={$cj,$fj};$hj=q#/io/file_update.b#;$ij=bless({$x5,$Zi,$u6,$q,$v6,$q,$w6,$gj,$K,$hj},$F6);$jj={};$kj=[];$lj=q#my $self = shift;
$$self{r}->close if $$self{r};
$$self{w}->close if $$self{w};
$$self{r} = $$self{w} = undef;
$self;#;$mj=bless({$t,$kj,$v,$q,$w,$lj,$y,$z},$A);$nj=q#r#;$oj=[];$pj=q#my $self = shift;
$$self{r} ||= ni('ni:/io/fd')->new(
  $self->io_check_defined(
    *POSIX::open, $$self{name}, POSIX::O_RDONLY));#;$qj=bless({$t,$oj,$v,$q,$w,$pj,$y,$z},$A);$rj=[];$sj=q#shift->r->read(@_)#;$tj=bless({$t,$rj,$v,$q,$w,$sj,$y,$z},$A);$uj=q#w#;$vj=[];$wj=q#my $self = shift;
$$self{w} ||= ni('ni:/io/fd')->new(
  $self->io_check_defined(
    *POSIX::open, $$self{name},
      POSIX::O_WRONLY | POSIX::O_TRUNC | POSIX::O_CREAT,
      $$self{mode}));#;$xj=bless({$t,$vj,$v,$q,$w,$wj,$y,$z},$A);$yj=[];$zj=q#shift->w->write(@_)#;$Aj=bless({$t,$yj,$v,$q,$w,$zj,$y,$z},$A);$Bj={$ch,$mj,$nj,$qj,$gd,$tj,$uj,$xj,$od,$Aj};$Cj=q#/io/file_io.b#;$Dj=bless({$x5,$jj,$u6,$q,$v6,$q,$w6,$Bj,$K,$Cj},$F6);$Ej=[$ic,$ti,$Bi,$Ii,$Yi,$ij,$Dj];$Fj=bless({$x5,$mi,$K,$R2,$n6,$Ej},$G5);$Gj=q#ni:/io/file.c#;$Hj={$G5,1};$Ij=q#/io/file.c#;$Jj=[$Qc];$Kj=bless({$x5,$Hj,$K,$Ij,$n6,$Jj},$o6);$Lj=q#ni:/io/file_accessors.b#;$Mj=q#ni:/io/file_fns.b#;$Nj=q#ni:/io/file_init.b#;$Oj=q#ni:/io/file_io.b#;$Pj=q#ni:/io/file_readers.b#;$Qj=q#ni:/io/file_update.b#;$Rj=q#ni:/io/file_update_fd#;$Sj={$E7,1};$Tj={};$Uj=[];$Vj=q#my ($class, $file, $tempfile) = @_;
my $fd = $tempfile->w;
+{writer   => $fd,
  fd       => $fd->fd,
  wfh      => undef,
  tempfile => $tempfile,
  file     => $file};#;$Wj=bless({$t,$Uj,$v,$q,$w,$Vj,$y,$z},$A);$Xj={$r7,$Wj};$Yj=q#/io/file_update_fd_init.b#;$Zj=bless({$x5,$Tj,$u6,$q,$v6,$q,$w6,$Xj,$K,$Yj},$F6);$ck={};$dk=[];$ek=bless({$t,$dk,$v,$q,$w,$Yg,$y,$z},$A);$fk=[];$gk=q#my $self = shift;
close $$self{wfh} if $$self{wfh};
$$self{writer} = undef if $$self{writer};
if ($$self{tempfile}) {
  $$self{tempfile}->mv($$self{file}->name);
  $$self{tempfile} = undef;
}
$self;#;$hk=bless({$t,$fk,$v,$q,$w,$gk,$y,$z},$A);$ik={$ch,$hk};$jk=q#/io/file_update_fd_gc.b#;$kk=bless({$x5,$ck,$u6,$q,$v6,$ek,$w6,$ik,$K,$jk},$F6);$lk=[$ic,$qg,$Vg,$wh,$Zj,$kk];$mk=bless({$x5,$Sj,$K,$X2,$n6,$lk},$H5);$nk=q#ni:/io/file_update_fd.c#;$ok={$H5,1};$pk=q#/io/file_update_fd.c#;$qk=[$Qc];$rk=bless({$x5,$ok,$K,$pk,$n6,$qk},$o6);$sk=q#ni:/io/file_update_fd_gc.b#;$tk=q#ni:/io/file_update_fd_init.b#;$uk=q#ni:/io/named_io_fns.b#;$vk={};$wk=q#fcntl#;$xk=[];$yk=q#CORE::fcntl $_[0], $_[1], $_[2]#;$zk=bless({$t,$xk,$v,$q,$w,$yk,$y,$z},$A);$Ak=[];$Bk=q#CORE::fork#;$Ck=bless({$t,$Ak,$v,$q,$w,$Bk,$y,$z},$A);$Dk=q#open2#;$Ek=[];$Fk=q#CORE::open $_[0], $_[1]#;$Gk=bless({$t,$Ek,$v,$q,$w,$Fk,$y,$z},$A);$Hk=q#rename#;$Ik=[];$Jk=q#CORE::rename $_[0], $_[1]#;$Kk=bless({$t,$Ik,$v,$q,$w,$Jk,$y,$z},$A);$Lk=q#unlink#;$Mk=[];$Nk=q#CORE::unlink @_#;$Ok=bless({$t,$Mk,$v,$q,$w,$Nk,$y,$z},$A);$Pk=q#waitpid#;$Qk=[];$Rk=q#CORE::waitpid $_[0], $_[1]#;$Sk=bless({$t,$Qk,$v,$q,$w,$Rk,$y,$z},$A);$Tk={$wk,$zk,$Hf,$Ck,$Dk,$Gk,$Hk,$Kk,$Lk,$Ok,$Pk,$Sk};$Uk=q#/io/named_io_fns.b#;$Vk=bless({$x5,$vk,$u6,$q,$v6,$q,$w6,$Tk,$K,$Uk},$F6);$Wk=q#main#;$Xk=q#ni:/io/null#;$Yk={$F7,1};$Zk=q#/io/null#;$cl={};$dl=[];$el=q#+{fd => undef}#;$fl=bless({$t,$dl,$v,$q,$w,$el,$y,$z},$A);$gl={$r7,$fl};$hl=q#/io/null_init.b#;$il=bless({$x5,$cl,$u6,$q,$v6,$q,$w6,$gl,$K,$hl},$F6);$jl={};$kl=[];$ll=q#my $self = shift;
$$self{fd} ||= ni('ni:/io/fd')->new(
  $self->io_check_defined(*POSIX::open, '/dev/null', POSIX::O_RDWR));#;$ml=bless({$t,$kl,$v,$q,$w,$ll,$y,$z},$A);$nl=[];$ol=q#shift->fd->read(@_)#;$pl=bless({$t,$nl,$v,$q,$w,$ol,$y,$z},$A);$ql=[];$rl=q#shift->fd->write(@_)#;$sl=bless({$t,$ql,$v,$q,$w,$rl,$y,$z},$A);$tl={$Ze,$ml,$gd,$pl,$od,$sl};$ul=q#/io/null_io.b#;$vl=bless({$x5,$jl,$u6,$q,$v6,$q,$w6,$tl,$K,$ul},$F6);$wl=[$ic,$il,$vl];$xl=bless({$x5,$Yk,$K,$Zk,$n6,$wl},$I5);$yl=q#ni:/io/null.c#;$zl={$I5,1};$Al=q#/io/null.c#;$Bl=[$Qc];$Cl=bless({$x5,$zl,$K,$Al,$n6,$Bl},$o6);$Dl=q#ni:/io/null_init.b#;$El=q#ni:/io/null_io.b#;$Fl=q#ni:/io/object#;$Gl=q#ni:/io/object.c#;$Hl=q#ni:/io/object.c_transfer_def.b#;$Il=q#ni:/io/object_checks.b#;$Jl=q#ni:/io/object_constructors.b#;$Kl=q#ni:/io/object_memory.b#;$Ll=q#ni:/io/object_ops.b#;$Ml=q#ni:/io/object_transfer_async.b#;$Nl=q#ni:/io/object_transfer_sync.b#;$Ol=q#ni:/io/pid#;$Pl={$H7,1};$Ql={};$Rl=q#pid#;$Sl=[];$Tl=q#shift->{'pid'}#;$Ul=bless({$t,$Sl,$v,$q,$w,$Tl,$y,$z},$A);$Vl=q#status#;$Wl=[];$Xl=q#shift->{'status'}#;$Yl=bless({$t,$Wl,$v,$q,$w,$Xl,$y,$z},$A);$Zl={$Rl,$Ul,$Vl,$Yl};$cm=q#/io/pid_readers.b#;$dm=bless({$x5,$Ql,$u6,$q,$v6,$q,$w6,$Zl,$K,$cm},$F6);$em={};$fm=[];$gm=q#shift->await#;$hm=bless({$t,$fm,$v,$q,$w,$gm,$y,$z},$A);$im=[];$jm=q#my ($class, $pid, $argv, $env, %external_fds) = @_;
+{pid          => $pid,
  argv         => $argv,
  env          => $env,
  external_fds => \\%external_fds,
  status       => undef};#;$km=bless({$t,$im,$v,$q,$w,$jm,$y,$z},$A);$lm={$r7,$km};$mm=q#/io/pid_init.b#;$nm=bless({$x5,$em,$u6,$q,$v6,$hm,$w6,$lm,$K,$mm},$F6);$om={};$pm=q#await#;$qm=[];$rm=q#my $self = shift;
return $$self{status} if defined $$self{status};
$self->io_check_defined(*main::waitpid, $$self{pid}, 0);
$$self{status} = $?;#;$sm=bless({$t,$qm,$v,$q,$w,$rm,$y,$z},$A);$tm=q#running#;$um=[];$vm=q#not defined $_[0]->{status} and kill 0, $_[0]->{pid}#;$wm=bless({$t,$um,$v,$q,$w,$vm,$y,$z},$A);$xm={$pm,$sm,$tm,$wm};$ym=q#/io/pid_wait.b#;$zm=bless({$x5,$om,$u6,$q,$v6,$q,$w6,$xm,$K,$ym},$F6);$Am={};$Bm=[];$Cm=q#shift->stdout->read(@_)#;$Dm=bless({$t,$Bm,$v,$q,$w,$Cm,$y,$z},$A);$Em=[];$Fm=q#shift->stdin->write(@_)#;$Gm=bless({$t,$Em,$v,$q,$w,$Fm,$y,$z},$A);$Hm={$gd,$Dm,$od,$Gm};$Im=q#/io/pid_io.b#;$Jm=bless({$x5,$Am,$u6,$q,$v6,$q,$w6,$Hm,$K,$Im},$F6);$Km={};$Lm=[];$Mm=q#$_[0]->{external_fds}{$_[1]}#;$Nm=bless({$t,$Lm,$v,$q,$w,$Mm,$y,$z},$A);$Om=[];$Pm=q#shift->fd(2)#;$Qm=bless({$t,$Om,$v,$q,$w,$Pm,$y,$z},$A);$Rm=[];$Sm=q#shift->fd(0)#;$Tm=bless({$t,$Rm,$v,$q,$w,$Sm,$y,$z},$A);$Um=[];$Vm=q#shift->fd(1)#;$Wm=bless({$t,$Um,$v,$q,$w,$Vm,$y,$z},$A);$Xm={$Ze,$Nm,$ff,$Qm,$jf,$Tm,$nf,$Wm};$Ym=q#/io/pid_accessors.b#;$Zm=bless({$x5,$Km,$u6,$q,$v6,$q,$w6,$Xm,$K,$Ym},$F6);$cn=[$ic,$dm,$nm,$zm,$Jm,$Zm];$dn=bless({$x5,$Pl,$K,$w3,$n6,$cn},$K5);$en=q#ni:/io/pid.c#;$fn={$K5,1};$gn=q#/io/pid.c#;$hn=[$Qc];$in=bless({$x5,$fn,$K,$gn,$n6,$hn},$o6);$jn=q#ni:/io/pid_accessors.b#;$kn=q#ni:/io/pid_init.b#;$ln=q#ni:/io/pid_io.b#;$mn=q#ni:/io/pid_readers.b#;$nn=q#ni:/io/pid_wait.b#;$on=q#ni:/io/str#;$pn={$I7,1};$qn=q#/io/str#;$rn={};$sn=q#data#;$tn=[];$un=q#shift->{'data'}#;$vn=bless({$t,$tn,$v,$q,$w,$un,$y,$z},$A);$wn=q#end#;$xn=[];$yn=q#shift->{'end'}#;$zn=bless({$t,$xn,$v,$q,$w,$yn,$y,$z},$A);$An=q#start#;$Bn=[];$Cn=q#shift->{'start'}#;$Dn=bless({$t,$Bn,$v,$q,$w,$Cn,$y,$z},$A);$En={$sn,$vn,$wn,$zn,$An,$Dn};$Fn=q#/io/str_ro.b#;$Gn=bless({$x5,$rn,$u6,$q,$v6,$q,$w6,$En,$K,$Fn},$F6);$Hn={};$In=[];$Jn=q#my $class = shift;
+{data  => \\$_[0],
  start => $_[1] || 0,
  end   => $_[2] || length $_[0]};#;$Kn=bless({$t,$In,$v,$q,$w,$Jn,$y,$z},$A);$Ln={$r7,$Kn};$Mn=q#/io/str_init.b#;$Nn=bless({$x5,$Hn,$u6,$q,$v6,$q,$w6,$Ln,$K,$Mn},$F6);$On={};$Pn=[];$Qn=q#my $self = shift;
my $l    = ni::min($$self{end} - $$self{start}, $_[1]);
return 0 unless $l;
if ($_[2]) {
  substr $_[0], $_[2], $l, substr ${$$self{data}}, $$self{start}, $l;
} else {
  $_[0] = substr ${$$self{data}}, $$self{start}, $l;
}
$$self{start} += $l;
$l;#;$Rn=bless({$t,$Pn,$v,$q,$w,$Qn,$y,$z},$A);$Sn=q#remaining#;$Tn=[];$Un=q#my $self = shift; $$self{end} - $$self{start}#;$Vn=bless({$t,$Tn,$v,$q,$w,$Un,$y,$z},$A);$Wn=[];$Xn=q#my $self = shift;
${$$self{data}} .= $_[0];
$$self{start} += length $_[0];
$$self{end} = length ${$$self{data}};
length $_[0];#;$Yn=bless({$t,$Wn,$v,$q,$w,$Xn,$y,$z},$A);$Zn={$gd,$Rn,$Sn,$Vn,$od,$Yn};$co=q#/io/str_io.b#;$do=bless({$x5,$On,$u6,$q,$v6,$q,$w6,$Zn,$K,$co},$F6);$eo=[$ic,$Gn,$Nn,$do];$fo=bless({$x5,$pn,$K,$qn,$n6,$eo},$L5);$go=q#ni:/io/str.c#;$ho={$L5,1};$io=q#/io/str.c#;$jo=[$Qc];$ko=bless({$x5,$ho,$K,$io,$n6,$jo},$o6);$lo=q#ni:/io/str_init.b#;$mo=q#ni:/io/str_io.b#;$no=q#ni:/io/str_ro.b#;$oo=q#ni:/io/transfer#;$po={$J7,1,$K7,1,$L7,1};$qo=q#/io/transfer#;$ro={$J7,1,$K7,1,$L7,1,$W7,1};$so=q#/semantic/task#;$to={};$uo=[];$vo=q#shift->{'outcome'}#;$wo=bless({$t,$uo,$v,$q,$w,$vo,$y,$z},$A);$xo={$r,$wo};$yo=q#/semantic/task_ro.b#;$zo=bless({$x5,$to,$u6,$q,$v6,$q,$w6,$xo,$K,$yo},$F6);$Ao={};$Bo=q#failure#;$Co=[];$Do=q#my $self = shift;
$$self{outcome} = [0, @_];
$self->die($_[0]);#;$Eo=bless({$t,$Co,$v,$q,$w,$Do,$y,$z},$A);$Fo=q#success#;$Go=[];$Ho=q#my $self = shift;
$$self{outcome} = [1, @_];
$self;#;$Io=bless({$t,$Go,$v,$q,$w,$Ho,$y,$z},$A);$Jo={$Bo,$Eo,$Fo,$Io};$Ko=q#/semantic/task_outcome.b#;$Lo=bless({$x5,$Ao,$u6,$q,$v6,$q,$w6,$Jo,$K,$Ko},$F6);$Mo=[$l8,$zo,$Lo];$No=bless({$x5,$ro,$K,$so,$n6,$Mo},$l6);$Oo={};$Po=[];$Qo=q#my $self = shift;
@$self{qw/read_bytes read_time write_bytes write_time/} = (0, 0, 0, 0);#;$Ro=bless({$t,$Po,$v,$q,$w,$Qo,$y,$z},$A);$So=[];$To=q#my $self = shift;
my $start_time = time;
my $n = $$self{source_io}->read(@_);
my $end_time = time;
$$self{start_time} ||= $start_time;
$$self{read_bytes} += $n if defined $n;
$$self{read_time} += $end_time - $start_time;
$n;#;$Uo=bless({$t,$So,$v,$q,$w,$To,$y,$z},$A);$Vo=[];$Wo=q#my $self = shift;
my $start_time = time;
my $n = $$self{dest_io}->write(@_);
my $end_time = time;
$$self{write_bytes} += $n if defined $n;
$$self{write_time} += $end_time - $start_time;
$n;#;$Xo=bless({$t,$Vo,$v,$q,$w,$Wo,$y,$z},$A);$Yo={$gd,$Uo,$od,$Xo};$Zo=q#/io/transfer_io_interop.b#;$cp=bless({$x5,$Oo,$u6,$Ro,$v6,$q,$w6,$Yo,$K,$Zo},$F6);$dp={};$ep=q#pressure#;$fp=[];$gp=q#my $self = shift;
my $in_impedance  = log($$self{read_time}  || 1);
my $out_impedance = log($$self{write_time} || 1);
($out_impedance - $in_impedance) / log 20;#;$hp=bless({$t,$fp,$v,$q,$w,$gp,$y,$z},$A);$ip=q#read_limit_throughput#;$jp=[];$kp=q#my $self = shift;
$$self{read_bytes} / ($$self{read_time} || 1);#;$lp=bless({$t,$jp,$v,$q,$w,$kp,$y,$z},$A);$mp=q#throughput#;$np=[];$op=q#my $self = shift;
my $end_time = $$self{end_time} || time;
my $dt       = $end_time - $$self{start_time} || 1;
$$self{write_bytes} / $dt;#;$pp=bless({$t,$np,$v,$q,$w,$op,$y,$z},$A);$qp=q#write_limit_throughput#;$rp=[];$sp=q#my $self = shift;
$$self{write_bytes} / ($$self{write_time} || 1);#;$tp=bless({$t,$rp,$v,$q,$w,$sp,$y,$z},$A);$up={$ep,$hp,$ip,$lp,$mp,$pp,$qp,$tp};$vp=q#/io/transfer_io_measurement.b#;$wp=bless({$x5,$dp,$u6,$q,$v6,$q,$w6,$up,$K,$vp},$F6);$xp=[$No,$cp,$wp];$yp=bless({$x5,$po,$K,$qo,$n6,$xp},$M5);$zp=[];$Ap=q#my $self = shift;
ni('ni:/io/object')->def_transfer_method($self, $1)
  if $self->name =~ /transfer_(\\w+)$/;#;$Bp=bless({$t,$zp,$v,$q,$w,$Ap,$y,$z},$A);$Cp=q#ni:/io/transfer.c#;$Dp={$M5,1,$N5,1,$O5,1};$Ep=q#/io/transfer.c#;$Fp={$M5,1,$N5,1,$O5,1,$l6,1};$Gp=q#/semantic/task.c#;$Hp=[$V9];$Ip=bless({$x5,$Fp,$K,$Gp,$n6,$Hp},$o6);$Jp={};$Kp={};$Lp=q#/io/transfer.c_into.b#;$Mp=bless({$x5,$Jp,$u6,$Bp,$v6,$q,$w6,$Kp,$K,$Lp},$F6);$Np=[$Ip,$Mp];$Op=bless({$x5,$Dp,$K,$Ep,$n6,$Np},$o6);$Pp=q#ni:/io/transfer.c_into.b#;$Qp=q#ni:/io/transfer_async#;$Rp={$K7,1};$Sp=q#/io/transfer_async#;$Tp={};$Up=q#dest_io#;$Vp=[];$Wp=q#shift->{'dest_io'}#;$Xp=bless({$t,$Vp,$v,$q,$w,$Wp,$y,$z},$A);$Yp=q#id#;$Zp=[];$cq=q#shift->{'id'}#;$dq=bless({$t,$Zp,$v,$q,$w,$cq,$y,$z},$A);$eq=q#source_io#;$fq=[];$gq=q#shift->{'source_io'}#;$hq=bless({$t,$fq,$v,$q,$w,$gq,$y,$z},$A);$iq={$Up,$Xp,$Yp,$dq,$eq,$hq};$jq=q#/io/transfer_async_ro.b#;$kq=bless({$x5,$Tp,$u6,$q,$v6,$q,$w6,$iq,$K,$jq},$F6);$lq={};$mq=[];$nq=q#my ($class, $source, $dest) = @_;
$source->nonblock(1) if $source->can('nonblock');
$dest  ->nonblock(1) if $dest  ->can('nonblock');
+{source_io => $source,
  dest_io   => $dest,
  pending   => '',
  outcome   => undef,
  id        => $class->new_id};#;$oq=bless({$t,$mq,$v,$q,$w,$nq,$y,$z},$A);$pq={$r7,$oq};$qq=q#/io/transfer_async_init.b#;$rq=bless({$x5,$lq,$u6,$q,$v6,$q,$w6,$pq,$K,$qq},$F6);$sq={};$tq=[];$uq=q#ni('ni:/io/transfer_async')->track(shift)#;$vq=bless({$t,$tq,$v,$q,$w,$uq,$y,$z},$A);$wq=[];$xq=q#ni('ni:/io/transfer_async')->untrack(shift->{id})#;$yq=bless({$t,$wq,$v,$q,$w,$xq,$y,$z},$A);$zq={};$Aq=q#/io/transfer_async_lifecycle.b#;$Bq=bless({$x5,$sq,$u6,$vq,$v6,$yq,$w6,$zq,$K,$Aq},$F6);$Cq={};$Dq=q#run#;$Eq=[];$Fq=q#shift#;$Gq=bless({$t,$Eq,$v,$q,$w,$Fq,$y,$z},$A);$Hq=q#run_async#;$Iq=[];$Jq=q#my $self = shift;
my $n;

\# Step one: write everything in the pending queue, if possible. Invariant
\# after this if() condition is that $$self{pending} is empty unless there
\# was something preventing IO.
if (length $$self{pending}) {
write_branch:
  $n = 0;
  while ($n < length $$self{pending}) {
    my $x = $self->write($n ? substr($$self{pending}, $n)
                            : $$self{pending});
    last unless defined $x;
    $n += $x;
  }
  $$self{pending} = substr $$self{pending}, $n;
}

\# Step two: load more data into $$self{pending} and, if successful, go
\# back to step one and write it.
unless (length $$self{pending}) {
  goto write_branch if $n = $self->read($$self{pending}, 32768);
  return $self if $!{EINTR} || $!{EAGAIN} || $!{EWOULDBLOCK};
  if (defined $n) {
    $$self{end_time} = time;
    return $self->success;
  } else {
    $self->failure($!);
  }
}

$self;#;$Kq=bless({$t,$Iq,$v,$q,$w,$Jq,$y,$z},$A);$Lq={$Dq,$Gq,$Hq,$Kq};$Mq=q#/io/transfer_async_run.b#;$Nq=bless({$x5,$Cq,$u6,$q,$v6,$q,$w6,$Lq,$K,$Mq},$F6);$Oq=[$yp,$kq,$rq,$Bq,$Nq];$Pq=q#tracked_transfers#;$Qq={};$Rq=q#transfer_id#;$Sq=bless({$x5,$Rp,$K,$Sp,$n6,$Oq,$Pq,$Qq,$Rq,0},$N5);$Tq=[];$Uq=q#my $self = shift;
$$self{tracked_transfers} = {};
$$self{transfer_id}       = 0;#;$Vq=bless({$t,$Tq,$v,$q,$w,$Uq,$y,$z},$A);$Wq=q#ni:/io/transfer_async.c#;$Xq={$N5,1};$Yq=q#/io/transfer_async.c#;$Zq={};$cr=q#new_id#;$dr=[];$er=q#++shift->{transfer_id}#;$fr=bless({$t,$dr,$v,$q,$w,$er,$y,$z},$A);$gr=q#track#;$hr=[];$ir=q#my ($self, $transfer) = @_;
Scalar::Util::weaken($$self{tracked_transfers}{$transfer->id} = $transfer);
$self;#;$jr=bless({$t,$hr,$v,$q,$w,$ir,$y,$z},$A);$kr=q#untrack#;$lr=[];$mr=q#my ($self, $id) = @_;
delete $$self{tracked_transfers}{$id};
$self;#;$nr=bless({$t,$lr,$v,$q,$w,$mr,$y,$z},$A);$or={$cr,$fr,$gr,$jr,$kr,$nr};$pr=q#/io/transfer_async.c_tracker.b#;$qr=bless({$x5,$Zq,$u6,$Vq,$v6,$q,$w6,$or,$K,$pr},$F6);$rr=[$Op,$qr];$sr=bless({$x5,$Xq,$K,$Yq,$n6,$rr},$o6);$tr=q#ni:/io/transfer_async.c_tracker.b#;$ur=q#ni:/io/transfer_async_init.b#;$vr=q#ni:/io/transfer_async_lifecycle.b#;$wr=q#ni:/io/transfer_async_ro.b#;$xr=q#ni:/io/transfer_async_run.b#;$yr=q#ni:/io/transfer_io_interop.b#;$zr=q#ni:/io/transfer_io_measurement.b#;$Ar=q#ni:/io/transfer_sync#;$Br={$L7,1};$Cr=q#/io/transfer_sync#;$Dr={};$Er=[];$Fr=q#my ($class, $source, $dest) = @_;
+{source_io => $source,
  dest_io   => $dest};#;$Gr=bless({$t,$Er,$v,$q,$w,$Fr,$y,$z},$A);$Hr={$r7,$Gr};$Ir=q#/io/transfer_sync_init.b#;$Jr=bless({$x5,$Dr,$u6,$q,$v6,$q,$w6,$Hr,$K,$Ir},$F6);$Kr={};$Lr=[];$Mr=q#my $self = shift;
my $bufsize = $$self{bufsize} || 32768;
my $buf;
my $r;
while (($r = $self->read($buf, $bufsize)) || $!{EINTR}) {
  my $n = $self->write($buf);
  $self->failure($!) unless $n || $!{EINTR};
  while ($n < $r) {
    my $n0 = $self->write($buf, $r - $n, $n);
    $self->failure($!) unless $!{EINTR} || $n0;
    $n += $n0 || 0;
  }
}
$$self{end_time} = time;
$self->success;#;$Nr=bless({$t,$Lr,$v,$q,$w,$Mr,$y,$z},$A);$Or={$Dq,$Nr};$Pr=q#/io/transfer_sync_run.b#;$Qr=bless({$x5,$Kr,$u6,$q,$v6,$q,$w6,$Or,$K,$Pr},$F6);$Rr=[$yp,$Jr,$Qr];$Sr=bless({$x5,$Br,$K,$Cr,$n6,$Rr},$O5);$Tr=q#ni:/io/transfer_sync.c#;$Ur={$O5,1};$Vr=q#/io/transfer_sync.c#;$Wr=[$Op];$Xr=bless({$x5,$Ur,$K,$Vr,$n6,$Wr},$o6);$Yr=q#ni:/io/transfer_sync_init.b#;$Zr=q#ni:/io/transfer_sync_run.b#;$cs=q#ni:/lib/accessor.b#;$ds=q#ni:/lib/behavior#;$es=q#ni:/lib/behavior.c#;$fs=q#ni:/lib/branch#;$gs={$H6,1};$hs=q#/lib/branch#;$is={};$js=q#local $_;
my $class = shift;
my $name  = shift;
+{name       => $name,
  applied_to => {},
  slices     => [map $class->resolve($_), @_]};#;$ks=bless({$w,$js,$y,$z},$A);$ls={$r7,$ks};$ms=q#/lib/branch_init.b#;$ns=bless({$x5,$is,$u6,$q,$v6,$q,$w6,$ls,$K,$ms},$F6);$os=[$v8,$N6,$G6,$ns,$u9];$ps=bless({$x5,$gs,$K,$hs,$n6,$os},$Q5);$qs=q#ni:/lib/branch.b#;$rs=q#ni:/lib/branch.c#;$ss={$Q5,1};$ts=q#/lib/branch.c#;$us=[$Z9];$vs=bless({$x5,$ss,$K,$ts,$n6,$us},$o6);$ws=q#ni:/lib/branch_init.b#;$xs=q#ni:/lib/class_init.b#;$ys=q#ni:/lib/dataslice#;$zs={$N7,1};$As=q#/lib/dataslice#;$Bs={};$Cs=q#my $class = shift;
my $name = shift;
+{name => $name, data => {@_}};#;$Ds=bless({$w,$Cs,$y,$z},$A);$Es={$r7,$Ds};$Fs=q#/lib/dataslice_init.b#;$Gs=bless({$x5,$Bs,$u6,$q,$v6,$q,$w6,$Es,$K,$Fs},$F6);$Hs={};$Is=q#local $_;
my ($self, $p) = @_;
$p = $p->package if ref $p;
return if $$self{applied_to}{$p};
$$self{applied_to}{$p} = 1;
*{"$p\\::$_"} = $$self{data}{$_} for keys %{$$self{data}};
$self;#;$Js=bless({$w,$Is,$y,$z},$A);$Ks={$A6,$Js};$Ls=q#/lib/dataslice_apply.b#;$Ms=bless({$x5,$Hs,$u6,$q,$v6,$q,$w6,$Ks,$K,$Ls},$F6);$Ns=[$v8,$Gs,$Ms];$Os=bless({$x5,$zs,$K,$As,$n6,$Ns},$R5);$Ps=q#ni:/lib/dataslice.c#;$Qs={$R5,1};$Rs=q#/lib/dataslice.c#;$Ss=[$Z9];$Ts=bless({$x5,$Qs,$K,$Rs,$n6,$Ss},$o6);$Us=q#ni:/lib/dataslice_apply.b#;$Vs=q#ni:/lib/dataslice_init.b#;$Ws=q#ni:/lib/definition.b#;$Xs=q#ni:/lib/definition_def.b#;$Ys=q#ni:/lib/definition_defdata.b#;$Zs=q#ni:/lib/definition_init_with_defaults.b#;$ct=q#ni:/lib/doc#;$dt={$M,1};$et={};$ft=q#shift; +{name => shift, doc => []}#;$gt=bless({$w,$ft,$y,$z},$A);$ht={$r7,$gt};$it=q#/lib/doc_init.b#;$jt=bless({$x5,$et,$u6,$q,$v6,$q,$w6,$ht,$K,$it},$F6);$kt={};$lt=q#'ni.doc'#;$mt=bless({$w,$lt,$y,$z},$A);$nt={$Q6,$mt};$ot=q#/lib/doc_namespace.b#;$pt=bless({$x5,$kt,$u6,$q,$v6,$q,$w6,$nt,$K,$ot},$F6);$qt={};$rt=q#my $self = shift;
(my $method = ${__PACKAGE__ . "::AUTOLOAD"}) =~ s/^.*:://;
push @{$$self{doc}}, [$method, map $self->fix_indentation($_), @_];
$self;#;$st=bless({$w,$rt,$y,$z},$A);$tt=q#fix_indentation#;$ut=q#my ($self, $x) = @_;
return $x if ref $x;
my @lines = split /\\n/, $x;
return $x unless @lines > 1;
my $indent = $lines[1] =~ /^(\\s*)/ && length $1;
for (@lines[2..$\#lines]) {
  my $li = /^(\\s*)/ && length $1;
  $indent = length $1 if length $1 < $indent;
}
my $spaces = ' ' x $indent;
s/^$spaces// for @lines;
join "\\n", @lines;#;$vt=bless({$w,$ut,$y,$z},$A);$wt={$qa,$st,$tt,$vt};$xt=q#/lib/doc_define.b#;$yt=bless({$x5,$qt,$u6,$q,$v6,$q,$w6,$wt,$K,$xt},$F6);$zt={};$At=q#shift->referent#;$Bt=bless({$w,$At,$y,$z},$A);$Ct=q#referent#;$Dt=q#ni 'ni:' . shift->{name}#;$Et=bless({$w,$Dt,$y,$z},$A);$Ft={$wn,$Bt,$Ct,$Et};$Gt=q#/lib/doc_end.b#;$Ht=bless({$x5,$zt,$u6,$q,$v6,$q,$w6,$Ft,$K,$Gt},$F6);$It={};$Jt=q#my $self = shift;
push @{$$self{doc}}, [eg => eg($_)] for @_;
$self;#;$Kt=bless({$w,$Jt,$y,$z},$A);$Lt=q#linearized#;$Mt=q#map @$_, @{shift->{doc}}#;$Nt=bless({$w,$Mt,$y,$z},$A);$Ot=q#tests#;$Pt=q#my $self = shift;
grep ref($_) eq 'lib/test_case', $self->linearized;#;$Qt=bless({$w,$Pt,$y,$z},$A);$Rt={$c3,$Kt,$Lt,$Nt,$Ot,$Qt};$St=q#/lib/doc_test.b#;$Tt=bless({$x5,$It,$u6,$q,$v6,$q,$w6,$Rt,$K,$St},$F6);$Ut=[$l8,$N6,$jt,$pt,$yt,$Ht,$Tt];$Vt=bless({$x5,$dt,$K,$X3,$n6,$Ut},$S5);$Wt=q#ni:/lib/doc.c#;$Xt={$S5,1};$Yt=q#/lib/doc.c#;$Zt=[$V9];$cu=bless({$x5,$Xt,$K,$Yt,$n6,$Zt},$o6);$du=q#ni:/lib/doc_define.b#;$eu=q#ni:/lib/doc_end.b#;$fu=q#ni:/lib/doc_init.b#;$gu=q#ni:/lib/doc_namespace.b#;$hu=q#ni:/lib/doc_test.b#;$iu=q#ni:/lib/documentable.b#;$ju=q#ni:/lib/fn#;$ku={$A,1};$lu=q#/lib/fn#;$mu=q#my $self = shift;
return $$self{closure} unless @_;
$$self{closure} = {@_};
$self;#;$nu=bless({$w,$mu,$y,$z},$A);$ou=q#\# NB: everything here needs to happen in a single method; otherwise JIT
\# compilation will cause infinite recursion.
local ($@, $_);
my $self = shift;
$$self{proto} ||= '';

my ($en) = ni::eval('__FILE__') =~ /eval (\\d+)/;
$$self{eval_number} = ++$en;
Scalar::Util::weaken(${'lib/fn::evals'}{$en} = $self);

my $fn_code = qq{sub $$self{proto} {$$self{code}\\n}};

my $closure = $$self{closure};
if ($closure) {
  my $closure_code = join ';',
    map /^([@%])/ ? "my$_=$1\\{\\${\\$_[0]}{'$_'}\\}"
      : /^\\$/     ? "my$_=\\${\\$_[0]}{'$_'}"
      :             "my\\$$_=\\${\\$_[0]}{'$_'}",
    sort keys %$closure;

  my $code   = qq{sub {$closure_code; $fn_code}};
  my $fn_gen = ni::eval $code;
  die "ni:/lib/fn failed to compile $code: $@" if $@;
  return $$self{fn} = &$fn_gen($closure);
} else {
  $$self{fn} = ni::eval $fn_code;
  die "ni:/lib/fn failed to compile $fn_code: $@" if $@;
  return $$self{fn};
}#;$pu=bless({$w,$ou},$A);$qu=q#my $class = shift;
my $code  = pop;
my $proto = @_ && $_[-1] =~ /^\\(/ ? pop : '';
+{code        => $code,
  proto       => $proto,
  closure     => undef,
  eval_number => undef,
  annotations => [@_]};#;$ru=bless({$w,$qu},$A);$su=q#lib/fn::closure#;$tu=q#lib/fn::compile#;$uu=q#lib/fn::instantiate#;$vu={};$wu=q#my $self = shift;
delete ${'lib/fn::evals'}{$$self{eval_number}}
  if defined $$self{eval_number};#;$xu=bless({$w,$wu,$y,$z},$A);$yu=q#compile#;$zu={$v,$nu,$yu,$pu,$r7,$ru};$Au=q#/lib/fn_init.b#;$Bu=bless({$x5,$vu,$u6,$q,$v6,$xu,$w6,$zu,$K,$Au},$F6);$Cu={};$Du=[];$Eu=q#shift->{'annotations'}#;$Fu=bless({$t,$Du,$v,$q,$w,$Eu,$y,$z},$A);$Gu=[];$Hu=q#shift->{'code'}#;$Iu=bless({$t,$Gu,$v,$q,$w,$Hu,$y,$z},$A);$Ju=q#eval_number#;$Ku=[];$Lu=q#shift->{'eval_number'}#;$Mu=bless({$t,$Ku,$v,$q,$w,$Lu,$y,$z},$A);$Nu=q#fn#;$Ou=[];$Pu=q#shift->{'fn'}#;$Qu=bless({$t,$Ou,$v,$q,$w,$Pu,$y,$z},$A);$Ru={$t,$Fu,$w,$Iu,$Ju,$Mu,$Nu,$Qu};$Su=q#/lib/fn_ro.b#;$Tu=bless({$x5,$Cu,$u6,$q,$v6,$q,$w6,$Ru,$K,$Su},$F6);$Uu={};$Vu=[];$Wu=q#my $self = shift; "fn {$$self{code}}"#;$Xu=bless({$t,$Vu,$v,$q,$w,$Wu,$y,$z},$A);$Yu=[];$Zu=bless({$t,$Yu,$v,$q,$w,$Y8,$y,$z},$A);$cv={$Q8,$Xu,$X8,$Zu};$dv=q#/lib/fn_ops.b#;$ev=bless({$x5,$Uu,$u6,$q,$v6,$q,$w6,$cv,$K,$dv},$F6);$fv={};$gv=q#serialize#;$hv=[];$iv=q#local $_;
my ($self, $quote) = @_;
$quote->quote_class(ref $self);

(my $code = $$self{code}) =~ s/^\\s*\\n|\\s*$//g;
my @lines = split /\\n/, $code;
my $spaces = length $code;
for (@lines) {
  $spaces = length $1 if /^([ \\t]*)\\S/ && length $1 < $spaces;
}
$spaces = ' ' x $spaces;
s/^$spaces// for @lines;

my %state = %$self;
delete @state{qw/fn eval_number/};
$state{code} = join "\\n", @lines;
$quote->quote_blessed(\\%state, ref $self);#;$jv=bless({$t,$hv,$v,$q,$w,$iv,$y,$z},$A);$kv={$gv,$jv};$lv=q#/lib/fn_serialize.b#;$mv=bless({$x5,$fv,$u6,$q,$v6,$q,$w6,$kv,$K,$lv},$F6);$nv=[$l8,$D9,$Bu,$Tu,$ev,$mv];$ov=bless({$x5,$ku,$K,$lu,$n6,$nv},$T5);$pv=[];$qv=q#my $self = shift;
$SIG{__WARN__} = sub {warn $self->resolve_evals(shift), @_};
$SIG{__DIE__}  = sub {die  $self->resolve_evals(shift), @_};#;$rv=bless({$t,$pv,$v,$q,$w,$qv,$y,$z},$A);$sv=q#ni:/lib/fn.c#;$tv={$T5,1};$uv=q#/lib/fn.c#;$vv={};$wv=q#resolve_evals#;$xv=[];$yv=q#my ($self, $trace) = @_;
1 while $trace =~ s\#\\(eval (\\d+)\\)\#
  ${'lib/fn::evals'}{$1}{code} || "(anonymous eval $1)"\#eg;
$trace;#;$zv=bless({$t,$xv,$v,$q,$w,$yv,$y,$z},$A);$Av={$wv,$zv};$Bv=q#/lib/fn.c_resolve_eval.b#;$Cv=bless({$x5,$vv,$u6,$rv,$v6,$q,$w6,$Av,$K,$Bv},$F6);$Dv=[$V9,$Cv];$Ev=bless({$x5,$tv,$K,$uv,$n6,$Dv},$o6);$Fv=q#ni:/lib/fn.c_resolve_eval.b#;$Gv=q#ni:/lib/fn_init.b#;$Hv=q#ni:/lib/fn_ops.b#;$Iv=q#ni:/lib/fn_ro.b#;$Jv=q#ni:/lib/fn_serialize.b#;$Kv=q#ni:/lib/future#;$Lv={$O7,1};$Mv={};$Nv=[];$Ov=bless({$t,$Nv,$v,$q,$w,$vo,$y,$z},$A);$Pv=q#parents#;$Qv=[];$Rv=q#shift->{'parents'}#;$Sv=bless({$t,$Qv,$v,$q,$w,$Rv,$y,$z},$A);$Tv={$r,$Ov,$Pv,$Sv};$Uv=q#/lib/future_ro.b#;$Vv=bless({$x5,$Mv,$u6,$q,$v6,$q,$w6,$Tv,$K,$Uv},$F6);$Wv={};$Xv=[];$Yv=q#my $class = shift;
+{v         => undef,
  parents   => [@_],
  listeners => [],
  outcome   => undef};#;$Zv=bless({$t,$Xv,$v,$q,$w,$Yv,$y,$z},$A);$cw={$r7,$Zv};$dw=q#/lib/future_init.b#;$ew=bless({$x5,$Wv,$u6,$q,$v6,$q,$w6,$cw,$K,$dw},$F6);$fw={};$gw=q#decide#;$hw=[];$iw=q#local $_;
my $self = shift;
die "ni:/lib/future: cannot change a decided future"
  if $$self{outcome};
$$self{outcome} = [1, @_];
$$self{v} = [@_];
defined && &$_(@_) for @{$$self{listeners}};
$$self{parents} = $$self{listeners} = undef;
$self;#;$jw=bless({$t,$hw,$v,$q,$w,$iw,$y,$z},$A);$kw=q#decided#;$lw=[];$mw=q#shift->{outcome}#;$nw=bless({$t,$lw,$v,$q,$w,$mw,$y,$z},$A);$ow=q#listener#;$pw=[];$qw=q#my ($self, $l) = @_;
$$self{outcome}
  ? &$l(@{$$self{v}})
  : push @{$$self{listeners}}, $l;
$self;#;$rw=bless({$t,$pw,$v,$q,$w,$qw,$y,$z},$A);$sw=q#v#;$tw=[];$uw=q#my $v = shift->{v};
return undef unless $v;
@$v;#;$vw=bless({$t,$tw,$v,$q,$w,$uw,$y,$z},$A);$ww={$gw,$jw,$kw,$nw,$ow,$rw,$sw,$vw};$xw=q#/lib/future_state.b#;$yw=bless({$x5,$fw,$u6,$q,$v6,$q,$w6,$ww,$K,$xw},$F6);$zw={};$Aw=q#and#;$Bw=[];$Cw=q#my $self   = $_[0];
my $child  = $self->class->new(grep ref, @_);
my $n      = @{$child->parents};
my $l      = 0;
my @result = map ref($_) ? undef : $_, @_;
for my $i (0..$\#_) {
  $_[$i]->listener(sub {
    $result[$i] = [@_];
    $child->decide(@result) if ++$l == $n;
  }) if ref $_[$i];
}
$child;#;$Dw=bless({$t,$Bw,$v,$q,$w,$Cw,$y,$z},$A);$Ew=q#flatmap#;$Fw=[];$Gw=q#my ($self, $f) = @_;
my $child = $self->class->new($self);
$self->listener(sub {&$f(@_)->listener(sub {$child->decide(@_)})});
$child;#;$Hw=bless({$t,$Fw,$v,$q,$w,$Gw,$y,$z},$A);$Iw=q#map#;$Jw=[];$Kw=q#my ($self, $f) = @_;
my $child = $self->class->new($self);
$self->listener(sub {$child->decide(&$f(@_))});
$child;#;$Lw=bless({$t,$Jw,$v,$q,$w,$Kw,$y,$z},$A);$Mw=q#or#;$Nw=[];$Ow=q#local $_;
my $self    = $_[0];
my $child   = $self->class->new(@_);
my $trigger = sub {$child->decide(@_) unless $child->decided};
$_->listener($trigger) for @_;
$child;#;$Pw=bless({$t,$Nw,$v,$q,$w,$Ow,$y,$z},$A);$Qw={$Aw,$Dw,$Ew,$Hw,$Iw,$Lw,$Mw,$Pw};$Rw=q#/lib/future_algebra.b#;$Sw=bless({$x5,$zw,$u6,$q,$v6,$q,$w6,$Qw,$K,$Rw},$F6);$Tw=[$l8,$Vv,$ew,$yw,$Sw];$Uw=bless({$x5,$Lv,$K,$q4,$n6,$Tw},$U5);$Vw=q#ni:/lib/future.c#;$Ww={$U5,1};$Xw=q#/lib/future.c#;$Yw=[$V9];$Zw=bless({$x5,$Ww,$K,$Xw,$n6,$Yw},$o6);$cx=q#ni:/lib/future_algebra.b#;$dx=q#ni:/lib/future_init.b#;$ex=q#ni:/lib/future_ro.b#;$fx=q#ni:/lib/future_state.b#;$gx=q#ni:/lib/gensym_generator_compact.b#;$hx={};$ix=q#gensym#;$jx=[];$kx=q#my $n = shift->{gensym_n}++;
my $s = '$' .
  substr "cdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
         $n % 50, 1;
$n = int $n / 50;
while ($n) {
  $s .= substr "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",
               $n % 63, 1;
  $n = int $n / 63;
}
$s;#;$lx=bless({$t,$jx,$v,$q,$w,$kx,$y,$z},$A);$mx={$ix,$lx};$nx=q#/lib/gensym_generator_compact.b#;$ox=bless({$x5,$hx,$u6,$q,$v6,$q,$w6,$mx,$K,$nx},$F6);$px=q#ni:/lib/global_static_test.b#;$qx={};$rx=[];$sx=q#ni('ni:/lib/test_case')->new(shift)#;$tx=q#($)#;$ux=bless({$t,$rx,$v,$q,$w,$sx,$y,$tx},$A);$vx=q#now#;$wx=[];$xx=q#ni('ni:/lib/test_value')->new(shift)#;$yx=bless({$t,$wx,$v,$q,$w,$xx,$y,$tx},$A);$zx={$c3,$ux,$vx,$yx};$Ax=q#/lib/global_static_test.b#;$Bx=bless({$x5,$qx,$u6,$q,$v6,$q,$w6,$zx,$K,$Ax},$F6);$Cx=q#ni:/lib/image#;$Dx={$P7,1};$Ex={};$Fx=[];$Gx=q#+{gensym_n     => 0,
  circular     => [],
  definitions  => {},
  objects      => {},
  side_effects => [],
  finalizers   => [],
  visited      => {},
  ordering     => []};#;$Hx=bless({$t,$Fx,$v,$q,$w,$Gx,$y,$z},$A);$Ix={$r7,$Hx};$Jx=q#/lib/image_init.b#;$Kx=bless({$x5,$Ex,$u6,$q,$v6,$q,$w6,$Ix,$K,$Jx},$F6);$Lx={};$Mx=q#boot_side_effect#;$Nx=[];$Ox=q#unshift @{${$_[0]}{side_effects}}, $_[1]; $_[0]#;$Px=bless({$t,$Nx,$v,$q,$w,$Ox,$y,$z},$A);$Qx=q#finalizer#;$Rx=[];$Sx=q#push    @{${$_[0]}{finalizers}},   $_[1]; $_[0]#;$Tx=bless({$t,$Rx,$v,$q,$w,$Sx,$y,$z},$A);$Ux=q#io#;$Vx=[];$Wx=q#local $_;
my $self = shift;
ni('ni:/io/str')->new(join '',
  "\#!/usr/bin/env perl\\n",
  "chomp(\\$ni::license=<<'_');\\n", $ni::license, "\\n_\\n",
  "BEGIN{eval(\\$ni::boot=<<'_')}\\n", $ni::boot, "\\n_\\n",
  $self->reconstruction,
  "ni->run(\\@ARGV);",
  "\\n__DATA__\\n");#;$Xx=bless({$t,$Vx,$v,$q,$w,$Wx,$y,$z},$A);$Yx=q#reconstruction#;$Zx=[];$cy=q#my $self = shift;
(@{$$self{definitions}}{@{$$self{ordering}}},
 $self->circular_links,
 @{$$self{side_effects}},
 @{$$self{finalizers}});#;$dy=bless({$t,$Zx,$v,$q,$w,$cy,$y,$z},$A);$ey=q#side_effect#;$fy=[];$gy=q#push    @{${$_[0]}{side_effects}}, $_[1]; $_[0]#;$hy=bless({$t,$fy,$v,$q,$w,$gy,$y,$z},$A);$iy={$Mx,$Px,$Qx,$Tx,$Ux,$Xx,$Yx,$dy,$ey,$hy};$jy=q#/lib/image_quoting.b#;$ky=bless({$x5,$Lx,$u6,$q,$v6,$q,$w6,$iy,$K,$jy},$F6);$ly={};$my=q#quote_code#;$ny=[];$oy=q#my ($self, $code) = @_;
my $message;
eval {
  require B::Deparse;
  $message = "can't quote perl native fn: "
           . B::Deparse->new->coderef2text($code);
};
die $message || "can't quote perl CODE refs (make B::Deparse available "
              . "for more info)";#;$py=bless({$t,$ny,$v,$q,$w,$oy,$y,$z},$A);$qy={$my,$py};$ry=q#/lib/quote_code_fail.b#;$sy=bless({$x5,$ly,$u6,$q,$v6,$q,$w6,$qy,$K,$ry},$F6);$ty={};$uy=q#quote_array#;$vy=[];$wy=q#local $_;
my ($self, $v) = @_;
$self->is_circular($$v[$_]) && $self->circular_arrayref($v, $_, $$v[$_])
  for 0..$\#{$v};
'[' . join(',', map $self->quote($_), @$v) . ']';#;$xy=bless({$t,$vy,$v,$q,$w,$wy,$y,$z},$A);$yy=q#quote_hash#;$zy=[];$Ay=q#local $_;
my ($self, $v) = @_;
my @ks = sort keys %$v;
my @qs;
for my $k (@ks) {
  $self->circular_hashref($v, $k, $$v{$k})
    if $self->is_circular($$v{$k});
  push @qs, $self->quote($k) . "," . $self->quote($$v{$k});
}
'{' . join(",", @qs) . '}';#;$By=bless({$t,$zy,$v,$q,$w,$Ay,$y,$z},$A);$Cy=q#quote_scalar#;$Dy=[];$Ey=q#my $v = $_[1];
return 'undef' unless defined $v;
return $v if Scalar::Util::looks_like_number $v;
$v =~ s/([\\\\\#])/\\\\$1/g;
"q\#$v\#";#;$Fy=bless({$t,$Dy,$v,$q,$w,$Ey,$y,$z},$A);$Gy=q#quote_scalar_ref#;$Hy=[];$Iy=q#'\\\\' . shift->quote(${$_[0]})#;$Jy=bless({$t,$Hy,$v,$q,$w,$Iy,$y,$z},$A);$Ky=q#quote_value#;$Ly=[];$My=q#my $self = shift;
return $self->quote_scalar($_[0])     unless ref $_[0];
return $self->quote_scalar_ref($_[0]) if 'SCALAR' eq ref $_[0];
return $self->quote_array($_[0])      if 'ARRAY'  eq ref $_[0];
return $self->quote_hash($_[0])       if 'HASH'   eq ref $_[0];
return $self->quote_code($_[0])       if 'CODE'   eq ref $_[0];
$self->quote_object($_[0]);#;$Ny=bless({$t,$Ly,$v,$q,$w,$My,$y,$z},$A);$Oy={$uy,$xy,$yy,$By,$Cy,$Fy,$Gy,$Jy,$Ky,$Ny};$Py=q#/lib/quote_values.b#;$Qy=bless({$x5,$ty,$u6,$q,$v6,$q,$w6,$Oy,$K,$Py},$F6);$Ry={};$Sy=q#quote_blessed#;$Ty=[];$Uy=q#my ($self, $x, $r) = @_;
$r ||= ref $x;
$self->quote_class($r);
my $t = Scalar::Util::reftype $x;
my $quoted = $t eq 'HASH' ? $self->quote_hash($x) : $self->quote_array($x);
"bless($quoted," . $self->quote($r) . ")";#;$Vy=bless({$t,$Ty,$v,$q,$w,$Uy,$y,$z},$A);$Wy=q#quote_class#;$Xy=[];$Yy=q#my ($self, $class) = @_;
$self->quote(ni"ni:$class") if ni->exists("ni:$class");#;$Zy=bless({$t,$Xy,$v,$q,$w,$Yy,$y,$z},$A);$cz=q#quote_object#;$dz=[];$ez=q#local $_;
my $self = shift;
my $q = $self->allocate_gensym($_[0],
  $_[0]->can('serialize') ? $_[0]->serialize($self) : $self->quote_blessed(@_));
$self->finalizer('&' . $self->quote($_) . "($q);")
  for @{ref($_[0]) . '::ctors'};
$q;#;$fz=bless({$t,$dz,$v,$q,$w,$ez,$y,$z},$A);$gz={$Sy,$Vy,$Wy,$Zy,$cz,$fz};$hz=q#/lib/quote_objects.b#;$iz=bless({$x5,$Ry,$u6,$q,$v6,$q,$w6,$gz,$K,$hz},$F6);$jz={};$kz=q#circular_arrayref#;$lz=[];$mz=q#my $self          = shift;
my $address       = $self->address(shift);
my $index         = shift;
my $value_address = $self->address(shift);
push @{$$self{circular}}, [$address, "[$index]", $value_address];
$self;#;$nz=bless({$t,$lz,$v,$q,$w,$mz,$y,$z},$A);$oz=q#circular_hashref#;$pz=[];$qz=q#my $self          = shift;
my $address       = $self->address(shift);
my $quoted_key    = $self->quote(shift);
my $value_address = $self->address(shift);
push @{$$self{circular}}, [$address, "{$quoted_key}", $value_address];
$self;#;$rz=bless({$t,$pz,$v,$q,$w,$qz,$y,$z},$A);$sz=q#is_circular#;$tz=[];$uz=q#my $self = shift;
ref $$self{visited}{$self->address(shift)};#;$vz=bless({$t,$tz,$v,$q,$w,$uz,$y,$z},$A);$wz={$kz,$nz,$oz,$rz,$sz,$vz};$xz=q#/lib/quote_circular_addressed.b#;$yz=bless({$x5,$jz,$u6,$q,$v6,$q,$w6,$wz,$K,$xz},$F6);$zz={};$Az=q#address#;$Bz=[];$Cz=q#return 'undef' unless defined $_[1];
return "id:$_[1]" if !ref $_[1] && length $_[1] < 256;
"addr:" . Scalar::Util::refaddr(ref $_[1] ? $_[1] : \\$_[1]);#;$Dz=bless({$t,$Bz,$v,$q,$w,$Cz,$y,$z},$A);$Ez=q#allocate_gensym#;$Fz=[];$Gz=q#my $self = shift;
my $a = $self->address(shift);
return $$self{visited}{$a} if $_[0] =~ /^\\$\\w+$/;
my $g = $$self{visited}{$a} = $self->gensym;
$$self{definitions}{$g} = "$g=$_[0];";
push @{$$self{ordering}}, $g;
$g;#;$Hz=bless({$t,$Fz,$v,$q,$w,$Gz,$y,$z},$A);$Iz=q#circular_links#;$Jz=[];$Kz=q#local $_;
my $self = shift;
map "\\$$$self{visited}{$$_[0]}$$_[1]=$$self{visited}{$$_[2]};",
    @{$$self{circular}};#;$Lz=bless({$t,$Jz,$v,$q,$w,$Kz,$y,$z},$A);$Mz=q#quote#;$Nz=[];$Oz=q#my $self = shift;
return $self->quote_scalar($_[0])
  if !ref $_[0] && Scalar::Util::looks_like_number($_[0]);
my $a = $self->address($_[0]);
$$self{objects}{$a} = \\$_[0];
my $v = $$self{visited}{$a};
return ref $v ? '0' : $v if defined $v;
$$self{visited}{$a} = \\'undef';
$self->allocate_gensym($_[0], $self->quote_value($_[0]));#;$Pz=bless({$t,$Nz,$v,$q,$w,$Oz,$y,$z},$A);$Qz={$Az,$Dz,$Ez,$Hz,$Iz,$Lz,$Mz,$Pz};$Rz=q#/lib/quote_gensym_identity.b#;$Sz=bless({$x5,$zz,$u6,$q,$v6,$q,$w6,$Qz,$K,$Rz},$F6);$Tz=[$l8,$Kx,$ky,$sy,$Qy,$iz,$yz,$Sz,$ox];$Uz=bless({$x5,$Dx,$K,$y4,$n6,$Tz},$V5);$Vz=q#ni:/lib/image.c#;$Wz={$V5,1};$Xz=q#/lib/image.c#;$Yz=[$V9];$Zz=bless({$x5,$Wz,$K,$Xz,$n6,$Yz},$o6);$cA=q#ni:/lib/image_init.b#;$dA=q#ni:/lib/image_quoting.b#;$eA=q#ni:/lib/instance.b#;$fA=q#ni:/lib/instantiable.b#;$gA=q#ni:/lib/json.b#;$hA={};$iA=q#json_decode#;$jA=[];$kA=q#local $_;
my @v = [];
for ($_[0] =~ /[][{}]|true|false|null|"(?:[^"\\\\]+|\\\\.)*"|[-+eE\\d.]+/g) {
  if (/^[[{]$/) {
    push @v, [];
  } elsif (/^\\]$/) {
    die "json_decode $_[0]: too many closing brackets" if @v < 2;
    push @{$v[-2]}, $v[-1];
    pop @v;
  } elsif (/^\\}$/) {
    die "json_decode $_[0]: too many closing brackets" if @v < 2;
    push @{$v[-2]}, {@{$v[-1]}};
    pop @v;
  } else {
    push @{$v[-1]}, /^"/      ? json_unescape $_
                  : /^true$/  ? 1
                  : /^false$/ ? 0
                  : /^null$/  ? undef
                  :             0 + $_;
  }
}
my $r = pop @v;
die "json_decode $_[0]: not enough closing brackets" if @v;
wantarray ? @$r : $$r[0];#;$lA=bless({$t,$jA,$v,$q,$w,$kA,$y,$tx},$A);$mA=q#json_encode#;$nA=[];$oA=q#local $_;
my ($v) = @_;
return "[" . join(',', map ni::json_encode($_), @$v) . "]" if 'ARRAY' eq ref $v;
return "{" . join(',', map ni::json_escape($_) . ":" . ni::json_encode($$v{$_}),
                           sort keys %$v) . "}" if 'HASH' eq ref $v;
Scalar::Util::looks_like_number $v
  ? $v
  : defined $v ? ni::json_escape($v) : 'null';#;$pA=bless({$t,$nA,$v,$q,$w,$oA,$y,$tx},$A);$qA=q#json_encode_pretty#;$rA=[];$sA=q#local $_;
my ($v, $indent) = @_;
$indent ||= 0;
my $spaces = ' ' x $indent;
return "$spaces\\[\\n"
     . join(",\\n", map ni::json_encode_pretty($_, $indent + 2), @$v)
     . "$spaces]" if 'ARRAY' eq ref $v;

return "$spaces\\{\\n"
     . join(",\\n", map "$spaces  " . ni::json_escape($_) . ":\\n"
                                   . ni::json_encode_pretty($$v{$_}, $indent + 2),
                       sort keys %$v)
     . "$spaces\\}" if 'HASH' eq ref $v;

$spaces . ni::json_encode($v);#;$tA=bless({$t,$rA,$v,$q,$w,$sA,$y,$z},$A);$uA=q#json_escape#;$vA=[];$wA=q#(my $x = shift) =~ s/([\\b\\f\\n\\r\\t"\\\\])/"\\\\" . ($ni::json_escapes{$1} || "")/eg;
"\\"$x\\"";#;$xA=bless({$t,$vA,$v,$q,$w,$wA,$y,$tx},$A);$yA=q#json_unescape#;$zA=[];$AA=q#my $x = substr shift, 1, -1;
$x =~ s/\\\\(["\\\\\\/bfnrt]|u[0-9a-fA-F]{4})/ni::json_unescape_one($1)/eg;
$x;#;$BA=bless({$t,$zA,$v,$q,$w,$AA,$y,$tx},$A);$CA=q#json_unescape_one#;$DA=[];$EA=q#$ni::json_unescapes{$_[0]} || chr hex substr $_[0], 1#;$FA=bless({$t,$DA,$v,$q,$w,$EA,$y,$tx},$A);$GA={$iA,$lA,$mA,$pA,$qA,$tA,$uA,$xA,$yA,$BA,$CA,$FA};$HA=q#/lib/json.b#;$IA=bless({$x5,$hA,$u6,$q,$v6,$q,$w6,$GA,$K,$HA},$F6);$JA=q#ni#;$KA=q#ni:/lib/name_as_string.b#;$LA=q#ni:/lib/named.b#;$MA=q#ni:/lib/named_in_ni.b#;$NA=q#ni:/lib/namespaced.b#;$OA=q#ni:/lib/ni#;$PA={$Q7,1};$QA={};$RA=q#extend#;$SA=q#my $self = shift;
for (@_) {
  my $r = do $_;
  die "ni: failed to parse $_: $@" if $@;
  die "ni: failed to execute $_: $!" unless defined $r;
}
$self;#;$TA=bless({$w,$SA,$y,$z},$A);$UA=q#is_mutable#;$VA=q#$0 ne '-' && -w $0#;$WA=bless({$w,$VA,$y,$z},$A);$XA=q#modify#;$YA=q#my ($self, $fn) = @_;
die "ni: cannot modify immutable instance $0" unless $self->is_mutable;
my (undef, undef, $mode) = stat $0;
&$fn(ni('ni:/io/file')->new($0, $mode)->atomic_update);#;$ZA=bless({$w,$YA,$y,$z},$A);$cB={$RA,$TA,$UA,$WA,$XA,$ZA};$dB=q#/lib/ni_self.b#;$eB=bless({$x5,$QA,$u6,$q,$v6,$q,$w6,$cB,$K,$dB},$F6);$fB={};$gB=q#--internal/+=#;$hB=q#my $self = shift;
$self->extend($_) for @_;
my $q = $self->quoted;
$self->modify(sub {$q->io->into_sync(shift)});
0;#;$iB=bless({$w,$hB,$y,$z},$A);$jB=q#--internal/eval#;$kB=q#my $self = shift;
for (@_) {
  my $r = ni::eval($_);
  print $@ ? "ERROR $@\\n" : "$r\\n";
}
0;#;$lB=bless({$w,$kB,$y,$z},$A);$mB=q#--internal/image#;$nB=q#shift->quoted->io->into_sync(ni"fd:1");
0;#;$oB=bless({$w,$nB,$y,$z},$A);$pB=q#--internal/test#;$qB=q#local $| = 1;
my $self   = shift;
my $failed = 0;
my @tests  = map ni($_)->tests, grep /^ni\\.doc:/, keys %{$$self{named}};
my %named  = %{$$ni::self{named}};
for (@tests) {
  $_->run;
  %{$$ni::self{named}} = %named;
  print '.';
}
print "\\n";
for my $f (grep $_->failed, @tests) {
  ++$failed;
  print "\\nTEST FAIL\\n", $f->test, "\\n";
  print "\\nERROR ", ni('ni:/lib/fn')->resolve_evals($f->error)
    if $f->error;
  print "\\nASSERTIONS\\n";
  print "  $_\\n" for @{$f->assertions};
}

print "\\nSUMMARY\\n";
printf "% 4d test(s) passed\\n", @tests - $failed;
printf "% 4d test(s) failed\\n", $failed;
!!$failed;#;$rB=bless({$w,$qB,$y,$z},$A);$sB=q#my $self = shift;
shift, exit $self->$1(@_) if $_[0] =~ /^(--.*)$/ && $self->can($1);
exit $self->default(@_);#;$tB=bless({$w,$sB,$y,$z},$A);$uB={$gB,$iB,$jB,$lB,$mB,$oB,$pB,$rB,$Dq,$tB};$vB=q#/lib/ni_main.b#;$wB=bless({$x5,$fB,$u6,$q,$v6,$q,$w6,$uB,$K,$vB},$F6);$xB={};$yB=q#my $self = shift;
return $$self{named}{$_[0]} if exists $$self{named}{$_[0]};
return $$self{resolvers}{$1}->($_[0]) if
  $_[0] =~ /^([^:]+):/ and exists $$self{resolvers}{$1};
die "ni:self failed to resolve $_[0]";#;$zB=bless({$w,$yB,$y,$z},$A);$AB=q#resolver_for#;$BB=q#my $self = shift;
${$$self{resolvers}}{$_[0]} = $_[1];
$self;#;$CB=bless({$w,$BB,$y,$z},$A);$DB={$g7,$zB,$AB,$CB};$EB=q#/lib/ni_resolver.b#;$FB=bless({$x5,$xB,$u6,$q,$v6,$q,$w6,$DB,$K,$EB},$F6);$GB={};$HB=q#exists#;$IB=q#exists $_[0]->{named}{$_[1]}#;$JB=bless({$w,$IB,$y,$z},$A);$KB=q#quoted#;$LB=q#my $self = shift;
my $q = ni('ni:/lib/image')->new(@_);
my $gs = $q->quote($self);
$q->side_effect("\\$ni::self=$gs;");
$q;#;$MB=bless({$w,$LB,$y,$z},$A);$NB={$HB,$JB,$KB,$MB};$OB=q#/lib/ni_image.b#;$PB=bless({$x5,$GB,$u6,$q,$v6,$q,$w6,$NB,$K,$OB},$F6);$QB=[$l8,$eB,$wB,$FB,$PB];$RB=bless({$x5,$PA,$K,$G4,$n6,$QB},$W5);$SB=q#ni:/lib/ni.c#;$TB={$W5,1};$UB=q#/lib/ni.c#;$VB=[$V9];$WB=bless({$x5,$TB,$K,$UB,$n6,$VB},$o6);$XB=q#ni:/lib/ni_image.b#;$YB=q#ni:/lib/ni_main.b#;$ZB=q#ni:/lib/ni_resolver.b#;$cC=q#ni:/lib/ni_self.b#;$dC=q#ni:/lib/ni_static_util.b#;$eC={};$fC=q#abbrev#;$gC=[];$hC=q#length($_[0]) < $_[1] ? $_[0] : substr($_[0], 0, $_[1] - 3) . '...'#;$iC=bless({$t,$gC,$v,$q,$w,$hC,$y,$z},$A);$jC=q#dor#;$kC=[];$lC=q#defined $_[0] ? $_[0] : $_[1]#;$mC=bless({$t,$kC,$v,$q,$w,$lC,$y,$z},$A);$nC=q#indent#;$oC=[];$pC=q#my ($s, $indent) = (@_, 2);
join "\\n", map ' ' x $indent . $_, split /\\n/, $s;#;$qC=bless({$t,$oC,$v,$q,$w,$pC,$y,$z},$A);$rC=q#max#;$sC=[];$tC=q#local $_; my $m = pop @_; $m = $m >  $_ ? $m : $_ for @_; $m#;$uC=bless({$t,$sC,$v,$q,$w,$tC,$y,$z},$A);$vC=q#maxstr#;$wC=[];$xC=q#local $_; my $m = pop @_; $m = $m gt $_ ? $m : $_ for @_; $m#;$yC=bless({$t,$wC,$v,$q,$w,$xC,$y,$z},$A);$zC=q#mean#;$AC=[];$BC=q#sum(@_) / (@_ || 1)#;$CC=bless({$t,$AC,$v,$q,$w,$BC,$y,$z},$A);$DC=q#min#;$EC=[];$FC=q#local $_; my $m = pop @_; $m = $m <  $_ ? $m : $_ for @_; $m#;$GC=bless({$t,$EC,$v,$q,$w,$FC,$y,$z},$A);$HC=q#minstr#;$IC=[];$JC=q#local $_; my $m = pop @_; $m = $m lt $_ ? $m : $_ for @_; $m#;$KC=bless({$t,$IC,$v,$q,$w,$JC,$y,$z},$A);$LC=q#sgr#;$MC=[];$NC=q#(my $x = $_[0]) =~ s/$_[1]/$_[2]/g; $x#;$OC=bless({$t,$MC,$v,$q,$w,$NC,$y,$z},$A);$PC=q#sr#;$QC=[];$RC=q#(my $x = $_[0]) =~ s/$_[1]/$_[2]/;  $x#;$SC=bless({$t,$QC,$v,$q,$w,$RC,$y,$z},$A);$TC=q#sum#;$UC=[];$VC=q#local $_; my $x = 0; $x += $_ for @_; $x#;$WC=bless({$t,$UC,$v,$q,$w,$VC,$y,$z},$A);$XC=q#swap#;$YC=[];$ZC=q#@_[0, 1] = @_[1, 0]#;$cD=bless({$t,$YC,$v,$q,$w,$ZC,$y,$z},$A);$dD={$fC,$iC,$jC,$mC,$nC,$qC,$rC,$uC,$vC,$yC,$zC,$CC,$DC,$GC,$HC,$KC,$LC,$OC,$PC,$SC,$TC,$WC,$XC,$cD};$eD=q#/lib/ni_static_util.b#;$fD=bless({$x5,$eC,$u6,$q,$v6,$q,$w6,$dD,$K,$eD},$F6);$gD=q#ni:/lib/perlbranch.b#;$hD=q#ni:/lib/quote_circular_addressed.b#;$iD=q#ni:/lib/quote_code_fail.b#;$jD=q#ni:/lib/quote_gensym_identity.b#;$kD=q#ni:/lib/quote_objects.b#;$lD=q#ni:/lib/quote_simple#;$mD={$R7,1};$nD={};$oD=[];$pD=q#+{}#;$qD=bless({$t,$oD,$v,$q,$w,$pD,$y,$z},$A);$rD={$r7,$qD};$sD=q#/lib/quote_simple_init.b#;$tD=bless({$x5,$nD,$u6,$q,$v6,$q,$w6,$rD,$K,$sD},$F6);$uD={};$vD=[];$wD=bless({$t,$vD,$v,$q,$w,0,$y,$z},$A);$xD=[];$yD=q#shift->quote_value(shift)#;$zD=bless({$t,$xD,$v,$q,$w,$yD,$y,$z},$A);$AD={$sz,$wD,$Mz,$zD};$BD=q#/lib/quote_simple_quote.b#;$CD=bless({$x5,$uD,$u6,$q,$v6,$q,$w6,$AD,$K,$BD},$F6);$DD=[$l8,$tD,$CD,$sy,$Qy,$iz];$ED=bless({$x5,$mD,$K,$R4,$n6,$DD},$X5);$FD=q#ni:/lib/quote_simple.c#;$GD={$X5,1};$HD=q#/lib/quote_simple.c#;$ID=[$V9];$JD=bless({$x5,$GD,$K,$HD,$n6,$ID},$o6);$KD=q#ni:/lib/quote_simple_init.b#;$LD=q#ni:/lib/quote_simple_quote.b#;$MD=q#ni:/lib/quote_values.b#;$ND=q#ni:/lib/ref_eq.b#;$OD=q#ni:/lib/resolver.b#;$PD=q#ni:/lib/slice#;$QD={$F6,1};$RD=q#local $_;
my ($self, $p) = @_;
$p = $p->package if ref $p;
die "/lib/slice.b->apply('$p'): perl packages don't start with "
  . "slashes (this fails on older versions of perl)" if $p =~ /^\\//;
return if $$self{applied_to}{$p};
for (keys %{$$self{methods}}) {
  die "$self: overlapping method $p\\::$_" if defined *{"$p\\::$_"}{CODE};
}
$self->apply_($p);#;$SD=bless({$w,$RD},$A);$TD=q#local $_;
my ($self, $p) = @_;
return if $$self{applied_to}{$p};
$$self{applied_to}{$p} = 1;
push @{"$p\\::ctors"}, $$self{ctor} if $$self{ctor};
push @{"$p\\::dtors"}, $$self{dtor} if $$self{dtor};
if (grep /^\\(/, keys %{$$self{methods}}) {
  *{"$p\\::()"} = sub {};
  *{"$p\\::OVERLOAD"} = {};
}
*{"$p\\::$_"} = \\&{$$self{methods}{$_}} for keys %{$$self{methods}};
$self;#;$UD=bless({$w,$TD},$A);$VD=q#lib/slice::apply#;$WD=q#lib/slice::apply_#;$XD={};$YD=q#apply_#;$ZD={$A6,$SD,$YD,$UD};$cE=q#/lib/slice.b#;$dE=bless({$x5,$XD,$w6,$ZD,$K,$cE},$F6);$eE={};$fE=q#my $class = shift;
my $name  = shift;
my %args  = @_;
+{ctor       => delete($args{ctor}),
  dtor       => delete($args{dtor}),
  applied_to => delete($args{applied_to}),
  name       => $name,
  methods    => \\%args};#;$gE=bless({$w,$fE,$y,$z},$A);$hE={$r7,$gE};$iE=q#/lib/slice_init.b#;$jE=bless({$x5,$eE,$w6,$hE,$K,$iE},$F6);$kE={};$lE=[];$mE=q#local $_;
my ($self, $quote) = @_;
my $name = $self->name;
$quote->quote_class(ref $self);

if (defined $name and $name eq 'ni:/lib/slice.b' || $name eq 'ni:/lib/fn_init.b') {
  my %methods;
  my @ks = sort keys %{$$self{methods}};
  @methods{@ks} = map $quote->quote($_), @{$$self{methods}}{@ks};
  for my $p (sort keys %{$$self{applied_to}}) {
    $quote->boot_side_effect(
      '*' . $quote->quote("$p\\::$_") . "=\\\\\\&$methods{$_};")
      for @ks;
  }
}

my $g = $quote->allocate_gensym($self,
  $quote->quote_blessed({%$self, applied_to => {}}, ref $self));
$quote->side_effect("$g\\->apply_(" . $quote->quote($_) . ");")
  for sort keys %{$$self{applied_to}};
$g;#;$nE=bless({$t,$lE,$v,$q,$w,$mE,$y,$z},$A);$oE={$gv,$nE};$pE=q#/lib/slice_serialize.b#;$qE=bless({$x5,$kE,$u6,$q,$v6,$q,$w6,$oE,$K,$pE},$F6);$rE=[$v8,$N6,$dE,$jE,$qE];$sE=bless({$x5,$QD,$K,$o5,$n6,$rE},$Y5);$tE=q#ni:/lib/slice.b#;$uE=q#ni:/lib/slice.c#;$vE={$Y5,1};$wE=q#/lib/slice.c#;$xE=[$Z9];$yE=bless({$x5,$vE,$K,$wE,$n6,$xE},$o6);$zE=q#ni:/lib/slice_init.b#;$AE=q#ni:/lib/slice_serialize.b#;$BE=q#ni:/lib/static_fn.b#;$CE={};$DE=q#fc#;$EE=[];$FE=q#ni('ni:/lib/fn')->new(pop)->closure(@_)#;$GE=bless({$t,$EE,$v,$q,$w,$FE,$y,$z},$A);$HE=q#fk#;$IE=[];$JE=q#ni('ni:/lib/fn')->closure('@x' => [@_], q{wantarray ? @x : $x[0]});#;$KE=bless({$t,$IE,$v,$q,$w,$JE,$y,$tx},$A);$LE=[];$ME=q#ni('ni:/lib/fn')->new(@_)#;$NE=bless({$t,$LE,$v,$q,$w,$ME,$y,$tx},$A);$OE=q#fp#;$PE=[];$QE=q#($$)#;$RE=bless({$t,$PE,$v,$q,$w,$ME,$y,$QE},$A);$SE={$DE,$GE,$HE,$KE,$Nu,$NE,$OE,$RE};$TE=q#/lib/static_fn.b#;$UE=bless({$x5,$CE,$u6,$q,$v6,$q,$w6,$SE,$K,$TE},$F6);$VE=q#ni:/lib/subclass.b#;$WE=q#ni:/lib/tag#;$XE={$O6,1};$YE=q#/lib/tag#;$ZE={};$cF=q#local $_;
my ($self, $p) = @_;
$_->apply($p) for @{$$self{slices}};
$self;#;$dF=bless({$w,$cF,$y,$z},$A);$eF={$A6,$dF};$fF=q#/lib/tag.b#;$gF=bless({$x5,$ZE,$u6,$q,$v6,$q,$w6,$eF,$K,$fF},$F6);$hF={};$iF=q#local $_;
my $class = shift;
my $name  = shift;
+{name   => $name,
  slices => [map $class->resolve($_), @_]};#;$jF=bless({$w,$iF,$y,$z},$A);$kF={$r7,$jF};$lF=q#/lib/tag_init.b#;$mF=bless({$x5,$hF,$u6,$q,$v6,$q,$w6,$kF,$K,$lF},$F6);$nF=[$v8,$N6,$gF,$mF];$oF=bless({$x5,$XE,$K,$YE,$n6,$nF},$Z5);$pF=q#ni:/lib/tag.b#;$qF=q#ni:/lib/tag.c#;$rF={$Z5,1};$sF=q#/lib/tag.c#;$tF=[$Z9];$uF=bless({$x5,$rF,$K,$sF,$n6,$tF},$o6);$vF=q#ni:/lib/tag_init.b#;$wF=q#ni:/lib/test_assert_eq#;$xF={$S7,1};$yF=q#/lib/test_assert_eq#;$zF={$S7,1,$T7,1};$AF=q#/lib/test_assertion#;$BF={};$CF=q#commit#;$DF=[];$EF=q#my $self = shift;
my $test = ni('ni:/lib/test_case')->running_test;
push @{$test->assertions}, $self->result;
$self;#;$FF=bless({$t,$DF,$v,$q,$w,$EF,$y,$z},$A);$GF={$CF,$FF};$HF=q#/lib/test_assertion_commit.b#;$IF=bless({$x5,$BF,$u6,$q,$v6,$q,$w6,$GF,$K,$HF},$F6);$JF=[$l8,$IF];$KF=bless({$x5,$zF,$K,$AF,$n6,$JF},$d6);$LF={};$MF=[];$NF=q#my ($class, $diff) = @_;
+{diff => $diff};#;$OF=bless({$t,$MF,$v,$q,$w,$NF,$y,$z},$A);$PF={$r7,$OF};$QF=q#/lib/test_assert_eq_init.b#;$RF=bless({$x5,$LF,$u6,$q,$v6,$q,$w6,$PF,$K,$QF},$F6);$SF={};$TF=[];$UF=q#my $self = shift;
$self->failed ? "FAIL " . ni::json_encode_pretty $$self{diff}
              : "PASS";#;$VF=bless({$t,$TF,$v,$q,$w,$UF,$y,$z},$A);$WF=q#failed#;$XF=[];$YF=q#defined shift->{diff}#;$ZF=bless({$t,$XF,$v,$q,$w,$YF,$y,$z},$A);$cG=q#result#;$dG=[];$eG=bless({$t,$dG,$v,$q,$w,$Fq,$y,$z},$A);$fG={$Q8,$VF,$WF,$ZF,$cG,$eG};$gG=q#/lib/test_assert_eq_result.b#;$hG=bless({$x5,$SF,$u6,$q,$v6,$q,$w6,$fG,$K,$gG},$F6);$iG=[$KF,$RF,$hG];$jG=bless({$x5,$xF,$K,$yF,$n6,$iG},$c6);$kG=q#ni:/lib/test_assert_eq.c#;$lG={$c6,1};$mG=q#/lib/test_assert_eq.c#;$nG={$c6,1,$d6,1};$oG=q#/lib/test_assertion.c#;$pG=[$V9];$qG=bless({$x5,$nG,$K,$oG,$n6,$pG},$o6);$rG=[$qG];$sG=bless({$x5,$lG,$K,$mG,$n6,$rG},$o6);$tG=q#ni:/lib/test_assert_eq_init.b#;$uG=q#ni:/lib/test_assert_eq_result.b#;$vG=q#ni:/lib/test_assertion#;$wG=q#ni:/lib/test_assertion.c#;$xG=q#ni:/lib/test_assertion_commit.b#;$yG=q#ni:/lib/test_case#;$zG={$C,1};$AG=q#/lib/test_case#;$BG=q#running_test#;$CG={};$DG=[];$EG=q#shift->{'assertions'}#;$FG=bless({$t,$DG,$v,$q,$w,$EG,$y,$z},$A);$GG=[];$HG=q#shift->{'test'}#;$IG=bless({$t,$GG,$v,$q,$w,$HG,$y,$z},$A);$JG={$n,$FG,$s,$IG};$KG=q#/lib/test_case_ro.b#;$LG=bless({$x5,$CG,$u6,$q,$v6,$q,$w6,$JG,$K,$KG},$F6);$MG={};$NG=[];$OG=q#@_ == 2 ? $_[0]->{'error'} = $_[1] : shift->{'error'}#;$PG=bless({$t,$NG,$v,$q,$w,$OG,$y,$z},$A);$QG={$p,$PG};$RG=q#/lib/test_case_rw.b#;$SG=bless({$x5,$MG,$u6,$q,$v6,$q,$w6,$QG,$K,$RG},$F6);$TG={};$UG=[];$VG=q#my $class = shift;
my $test  = fn shift;
+{test       => $test,
  assertions => [],
  error      => undef,
  outcome    => undef};#;$WG=bless({$t,$UG,$v,$q,$w,$VG,$y,$z},$A);$XG={$r7,$WG};$YG=q#/lib/test_case_init.b#;$ZG=bless({$x5,$TG,$u6,$q,$v6,$q,$w6,$XG,$K,$YG},$F6);$cH={};$dH=[];$eH=q#my $self = shift;
join '', $self->failed  ? 'FAIL ' : 'PASS ',
         $self->error   ? 'E'     : ':',
         map $_->failed ? 'X'     : '.', @{$$self{assertions}};#;$fH=bless({$t,$dH,$v,$q,$w,$eH,$y,$z},$A);$gH=[];$hH=q#!shift->{outcome}->[0]#;$iH=bless({$t,$gH,$v,$q,$w,$hH,$y,$z},$A);$jH={$Q8,$fH,$WF,$iH};$kH=q#/lib/test_case_metrics.b#;$lH=bless({$x5,$cH,$u6,$q,$v6,$q,$w6,$jH,$K,$kH},$F6);$mH={};$nH=q#done#;$oH=[];$pH=q#my $self = shift;
my @failed = grep $_->failed, @{$$self{assertions}};
my $any_failed = @failed || defined $$self{error};
$$self{outcome} = [!$any_failed, $$self{error}, @failed];#;$qH=bless({$t,$oH,$v,$q,$w,$pH,$y,$z},$A);$rH=[];$sH=q#local $_;
my $self = shift;
$self->class->with_test($self, \\&{$$self{test}});
$self;#;$tH=bless({$t,$rH,$v,$q,$w,$sH,$y,$z},$A);$uH={$nH,$qH,$Dq,$tH};$vH=q#/lib/test_case_run.b#;$wH=bless({$x5,$mH,$u6,$q,$v6,$q,$w6,$uH,$K,$vH},$F6);$xH=[$l8,$LG,$SG,$ZG,$lH,$wH];$yH=bless({$x5,$zG,$K,$AG,$BG,$q,$n6,$xH},$e6);$zH=[];$AH=q#shift->{running_test} = undef#;$BH=bless({$t,$zH,$v,$q,$w,$AH,$y,$z},$A);$CH=q#ni:/lib/test_case.c#;$DH={$e6,1};$EH=q#/lib/test_case.c#;$FH={};$GH=[];$HH=q#shift->{'running_test'}#;$IH=bless({$t,$GH,$v,$q,$w,$HH,$y,$z},$A);$JH={$BG,$IH};$KH=q#/lib/test_case.c_test_ro.b#;$LH=bless({$x5,$FH,$u6,$q,$v6,$q,$w6,$JH,$K,$KH},$F6);$MH={};$NH=q#with_test#;$OH=[];$PH=q#my ($self, $test, $f) = @_;
local $$self{running_test} = $test;
eval {&$f};
$test->error($@) if $@;
$test->done;#;$QH=bless({$t,$OH,$v,$q,$w,$PH,$y,$z},$A);$RH={$NH,$QH};$SH=q#/lib/test_case.c_test.b#;$TH=bless({$x5,$MH,$u6,$BH,$v6,$q,$w6,$RH,$K,$SH},$F6);$UH=[$V9,$LH,$TH];$VH=bless({$x5,$DH,$K,$EH,$n6,$UH},$o6);$WH=q#ni:/lib/test_case.c_test.b#;$XH=q#ni:/lib/test_case.c_test_ro.b#;$YH=q#ni:/lib/test_case_init.b#;$ZH=q#ni:/lib/test_case_metrics.b#;$cI=q#ni:/lib/test_case_ro.b#;$dI=q#ni:/lib/test_case_run.b#;$eI=q#ni:/lib/test_case_rw.b#;$fI=q#ni:/lib/test_value#;$gI={$U7,1};$hI=q#/lib/test_value#;$iI={};$jI=[];$kI=q#\\$_[1]#;$lI=bless({$t,$jI,$v,$q,$w,$kI,$y,$z},$A);$mI={$r7,$lI};$nI=q#/lib/test_value_init.b#;$oI=bless({$x5,$iI,$u6,$q,$v6,$q,$w6,$mI,$K,$nI},$F6);$pI={};$qI=q#(==#;$rI=[];$sI=q#my ($self, $rhs) = @_;
ni('ni:/lib/test_assert_eq')
  ->new($self->diff($rhs))
  ->commit;#;$tI=bless({$t,$rI,$v,$q,$w,$sI,$y,$z},$A);$uI=q#detailed_scalar_diff#;$vI=[];$wI=q#local $_;
my ($self, $lhs, $rhs) = @_;
my $lpos = 0;
my $rpos = 0;
my @diff;
while ($lpos < length $lhs || $rpos < length $rhs) {
  my $found = index $rhs, substr($lhs, $lpos, 16), $rpos;
  if ($found == -1) {
    if (@diff && $diff[-1]{delete}) {
      $diff[-1]{delete} .= substr($lhs, $lpos, 16);
    } else {
      push @diff, {delete => substr($lhs, $lpos, 16)};
    }
    $lpos += 16;
  } else {
    push @diff, {insert => substr($rhs, $rpos, $found - $rpos)}
      unless $found == $rpos;
    $lpos += 16;
    $rpos = $found + 16;
  }
}
[@diff];#;$xI=bless({$t,$vI,$v,$q,$w,$wI,$y,$z},$A);$yI=q#diff#;$zI=[];$AI=q#my ($self, $rhs) = @_;
my $class = $self->class;
my $lhs = $$self;
my $rl = ref $lhs;
my $rr = ref $rhs;
my $realtype = Scalar::Util::reftype($lhs) || "";
return {type_difference => [$rl, $rr]} unless $rl eq $rr;
if ($realtype eq 'HASH') {
  my @left_only  = grep !exists $$rhs{$_}, keys %$lhs;
  my @right_only = grep !exists $$lhs{$_}, keys %$rhs;
  return {hash_key_mismatch => 1,
          object_type       => $rl,
          left_only         => \\@left_only,
          right_only        => \\@right_only}
    if @left_only || @right_only;
  my %diff;
  $diff{$_} = $class->new($$lhs{$_})->diff($$rhs{$_})
    for keys %$lhs;
  delete @diff{grep !defined($diff{$_}), keys %diff};
  return {hash_value_mismatch => 1,
          object_type         => $rl,
          diffs               => \\%diff} if keys %diff;
} elsif ($realtype eq 'ARRAY') {
  return {array_length_mismatch => [scalar(@$lhs), scalar(@$rhs)]}
    unless @$lhs == @$rhs;
  my %diff;
  $diff{$_} = $class->new($$lhs[$_])->diff($$rhs[$_])
    for 0..$\#{$lhs};
  delete @diff{grep !defined($diff{$_}), keys %diff};
  return {array_value_mismatch => 1,
          object_type          => $rl,
          diffs                => \\%diff} if keys %diff;
} elsif ($realtype eq 'SCALAR') {
  return $class->new($$lhs)->diff($$rhs);
} elsif (!$rl) {
  no warnings 'uninitialized';
  return undef if $lhs eq $rhs;
  return {scalar_difference => $self->detailed_scalar_diff($lhs, $rhs)}
    if length($lhs) + length($rhs) > 80;
  return {scalar_difference => [$lhs, $rhs]};
}
return undef;#;$BI=bless({$t,$zI,$v,$q,$w,$AI,$y,$z},$A);$CI={$qI,$tI,$uI,$xI,$yI,$BI};$DI=q#/lib/test_value_eq.b#;$EI=bless({$x5,$pI,$u6,$q,$v6,$q,$w6,$CI,$K,$DI},$F6);$FI={};$GI=[];$HI=q#ni::json_encode ${$_[0]}#;$II=bless({$t,$GI,$v,$q,$w,$HI,$y,$z},$A);$JI={$Q8,$II};$KI=q#/lib/test_value_str.b#;$LI=bless({$x5,$FI,$u6,$q,$v6,$q,$w6,$JI,$K,$KI},$F6);$MI=[$l8,$oI,$EI,$LI];$NI=bless({$x5,$gI,$K,$hI,$n6,$MI},$f6);$OI=q#ni:/lib/test_value.c#;$PI={$f6,1};$QI=q#/lib/test_value.c#;$RI=[$V9];$SI=bless({$x5,$PI,$K,$QI,$n6,$RI},$o6);$TI=q#ni:/lib/test_value_eq.b#;$UI=q#ni:/lib/test_value_init.b#;$VI=q#ni:/lib/test_value_str.b#;$WI=q#ni:/metaclass#;$XI={$o6,1};$YI=q#/metaclass#;$ZI=[$n7,$D9,$w7,$w9];$cJ=bless({$x5,$XI,$K,$YI,$n6,$ZI},$g6);$dJ=q#ni:/metaclass.c#;$eJ={$g6,1};$fJ=q#/metaclass.c#;$gJ=[$M9];$hJ=bless({$x5,$eJ,$K,$fJ,$n6,$gJ},$o6);$iJ=q#ni:/module#;$jJ=q#ni:/module.c#;$kJ=q#ni:/object#;$lJ=q#ni:/object.c#;$mJ=q#ni:/semantic/dimension#;$nJ={$j6,1};$oJ=q#/semantic/dimension#;$pJ=[$M9];$qJ=bless({$x5,$nJ,$K,$oJ,$n6,$pJ},$k6);$rJ=q#ni:/semantic/dimension.c#;$sJ={$k6,1};$tJ=q#/semantic/dimension.c#;$uJ=[$fa];$vJ=bless({$x5,$sJ,$K,$tJ,$n6,$uJ},$o6);$wJ=q#ni:/semantic/task#;$xJ=q#ni:/semantic/task.c#;$yJ=q#ni:/semantic/task_outcome.b#;$zJ=q#ni:/semantic/task_ro.b#;$AJ=q#ni:main#;$BJ={$Wk,1};$CJ=[$UE,$Bx,$Vk];$DJ=bless({$x5,$BJ,$K,$Wk,$n6,$CJ},$p6);$EJ=q#ni:ni#;$FJ={$JA,1};$GJ={$JA,1};$HJ=q#json_escapes#;$IJ=q##;$JJ=q#b#;$KJ=q#	#;$LJ=q#t#;$MJ=q#
#;$NJ=q#n#;$OJ=q##;$PJ=q#"#;$QJ=q#/#;$RJ=q#\\#;$SJ={$IJ,$JJ,$KJ,$LJ,$MJ,$NJ,$OJ,$nj,$PJ,$PJ,$QJ,$QJ,$RJ,$RJ};$TJ=q#json_unescapes#;$UJ={$PJ,$PJ,$QJ,$QJ,$RJ,$RJ,$JJ,$IJ,$NJ,$MJ,$nj,$OJ,$LJ,$KJ};$VJ={$HJ,$SJ,$TJ,$UJ};$WJ=q#/lib/json_data.b#;$XJ=bless({$x5,$GJ,$sn,$VJ,$K,$WJ},$N7);$YJ=[$XJ,$IA,$fD];$ZJ=bless({$x5,$FJ,$K,$JA,$n6,$YJ},$p6);$cK={$d,$N,$Q,$W,$X,$e1,$f1,$o1,$p1,$u1,$v1,$H1,$I1,$U1,$V1,$j2,$k2,$w2,$x2,$S2,$T2,$Y2,$Z2,$x3,$y3,$E3,$F3,$Y3,$Z3,$r4,$s4,$z4,$A4,$H4,$I4,$S4,$T4,$p5,$q5,$v5,$w5,$M9,$N9,$fa,$ga,$ya,$za,$Da,$Ea,$oa,$Fa,$wa,$Ga,$Bc,$Cc,$Sc,$Tc,$zc,$Uc,$Ad,$Bd,$Fd,$Gd,$ed,$Hd,$yd,$Id,$Zd,$ce,$ge,$he,$Qd,$ie,$Xd,$je,$Tf,$Uf,$Yf,$Zf,$Bf,$cg,$Rf,$dg,$ze,$eg,$tf,$fg,$Te,$gg,$se,$hg,$zh,$Dh,$di,$ei,$Zh,$fi,$Vg,$gi,$ih,$hi,$xg,$ii,$wh,$ji,$qg,$ki,$Fg,$li,$Fj,$Gj,$Kj,$Lj,$Bi,$Mj,$Yi,$Nj,$Ii,$Oj,$Dj,$Pj,$ti,$Qj,$ij,$Rj,$mk,$nk,$rk,$sk,$kk,$tk,$Zj,$uk,$Vk,$Xk,$xl,$yl,$Cl,$Dl,$il,$El,$vl,$Fl,$ic,$Gl,$Qc,$Hl,$Oc,$Il,$mb,$Jl,$ub,$Kl,$Gb,$Ll,$Qa,$Ml,$gc,$Nl,$Sb,$Ol,$dn,$en,$in,$jn,$Zm,$kn,$nm,$ln,$Jm,$mn,$dm,$nn,$zm,$on,$fo,$go,$ko,$lo,$Nn,$mo,$do,$no,$Gn,$oo,$yp,$Cp,$Op,$Pp,$Mp,$Qp,$Sq,$Wq,$sr,$tr,$qr,$ur,$rq,$vr,$Bq,$wr,$kq,$xr,$Nq,$yr,$cp,$zr,$wp,$Ar,$Sr,$Tr,$Xr,$Yr,$Jr,$Zr,$Qr,$cs,$O8,$ds,$v8,$es,$Z9,$fs,$ps,$qs,$G6,$rs,$vs,$ws,$ns,$xs,$w7,$ys,$Os,$Ps,$Ts,$Us,$Ms,$Vs,$Gs,$Ws,$u9,$Xs,$E8,$Ys,$l9,$Zs,$s9,$ct,$Vt,$Wt,$cu,$du,$yt,$eu,$Ht,$fu,$jt,$gu,$pt,$hu,$Tt,$iu,$t8,$ju,$ov,$sv,$Ev,$Fv,$Cv,$Gv,$Bu,$Hv,$ev,$Iv,$Tu,$Jv,$mv,$Kv,$Uw,$Vw,$Zw,$cx,$Sw,$dx,$ew,$ex,$Vv,$fx,$yw,$gx,$ox,$px,$Bx,$Cx,$Uz,$Vz,$Zz,$cA,$Kx,$dA,$ky,$eA,$j8,$fA,$D9,$gA,$IA,$KA,$V8,$LA,$N6,$MA,$V6,$NA,$e7,$OA,$RB,$SB,$WB,$XB,$PB,$YB,$wB,$ZB,$FB,$cC,$eB,$dC,$fD,$gD,$n7,$hD,$yz,$iD,$sy,$jD,$Sz,$kD,$iz,$lD,$ED,$FD,$JD,$KD,$tD,$LD,$CD,$MD,$Qy,$ND,$e9,$OD,$l7,$PD,$sE,$tE,$dE,$uE,$yE,$zE,$jE,$AE,$qE,$BE,$UE,$VE,$K9,$WE,$oF,$pF,$gF,$qF,$uF,$vF,$mF,$wF,$jG,$kG,$sG,$tG,$RF,$uG,$hG,$vG,$KF,$wG,$qG,$xG,$IF,$yG,$yH,$CH,$VH,$WH,$TH,$XH,$LH,$YH,$ZG,$ZH,$lH,$cI,$LG,$dI,$wH,$eI,$SG,$fI,$NI,$OI,$SI,$TI,$EI,$UI,$oI,$VI,$LI,$WI,$cJ,$dJ,$hJ,$iJ,$w9,$jJ,$da,$kJ,$l8,$lJ,$V9,$mJ,$qJ,$rJ,$vJ,$wJ,$No,$xJ,$Ip,$yJ,$Lo,$zJ,$zo,$AJ,$DJ,$EJ,$ZJ};$dK=q#resolvers#;$eK=[];$fK=q#ni('ni:/io/fd')->new(0 + substr shift, 3)#;$gK=bless({$t,$eK,$v,$q,$w,$fK,$y,$z},$A);$hK=q#file#;$iK=[];$jK=q#my $f = shift;
$f =~ s/^file:(?:\\/\\/)?//;
ni('ni:/io/file')->new($f);#;$kK=bless({$t,$iK,$v,$q,$w,$jK,$y,$z},$A);$lK=q#null#;$mK=[];$nK=q#ni('ni:/io/null')->new#;$oK=bless({$t,$mK,$v,$q,$w,$nK,$y,$z},$A);$pK=q#sh#;$qK=[];$rK=q#ni('ni:/io/exec')->new('/bin/sh', '-c', substr shift, 3)->fork#;$sK=bless({$t,$qK,$v,$q,$w,$rK,$y,$z},$A);$tK=q#str#;$uK=[];$vK=q#my $s = shift;
ni('ni:/io/str')->new(substr($s, 4) . "\\n");#;$wK=bless({$t,$uK,$v,$q,$w,$vK,$y,$z},$A);$xK={$Ze,$gK,$hK,$kK,$lK,$oK,$pK,$sK,$tK,$wK};$yK=bless({$c,$cK,$dK,$xK},$Q7);*$WD=\&$UD;*$VD=\&$SD;*$uu=\&$ru;*$tu=\&$pu;*$su=\&$nu;$G6->apply_($y5);$G6->apply_($z5);$G6->apply_($A5);$G6->apply_($B5);$G6->apply_($C5);$G6->apply_($D5);$G6->apply_($E5);$G6->apply_($F5);$G6->apply_($G5);$G6->apply_($H5);$G6->apply_($I5);$G6->apply_($J5);$G6->apply_($K5);$G6->apply_($L5);$G6->apply_($M5);$G6->apply_($N5);$G6->apply_($O5);$G6->apply_($P5);$G6->apply_($H6);$G6->apply_($Q5);$G6->apply_($R5);$G6->apply_($S5);$G6->apply_($T5);$G6->apply_($U5);$G6->apply_($V5);$G6->apply_($W5);$G6->apply_($X5);$G6->apply_($Y5);$G6->apply_($Z5);$G6->apply_($c6);$G6->apply_($d6);$G6->apply_($e6);$G6->apply_($f6);$G6->apply_($o6);$G6->apply_($g6);$G6->apply_($p6);$G6->apply_($h6);$G6->apply_($i6);$G6->apply_($j6);$G6->apply_($k6);$G6->apply_($l6);$N6->apply_($y5);$N6->apply_($z5);$N6->apply_($A5);$N6->apply_($B5);$N6->apply_($C5);$N6->apply_($D5);$N6->apply_($E5);$N6->apply_($F5);$N6->apply_($G5);$N6->apply_($H5);$N6->apply_($I5);$N6->apply_($J5);$N6->apply_($K5);$N6->apply_($L5);$N6->apply_($M5);$N6->apply_($N5);$N6->apply_($O5);$N6->apply_($P5);$N6->apply_($H6);$N6->apply_($Q5);$N6->apply_($R5);$N6->apply_($M);$N6->apply_($S5);$N6->apply_($T5);$N6->apply_($U5);$N6->apply_($V5);$N6->apply_($W5);$N6->apply_($X5);$N6->apply_($F6);$N6->apply_($Y5);$N6->apply_($O6);$N6->apply_($Z5);$N6->apply_($c6);$N6->apply_($d6);$N6->apply_($e6);$N6->apply_($f6);$N6->apply_($o6);$N6->apply_($g6);$N6->apply_($p6);$N6->apply_($h6);$N6->apply_($i6);$N6->apply_($j6);$N6->apply_($k6);$N6->apply_($l6);$V6->apply_($y5);$V6->apply_($z5);$V6->apply_($A5);$V6->apply_($B5);$V6->apply_($C5);$V6->apply_($D5);$V6->apply_($E5);$V6->apply_($F5);$V6->apply_($G5);$V6->apply_($H5);$V6->apply_($I5);$V6->apply_($J5);$V6->apply_($K5);$V6->apply_($L5);$V6->apply_($M5);$V6->apply_($N5);$V6->apply_($O5);$V6->apply_($P5);$V6->apply_($H6);$V6->apply_($Q5);$V6->apply_($R5);$V6->apply_($S5);$V6->apply_($T5);$V6->apply_($U5);$V6->apply_($V5);$V6->apply_($W5);$V6->apply_($X5);$V6->apply_($F6);$V6->apply_($Y5);$V6->apply_($O6);$V6->apply_($Z5);$V6->apply_($c6);$V6->apply_($d6);$V6->apply_($e6);$V6->apply_($f6);$V6->apply_($o6);$V6->apply_($g6);$V6->apply_($p6);$V6->apply_($h6);$V6->apply_($i6);$V6->apply_($j6);$V6->apply_($k6);$V6->apply_($l6);$e7->apply_($y5);$e7->apply_($z5);$e7->apply_($A5);$e7->apply_($B5);$e7->apply_($C5);$e7->apply_($D5);$e7->apply_($E5);$e7->apply_($F5);$e7->apply_($G5);$e7->apply_($H5);$e7->apply_($I5);$e7->apply_($J5);$e7->apply_($K5);$e7->apply_($L5);$e7->apply_($M5);$e7->apply_($N5);$e7->apply_($O5);$e7->apply_($P5);$e7->apply_($H6);$e7->apply_($Q5);$e7->apply_($R5);$e7->apply_($S5);$e7->apply_($T5);$e7->apply_($U5);$e7->apply_($V5);$e7->apply_($W5);$e7->apply_($X5);$e7->apply_($F6);$e7->apply_($Y5);$e7->apply_($O6);$e7->apply_($Z5);$e7->apply_($c6);$e7->apply_($d6);$e7->apply_($e6);$e7->apply_($f6);$e7->apply_($o6);$e7->apply_($g6);$e7->apply_($p6);$e7->apply_($h6);$e7->apply_($i6);$e7->apply_($j6);$e7->apply_($k6);$e7->apply_($l6);$l7->apply_($y5);$l7->apply_($z5);$l7->apply_($A5);$l7->apply_($B5);$l7->apply_($C5);$l7->apply_($D5);$l7->apply_($E5);$l7->apply_($F5);$l7->apply_($G5);$l7->apply_($H5);$l7->apply_($I5);$l7->apply_($J5);$l7->apply_($K5);$l7->apply_($L5);$l7->apply_($M5);$l7->apply_($N5);$l7->apply_($O5);$l7->apply_($P5);$l7->apply_($H6);$l7->apply_($Q5);$l7->apply_($R5);$l7->apply_($S5);$l7->apply_($T5);$l7->apply_($U5);$l7->apply_($V5);$l7->apply_($W5);$l7->apply_($X5);$l7->apply_($Y5);$l7->apply_($O6);$l7->apply_($Z5);$l7->apply_($c6);$l7->apply_($d6);$l7->apply_($e6);$l7->apply_($f6);$l7->apply_($o6);$l7->apply_($g6);$l7->apply_($p6);$l7->apply_($h6);$l7->apply_($i6);$l7->apply_($j6);$l7->apply_($k6);$l7->apply_($l6);$w7->apply_($y5);$w7->apply_($z5);$w7->apply_($A5);$w7->apply_($B5);$w7->apply_($C5);$w7->apply_($D5);$w7->apply_($E5);$w7->apply_($F5);$w7->apply_($G5);$w7->apply_($H5);$w7->apply_($I5);$w7->apply_($J5);$w7->apply_($K5);$w7->apply_($L5);$w7->apply_($M5);$w7->apply_($N5);$w7->apply_($O5);$w7->apply_($P5);$w7->apply_($Q5);$w7->apply_($R5);$w7->apply_($S5);$w7->apply_($T5);$w7->apply_($U5);$w7->apply_($V5);$w7->apply_($W5);$w7->apply_($X5);$w7->apply_($Y5);$w7->apply_($Z5);$w7->apply_($c6);$w7->apply_($d6);$w7->apply_($e6);$w7->apply_($f6);$w7->apply_($o6);$w7->apply_($g6);$w7->apply_($p6);$w7->apply_($h6);$w7->apply_($i6);$w7->apply_($j6);$w7->apply_($k6);$w7->apply_($l6);$j8->apply_($y5);$j8->apply_($z5);$j8->apply_($x7);$j8->apply_($A5);$j8->apply_($y7);$j8->apply_($B5);$j8->apply_($z7);$j8->apply_($C5);$j8->apply_($A7);$j8->apply_($D5);$j8->apply_($B7);$j8->apply_($E5);$j8->apply_($C7);$j8->apply_($F5);$j8->apply_($D7);$j8->apply_($G5);$j8->apply_($E7);$j8->apply_($H5);$j8->apply_($F7);$j8->apply_($I5);$j8->apply_($G7);$j8->apply_($J5);$j8->apply_($H7);$j8->apply_($K5);$j8->apply_($I7);$j8->apply_($L5);$j8->apply_($J7);$j8->apply_($M5);$j8->apply_($K7);$j8->apply_($N5);$j8->apply_($L7);$j8->apply_($O5);$j8->apply_($M7);$j8->apply_($P5);$j8->apply_($H6);$j8->apply_($Q5);$j8->apply_($N7);$j8->apply_($R5);$j8->apply_($M);$j8->apply_($S5);$j8->apply_($A);$j8->apply_($T5);$j8->apply_($O7);$j8->apply_($U5);$j8->apply_($P7);$j8->apply_($V5);$j8->apply_($Q7);$j8->apply_($W5);$j8->apply_($R7);$j8->apply_($X5);$j8->apply_($F6);$j8->apply_($Y5);$j8->apply_($O6);$j8->apply_($Z5);$j8->apply_($S7);$j8->apply_($c6);$j8->apply_($T7);$j8->apply_($d6);$j8->apply_($C);$j8->apply_($e6);$j8->apply_($U7);$j8->apply_($f6);$j8->apply_($o6);$j8->apply_($g6);$j8->apply_($p6);$j8->apply_($h6);$j8->apply_($V7);$j8->apply_($i6);$j8->apply_($j6);$j8->apply_($k6);$j8->apply_($W7);$j8->apply_($l6);$t8->apply_($y5);$t8->apply_($z5);$t8->apply_($A5);$t8->apply_($B5);$t8->apply_($C5);$t8->apply_($D5);$t8->apply_($E5);$t8->apply_($F5);$t8->apply_($G5);$t8->apply_($H5);$t8->apply_($I5);$t8->apply_($J5);$t8->apply_($K5);$t8->apply_($L5);$t8->apply_($M5);$t8->apply_($N5);$t8->apply_($O5);$t8->apply_($M7);$t8->apply_($P5);$t8->apply_($H6);$t8->apply_($Q5);$t8->apply_($N7);$t8->apply_($R5);$t8->apply_($S5);$t8->apply_($T5);$t8->apply_($U5);$t8->apply_($V5);$t8->apply_($W5);$t8->apply_($X5);$t8->apply_($F6);$t8->apply_($Y5);$t8->apply_($O6);$t8->apply_($Z5);$t8->apply_($c6);$t8->apply_($d6);$t8->apply_($e6);$t8->apply_($f6);$t8->apply_($o6);$t8->apply_($g6);$t8->apply_($p6);$t8->apply_($h6);$t8->apply_($i6);$t8->apply_($j6);$t8->apply_($k6);$t8->apply_($l6);$E8->apply_($y5);$E8->apply_($z5);$E8->apply_($A5);$E8->apply_($B5);$E8->apply_($C5);$E8->apply_($D5);$E8->apply_($E5);$E8->apply_($F5);$E8->apply_($G5);$E8->apply_($H5);$E8->apply_($I5);$E8->apply_($J5);$E8->apply_($K5);$E8->apply_($L5);$E8->apply_($M5);$E8->apply_($N5);$E8->apply_($O5);$E8->apply_($P5);$E8->apply_($H6);$E8->apply_($Q5);$E8->apply_($R5);$E8->apply_($S5);$E8->apply_($T5);$E8->apply_($U5);$E8->apply_($V5);$E8->apply_($W5);$E8->apply_($X5);$E8->apply_($Y5);$E8->apply_($Z5);$E8->apply_($c6);$E8->apply_($d6);$E8->apply_($e6);$E8->apply_($f6);$E8->apply_($o6);$E8->apply_($g6);$E8->apply_($p6);$E8->apply_($h6);$E8->apply_($i6);$E8->apply_($j6);$E8->apply_($k6);$E8->apply_($l6);$O8->apply_($y5);$O8->apply_($z5);$O8->apply_($A5);$O8->apply_($B5);$O8->apply_($C5);$O8->apply_($D5);$O8->apply_($E5);$O8->apply_($F5);$O8->apply_($G5);$O8->apply_($H5);$O8->apply_($I5);$O8->apply_($J5);$O8->apply_($K5);$O8->apply_($L5);$O8->apply_($M5);$O8->apply_($N5);$O8->apply_($O5);$O8->apply_($P5);$O8->apply_($H6);$O8->apply_($Q5);$O8->apply_($R5);$O8->apply_($S5);$O8->apply_($T5);$O8->apply_($U5);$O8->apply_($V5);$O8->apply_($W5);$O8->apply_($X5);$O8->apply_($Y5);$O8->apply_($Z5);$O8->apply_($c6);$O8->apply_($d6);$O8->apply_($e6);$O8->apply_($f6);$O8->apply_($o6);$O8->apply_($g6);$O8->apply_($p6);$O8->apply_($h6);$O8->apply_($i6);$O8->apply_($j6);$O8->apply_($k6);$O8->apply_($l6);$V8->apply_($y5);$V8->apply_($z5);$V8->apply_($A5);$V8->apply_($B5);$V8->apply_($C5);$V8->apply_($D5);$V8->apply_($E5);$V8->apply_($F5);$V8->apply_($G5);$V8->apply_($H5);$V8->apply_($I5);$V8->apply_($J5);$V8->apply_($K5);$V8->apply_($L5);$V8->apply_($M5);$V8->apply_($N5);$V8->apply_($O5);$V8->apply_($P5);$V8->apply_($H6);$V8->apply_($Q5);$V8->apply_($R5);$V8->apply_($S5);$V8->apply_($T5);$V8->apply_($U5);$V8->apply_($V5);$V8->apply_($W5);$V8->apply_($X5);$V8->apply_($Y5);$V8->apply_($Z5);$V8->apply_($c6);$V8->apply_($d6);$V8->apply_($e6);$V8->apply_($f6);$V8->apply_($o6);$V8->apply_($g6);$V8->apply_($p6);$V8->apply_($h6);$V8->apply_($i6);$V8->apply_($j6);$V8->apply_($k6);$V8->apply_($l6);$e9->apply_($y5);$e9->apply_($z5);$e9->apply_($A5);$e9->apply_($B5);$e9->apply_($C5);$e9->apply_($D5);$e9->apply_($E5);$e9->apply_($F5);$e9->apply_($G5);$e9->apply_($H5);$e9->apply_($I5);$e9->apply_($J5);$e9->apply_($K5);$e9->apply_($L5);$e9->apply_($M5);$e9->apply_($N5);$e9->apply_($O5);$e9->apply_($P5);$e9->apply_($H6);$e9->apply_($Q5);$e9->apply_($R5);$e9->apply_($S5);$e9->apply_($T5);$e9->apply_($U5);$e9->apply_($V5);$e9->apply_($W5);$e9->apply_($X5);$e9->apply_($Y5);$e9->apply_($Z5);$e9->apply_($c6);$e9->apply_($d6);$e9->apply_($e6);$e9->apply_($f6);$e9->apply_($o6);$e9->apply_($g6);$e9->apply_($p6);$e9->apply_($h6);$e9->apply_($i6);$e9->apply_($j6);$e9->apply_($k6);$e9->apply_($l6);$l9->apply_($y5);$l9->apply_($z5);$l9->apply_($A5);$l9->apply_($B5);$l9->apply_($C5);$l9->apply_($D5);$l9->apply_($E5);$l9->apply_($F5);$l9->apply_($G5);$l9->apply_($H5);$l9->apply_($I5);$l9->apply_($J5);$l9->apply_($K5);$l9->apply_($L5);$l9->apply_($M5);$l9->apply_($N5);$l9->apply_($O5);$l9->apply_($P5);$l9->apply_($H6);$l9->apply_($Q5);$l9->apply_($R5);$l9->apply_($S5);$l9->apply_($T5);$l9->apply_($U5);$l9->apply_($V5);$l9->apply_($W5);$l9->apply_($X5);$l9->apply_($Y5);$l9->apply_($Z5);$l9->apply_($c6);$l9->apply_($d6);$l9->apply_($e6);$l9->apply_($f6);$l9->apply_($o6);$l9->apply_($g6);$l9->apply_($p6);$l9->apply_($h6);$l9->apply_($i6);$l9->apply_($j6);$l9->apply_($k6);$l9->apply_($l6);$s9->apply_($y5);$s9->apply_($z5);$s9->apply_($A5);$s9->apply_($B5);$s9->apply_($C5);$s9->apply_($D5);$s9->apply_($E5);$s9->apply_($F5);$s9->apply_($G5);$s9->apply_($H5);$s9->apply_($I5);$s9->apply_($J5);$s9->apply_($K5);$s9->apply_($L5);$s9->apply_($M5);$s9->apply_($N5);$s9->apply_($O5);$s9->apply_($P5);$s9->apply_($H6);$s9->apply_($Q5);$s9->apply_($R5);$s9->apply_($S5);$s9->apply_($T5);$s9->apply_($U5);$s9->apply_($V5);$s9->apply_($W5);$s9->apply_($X5);$s9->apply_($Y5);$s9->apply_($Z5);$s9->apply_($c6);$s9->apply_($d6);$s9->apply_($e6);$s9->apply_($f6);$s9->apply_($o6);$s9->apply_($g6);$s9->apply_($p6);$s9->apply_($h6);$s9->apply_($i6);$s9->apply_($j6);$s9->apply_($k6);$s9->apply_($l6);$D9->apply_($y5);$D9->apply_($z5);$D9->apply_($A5);$D9->apply_($B5);$D9->apply_($C5);$D9->apply_($D5);$D9->apply_($E5);$D9->apply_($F5);$D9->apply_($G5);$D9->apply_($H5);$D9->apply_($I5);$D9->apply_($J5);$D9->apply_($K5);$D9->apply_($L5);$D9->apply_($M5);$D9->apply_($N5);$D9->apply_($O5);$D9->apply_($P5);$D9->apply_($Q5);$D9->apply_($R5);$D9->apply_($S5);$D9->apply_($A);$D9->apply_($T5);$D9->apply_($U5);$D9->apply_($V5);$D9->apply_($W5);$D9->apply_($X5);$D9->apply_($F6);$D9->apply_($Y5);$D9->apply_($O6);$D9->apply_($Z5);$D9->apply_($c6);$D9->apply_($d6);$D9->apply_($e6);$D9->apply_($f6);$D9->apply_($o6);$D9->apply_($g6);$D9->apply_($h6);$D9->apply_($i6);$D9->apply_($j6);$D9->apply_($k6);$D9->apply_($l6);$K9->apply_($y5);$K9->apply_($z5);$K9->apply_($A5);$K9->apply_($B5);$K9->apply_($C5);$K9->apply_($D5);$K9->apply_($E5);$K9->apply_($F5);$K9->apply_($G5);$K9->apply_($H5);$K9->apply_($I5);$K9->apply_($J5);$K9->apply_($K5);$K9->apply_($L5);$K9->apply_($M5);$K9->apply_($N5);$K9->apply_($O5);$K9->apply_($P5);$K9->apply_($Q5);$K9->apply_($R5);$K9->apply_($S5);$K9->apply_($T5);$K9->apply_($U5);$K9->apply_($V5);$K9->apply_($W5);$K9->apply_($X5);$K9->apply_($Y5);$K9->apply_($Z5);$K9->apply_($c6);$K9->apply_($d6);$K9->apply_($e6);$K9->apply_($f6);$K9->apply_($g6);$K9->apply_($h6);$K9->apply_($i6);$K9->apply_($j6);$K9->apply_($k6);$K9->apply_($l6);$oa->apply_($x7);$wa->apply_($x7);$Qa->apply_($y7);$Qa->apply_($z7);$Qa->apply_($A7);$Qa->apply_($B7);$Qa->apply_($C7);$Qa->apply_($D7);$Qa->apply_($E7);$Qa->apply_($F7);$Qa->apply_($G7);$Qa->apply_($H7);$Qa->apply_($I7);$mb->apply_($y7);$mb->apply_($z7);$mb->apply_($A7);$mb->apply_($B7);$mb->apply_($C7);$mb->apply_($D7);$mb->apply_($E7);$mb->apply_($F7);$mb->apply_($G7);$mb->apply_($H7);$mb->apply_($I7);$ub->apply_($y7);$ub->apply_($z7);$ub->apply_($A7);$ub->apply_($B7);$ub->apply_($C7);$ub->apply_($D7);$ub->apply_($E7);$ub->apply_($F7);$ub->apply_($G7);$ub->apply_($H7);$ub->apply_($I7);$Gb->apply_($y7);$Gb->apply_($z7);$Gb->apply_($A7);$Gb->apply_($B7);$Gb->apply_($C7);$Gb->apply_($D7);$Gb->apply_($E7);$Gb->apply_($F7);$Gb->apply_($G7);$Gb->apply_($H7);$Gb->apply_($I7);$Sb->apply_($y7);$Sb->apply_($z7);$Sb->apply_($A7);$Sb->apply_($B7);$Sb->apply_($C7);$Sb->apply_($D7);$Sb->apply_($E7);$Sb->apply_($F7);$Sb->apply_($G7);$Sb->apply_($H7);$Sb->apply_($I7);$gc->apply_($y7);$gc->apply_($z7);$gc->apply_($A7);$gc->apply_($B7);$gc->apply_($C7);$gc->apply_($D7);$gc->apply_($E7);$gc->apply_($F7);$gc->apply_($G7);$gc->apply_($H7);$gc->apply_($I7);$zc->apply_($y7);$Oc->apply_($B5);$Oc->apply_($C5);$Oc->apply_($D5);$Oc->apply_($E5);$Oc->apply_($F5);$Oc->apply_($G5);$Oc->apply_($H5);$Oc->apply_($I5);$Oc->apply_($J5);$Oc->apply_($K5);$Oc->apply_($L5);$ed->apply_($z7);$yd->apply_($z7);$Qd->apply_($A7);$Xd->apply_($A7);$se->apply_($B7);$ze->apply_($B7);$Te->apply_($B7);$tf->apply_($B7);$Bf->apply_($B7);$Rf->apply_($B7);$qg->apply_($C7);$qg->apply_($E7);$xg->apply_($C7);$Fg->apply_($C7);$Vg->apply_($C7);$Vg->apply_($E7);$ih->apply_($C7);$wh->apply_($C7);$wh->apply_($E7);$Zh->apply_($F5);$ti->apply_($D7);$Bi->apply_($D7);$Ii->apply_($D7);$Yi->apply_($D7);$ij->apply_($D7);$Dj->apply_($D7);$Zj->apply_($E7);$kk->apply_($E7);$Vk->apply_($Wk);$il->apply_($F7);$vl->apply_($F7);$dm->apply_($H7);$nm->apply_($H7);$zm->apply_($H7);$Jm->apply_($H7);$Zm->apply_($H7);$Gn->apply_($I7);$Nn->apply_($I7);$do->apply_($I7);$zo->apply_($J7);$zo->apply_($K7);$zo->apply_($L7);$zo->apply_($W7);$Lo->apply_($J7);$Lo->apply_($K7);$Lo->apply_($L7);$Lo->apply_($W7);$cp->apply_($J7);$cp->apply_($K7);$cp->apply_($L7);$wp->apply_($J7);$wp->apply_($K7);$wp->apply_($L7);$Mp->apply_($M5);$Mp->apply_($N5);$Mp->apply_($O5);$kq->apply_($K7);$rq->apply_($K7);$Bq->apply_($K7);$Nq->apply_($K7);$qr->apply_($N5);$Jr->apply_($L7);$Qr->apply_($L7);$ns->apply_($H6);$Gs->apply_($N7);$Ms->apply_($N7);$jt->apply_($M);$pt->apply_($M);$yt->apply_($M);$Ht->apply_($M);$Tt->apply_($M);$Bu->apply_($A);$Tu->apply_($A);$ev->apply_($A);$mv->apply_($A);$Cv->apply_($T5);$Vv->apply_($O7);$ew->apply_($O7);$yw->apply_($O7);$Sw->apply_($O7);$ox->apply_($P7);$Bx->apply_($Wk);$Kx->apply_($P7);$ky->apply_($P7);$sy->apply_($P7);$sy->apply_($R7);$Qy->apply_($P7);$Qy->apply_($R7);$iz->apply_($P7);$iz->apply_($R7);$yz->apply_($P7);$Sz->apply_($P7);$IA->apply_($JA);$eB->apply_($Q7);$wB->apply_($Q7);$FB->apply_($Q7);$PB->apply_($Q7);$fD->apply_($JA);$tD->apply_($R7);$CD->apply_($R7);$dE->apply_($F6);$jE->apply_($F6);$qE->apply_($F6);$UE->apply_($Wk);$gF->apply_($O6);$mF->apply_($O6);$IF->apply_($S7);$IF->apply_($T7);$RF->apply_($S7);$hG->apply_($S7);$LG->apply_($C);$SG->apply_($C);$ZG->apply_($C);$lH->apply_($C);$wH->apply_($C);$LH->apply_($e6);$TH->apply_($e6);$oI->apply_($U7);$EI->apply_($U7);$LI->apply_($U7);$ni::self=$yK;&$P($N);&$P($W);&$P($e1);&$P($o1);&$P($u1);&$P($H1);&$P($U1);&$P($j2);&$P($w2);&$P($S2);&$P($Y2);&$P($x3);&$P($E3);&$P($Y3);&$P($r4);&$P($z4);&$P($H4);&$P($S4);&$P($p5);&$P($v5);&$P($G6);&$P($N6);&$P($V6);&$P($e7);&$P($l7);&$P($n7);&$P($w7);&$P($j8);&$P($l8);&$q7($l8);&$P($t8);&$P($v8);&$q7($v8);&$P($E8);&$P($O8);&$P($V8);&$P($e9);&$P($l9);&$P($s9);&$P($u9);&$P($w9);&$q7($w9);&$P($D9);&$P($K9);&$P($M9);&$q7($M9);&$P($V9);&$q7($V9);&$P($Z9);&$q7($Z9);&$P($da);&$q7($da);&$P($fa);&$q7($fa);&$P($oa);&$P($wa);&$P($ya);&$q7($ya);&$P($Da);&$q7($Da);&$P($Qa);&$P($mb);&$P($ub);&$P($Gb);&$P($Sb);&$P($gc);&$P($ic);&$q7($ic);&$P($zc);&$P($Bc);&$q7($Bc);&$P($Oc);&$P($Qc);&$q7($Qc);&$P($Sc);&$q7($Sc);&$P($ed);&$P($yd);&$P($Ad);&$q7($Ad);&$P($Fd);&$q7($Fd);&$P($Qd);&$P($Xd);&$P($Zd);&$q7($Zd);&$P($ge);&$q7($ge);&$P($se);&$P($ze);&$P($Te);&$P($tf);&$P($Bf);&$P($Rf);&$P($Tf);&$q7($Tf);&$P($Yf);&$q7($Yf);&$P($qg);&$P($xg);&$P($Fg);&$P($Vg);&$P($ih);&$P($wh);&$P($zh);&$q7($zh);&$Ch($zh);&$P($Zh);&$P($di);&$q7($di);&$P($ti);&$P($Bi);&$P($Ii);&$P($Yi);&$P($ij);&$P($Dj);&$P($Fj);&$q7($Fj);&$P($Kj);&$q7($Kj);&$P($Zj);&$P($kk);&$P($mk);&$q7($mk);&$P($rk);&$q7($rk);&$P($Vk);&$P($il);&$P($vl);&$P($xl);&$q7($xl);&$P($Cl);&$q7($Cl);&$P($dm);&$P($nm);&$P($zm);&$P($Jm);&$P($Zm);&$P($dn);&$q7($dn);&$P($in);&$q7($in);&$P($Gn);&$P($Nn);&$P($do);&$P($fo);&$q7($fo);&$P($ko);&$q7($ko);&$P($zo);&$P($Lo);&$P($No);&$q7($No);&$P($cp);&$P($wp);&$P($yp);&$q7($yp);&$Bp($yp);&$P($Ip);&$q7($Ip);&$P($Mp);&$P($Op);&$q7($Op);&$P($kq);&$P($rq);&$P($Bq);&$P($Nq);&$P($Sq);&$q7($Sq);&$Bp($Sq);&$Vq($Sq);&$P($qr);&$P($sr);&$q7($sr);&$P($Jr);&$P($Qr);&$P($Sr);&$q7($Sr);&$Bp($Sr);&$P($Xr);&$q7($Xr);&$P($ns);&$P($ps);&$q7($ps);&$P($vs);&$q7($vs);&$P($Gs);&$P($Ms);&$P($Os);&$q7($Os);&$P($Ts);&$q7($Ts);&$P($jt);&$P($pt);&$P($yt);&$P($Ht);&$P($Tt);&$P($Vt);&$q7($Vt);&$P($cu);&$q7($cu);&$P($Bu);&$P($Tu);&$P($ev);&$P($mv);&$P($ov);&$q7($ov);&$rv($ov);&$P($Cv);&$P($Ev);&$q7($Ev);&$P($Vv);&$P($ew);&$P($yw);&$P($Sw);&$P($Uw);&$q7($Uw);&$P($Zw);&$q7($Zw);&$P($ox);&$P($Bx);&$P($Kx);&$P($ky);&$P($sy);&$P($Qy);&$P($iz);&$P($yz);&$P($Sz);&$P($Uz);&$q7($Uz);&$P($Zz);&$q7($Zz);&$P($IA);&$P($eB);&$P($wB);&$P($FB);&$P($PB);&$P($RB);&$q7($RB);&$P($WB);&$q7($WB);&$P($fD);&$P($tD);&$P($CD);&$P($ED);&$q7($ED);&$P($JD);&$q7($JD);&$P($dE);&$P($jE);&$P($qE);&$P($sE);&$q7($sE);&$P($yE);&$q7($yE);&$P($UE);&$P($gF);&$P($mF);&$P($oF);&$q7($oF);&$P($uF);&$q7($uF);&$P($IF);&$P($KF);&$q7($KF);&$P($RF);&$P($hG);&$P($jG);&$q7($jG);&$P($qG);&$q7($qG);&$P($sG);&$q7($sG);&$P($LG);&$P($SG);&$P($ZG);&$P($lH);&$P($wH);&$P($yH);&$q7($yH);&$BH($yH);&$P($LH);&$P($TH);&$P($VH);&$q7($VH);&$P($oI);&$P($EI);&$P($LI);&$P($NI);&$q7($NI);&$P($SI);&$q7($SI);&$P($cJ);&$q7($cJ);&$P($hJ);&$q7($hJ);&$P($qJ);&$q7($qJ);&$P($vJ);&$q7($vJ);&$P($DJ);&$q7($DJ);&$P($ZJ);&$q7($ZJ);ni->run(@ARGV);
__DATA__

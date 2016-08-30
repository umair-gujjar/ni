#!/usr/bin/env perl
# ni: https://github.com/spencertipping/ni
# Copyright (c) 2016 Spencer Tipping
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
use 5.006_000;
chomp($ni::self{push(@ni::keys, $2) && $2} = join '', map $_ = <DATA>, 1..$1) while <DATA> =~ /^(\d+)\s+(.*)$/;
push(@ni::evals, $_), eval "package ni;$ni::self{$_}", $@ && die "$@ evaluating $_" for grep /\.pl$/i, @ni::keys;
eval {exit ni::main(@ARGV)}; $@ =~ s/\(eval (\d+)\)/$ni::evals[$1-1]/g; die $@;
__DATA__
26 ni
#!/usr/bin/env perl
# ni: https://github.com/spencertipping/ni
# Copyright (c) 2016 Spencer Tipping
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
use 5.006_000;
chomp($ni::self{push(@ni::keys, $2) && $2} = join '', map $_ = <DATA>, 1..$1) while <DATA> =~ /^(\d+)\s+(.*)$/;
push(@ni::evals, $_), eval "package ni;$ni::self{$_}", $@ && die "$@ evaluating $_" for grep /\.pl$/i, @ni::keys;
eval {exit ni::main(@ARGV)}; $@ =~ s/\(eval (\d+)\)/$ni::evals[$1-1]/g; die $@;
__DATA__
25 ni.map


unquote ni
resource ni
resource ni.map
resource util.pl
resource self.pl
resource cli.pl
resource sh.pl
resource main.pl
lib core/common
lib core/gen
lib core/stream
lib core/meta
lib core/col
lib core/row
lib core/facet
lib core/pl
lib core/python
lib core/sql
lib core/java
lib core/lisp
lib core/hadoop
lib core/pyspark
lib doc
11 util.pl

sub sgr($$$) {(my $x = $_[0]) =~ s/$_[1]/$_[2]/g; $x}
sub sr($$$)  {(my $x = $_[0]) =~ s/$_[1]/$_[2]/;  $x}
sub dor($$)  {defined $_[0] ? $_[0] : $_[1]}
sub rf  {open my $fh, "< $_[0]"; my $r = join '', <$fh>; close $fh; $r}
sub rl  {open my $fh, "< $_[0]"; my @r =          <$fh>; close $fh; @r}
sub rfc {chomp(my $r = rf @_); $r}
sub max    {local $_; my $m = pop @_; $m = $m >  $_ ? $m : $_ for @_; $m}
sub min    {local $_; my $m = pop @_; $m = $m <  $_ ? $m : $_ for @_; $m}
sub maxstr {local $_; my $m = pop @_; $m = $m gt $_ ? $m : $_ for @_; $m}
sub minstr {local $_; my $m = pop @_; $m = $m lt $_ ? $m : $_ for @_; $m}
33 self.pl

sub map_u {@self{@_}}
sub map_r {map sprintf("%d %s\n%s", scalar(split /\n/, "$self{$_} "), $_, $self{$_}), @_}
sub map_l {map {my $l = $_;
                map_r "$_/lib", map "$l/$_", split /\n/, $self{"$_/lib"}} @_}
sub read_map {join '', map "$_\n",
                       (map {my ($c, @a) = split /\s+/;
                               $c eq 'unquote'     ? map_u @a
                             : $c eq 'resource'    ? map_r @a
                             : $c =~ /^lib$|^ext$/ ? map_l @a
                             : die "ni: unknown map command+args: $c @a"}
                        grep {s/#.*//g; length}
                        map split(/\n/), @self{@_}), "__END__"}
sub intern_lib {
  for my $l (@_) {
    for (grep length, split /\n/, ($self{"$l/lib"} = rfc "$l/lib")) {
      my $c = $self{"$l/$_"} = rfc "$l/$_";
      eval "package ni;$c", $@ && die "$@ evaluating $l/$_" if /\.pl$/;
    }
  }
}
sub modify_self($) {
  die "ni: not a modifiable instance: $0" unless -w $0;
  open my $fh, "> $0" or die "ni: failed to open self: $!";
  print $fh read_map $_[0];
  close $fh;
}
sub extend_self($) {
  $self{'ni.map'} .= "\next $_[0]";
  intern_lib $_[0];
  modify_self 'ni.map';
}
sub image {read_map 'ni.map'}
94 cli.pl




use constant end_of_argv  => sub {@_           ? () : (0)};
use constant consumed_opt => sub {length $_[0] ? () : @_};
use constant none         => sub {(undef, @_)};
sub k($) {my ($v) = @_; sub {($v, @_)}}
sub seqr(\@) {my ($ps) = @_;
         sub {my ($x, @xs, @ys, @ps);
              (($x, @_) = &$_(@_)) ? push @xs, $x : return () for @ps = @$ps;
              (\@xs, @_)}}
sub altr(\@) {my ($ps) = @_;
         sub {my @ps, @r; @r = &$_(@_) and return @r for @ps = @$ps; ()}}
sub seq(@) {ref $_ or die "non-ref to seq(): $_" for @_; seqr @_}
sub alt(@) {ref $_ or die "non-ref to alt(): $_" for @_; altr @_}
sub rep($;$) {my ($p, $n) = (@_, 0);
         sub {my (@c, @r);
              push @r, $_ while ($_, @_) = &$p(@c = @_);
              @r >= $n ? (\@r, @c) : ()}}
sub maybe($) {my ($p) = @_;
         sub {my @xs = &$p(@_); @xs ? @xs : (undef, @_)}};
sub pmap(&$) {my ($f, $p) = @_;
         sub {my @xs = &$p(@_); @xs ? (&$f($_ = $xs[0]), @xs[1..$#xs]) : ()}}
sub pif(&$) {my ($f, $p) = @_;
        sub {my @xs = &$p(@_); @xs && &$f($_ = $xs[0]) ? @xs : ()}}
sub ptag(@) {my (@xs, $p) = @_; $p = pop @xs; pmap {[@xs, $_]} $p}
sub pn($@)  {my ($n, @ps) = @_; pmap {$$_[$n]} seq @ps}

sub mr($) {my $r = qr/$_[0]/;
      sub {my ($x, @xs) = @_; $x =~ s/^($r)// ? ($2 || $1, $x, @xs) : ()}}
sub mrc($) {pn 0, mr $_[0], maybe consumed_opt}



sub chaltr(\%) {my ($ps) = @_;
           sub {my ($x, @xs, $k, @ys, %ls) = @_;
                ++$ls{length $_} for keys %$ps;
                for my $l (sort {$b <=> $a} keys %ls) {
                  return (@ys = $$ps{$c}(substr($x, $l), @xs))
                    ? ($ys[0], @ys[1..$#ys])
                    : ()
                  if exists $$ps{$c = substr $x, 0, $l};
                }
                ()}}
sub chalt(%) {my %h = @_; chaltr %h}

use constant regex => pmap {s/\/$//; $_} mr qr/^(?:[^\\\/]+|\\.)*\//;

use constant rbcode => sub {
  return @_ unless $_[0] =~ /\]$/;
  my ($code, @xs, $x, $qcode) = @_;
  ($qcode = $code) =~ s/'/'\\''/g;
  $x .= ']' while $_ = system("ruby -ce '$qcode' >/dev/null 2>&1")
                  and ($qcode =~ s/\]$//, $code =~ s/\]$//);
  $_ ? () : length $x ? ($code, $x, @xs) : ($code, @xs)};

use constant plcode => sub {
  return @_ unless $_[0] =~ /\]$/;
  my ($code, @xs, $x, $qcode) = @_;
  ($qcode = $code) =~ s/'/'\\''/g;
  my $begin_warning = $qcode =~ s/BEGIN/END/g;
  $x .= ']' while $_ = system("perl -ce '$qcode' >/dev/null 2>&1")
                  and ($qcode =~ s/\]$//, $code =~ s/\]$//);
  print STDERR <<EOF if $_ && $begin_warning;
ni: failed to get closing bracket count for perl code "$_[0]", possibly
    because BEGIN-block metaprogramming is disabled when ni tries to figure
    this out.
    https://github.com/spencertipping/ni/tree/master/design/cli-reader-problem.md
EOF
  $_ ? () : length $x ? ($code, $x, @xs) : ($code, @xs)};

our %contexts;
sub context($) {my ($c, $p) = split /\//, $_[0]; $contexts{$c}{$p}}
sub defcontext($) {
  my $short = {};
  my $long  = [];
  my $r = $contexts{$_[0]} = {};
  $$r{ops} = sub {$$r{ops}->(@_)};
  $$r{longs}  = $long;
  $$r{shorts} = $short;
  $$r{long}   = altr @$long;
  $$r{short}  = chaltr %$short;
  $$r{lambda} = alt mr '_', pn 1, mrc '\[', $$r{ops}, mr '\]';
  $$r{thing}  = alt $$r{lambda}, $$r{long}, $$r{short};
  $$r{suffix} = rep $$r{thing}, 1;
  $$r{op}     = pn 1, rep(consumed_opt), $$r{thing}, rep(consumed_opt);
  $$r{ops}    = rep $$r{op};
  $$r{cli}    = pn 0, $$r{ops}, end_of_argv;
  $$r{cli_d}  = $$r{ops};
}
defcontext 'root';
sub defshort($$$) {$contexts{$_[0]}{shorts}{$_[1]} = $_[2]}
sub deflong($$$)  {unshift @{$contexts{$_[0]}{longs}}, $_[2]}
68 sh.pl




sub quote {join ' ', map /[^-A-Za-z_0-9\/:@.]/
                           ? "'" . sgr($_, qr/'/, "'\\''") . "'"
                           : $_,
                     map 'ARRAY' eq ref($_) ? quote(@$_) : $_, @_}





sub collect_nested_invocations {
  local $_;
  my ($options, @xs) = @_;
  map {
    my $c = $_;
    if ('HASH' eq ref $c) {
      if (exists $$c{stdin}) {
        die "ni sh: only one stdin redirection is allowed for a subquoted "
          . "command: " . quote(@{$$c{exec}}) if exists $$options{stdin};
        $$options{stdin} = $$c{stdin};
      }
      if (exists $$c{prefix}) {
        my $p = $$c{prefix};
        $$options{prefix}{$_} = $$p{$_} for keys %$p;
      }
      [collect_nested_invocations($options, @{$$c{exec}})];
    } elsif ('ARRAY' eq ref $c) {
      [collect_nested_invocations($options, @$c)];
    } else {
      $c;
    }
  } @xs;
}
sub sh {
  return {exec => [@_]} unless ref $_[0];
  my ($c, %o) = @_;
  my ($exec) = collect_nested_invocations \%o, $c;
  +{exec => $exec, %o};
}
sub heredoc_for {my $n = 0; ++$n while $_[0] =~ /^_$n$/m; "_$n"}
sub sh_prefix() {join "\n", @self{@sh_libs}}
sub flatten {map 'ARRAY' eq ref($_) ? flatten(@$_) : $_, @_}
sub pipeline {
  my %ps;
  my @cs;
  my @hs;
  for (flatten @_) {
    my $c = quote @{$$_{exec}};
    $c .= " $$_{magic}" if exists $$_{magic};
    if (exists $$_{stdin}) {
      my $h = heredoc_for $$_{stdin};
      push @cs, "$c 3<&0 <<'$h'";
      push @hs, "$$_{stdin}\n$h";
    } else {
      push @cs, $c;
    }
    if (exists $$_{prefix}) {
      my $p = $$_{prefix};
      $ps{$_} = $$p{$_} for keys %$p;
    }
  }
  join '', map "$_\n", values %ps,
                       join("\\\n| ", @cs),
                       @hs;
}
71 main.pl

use POSIX qw/dup dup2/;
use constant exit_success      => 0;
use constant exit_run_error    => 1;
use constant exit_nop          => 2;
use constant exit_sigchld_fail => 3;
our %option_handlers;
our @pipeline_prefix = sh 'true';
our @pipeline_suffix = ();
sub parse_ops {
  return () unless @_;
  my ($parsed) = context('root/cli')->(@_);
  return @$parsed if ref $parsed && @$parsed;
  my (undef, @rest) = context('root/cli_d')->(@_);
  die "failed to parse " . join ' ', @rest;
}
sub sh_code {pipeline @pipeline_prefix, parse_ops(@_), @pipeline_suffix}


sub run_sh {
  pipe my $r, $w;
  if (my $child = fork) {
    close $r;
    close STDIN;
    close STDOUT;
    syswrite $w, $_[0] or die "ni: failed to write pipeline to shell: $!";
    close STDERR;
    close $w;
    waitpid $child, 0;
    $?;
  } else {
    close $w;
    if (fileno $r == 3) {
      defined(my $fd = dup fileno $r) or die "ni: failed to dup temp fd: $!";
      close $r;
      $r = $fd;
    }
    dup2 0, 3 or die "ni: failed to redirect stdin to shell: $!"
      unless -t STDIN;
    close STDIN;
    dup2 fileno $r, 0 or die "ni: failed to redirect command to shell: $!";
    close $r;
    exec 'sh' or exec 'ash' or exec 'dash' or exec 'bash'
      or die "ni: failed to run any POSIX sh: $!";
  }
}

$option_handlers{'internal/eval'}
  = sub {eval "package ni; $_[0]"; die $@ if $@; exit_success};
$option_handlers{'internal/lib'}
  = sub {intern_lib $_[0]; $self{'ni.map'} .= "\nlib $_[0]";
         modify_self 'ni.map'};

$option_handlers{lib} = sub {intern_lib shift; goto \&main};
$option_handlers{run} = sub {eval 'package ni;' . shift;
                             die $@ if $@;
                             goto \&main};
$option_handlers{extend}
  = sub {intern_lib $_[0]; $self{'ni.map'} .= "\next $_[0]";
         modify_self 'ni.map'};

$option_handlers{help} = sub {@_ = ("//help/" . (@_ ? $_[0] : '')); goto \&main};
$option_handlers{explain} = sub {TODO()};
$option_handlers{compile} = sub {print sh_code @_; exit_nop};
sub main {
  my ($command, @args) = @_;
  $command = '--help' if $command eq '-h' or !@_ && -t STDIN && -t STDOUT;
  my $h = $command =~ s/^--// && $option_handlers{$command};
  return &$h(@args) if $h;
  run_sh sh_code @_;
}
1 core/common/lib
common.pl
18 core/common/common.pl

use constant neval   => pmap {eval} mr '^=([^]]+)';
use constant integer => alt pmap(sub {10 ** $_},  mr '^E(-?\d+)'),
                            pmap(sub {1 << $_},   mr '^B(\d+)'),
                            pmap(sub {0 + "0$_"}, mr '^x[0-9a-fA-F]+'),
                            pmap(sub {0 + $_},    mr '\d+');
use constant float   => pmap {0 + $_} mr '^-?\d*(?:\.\d+)?(?:[eE][-+]?\d+)?';
use constant number  => alt neval, integer, float;
use constant colspec1 => mr '^[A-Z]';
use constant colspec  => mr '^[-A-Z.]+';

use constant generic_code => sub {
  return @_ unless $_[0] =~ /\]$/;
  my ($code, @xs) = @_;
  (my $tcode = $code) =~ s/"([^"\\]+|\\.)"|'([^'\\]+|\\.)'//g;
  my $balance = sr($tcode, qr/[^[]/, '') - sr($tcode, qr/[^]]/, '');
  $balance ? (substr($code, 0, $balance), substr($code, $balance))
           : ($code, @xs)};
1 core/gen/lib
gen.pl
13 core/gen/gen.pl


our $gensym_index = 0;
sub gensym {join '_', '_gensym', ++$gensym_index, @_}
sub gen($) {
  my @pieces = split /(%\w+)/, $_[0];
  sub {
    my %vars = @_;
    my @r = @pieces;
    $r[$_] = $vars{substr $pieces[$_], 1} for grep $_ & 1, 0..$#pieces;
    join '', @r;
  };
}
4 core/stream/lib
cat.pm
decode.pm
stream.pl
stream.sh
13 core/stream/cat.pm

while (@ARGV) {
  my $f = shift @ARGV;
  if (-d $f) {
    opendir my $d, $f or die "ni_cat: failed to opendir $f: $!";
    print "$f/$_\n" for sort grep $_ ne '.' && $_ ne '..', readdir $d;
    closedir $d;
  } else {
    open F, '<', $f or die "ni_cat: failed to open $f: $!";
    syswrite STDOUT, $_ while sysread F, $_, 8192;
    close F;
  }
}
24 core/stream/decode.pm




my ($fd) = @ARGV;
if (defined $fd) {
  close STDIN;
  open STDIN, "<&=$fd" or die "ni_decode: failed to open fd $fd: $!";
}
sysread STDIN, $_, 8192;
my $decoder = /^\x1f\x8b/             ? "gzip -dc"
            : /^BZh\0/                ? "bzip2 -dc"
            : /^\x89\x4c\x5a\x4f/     ? "lzop -dc"
            : /^\x04\x22\x4d\x18/     ? "lz4 -dc"
            : /^\xfd\x37\x7a\x58\x5a/ ? "xz -dc" : undef;
if (defined $decoder) {
  open FH, "| $decoder" or die "ni_decode: failed to open '$decoder': $!";
  syswrite FH, $_;
  syswrite FH, $_ while sysread STDIN, $_, 8192;
  close FH;
} else {
  syswrite STDOUT, $_;
  syswrite STDOUT, $_ while sysread STDIN, $_, 8192;
}
27 core/stream/stream.pl

use constant stream_sh => {stream_sh => $self{'core/stream/stream.sh'}};
use constant perl_fn   => gen '%name() { perl -e %code "$@"; }';
use constant perl_ifn  => gen "%name() { perl - \"\$@\" <<'%hd'; }\n%code\n%hd";
sub perl_fn_dep($$)
{+{$_[0] => perl_fn->(name => $_[0], code => quote $self{$_[1]})}}
sub perl_stdin_fn_dep($$)
{+{$_[0] => perl_ifn->(name => $_[0], code => $_[1], hd => heredoc_for $_[1])}}
sub ni_cat($)     {sh ['ni_cat', $_[0]], prefix => perl_fn_dep 'ni_cat',    'core/stream/cat.pm'}
sub ni_decode(;$) {sh ['ni_decode', @_], prefix => perl_fn_dep 'ni_decode', 'core/stream/decode.pm'}
sub ni_pager {sh ['ni_pager'], prefix => stream_sh}
sub ni_pipe {@_ == 1 ? $_[0] : sh ['ni_pipe', $_[0], ni_pipe(@_[1..$#_])],
                                  prefix => stream_sh}
sub ni_append  {sh ['ni_append', @_], prefix => stream_sh}
sub ni_verb($) {sh ['ni_append_hd', 'cat'], stdin => $_[0],
                                            prefix => stream_sh}
@pipeline_prefix = -t STDIN  ? ()       : ni_decode 3;
@pipeline_suffix = -t STDOUT ? ni_pager : ();
deflong 'root', 'stream/sh', pmap {ni_append qw/sh -c/, $_}
                             mrc '^(?:sh|\$):(.*)';
deflong 'root', 'stream/fs',
  pmap {ni_append 'eval', ni_pipe ni_cat $_, ni_decode}
  alt mrc '^file:(.+)', pif {-e} mrc '^[^]]+';
deflong 'root', 'stream/n',  pmap {ni_append 'seq',    $_}     pn 1, mr '^n:',  number;
deflong 'root', 'stream/n0', pmap {ni_append 'seq', 0, $_ - 1} pn 1, mr '^n0:', number;
deflong 'root', 'stream/id', pmap {ni_append 'echo', $_} mrc '^id:(.*)';
deflong 'root', 'stream/pipe', pmap {sh 'sh', '-c', $_} mrc '^\$=(.*)';
10 core/stream/stream.sh



ni_append()  { cat; "$@"; }
ni_prepend() { "$@"; cat; }
ni_append_hd()  { cat <&3; "$@"; }
ni_prepend_hd() { "$@"; cat <&3; }
ni_pipe() { eval "$1" | eval "$2"; }

ni_pager() { ${NI_PAGER:-less} || more || cat; }
1 core/meta/lib
meta.pl
12 core/meta/meta.pl

deflong 'root', 'meta/self', pmap {ni_verb image}            mr '^//ni';
deflong 'root', 'meta/keys', pmap {ni_verb join "\n", @keys} mr '^//ni/';
deflong 'root', 'meta/get',  pmap {ni_verb $self{$_}}        mr '^//ni/([^]]+)';
sub ni {sh ['ni_self', @_], prefix => perl_stdin_fn_dep 'ni_self', image}
deflong 'root', 'meta/ni', pmap {ni @$_} pn 1, mr '^@', context 'root/lambda';

deflong 'root', 'meta/help',
  pmap {$_ = 'README' if !length or /^tutorial$/;
        die "ni: unknown help topic: $_" unless exists $self{"doc/$_.md"};
        ni_verb $self{"doc/$_.md"}}
  pn 1, mr '^//help/?', mrc '^.*';
1 core/col/lib
col.pl
40 core/col/col.pl



sub col_cut {
  my ($floor, $rest, @fs) = @_;
  sh 'cut', '-f', join ',', $rest ? (@fs, "$floor-") : @fs;
}
our $cut_gen = gen q{chomp; @_ = split /\t/; print join("\t", @_[%is]), "\n"};
sub ni_cols(@) {
  # TODO: this function shouldn't be parsing column specs
  my $ind   = grep /[^A-I.]/, @_;
  my $asc   = join('', @_) eq join('', sort @_);
  my @cols  = map /^\.$/ ? -1 : ord($_) - 65, @_;
  my $floor = (sort {$b <=> $a} @cols)[0] + 1;
  return col_cut $floor, scalar(grep $_ eq '.', @_), @cols if $ind && $asc;
  sh ['perl', '-ne',
      $cut_gen->(is => join ',', map $_ == -1 ? "$floor..\$#_" : $_, @cols)];
}
our @col_alt = (pmap {ni_cols split //, $_} colspec);
defshort 'root', 'f', altr @col_alt;

sub ni_colswap(@) {
  # TODO after we do the colspec parsing refactor
}



sub ni_split_chr($)   {sh 'perl', '-lnpe', "y/$_[0]/\\t/"}
sub ni_split_regex($) {sh 'perl', '-lnpe', "s/$_[0]/\$1\\t/g"}
sub ni_scan_regex($)  {sh 'perl', '-lne',  'print join "\t", /' . "$_[0]/g"}
our %split_chalt = (
  'C' => (pmap {ni_split_chr   ','}              none),
  'P' => (pmap {ni_split_chr   '|'}              none),
  'S' => (pmap {ni_split_regex qr/\h+/}          none),
  'W' => (pmap {ni_split_regex qr/[^\w\n]+/}     none),
  '/' => (pmap {ni_split_regex $_}               regex),
  ':' => (pmap {ni_split_chr   $_}               mr '^.'),
  'm' => (pn 1, mr '^/', pmap {ni_scan_regex $_} regex),
);
defshort 'root', 'F', chaltr %split_chalt;
2 core/row/lib
row.pl
row.sh
24 core/row/row.pl

use constant row_pre => {row_sh => $self{'core/row/row.sh'}};
our @row_alt = (
  (pmap {sh 'tail', '-n', $_}                      pn 1, mr '^\+', number),
  (pmap {sh 'tail', '-n', '+' . ($_ + 1)}          pn 1, mr '^-',  number),
  (pmap {sh ['ni_revery',  $_], prefix => row_pre} pn 1, mr '^x',  number),
  (pmap {sh ['ni_rmatch',  $_], prefix => row_pre} pn 1, mr '^/',  regex),
  (pmap {sh ['ni_rsample', $_], prefix => row_pre} mr '^\.\d+'),
  (pmap {sh 'head', '-n', $_}                      alt neval, integer));
defshort 'root', 'r', altr @row_alt;




use constant sortspec => rep seq colspec1, maybe mr '^[gnr]+';
sub sort_args {'-t', "\t",
               map {my $i = ord($$_[0]) - 64;
                    my $m = defined $$_[1] ? $$_[1] : '';
                    ('-k', "$i$m,$i")} @_}
sub ni_sort(@) {sh ['ni_sort', @_], prefix => row_pre}
defshort 'root', 'g', pmap {ni_sort        sort_args @$_} sortspec;
defshort 'root', 'G', pmap {ni_sort '-u',  sort_args @$_} sortspec;
defshort 'root', 'o', pmap {ni_sort '-n',  sort_args @$_} sortspec;
defshort 'root', 'O', pmap {ni_sort '-rn', sort_args @$_} sortspec;
11 core/row/row.sh

ni_revery()  { perl -ne 'print unless $. % '"$1"; }
ni_rmatch()  { perl -lne 'print if /'"$1"/; }

ni_rsample() { perl -ne '
  BEGIN {srand($ENV{NI_SEED} || 42)}
  if ($. >= 0) {print; $. -= -log(1 - rand()) / '"$1"'}'; }

ni_sort() {
  # TODO: --compress-program etc
  sort "$@"; }
1 core/facet/lib
facet.pl
7 core/facet/facet.pl





our %facet_chalt;
defshort 'root', '@', chaltr %facet_chalt;
5 core/pl/lib
pl.pl
util.pm
math.pm
stream.pm
facet.pm
30 core/pl/pl.pl

use constant perl_mapgen => gen q{
  %prefix
  close STDIN;
  open STDIN, '<&=3' or die "ni: failed to open fd 3: $!";
  sub row {
    %body
  }
  while (defined rl) {
    %each
  }
};
sub perl_prefix() {join "\n", @self{qw| core/pl/util.pm
                                        core/pl/math.pm
                                        core/pl/stream.pm
                                        core/gen/gen.pl
                                        core/pl/facet.pm |}}
sub perl_gen($$) {sh [qw/perl -/],
  stdin => perl_mapgen->(prefix => perl_prefix,
                         body   => $_[0],
                         each   => $_[1])}
sub perl_mapper($)  {perl_gen $_[0], 'pr for row'}
sub perl_grepper($) {perl_gen $_[0], 'pr if row'}
sub perl_facet($)   {perl_gen $_[0], 'pr row . "\t$_"'}
our @perl_alt = (pmap {perl_mapper $_} plcode);
defshort 'root', 'p', altr @perl_alt;
unshift @row_alt, pmap {perl_grepper $_} pn 1, mr '^p', plcode;
$facet_chalt{p} = pmap {[perl_facet $$_[0],
                         sh(['ni_sort', '-k1,1'], prefix => row_pre),
                         perl_mapper $$_[1]]} seq plcode, plcode;
48 core/pl/util.pm

sub sr($$$)  {(my $x = $_[2]) =~ s/$_[0]/$_[1]/;  $x}
sub sgr($$$) {(my $x = $_[2]) =~ s/$_[0]/$_[1]/g; $x}
sub sum  {local $_; my $s = 0; $s += $_ for @_; $s}
sub prod {local $_; my $p = 1; $p *= $_ for @_; $p}
sub mean {scalar @_ && sum(@_) / @_}
sub max    {local $_; my $m = pop @_; $m = $m >  $_ ? $m : $_ for @_; $m}
sub min    {local $_; my $m = pop @_; $m = $m <  $_ ? $m : $_ for @_; $m}
sub maxstr {local $_; my $m = pop @_; $m = $m gt $_ ? $m : $_ for @_; $m}
sub minstr {local $_; my $m = pop @_; $m = $m lt $_ ? $m : $_ for @_; $m}
sub argmax(&@) {
  local $_;
  my ($f, $m, @xs) = @_;
  my $fm = &$f($m);
  for my $x (@xs) {
    ($m, $fm) = ($x, $fx) if (my $fx = &$f($x)) > $fm;
  }
  $m;
}
sub argmin(&@) {
  local $_;
  my ($f, $m, @xs) = @_;
  my $fm = &$f($m);
  for my $x (@xs) {
    ($m, $fm) = ($x, $fx) if (my $fx = &$f($x)) < $fm;
  }
  $m;
}
sub any(&@) {local $_; my ($f, @xs) = @_; &$f($_) && return 1 for @_; 0}
sub all(&@) {local $_; my ($f, @xs) = @_; &$f($_) || return 0 for @_; 1}
sub uniq  {local $_; my(%seen, @xs); $seen{$_}++ or push @xs, $_ for @_; @xs}
sub freqs {local $_; my %fs; ++$fs{$_} for @_; \%fs}
sub reduce(&$@) {local $_; my ($f, $x, @xs) = @_; $x = &$f($x, $_) for @xs; $x}
sub reductions(&$@) {
  local $_;
  my ($f, $x, @xs, @ys) = @_;
  push @ys, $x = &$f($x, $_) for @xs;
  @ys;
}
sub cart {
  local $_;
  return () unless @_;
  return map [$_], @{$_[0]} if @_ == 1;
  my @ns     = map scalar(@$_), @_;
  my @shifts = reverse reductions {$_[0] * $_[1]} 1 / $ns[0], reverse @ns;
  map {my $i = $_; [map $_[$_][int($i / $shifts[$_]) % $ns[$_]], 0..$#_]}
      0..prod(@ns) - 1;
}
24 core/pl/math.pm

use constant tau => 2 * 3.14159265358979323846264;
use constant LOG2  => log 2;
use constant LOG2R => 1 / LOG2;
sub log2 {LOG2R * log $_[0]}
sub quant {my ($x, $q) = @_; $q ||= 1;
           my $s = $x < 0 ? -1 : 1; int(abs($x) / $q + 0.5) * $q * $s}
sub dot {local $_; my ($u, $v) = @_;
         sum map $$u[$_] * $$v[$_], 0..min $#{$u}, $#{$v}}
sub l1norm {local $_; sum map abs($_), @_}
sub l2norm {local $_; sqrt sum map $_*$_, @_}
sub rdeg($) {$_[0] * 360 / tau}
sub drad($) {$_[0] / 360 * tau}
sub prec {($_[0] * sin drad $_[1], $_[0] * cos drad $_[1])}
sub rpol {(l2norm(@_), rdeg atan2($_[0], $_[1]))}
if (eval {require Math::Trig}) {
  sub haversine {
    local $_;
    my ($th1, $ph1, $th2, $ph2) = map drad $_, @_;
    my ($dt, $dp) = ($th2 - $th1, $ph2 - $ph1);
    my $a = sin($dp / 2)**2 + cos($p1) * cos($p2) * sin($dt / 2)**2;
    2 * atan2(sqrt($a), sqrt(1 - $a));
  }
}
28 core/pl/stream.pm






our @q;
our @F;
our $l;
sub rl()   {$l = $_ = @q ? shift @q : <STDIN>; @F = (); $_}
sub F_(@)  {chomp $l, @F = split /\t/, $l unless @F; @_ ? @F[@_] : @F}
sub r(@)   {(my $l = join "\t", @_) =~ s/\n//g; print "$l\n"; ()}
sub pr(;$) {(my $l = @_ ? $_[0] : $_) =~ s/\n//g; print "$l\n"; ()}
BEGIN {eval sprintf 'sub %s() {F_ %d}', $_, ord($_) - 97 for 'b'..'q';
       eval sprintf 'sub %s() {"%s"}', uc, $_ for 'a'..'q';
       eval sprintf 'sub %s_  {local $_; map((split /\t/)[%d], @_)}',
                    $_, ord($_) - 97 for 'a'..'q'}

sub a() {@F ? $F[0] : substr $l, 0, index $l, "\t"}





sub rw(&) {my @r = ($l); push @r, $_ while defined rl && &{$_[0]}; push @q, $_ if defined; @r}
sub ru(&) {my @r = ($l); push @r, $_ until defined rl && &{$_[0]}; push @q, $_ if defined; @r}
sub re(&) {my ($f, $i) = ($_[0], &{$_[0]}); rw {&$f eq $i}}
BEGIN {eval sprintf 'sub re%s() {re {%s}}', $_, $_ for 'a'..'q'}
47 core/pl/facet.pm


sub fe(&) {my ($k, $f, $x) = (a, @_);
           $x = &$f, rl while defined and a eq $k;
           push @q, $_ if defined;
           $x}
sub fr(&@) {my ($k, $f, @xs) = (a, @_);
            @xs = &$f(@xs), rl while defined and a eq $k;
            push @q, $_ if defined;
            @xs}


sub fsum($)  {+{reduce => gen "%1 + ($_[0])",
                init   => [0],
                end    => gen '%1'}}
sub fmean($) {+{reduce => gen "%1 + ($_[0]), %2 + 1",
                init   => [0, 0],
                end    => gen '%1 / (%2 || 1)'}}
sub fmin($)  {+{reduce => gen "defined %1 ? min %1, ($_[0]) : ($_[0])",
                init   => [undef],
                end    => gen '%1'}}
sub fmax($)  {+{reduce => gen "defined %1 ? max %1, ($_[0]) : ($_[0])",
                init   => [undef],
                end    => gen '%1'}}
sub farr($)  {+{reduce => gen "[\@{%1}, ($_[0])]",
                init   => [[]],
                end    => gen '%1'}}
sub rfn($$)  {+{reduce => gen $_[0],
                init   => [@_[1..$#_]],
                end    => gen join ', ', map "%$_", 1..$#_}}
sub compound_facet(@) {
  local $_;
  my $slots = 0;
  my @indexes = map {my $n = @{$$_{init}}; $slots += $n; $slots - $n} @_;
  my @mapping = map {my $i = $_;
                     [map {;$_ => sprintf "\$_[%d]", $indexes[$i] + $_ - 1}
                          1..@{$_[$i]{init}}]} 0..$#_;
  +{init   => [map @{$$_{init}}, @_],
    reduce => join(', ', map $_[$_]{reduce}->(@{$mapping[$_]}), 0..$#_),
    end    => join(', ', map $_[$_]{end}->(@{$mapping[$_]}),    0..$#_)}
}
sub fc(@) {
  my %c      = %{compound_facet @_};
  my $reduce = eval "sub{\n($c{reduce})\n}" or die "fc: '$c{reduce}': $@";
  my $end    = eval "sub{\n($c{end})\n}"    or die "fc: '$c{end}': $@";
  &$end(fr {$reduce->(@_)} @{$c{init}});
}
1 core/python/lib
python.pl
22 core/python/python.pl





sub pydent($) {
  my @lines   = split /\n/, $_[0];
  my @indents = map length(sr $_, qr/\S.*$/, ''), @lines;
  my $indent  = @lines > 1 ? $indents[1] - $indents[0] : 0;
  $indent = min $indent - 1, @indents[2..$#indents]
    if $lines[0] =~ /:\s*(#.*)?$/ && @lines > 2;
  my $spaces = ' ' x $indent;
  $lines[$_] =~ s/^$spaces// for 1..$#lines;
  join "\n", @lines;
}
sub indent($;$) {
  my ($code, $indent) = (@_, 2);
  join "\n", map ' ' x $indent . $_, split /\n/, $code;
}
sub pyquote($) {"'" . sgr(sgr($_[0], qr/\\/, '\\\\'), qr/'/, '\\\'') . "'"}

use constant pycode => pmap {pydent $_} generic_code;
1 core/sql/lib
sql.pl
90 core/sql/sql.pl

sub sqlgen($) {bless {from => $_[0]}, 'ni::sqlgen'}
sub ni::sqlgen::render {
  local $_;
  my ($self) = @_;
  return $$self{from} if 1 == keys %$self;
  my $select = ni::dor $$self{select}, '*';
  my @others;
  for (qw/from where order_by group_by limit union intersect except
          inner_join left_join right_join full_join natural_join/) {
    next unless exists $$self{$_};
    (my $k = $_) =~ y/a-z_/A-Z /;
    push @others, "$k $$self{$_}";
  }
  ni::gen('SELECT %distinct %stuff %others')
       ->(stuff    => $select,
          distinct => $$self{uniq} ? 'DISTINCT' : '',
          others   => join ' ', @others);
}
sub ni::sqlgen::modify_where {join ' AND ', @_}
sub ni::sqlgen::modify {
  my ($self, %kvs) = @_;
  while (my ($k, $v) = each %kvs) {
    if (exists $$self{$k}) {
      if (exists ${'ni::sqlgen::'}{"modify_$k"}) {
        $v = &{"ni::sqlgen::modify_$k"}($$self{$k}, $v);
      } else {
        $self = ni::sqlgen "($self->render)";
      }
    }
    $$self{$k} = $v;
  }
  $self;
}
sub ni::sqlgen::map        {$_[0]->modify(select => $_[1])}
sub ni::sqlgen::filter     {$_[0]->modify(where =>  $_[1])}
sub ni::sqlgen::take       {$_[0]->modify(limit =>  $_[1])}
sub ni::sqlgen::sample     {$_[0]->modify(where =>  "random() < $_[1]")}
sub ni::sqlgen::ijoin      {$_[0]->modify(join => 1, inner_join   => $_[1])}
sub ni::sqlgen::ljoin      {$_[0]->modify(join => 1, left_join    => $_[1])}
sub ni::sqlgen::rjoin      {$_[0]->modify(join => 1, right_join   => $_[1])}
sub ni::sqlgen::njoin      {$_[0]->modify(join => 1, natural_join => $_[1])}
sub ni::sqlgen::order_by   {$_[0]->modify(order_by => $_[1])}
sub ni::sqlgen::uniq       {${$_[0]}{uniq} = 1; $_[0]}
sub ni::sqlgen::union      {$_[0]->modify(setop => 1, union     => $_[1])}
sub ni::sqlgen::intersect  {$_[0]->modify(setop => 1, intersect => $_[1])}
sub ni::sqlgen::difference {$_[0]->modify(setop => 1, except    => $_[1])}

use constant sqlcode => generic_code;

sub sql_compile {
  local $_;
  my ($g, @ms) = @_;
  for (@ms) {
    if (ref($_) eq 'ARRAY') {
      my ($m, @args) = @$_;
      $g = $g->$m(@args);
    } else {
      $g = $g->modify(%$_);
    }
  }
  $g->render;
}

defcontext 'sql';
use constant sql_table => pmap {sqlgen $_} mrc '^.*';
our $sql_query = pmap {sql_compile $$_[0], @{$$_[1]}}
                 seq sql_table, maybe alt context 'sql/lambda',
                                          context 'sql/suffix';
our @sql_row_alt;
our @sql_join_alt = (
  (pmap {['ljoin', $_]} pn 1, mr '^L', $sql_query),
  (pmap {['rjoin', $_]} pn 1, mr '^R', $sql_query),
  (pmap {['njoin', $_]} pn 1, mr '^N', $sql_query),
  (pmap {['ijoin', $_]} $sql_query),
);
defshort 'sql', 's', pmap {['map',    $_]} sqlcode;
defshort 'sql', 'w', pmap {['filter', $_]} sqlcode;
defshort 'sql', 'r', altr @sql_row_alt;
defshort 'sql', 'j', altr @sql_join_alt;
defshort 'sql', 'G', k ['uniq'];
defshort 'sql', 'g', pmap {['order_by', $_]} sqlcode;
defshort 'sql', '+', pmap {['union',      $_]} $sql_query;
defshort 'sql', '*', pmap {['intersect',  $_]} $sql_query;
defshort 'sql', '-', pmap {['difference', $_]} $sql_query;
defshort 'sql', '@', pmap {+{select => $$_[1], group_by => $$_[0]}}
                     seq sqlcode, sqlcode;

our %sql_profiles;
defshort 'root', 'Q', chaltr %sql_profiles;
1 core/java/lib
java.pl
2 core/java/java.pl

defcontext 'java/cf';
3 core/lisp/lib
prefix.lisp
fd-redirect.lisp
lisp.pl
1 core/lisp/prefix.lisp
(declaim (optimize (speed 3) (safety 0)))
7 core/lisp/fd-redirect.lisp
;; Ok Wes, this one's on you dude.
;; The contents of the data stream we want to process are coming in on FD 3,
;; which should be available for reading (just like 0 normally is). In theory
;; you could issue a read() syscall on fd 3 immediately and it would give you
;; data, so you just have to convince Lisp to do this.

(print :uhoh-no-fd-3-yet)
16 core/lisp/lisp.pl


use constant lisp_mapgen => gen q{
  %prefix
  (when t
    (print :booyah)
    %body)
};

sub lisp_prefix() {join "\n", @self{qw| core/lisp/prefix.lisp
                                        core/lisp/fd-redirect.lisp |}}

defshort 'root', 'L', pmap {sh [qw/sbcl --noinform --script/],
                               stdin => lisp_mapgen->(prefix => lisp_prefix,
                                                      body   => $_)}
                           mrc '^.*[^]]+';
1 core/hadoop/lib
hadoop.pl
1 core/hadoop/hadoop.pl

1 core/pyspark/lib
pyspark.pl
32 core/pyspark/pyspark.pl



sub pyspark_compile {my $v = shift; $v = $_->(v => $v) for @_; $v}
sub pyspark_lambda($) {$_[0]}
defcontext 'pyspark';
use constant pyspark_fn => pmap {pyspark_lambda $_} pycode;
our $pyspark_rdd = pmap {pyspark_compile 'sc', @$_}
                   alt context 'pyspark/lambda',
                       context 'pyspark/suffix';
our @pyspark_row_alt = (
  (pmap {gen "%v.sample(False, $_)"} alt neval, integer),
  (pmap {gen "%v.takeSample(False, $_)"} mr '^\.(\d+)'),
  (pmap {gen "%v.filter($_)"} pyspark_fn));
deflong 'pyspark', 'stream/n',
  pmap {gen "sc.parallelize(range($_))"} pn 1, mr '^n:', number;
deflong 'pyspark', 'stream/pipe',
  pmap {gen "%v.pipe(" . pyquote($_) . ")"} mr '^\$=([^]]+)';
defshort 'pyspark', 'p', pmap {gen "%v.map(lambda x: $_)"} pyspark_fn;
defshort 'pyspark', 'r', altr @pyspark_row_alt;
defshort 'pyspark', 'G', k gen "%v.distinct()";
defshort 'pyspark', 'g', k gen "%v.sortByKey()";
defshort 'pyspark', '+', pmap {gen "%v.union($_)"} $pyspark_rdd;
defshort 'pyspark', '*', pmap {gen "%v.intersect($_)"} $pyspark_rdd;

our %spark_profiles = (
  L => k gen pydent q{from pyspark import SparkContext
                      sc = SparkContext("local", "%name")
                      %body});
sub ni_pyspark {sh ['echo', 'TODO: pyspark', @_]}
defshort 'root', 'P', pmap {ni_pyspark @$_}
                      seq chaltr(%spark_profiles), $pyspark_rdd;
6 doc/lib
README.md
stream.md
row.md
col.md
options.md
sql.md
16 doc/README.md
# ni tutorial
You can access this tutorial by running `ni //help` or `ni //help/tutorial`.

ni parses its command arguments to build and run a shell pipeline. Help topics
include:

## Basics
- [stream.md](stream.md) (`ni //help/stream`): intro to ni grammar and data
- [row.md](row.md) (`ni //help/row`): row-level operators
- [col.md](col.md) (`ni //help/col`): column-level operators
- [perl.md](perl.md) (`ni //help/perl`): ni's Perl library
- [ruby.md](ruby.md) (`ni //help/ruby`): ni's Ruby library

## Reference
- [options.md](options.md) (`ni //help/options`): every CLI option and
  operator, each with example usage
95 doc/stream.md
# Stream operations
Streams are made of text, and ni can do a few different things with them. The
simplest involve stuff that bash utilities already handle (though more
verbosely):

```bash
$ echo test > foo
$ ni foo
test
$ ni foo foo
test
test
```

ni transparently decompresses common formats, regardless of file extension:

```bash
$ echo test | gzip > fooz
$ ni fooz
test
$ cat fooz | ni
test
```

## Data sources
In addition to files, ni can generate data in a few ways:

```bash
$ ni $:'seq 4'                  # shell command stdout
1
2
3
4
$ ni n:4                        # integer generator
1
2
3
4
$ ni n0:4                       # integer generator, zero-based
0
1
2
3
$ ni id:foo                     # literal text
foo
```

## Transformation
ni can stream data through a shell process, which is often shorter than
shelling out separately:

```bash
$ ni n:3 | sort
1
2
3
$ ni n:3 $=sort                 # $= filters through a command
1
2
3
$ ni n:3 $='sort -r'
3
2
1
```

And, of course, ni has shorthands for doing all of the above:

```bash
$ ni n:3 g                      # g = sort
1
2
3
$ ni n:3g                       # no need for whitespace
1
2
3
$ ni n:3gAr                     # reverse-sort by first field
3
2
1
$ ni n:3O                       # more typical reverse numeric sort
3
2
1
```

Notice that ni typically doesn't require whitespace between commands. The only
case where it does is when the parse would be ambiguous without it (and
figuring out when this happens requires some knowledge about how the shell
quotes things, since ni sees post-quoted arguments). ni will complain if it
can't parse something, though.

See [row.md](row.md) (`ni //help/row`) for details about row-reordering
operators like sorting.
149 doc/row.md
# Row operations
These are fairly well-optimized operations that operate on rows as units, which
basically means that ni can just scan for newlines and doesn't have to parse
anything else. They include:

- Take first/last N
- Take uniform-random or periodic sample
- Rows matching regex
- Rows satisfying code
- Reorder rows

## First/last
Shorthands for UNIX `head` and `tail`.

```bash
$ ni n:10r3                     # take first 3
1
2
3
$ ni n:10r+3                    # take last 3
8
9
10
$ ni n:10r-7                    # drop first 7
8
9
10
```

## Sampling
```bash
$ ni n:10000rx4000              # take every 4000th row
4000
8000
$ ni n:10000r.0002              # sample uniformly, P(row) = 0.0002
1
6823
8921
9509
```

It's worth noting that uniform sampling, though random, is also deterministic;
by default ni seeds the RNG with 42 every time (though you can change this by
exporting `NI_SEED`). ni also uses an optimized Poisson process to sample rows,
which minimizes calls to `rand()`.

## Regex matching
```bash
$ ni n:10000r/[42]000$/
2000
4000
$ ni n:1000r/[^1]$/r3
2
3
4
```

These regexes are evaluated by Perl, which is likely to be faster than `grep`
for nontrivial patterns.

## Code
`rp` means "select rows for which this Perl expression returns true".

```bash
$ ni n:10000rp'$_ % 100 == 42' r3
42
142
242
```

The expression has access to column accessors and everything else described in
[perl.md](perl.md) (`ni //help/perl`).

Note that whitespace is always required after quoted code.

**TODO:** other languages

## Sorting
ni has four operators that shell out to the UNIX sort command. Two are
alpha-sorts:

```bash
$ ni n:100n:10gr4               # g = 'group'
1
1
10
10
$ ni n:100n:100Gr4              # G = 'group uniq'
1
10
100
11
```

The idea behind `g` as `group` is that this is what you do prior to an
aggregation; i.e. to group related rows together so you can stream into a
reducer (covered in more detail in [facet.md](facet.md) (`ni //help/facet`)).

ni also has two `order` operators that sort numerically:

```bash
$ ni n:100or3                   # o = 'order': sort numeric ascending
1
2
3
$ ni n:100Or3                   # O = 'reverse order'
100
99
98
```

### Specifying sort columns
When used without options, the sort operators sort by a whole row; but you can
append one or more column specifications to change this. I'll generate some
multicolumn data to demonstrate this (see [perl.md](perl.md) (`ni //help/perl`)
for an explanation of the `p` operator).

```bash
$ ni n:100p'r a, sin(a), log(a)' > data         # generate multicolumn data
$ ni data r4
1	0.841470984807897	0
2	0.909297426825682	0.693147180559945
3	0.141120008059867	1.09861228866811
4	-0.756802495307928	1.38629436111989
```

Now we can sort by the second column, which ni refers to as `B` (in general, ni
uses spreadsheet notation: columns are letters, rows are numbers):

```bash
$ ni data oB r4
11	-0.999990206550703	2.39789527279837
55	-0.99975517335862	4.00733318523247
99	-0.999206834186354	4.59511985013459
80	-0.993888653923375	4.38202663467388
```

This is an example of required whitespace between `oB` and `r4`; columns can be
suffixed with `g`, `n`, and/or `r` modifiers to modify how they are sorted
(these behave as described for `sort`'s `-k` option), and ni prefers this
interpretation:

```bash
$ ni data oBr r4                # r suffix = reverse sort
33	0.999911860107267	3.49650756146648
77	0.999520158580731	4.34380542185368
58	0.992872648084537	4.06044301054642
14	0.99060735569487	2.63905732961526
```
143 doc/col.md
# Column operations
ni models incoming data as a tab-delimited spreadsheet and provides some
operators that allow you to manipulate the columns in a stream accordingly. The
two important ones are `f[columns...]` to rearrange columns, and `F[delimiter]`
to create new ones.

ni always refers to columns using letters: `A` to `Z`.

## Reordering
First let's generate some data, in this case an 8x8 multiplication table:

```bash
$ ni n:8p'r map a*$_, 1..8' > mult-table
$ ni mult-table
1	2	3	4	5	6	7	8
2	4	6	8	10	12	14	16
3	6	9	12	15	18	21	24
4	8	12	16	20	24	28	32
5	10	15	20	25	30	35	40
6	12	18	24	30	36	42	48
7	14	21	28	35	42	49	56
8	16	24	32	40	48	56	64
```

The `f` operator takes a multi-column spec and reorders, duplicates, or deletes
columns accordingly.

```bash
$ ni mult-table fA      # the first column
1
2
3
4
5
6
7
8
$ ni mult-table fDC     # fourth, then third column
4	3
8	6
12	9
16	12
20	15
24	18
28	21
32	24
$ ni mult-table fAA     # first column, duplicated
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
```

You can also choose "the rest of the columns" using `.` within your column
spec. This selects everything to the right of the rightmost column you've
mentioned.

```bash
$ ni mult-table fDA.    # fourth, first, "and the rest (i.e. 5-8)"
4	1	5	6	7	8
8	2	10	12	14	16
12	3	15	18	21	24
16	4	20	24	28	32
20	5	25	30	35	40
24	6	30	36	42	48
28	7	35	42	49	56
32	8	40	48	56	64
$ ni mult-table fBA.    # an easy way to swap first two columns
2	1	3	4	5	6	7	8
4	2	6	8	10	12	14	16
6	3	9	12	15	18	21	24
8	4	12	16	20	24	28	32
10	5	15	20	25	30	35	40
12	6	18	24	30	36	42	48
14	7	21	28	35	42	49	56
16	8	24	32	40	48	56	64
```

## Splitting
The `F` operator gives you a way to convert non-tab-delimited data into TSV.
For example, if you're parsing `/etc/passwd`, you'd turn colons into tabs
first.

`F` has the following uses:

- `F:<char>`: split on character
- `F/regex/`: split on occurrences of regex. If present, the first capture
  group will be included before a tab is appended to a field.
- `Fm/regex/`: don't split; instead, look for matches of regex and use those as
  the field values.
- `FC`: split on commas
- `FS`: split on runs of horizontal whitespace
- `FW`: split on runs of non-word characters
- `FP`: split on pipe symbols

Note that `FC` isn't a proper CSV parser; it just transliterates all commas
into tabs.

### Examples
```bash
$ ni /etc/passwd r2F::          # F: followed by :, which is the split char
root	x	0	0	root	/root	/bin/bash
daemon	x	1	1	daemon	/usr/sbin	/bin/sh
```

```bash
$ ni //ni r3                            # some data
#!/usr/bin/env perl
# ni: https://github.com/spencertipping/ni
# Copyright (c) 2016 Spencer Tipping
```

```bash
$ ni //ni r3F/\\//                      # split on forward slashes
#!	usr	bin	env perl
# ni: https:		github.com	spencertipping	ni
# Copyright (c) 2016 Spencer Tipping
```

```bash
$ ni //ni r3FW                          # split on non-words
	usr	bin	env	perl
	ni	https	github	com	spencertipping	ni
	Copyright	c	2016	Spencer	Tipping
```

```bash
$ ni //ni r3FS                          # split on whitespace
#!/usr/bin/env	perl
#	ni:	https://github.com/spencertipping/ni
#	Copyright	(c)	2016	Spencer	Tipping
```

```bash
$ ni //ni r3Fm'/\/\w+/'                 # words beginning with a slash
/usr	/bin	/env
/github	/spencertipping	/ni

```
2 doc/options.md
# Complete ni operator listing
## 
24 doc/sql.md
# SQL interop
ni defines a parsing context that translates command-line syntax into SQL
queries. We'll need to define a SQL connection profile in order to use it:

```bash
$ mkdir sqlite-profile
$ echo sqlite.pl > sqlite-profile/lib
$ cat > sqlite-profile/sqlite.pl <<'EOF'
$sql_profiles{S} = pmap {sh "sqlite3", $$_[0], $$_[1]}
                        seq mrc '^.*', $sql_query;
EOF
```

Now we can create a test database and use this library to access it.

```bash
$ sqlite3 test.db <<'EOF'
CREATE TABLE foo(x int, y int);
INSERT INTO foo(x, y) VALUES (1, 2);
INSERT INTO foo(x, y) VALUES (3, 4);
INSERT INTO foo(x, y) VALUES (5, 6);
EOF
$ ni --lib sqlite-profile QStest.db foo [wx=3]
```
__END__

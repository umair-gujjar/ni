# Streaming data sources.
# Common ways to read data, most notably from files and directories. Also
# included are numeric generators, shell commands, etc.

BEGIN {
  defparseralias multiword    => pn 1, prx '\[',  prep(prc '[\s\S]*[^]]', 1), prx '\]';
  defparseralias multiword_ws => pn 1, prc '\[$', prep(pnx '\]$',         1), prx '\]$';

  defparser 'super_brackets', '', q{
    my ($self, @xs) = @_;
    return () unless $xs[0] =~ s/^(\^[^[]*)\[//;
    my $superness = $1;
    my @r;
    push @r, shift @xs while @xs && $xs[0] !~ s/^(\Q$superness\E)\]//;
    $1 eq $superness ? (\@r, @xs) : ();
  };
}
BEGIN {
  defparseralias shell_command => palt pmap(q{shell_quote @$_}, super_brackets),
                                       pmap(q{shell_quote @$_}, multiword_ws),
                                       pmap(q{shell_quote @$_}, multiword),
                                       prx '[^][]+';
  defparseralias id_text => palt pmap(q{join "\t", @$_}, super_brackets),
                                 pmap(q{join "\t", @$_}, multiword_ws),
                                 pmap(q{join "\t", @$_}, multiword),
                                 prx '[^][]+';
}

defoperator echo => q{my ($x) = @_; sio; print "$x\n"};
defoperator sh   => q{my ($c) = @_; sh $c};

defshort '/e', pmap q{sh_op $_}, shell_command;

# Cat meta-operator.
# We don't want 'cat' to be a regular operator because of how shell wildcards
# work. If you say something like `ni *`, it's going to get a bunch of filenames,
# each of which will fork out to another ni process. Most of these ni processes
# will just be copying stdin to stdout, a huge waste if there are a lot of files.

# We get around this by making `cat` a meta-operator that merges adjacent cat
# operations into a single `cat_multi`.

defoperator cat_multi => q{sio; scat $_ for @_};

defmetaoperator cat => q{
  my ($args, $left, $right) = @_;
  my ($f) = @$args;
  my $i = -1;
  ++$i while $i+1 < @$right && $$right[$i+1][0] eq 'cat';
  ($left, [cat_multi_op($f, $i > -1 ? map $$_[1], @$right[0..$i] : ()),
           @$right[$i+1..$#{$right}]]);
};

docparser multiword => <<'_';
A bracketed list of arguments to exec(), interpreted verbatim (i.e. shell
metacharacters within the arguments won't be expanded). If you use this form,
no ARGV entry can end in a closing bracket; otherwise ni will assume you wanted
to close the list.
_

docparser multiword_ws => <<'_';
A bracketed list of arguments to exec(), interpreted verbatim (i.e. shell
metacharacters within the arguments won't be expanded). Whitespace is required
around both brackets.
_

docparser shell_command => q{A quoted or bracketed shell command};

docoperator cat  => q{Append contents of a file or resource};
docoperator echo => q{Append text verbatim};
docoperator sh   => q{Filter stream through a shell command};

# Note that we generate numbers internally rather than shelling out to `seq`
# (which is ~20x faster than Perl for the purpose, incidentally). This is
# deliberate: certain versions of `seq` generate floating-point numbers after a
# point, which can cause unexpected results and loss of precision.

defoperator n => q{
  my ($l, $u) = @_;
  sio; for (my $i = $l; $u < 0 || $i < $u; ++$i) {print "$i\n"};
};

docoperator n => q{Append consecutive integers within a range};

defshort '/n',  pmap q{n_op 1, defined $_ ? $_ + 1 : -1}, popt number;
defshort '/n0', pmap q{n_op 0, defined $_ ? $_ : -1}, popt number;
defshort '/i',  pmap q{echo_op $_}, id_text;

defshort '/1', pmap q{n_op 1, 2}, pnone;

deflong '/fs', pmap q{cat_op $_}, filename;

docshort '/n' => q{Append integers 1..N, or 1..infinity if N is unspecified};
docshort '/n0' => q{Append integers 0..N-1, or 0..infinity if N is unspecified};
docshort '/i' => q{Identity: append literal text};
docshort '/e' => q{Exec shell command as a filter for the current stream};

docshort '/1' => q{Alias for 'n1'};

doclong '/fs' => q{Append things that appear to be files};

# Stream mixing/forking.
# Append, prepend, divert.

defoperator append => q{my @xs = @_; sio; exec_ni @xs};
docoperator append => q{Append another ni stream to this one};

defoperator prepend => q{
  my @xs = @_;
  close(my $fh = siproc {exec_ni @xs});
  $fh->await;
  sio;
};
docoperator prepend => q{Prepend a ni stream to this one};

defoperator sink_null => q{1 while saferead \*STDIN, $_, 8192};
docoperator sink_null => q{Consume stream and produce nothing};

defoperator divert => q{
  my @xs = @_;
  my $fh = siproc {close STDOUT; exec_ni @xs, sink_null_op};
  stee \*STDIN, $fh, \*STDOUT;
  close $fh;
  $fh->await;
};
docoperator divert => q{Duplicate this stream into a ni pipeline, discarding that pipeline's output};

defshort '/+', pmap q{append_op    @$_}, _qfn;
defshort '/^', pmap q{prepend_op   @$_}, _qfn;
defshort '/=', pmap q{divert_op    @$_}, _qfn;

# Interleaving.
# Append/prepend will block one of the two data sources until the other
# completes. Sometimes, though, you want to stream both at once. Interleaving
# makes that possible, and you can optionally specify the mixture ratio, which is
# the number of interleaved rows per input row. (Negative numbers are interpreted
# as reciprocals, so -2 means two stdin rows for every interleaved.)

defoperator interleave => q{
  my ($ratio, $lambda) = @_;
  my $fh = soproc {close STDIN; exec_ni @$lambda};

  if ($ratio) {
    $ratio = 1/-$ratio if $ratio < 0;
    my ($n1, $n2) = (0, 0);
    while (1) {
      ++$n1, defined($_ = <STDIN>) || goto done, print while $n1 <= $n2 * $ratio;
      ++$n2, defined($_ = <$fh>)   || goto done, print while $n1 >= $n2 * $ratio;
    }
  } else {
    my $rmask;
    my ($stdin_ok,  $ni_ok) = (1, 1);
    my ($stdin_buf, $ni_buf);
    while ($stdin_ok || $ni_ok) {
      vec($rmask, fileno STDIN, 1) = $stdin_ok;
      vec($rmask, fileno $fh,   1) = $ni_ok;
      my $n = select my $rout = $rmask, undef, undef, 0.01;
      if (vec $rout, fileno STDIN, 1) {
        $stdin_ok = !!saferead \*STDIN, $stdin_buf, 1048576, length $stdin_buf;
        my $i = 1 + rindex $stdin_buf, "\n";
        if ($i) {
          safewrite \*STDOUT, substr $stdin_buf, 0, $i;
          $stdin_buf = substr $stdin_buf, $i;
        }
      }
      if (vec $rout, fileno $fh, 1) {
        $ni_ok = !!saferead $fh, $ni_buf, 1048576, length $ni_buf;
        my $i = 1 + rindex $ni_buf, "\n";
        if ($i) {
          safewrite \*STDOUT, substr $ni_buf, 0, $i;
          $ni_buf = substr $ni_buf, $i;
        }
      }
    }
  }

  done:
  close $fh;
  $fh->await;
};

defshort '/%', pmap q{interleave_op @$_}, pseq popt number, _qfn;

# Sinking.
# We can sink data into a file just as easily as we can read from it. This is
# done with the `>` operator, which is typically written as `\>`. The difference
# between this and the shell's > operator is that \> outputs the filename; this
# lets you invert the operation with the nullary \< operator.

defoperator file_read  => q{chomp, weval q{scat $_} while <STDIN>};
defoperator file_write => q{
  my ($file) = @_;
  $file = resource_tmp('file://') unless defined $file;
  sforward \*STDIN, swfile $file;
  print "$file\n";
};

defshort '/>', pmap q{file_write_op $_}, nefilename;
defshort '/<', pmap q{file_read_op},     pnone;

defoperator file_prepend_name_read => q{
  my $file;
  while (defined($file = <STDIN>))
  {
    chomp $file;
    my $fh = soproc {scat $file};
    print "$file\t$_" while <$fh>;
    close $fh;
    $fh->await;
  }
};

defshort '/W<', pmap q{file_prepend_name_read_op}, pnone;

defoperator file_prepend_name_write => q{
  my ($lambda) = @_;
  my $file     = undef;
  my $fh       = undef;

  while (<STDIN>)
  {
    my ($fname, $l) = /^([^\t\n]*)\t([\s\S]*)/;
    if (!defined $file or $fname ne $file)
    {
      close $fh, $fh->can('await') && $fh->await if defined $fh;
      $file = $fname;

      # NB: swfile has much lower startup overhead than exec_ni(), so use that
      # unless we have a lambda that requires slower operation.
      $fh = defined $lambda
        ? siproc {exec_ni(@$lambda, file_write_op $file)}
        : swfile $file;
    }
    print $fh $l;
  }

  close $fh, $fh->await if defined $fh;
};

defshort '/W>', pmap q{file_prepend_name_write_op $_}, popt _qfn;

# Resource stream encoding.
# This makes it possible to serialize a directory structure into a single stream.
# ni uses this format internally to store its k/v state.

defoperator encode_resource_stream => q{
  my @xs;
  while (<STDIN>) {
    chomp;
    my $s = rfc $_;
    my $line_count = @xs = split /\n/, "$s ";
    print "$line_count $_\n", $s, "\n";
  }
};

defshort '/>\'R', pmap q{encode_resource_stream_op}, pnone;

# Compression and decoding.
# Sometimes you want to emit compressed data, which you can do with the `Z`
# operator. It defaults to gzip, but you can also specify xz, lzo, lz4, or bzip2
# by adding a suffix. You can decode a stream in any of these formats using `ZD`
# (though in most cases ni will automatically decode compressed formats).

our %compressors = qw/ g gzip  x xz  o lzop  4 lz4  b bzip2 /;

BEGIN {defparseralias compressor_name => prx '[gxo4b]'}
BEGIN {
  defparseralias compressor_spec =>
    pmap q{my ($c, $level) = @$_;
           $c = $ni::compressors{$c || 'g'};
           defined $level ? sh_op "$c -$level" : sh_op $c},
    pseq popt compressor_name, popt integer;
}

defoperator decode => q{sdecode};

defshort '/z',  compressor_spec;
defshort '/zn', pk sink_null_op();
defshort '/zd', pk decode_op();

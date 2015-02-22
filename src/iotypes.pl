# Bidirectional file IO
defio 'file',
sub {
  my ($read, $write) = @_;

  open my $read_new, $read or die "failed to open $read: $!"
    if !ref $read and defined $read;
  $read_new //= $read;

  open my $write_new, $write or die "failed to open $write: $!"
    if !ref $write and defined $write;
  $write_new //= $write;

  die "must specify at least one end (read, write) of the file"
    unless defined $read_new || defined $write_new;
  [$read_new, $write_new];
},
{
  quoted_into => sub {
    my ($self, $code, $refs) = @_;
    my $fh_gensym = gensym 'fh';
    die "cannot read from file (opened write-only)"
      unless defined($refs->{$fh_gensym} = $self->[0]);
    qq{
      my \$$fh_gensym = \$_[0]->{'$fh_gensym'};
      while (<\$$fh_gensym>) {
        $code
      }
    };
  },

  quoted_from => sub {
    my ($self, $prefix, $refs) = @_;
    my $fh_gensym = gensym 'fh';
    die "cannot write into file (opened read-only)"
      unless defined($refs->{$fh_gensym} = $self->[1]);
    qq{
      my \$$fh_gensym = \$_[0]->{'$fh_gensym'};
      $prefix {
        print \$$fh_gensym \$_;
      }
    };
  },
};

defio 'const',
sub { [@_] },
{
  quoted_into => sub {
    my ($self, $code, $refs) = @_;
    my $gensym = gensym 'const';
    $refs->{$gensym} = $self;
    qq{
      for (\@{\$_[0]->{'$gensym'}}) {
        $code
      }
    };
  },
};

# Sum of multiple IOs
defio 'sum',
sub { [map $_->flatten, @_] },
{
  flatten     => sub { @{$_[0]} },
  quoted_into => sub {
    my ($self, $code, $refs) = @_;
    join "\n;\n", map $_->quoted_into($code, $refs), @$self;
  },
};

# Concatenation of an IO of IOs
defio 'cat',
sub { \$_[0] },
{
  quoted_into => sub {
    my ($self, $code, $refs) = @_;
    my $refs_gensym = gensym 'refs';
    my $code_gensym = gensym 'code';
    $refs->{$refs_gensym} = $refs;
    $refs->{$code_gensym} = $code;

    my $loop = $$self->quoted_into(qq{
      eval \$_->quoted_into(\$$code_gensym, \$$refs_gensym);
      die \$@ if \$@;
    }, $refs);

    qq{
      my \$$refs_gensym = \$_[0]->{'$refs_gensym'};
      my \$$code_gensym = \$_[0]->{'$code_gensym'};
      $loop
    };
  },
};

# Introduces arbitrary indirection into an IO's code stream.
defio 'bind',
sub { +{ base => $_[0], code_transform => $_[1] } },
{
  quoted_into => sub {
    my ($self, $code, $refs) = @_;
    my $transformed = $self->{code_transform}->($code, $refs);
    $self->{base}->quoted_into($transformed, $refs);
  },
};

# Bindings for common transformations
sub flatmap_binding {
  my ($f, @args) = @_;
  my $args_ref = [@args];
  my $args_gensym = gensym 'args';
  my $f_gensym    = gensym 'f';
  sub {
    my ($code, $refs) = @_;
    if (ref $f eq 'CODE' || @args) {
      $refs->{$args_gensym} = $args_ref;
      $refs->{$f_gensym}    = compile $f;
      qq{ for (\$_[0]->{'$f_gensym'}->(\$_, \@{\$_[0]->{'$args_gensym'}})) {
            $code
          } };
    } else {
      qq{ for ($f) {
            $code;
          } };
    }
  };
}

sub mapone_binding {
  my ($f, @args) = @_;
  my $args_ref = [@args];
  my $args_gensym = gensym 'args';
  my $f_gensym    = gensym 'f';
  sub {
    my ($code, $refs) = @_;
    if (ref $f eq 'CODE' || @args) {
      $refs->{$args_gensym} = $args_ref;
      $refs->{$f_gensym}    = compile $f;
      qq{ \$_ = \$_[0]->{'$f_gensym'}->(\$_, \@{\$_[0]->{'$args_gensym'}});
          $code };
    } else {
      qq{ \$_ = $f;
          $code };
    }
  };
}

sub grep_binding {
  my ($f, @args) = @_;
  my $args_ref = [@args];
  my $args_gensym = gensym 'args';
  my $f_gensym    = gensym 'f';
  sub {
    my ($code, $refs) = @_;
    if (ref $f eq 'CODE' || @args) {
      $refs->{$args_gensym} = $args_ref;
      $refs->{$f_gensym}    = compile $f;
      qq{ if (\$_[0]->{'$f_gensym'}->(\$_, \@{\$_[0]->{'$args_gensym'}})) {
            $code
          } };
    } else {
      qq{ if ($f) {
            $code
          } };
    }
  };
}

sub reduce_binding {
  my ($f, $init, @args) = @_;
  my $args_ref = [@args];
  my $args_gensym = gensym 'args';
  my $init_gensym = gensym 'init';
  my $f_gensym    = gensym 'f';
  sub {
    my ($code, $refs) = @_;
    $refs->{$init_gensym} = $init;
    my $out_gensym = gensym 'results';
    if (ref $f eq 'CODE' || @args) {
      $refs->{$args_gensym} = $args_ref;
      $refs->{$f_gensym}    = compile $f;
      qq{ (\$$init_gensym, \@$out_gensym) =
          \$_[0]->{'$f_gensym'}->(\$$init_gensym, \$_,
                                  \@{\$_[0]->{'$args_gensym'}});
          for (\@$out_gensym) {
            $code
          } };
    } else {
      # Replace the custom symbol '%init' with the accumulator so the function
      # has a way to refer to it.
      $f =~ s/%init/\$$init_gensym/g;
      qq{ (\$$init_gensym, \@$out_gensym) = $f;
          for (\@$out_gensym) {
            $code;
          } };
    }
  };
}

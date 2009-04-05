package Test::CPAN::Meta;

use warnings;
use strict;

use vars qw($VERSION);
$VERSION = '0.13';

#----------------------------------------------------------------------------

=head1 NAME

Test::CPAN::Meta - Validation of the META.yml file in a CPAN distribution.

=head1 SYNOPSIS

There are two forms this module can be used.

The first is a standalone test of your distribution's META.yml file:

  use Test::More;
  eval "use Test::CPAN::Meta";
  plan skip_all => "Test::CPAN::Meta required for testing META.yml" if $@;
  meta_yaml_ok();

Note that you may provide an optional label/comment/message/etc to the
function, or one will be created automatically.

The second form allows you to test other META.yml files, or specify a specific
version you wish to test against:

  use Test::More test => 6;
  use Test::CPAN::Meta;

  # specify a file and specification version
  meta_spec_ok('META.yml','1.3',$msg);

  # specify the specification version to validate the local META.yml
  meta_spec_ok(undef,'1.3',$msg);

  # specify a file, where the specification version is deduced
  # from the file itself
  meta_spec_ok('META.yml',undef,$msg);

Note that this form requires you to specify the number of tests you will be
running in your test script. Also note that each 'meta_spec_ok' is actually 2
tests under the hood.

=head1 DESCRIPTION

This module was written to ensure that a META.yml file, provided with a
standard distribution uploaded to CPAN, meets the specifications that are
slowly being introduced to module uploads, via the use of package makers and
installers such as L<ExtUtils::MakeMaker>, L<Module::Build> and
L<Module::Install>.

=head1 ABSTRACT

A test module to validate a CPAN META.yml file.

=cut

#----------------------------------------------------------------------------

#############################################################################
#Library Modules															#
#############################################################################

use Parse::CPAN::Meta;
use Test::Builder;
use Test::CPAN::Meta::Version;

#----------------------------------------------------------------------------

my $Test = Test::Builder->new();

sub import {
    my $self = shift;
    my $caller = caller;
    no strict 'refs';
    *{$caller.'::meta_yaml_ok'}   = \&meta_yaml_ok;
    *{$caller.'::meta_spec_ok'}   = \&meta_spec_ok;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

#############################################################################
#Interface Functions														#
#############################################################################

=head1 FUNCTIONS

=over

=item * meta_yaml_ok([$msg])

Basic META.yml wrapper around meta_spec_ok.

Returns a hash reference to the contents of the parsed META.yml

=cut

sub meta_yaml_ok {
    $Test->plan( tests => 2 );
    return meta_spec_ok(undef,undef,@_);
}

=item * meta_spec_ok($file, $version [,$msg])

Validates the named file against the given specification version. Both $file
and $version can be undefined.

Returns a hash reference to the contents of the given file, after it has been
parsed.

=back

=cut

sub meta_spec_ok {
	my ($file, $vers, $msg) = @_;
    $file ||= 'META.yml';

    unless($msg) {
        $msg = "$file meets the designated specification";
        $msg .= " ($vers)"   if($vers);
    }

    my ($yaml) = eval { Parse::CPAN::Meta::LoadFile($file) };

    if($@) {
        $Test->ok(0,"$file contains valid YAML");
        $Test->ok(0,$msg);
        $Test->diag("  ERR: $@");
        return;
    } else {
        $Test->ok(1,"$file contains valid YAML");
    }

    my %hash;
    $hash{spec} = $vers if($vers);
    $hash{yaml} = $yaml;

    my $spec = Test::CPAN::Meta::Version->new(%hash);
    if(my $result = $spec->parse()) {
        $Test->ok(0,$msg);
        $Test->diag("  ERR: $_") for($spec->errors);
    } else {
        $Test->ok(1,$msg);
    }

    return $yaml;
}

q( Currently Listening To: Joy Division - "Transmission" from 'Heart And Soul');

__END__

#----------------------------------------------------------------------------

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please send an email to barbie@cpan.org or submit a bug to the
RT system (http://rt.cpan.org/Public/Dist/Display.html?Name=Test-YAML-Meta).
However, it would help greatly if you are able to pinpoint problems or even
supply a patch.

Fixes are dependant upon their severity and my availablity. Should a fix not
be forthcoming, please feel free to (politely) remind me.

=head1 SEE ALSO

  Test::YAML::Valid

=head1 DSLIP

  b - Beta testing
  d - Developer
  p - Perl-only
  O - Object oriented
  p - Standard-Perl: user may choose between GPL and Artistic

=head1 AUTHOR

Barbie, <barbie@cpan.org>
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2007,2008 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=cut

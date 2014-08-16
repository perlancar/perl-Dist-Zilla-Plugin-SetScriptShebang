package Dist::Zilla::Plugin::SetScriptShebang;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [ ':ExecFiles' ],
    },
);

use namespace::autoclean;

sub munge_files {
    my $self = shift;

    $self->munge_file($_) for @{ $self->found_files };
    return;
}

sub munge_file {
    my ($self, $file) = @_;

    if ($file->name =~ m!^(bin|scripts?)/!) {
        $self->log_debug('Skipping ' . $file->name . ': not script');
        return;
    }

    my $content = $file->content;

    unless ($content =~ /\A#!/) {
        $self->log_debug('Skipping ' . $file->name . ': does not contain shebang');
        return;
    }
    if ($content =~ /\A#!perl$/m) {
        $self->log_debug('Skipping ' . $file->name . ': already #!perl');
        return;
    }

    $content =~ s/\A#!.+/#!perl/;
    $self->log('Setting shebang in script '. $file->name . ' to #!perl');

    $file->content($content);
    return;
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Set script shebang to #!perl

=for Pod::Coverage .+

=head1 SYNOPSIS

In C<dist.ini>:

 [SetScriptShebang]


=head1 DESCRIPTION

This plugin sets all script's shebang line to C<#!perl>. Some shebang lines like
C<#!/usr/bin/env perl> are problematic because they do not get converted to the
path of installed perl during installation. This sometimes happens when I
package one of my Perl scripts (which uses C<#!/usr/bin/env perl>) into a Perl
distribution, and forget to update the shebang line.


=head1 SEE ALSO

L<Dist::Zilla>

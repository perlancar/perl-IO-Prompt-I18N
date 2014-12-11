package IO::Prompt::I18N;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(prompt confirm);

sub prompt {
    my ($text, $opts) = @_;

    $text //= "Enter value";
    $opts //= {};

    my $answer;

    my $default;
    $default = ${$opts->{var}} if $opts->{var};
    $default = $opts->{default} if defined($opts->{default});

    while (1) {
        # prompt
        print $text;
        print " ($default)" if defined($default);
        print ":" unless $text =~ /[:?]\s*$/;
        print " ";

        # get input
        $answer = <STDIN>;
        if (!defined($answer)) {
            print "\n";
            $answer = "";
        }
        chomp($answer);

        # check+process answer
        if (defined($default)) {
            $answer = $default if !length($answer);
        }
        my $success = 1;
        if ($opts->{required}) {
            $success = 0 if !length($answer);
        }
        if ($opts->{regex}) {
            $success = 0 if $answer !~ /$opts->{regex}/;
        }
        last if $success;
    }
    ${$opts->{var}} = $answer if $opts->{var};
    $answer;
}

sub confirm {
    my ($text, $opts) = @_;

    $text //= "Confirm";
    $opts //= {};

    state $supported_langs = {
        en => {yes_words=>[qw/y yes/], no_words=>[qw/n no/]},
        fr => {yes_words=>[qw/o oui/], no_words=>[qw/n non/]},
        id => {yes_words=>[qw/y ya/] , no_words=>[qw/t tidak/]},
    };

    $opts->{lang} //= do {
        if ($ENV{LANG} && $ENV{LANG} =~ /^([a-z]{2})/ &&
                $supported_langs->{$1}) {
            $1;
        } elsif ($ENV{LANGUAGE} && $ENV{LANGUAGE} =~ /^([a-z]{2})/ &&
                $supported_langs->{$1}) {
            $1;
        } else {
            'en';
        }
    };

    $supported_langs->{$opts->{lang}}
        or die "Unknown language '$opts->{lang}'";
    $opts->{yes_words} //= $supported_langs->{$opts->{lang}}{yes_words};
    $opts->{no_words}  //= $supported_langs->{$opts->{lang}}{no_words};

    my $default;
    if (defined $opts->{default}) {
        if ($opts->{default}) {
            $default = $opts->{yes_words}[0];
        } else {
            $default = $opts->{no_words}[0];
        }
    }

    my $suffix;
    unless ($text =~ /[()?]/) {
        $text .=
            join("",
                 " (",
                 join("/", map {defined($default) && $_ eq $default ?
                                    uc($_) : lc($_)} (
                     @{ $opts->{yes_words} }, @{ $opts->{no_words} })),
                 ")?",
             );
    }

    my $re = join("|", map {quotemeta}
                      (@{$opts->{yes_words}}, @{$opts->{no_words}}));
    $re = qr/\A($re)\z/i;

    my $answer = prompt($text, {
        required => 1,
        regex    => $re,
        default  => $default,
    });
    use experimental 'smartmatch';
    $answer ~~ @{$opts->{yes_words}} ? 1:0;
}

1;
# ABSTRACT: Prompt user question, with some options (including I18N)

=head1 SYNOPSIS

 use IO::Prompt::I18N qw(prompt confirm);
 use Text::LocaleDomain 'My-App';

 my $file = prompt(__"Enter filename");

 if (confirm(__"Really delete filename", {lang=>"id", default=>0})) {
     unlink $file;
 }


=head1 DESCRIPTION

This module provides the C<prompt> function to ask for a value from STDIN. It
features prompt text, default value, validation (using regex),
optional/required. It also provides C<confirm> wrapper to ask yes/no, with
localizable text.


=head1 FUNCTIONS

=head2 prompt($text, \%opts) => val

Display C<$text> and ask value from STDIN. Will re-ask if value is not valid.
Return the chomp-ed value.

Options:

=over

=item * var => \$var

=item * required => bool

If set to true then will require that value is not empty (zero-length).

=item * default => VALUE

Set default value.

=item * regex => REGEX

Validate using regex.

=back


=head2 confirm($text, \%opts) => bool

Display C<$text> (defaults to C<Confirm>) and ask for yes or no. Will return
bool. Basically a convenient wrapper around C<prompt>. Confirmation text is
localizable by providing

Options:

=over

=item * lang => str

Support several languages (C<id>, C<en>, C<fr>). Will preset C<yes_words> and
C<no_words> and adds the choice of words to C<$text>. Will die if language is
not supported. Here are the supported languages:

  lang  yes_words     no_regex
  ----  ---------     --------
  en    y, yes        n, no
  fr    o, oui        n, non
  id    y, ya         t, tidak

=item * yes_words => array

Overrides preset from C<lang>.

=item * no_words => array

Overrides preset from C<lang>.

=item * default => bool

Set default value.

=back


=head1 TODO

Detect language.

Option to stty off (e.g. when prompting password).

Validation using coderef (probably with a C<validation> key which can be regex
or coderef, and then deprecate C<regex>).

Timeout, like L<Prompt::Timeout>.


=head1 SEE ALSO

L<IO::Prompt>, L<IO::Prompt::Tiny>, L<Term::Prompt>, L<Prompt::Timeout>

=cut

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
    $opts->{lang} //= 'en';

    my $suffix;
    if ($opts->{lang} eq 'en') {
        $opts->{yes_regex} //= qr/\A(y|yes)\z/i;
        $opts->{no_regex}  //= qr/\A(n|no)\z/i;
        $suffix = ' (y|yes|n|no)?';
    } elsif ($opts->{lang} eq 'fr') {
        $opts->{yes_regex} //= qr/\A(o|oui)\z/i;
        $opts->{no_regex}  //= qr/\A(n|non)\z/i;
        $suffix = ' (y|yes|n|no)?';
    } elsif ($opts->{lang} eq 'id') {
        $opts->{yes_regex} //= qr/\A(y|ya)\z/i;
        $opts->{no_regex}  //= qr/\A(t|tidak)\z/i;
        $suffix = ' (y|yes|n|no)?';
    } else {
        die "Unknown language '$opts->{lang}'";
    }
    $text .= $suffix unless $text =~ /[()?]/;

    my $answer = prompt($text, {
        required => 1,
        regex    => qr/$opts->{yes_regex}|$opts->{no_regex}/,
        default  => $opts->{default},
    });
    $answer =~ $opts->{yes_regex} ? 1:0;
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

Support several languages (C<id>, C<en>, C<fr>). Will preset C<yes_regex> and
C<no_regex> and adds suffix to C<$text>. Will die if language is not supported.
Here are the supported languages:

  lang  yes_regex             no_regex                 suffix
  ----  ---------             --------                 ------
  id    qr/\A(y|ya)\z/i       qr/\A(t|tidak)\z/i       (y/ya/t/tidak)?
  en    qr/\A(y|yes)\z/i      qr/\A(n|no)\z/i          (y/yes/n/no)?
  fr    qr/\A(o|oui)\z/i      qr/\A(n|non)\z/i         (o/oui/n/non)?

=item * yes_regex => regex (default: qr/\Ay(es)?\z/i)

Overrides C<lang>.

=item * no_regex => regex (default: qr/\An(o)?\z/i)

Overrides C<lang>.

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

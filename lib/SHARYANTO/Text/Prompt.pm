package SHARYANTO::Text::Prompt;

# DATE
# VERSION

use 5.010;
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

    $text //= "Confirm (yes/no)?";
    $opts //= {};

    my $answer = prompt($text, {
        required=>1, regex=>qr/\A(y|yes|n|no)\z/i, default=>$opts->{default}});
    $answer =~ /\A(y|yes)\z/i ? 1:0;
}

1;
# ABSTRACT: Prompt user question

=head1 FUNCTIONS

=head2 prompt($text, \%opts) => val

Display C<$text> and ask value from STDIN. Will re-ask if value is not valid.
Return the chomp-ed value.

Options:

=over 4

=item * var => \$var

=item * required => bool

If set to true then will require that value is not empty (zero-length).

=item * default => VALUE

Set default value.

=item * regex => REGEX

Validate using regex.


=head2 confirm($text, \%opts) => bool

Display C<$text> and ask for yes or no. Will return bool.

Options:

=item * default => bool

Set default value.

=back


=head1 TODO

Option to stty off (e.g. when prompting password).

Localize confirm().


=head1 SEE ALSO

L<SHARYANTO>

=cut

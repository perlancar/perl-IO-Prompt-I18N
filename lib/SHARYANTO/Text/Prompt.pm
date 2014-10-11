package SHARYANTO::Text::Prompt;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(prompt);

sub prompt {
    my ($text, $opts) = @_;
    $opts //= {};
    my $answer;

    my $default;
    if ($opts->{var}) {
    }
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

1;
# ABSTRACT: Prompt user question

=head1 FUNCTIONS

=head2 prompt($text, \%opts)

Options:

=over 4

=item * var => \$var

=item * required => \$var

=item * default => VALUE

=item * regex => REGEX

=back


=head1 SEE ALSO

L<SHARYANTO>

=cut

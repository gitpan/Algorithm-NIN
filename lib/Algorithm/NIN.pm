package Algorithm::NIN;

use strict; use warnings;

=head1 NAME

Algorithm::NIN - A very simple module to validate national insurance number.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

use Carp;
use Readonly;
use Data::Dumper;

Readonly my $TOO_LONG                  => "Given NI number is longer than 9 characters";
Readonly my $INVALID_FIRST_LETTER      => "First letter of NI number can't be D,F,I,Q,U or V";
Readonly my $INVALID_SECOND_LETTER     => "Second letter of NI number can't be D,F,I,O,Q,U or V";
Readonly my $FIRST_TWO_LETTERS_INVALID => "First two lettes of NI number can't be BG,GB,NK,KN,NT or ZZ";
Readonly my $LAST_LETTER_INVALID       => "Last letter of NI number can only be A,B,C,D or a number";
Readonly my $MISSING_NUMBERS           => "NI number should have 6 numbers after the first two alphabets";
Readonly my $INVALID_TEMP_NUMBER       => "Temporary NI number should always start with TN and ends with either M or F";
Readonly my $INVALID_DOB               => "Temporary NI number contains invalid date of birth";

=head1 SYNOPSIS

    use Algorithm::NIN;

    my $ni = "AA123456C";
    my $status = Algorithm::NIN::validate($ni);
    ...

=head1 METHODS

=head2 validate

This method accepts National Insurance number and validate it against the UK format (currently).
For more information please visit http://en.wikipedia.org/wiki/National_Insurance_UK

=cut

sub validate
{
    my $ni = shift;
    return 0 unless defined $ni;
    
    chomp($ni);
    $ni =~ s/\s+//g;
    
    croak(_error($TOO_LONG))                  if (length($ni) > 9);
    croak(_error($INVALID_FIRST_LETTER))      if ($ni =~ m/^(D|F|I|Q|U|V)/i);
    croak(_error($INVALID_SECOND_LETTER))     if ($ni =~ m/^[A-Z](D|F|I|O|Q|U|V)/i);
    croak(_error($FIRST_TWO_LETTERS_INVALID)) if ($ni =~ m/^(BG|GB|NK|KN|NT|ZZ)/i);
    croak(_error($LAST_LETTER_INVALID))       if ($ni =~ m/(E|G-L|N-Z)$/i);
    croak(_error($MISSING_NUMBERS))           if ($ni !~ m/[A-Z][A-Z]\d\d\d\d\d\d/i);
    croak(_error($INVALID_TEMP_NUMBER))       if (($ni =~ m/^TN/i) && ($ni !~ m/[M|F]$/i));

    if (($ni =~ m/^TN/i) && ($ni =~ m/[M|F]$/i))
    {
        $ni =~ /^TN(\d\d)(\d\d)(\d\d)/;
        croak(_error($INVALID_DOB)) if (($1 > 31) || ($2 > 12) || ($3 == 0));
    }
    return 1;
}

=head2 format

This method accepts National Insurance number and returns back in the pair format.
e.g. AA1234546C would become AA 12 34 56 C as it appears on NI card. 

=cut

sub format 
{
    my $ni = shift;
    if (validate($ni))
    {
        my @ni = split(//,$ni);
        (scalar(@ni) == 9)
        ?
        return sprintf("%s%s %d%d %d%d %d%d %s", 
            $ni[0],$ni[1],  $ni[2],$ni[3], $ni[4],$ni[5], $ni[6],$ni[7], $ni[8])
        :
        return sprintf("%s%s %d%d %d%d %d%d", 
            $ni[0],$ni[1],  $ni[2],$ni[3], $ni[4],$ni[5], $ni[6],$ni[7]);
    }
    return;
}

sub _error
{
    my $message = shift;
    return "ERROR: Validation failed [$message].\n";
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-algorithm-nin at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-NIN>.  
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::NIN

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-NIN>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-NIN>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-NIN>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-NIN/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Algorithm::NIN

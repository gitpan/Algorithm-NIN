package Algorithm::NIN;

use strict; use warnings;

=head1 NAME

Algorithm::NIN - Interface to validate National Insurance number (UK) and calculate NI contributions.

=head1 VERSION

Version 1.01

=cut

our $VERSION = '1.01';
our $DEBUG   = 0;

use Carp;
use Readonly;
use Data::Dumper;

Readonly my $TOO_SHORT                 => "NI number can't be shorter than 8 characters";
Readonly my $TOO_LONG                  => "NI number can't be longer than 9 characters";
Readonly my $INVALID_FIRST_LETTER      => "First letter of NI number can't be D,F,I,Q,U or V";
Readonly my $INVALID_SECOND_LETTER     => "Second letter of NI number can't be D,F,I,O,Q,U or V";
Readonly my $FIRST_TWO_LETTERS_INVALID => "First two lettes of NI number can't be BG,GB,NK,KN,NT or ZZ";
Readonly my $LAST_LETTER_INVALID       => "Last letter of NI number can only be A,B,C,D or a number";
Readonly my $MISSING_NUMBERS           => "NI number should have 6 numbers after the first two alphabets";
Readonly my $INVALID_TEMP_NUMBER       => "Temporary NI number should always start with TN and ends with either M or F";
Readonly my $INVALID_DOB               => "Temporary NI number contains invalid date of birth";

Readonly my @VALID_PARAM => qw 
[
    fiscal_year   gross_salary annual_profit
    self_employed married      sex
    class
];

# Class 1   - Employed.
# Class 2/4 - Self-employed.
# Class 3   - Voluntary contributions.
# Rate A    - Applied to any earnings between PRIMARY THRESHOLD and UPPER EARNINGS LIMIT.
# Rate B    - Anything above UPPER EARNINGS LIMIT plus Rate A.

# According to official website [ http://www.hmrc.gov.uk/rates/nic.htm ].
Readonly my $TABLE =>
{
    '2009-10' => 
    {
        'UPPER_EARNINGS_LIMIT_PW'       => 844,
        'PRIMARY_THRESHOLD_PW'          => 110,
        'CLASS_1_RATE_A'                => .11,
        'CLASS_1_RATE_B'                => .01,
        'CLASS_2_FLAT_PW'               => 2.4,
        'CLASS_3_FLAT_PW'               => 12.05,
        'CLASS_4_LOWER_PROFIT_LIMIT_PA' => 5715,
        'CLASS_4_UPPER_PROFIT_LIMIT_PA' => 43875,
        'CLASS_4_RATE_A'                => .08,
        'CLASS_4_RATE_B'                => .01,
        'MARRIED_WOMEN_RATE_A'          => .0485,
        'MARRIED_WOMEN_RATE_B'          => .01,
        'FISCAL_WEEKS'                  => 52,
    },
    '2010-11' => 
    {
        'UPPER_EARNINGS_LIMIT_PW'       => 844,
        'PRIMARY_THRESHOLD_PW'          => 110,
        'CLASS_1_RATE_A'                => .11,
        'CLASS_1_RATE_B'                => .01,
        'CLASS_2_FLAT_PW'               => 2.4,
        'CLASS_3_FLAT_PW'               => 12.05,
        'CLASS_4_LOWER_PROFIT_LIMIT_PA' => 5715,
        'CLASS_4_UPPER_PROFIT_LIMIT_PA' => 43875,
        'CLASS_4_RATE_A'                => .08,
        'CLASS_4_RATE_B'                => .01,
        'MARRIED_WOMEN_RATE_A'          => .0485,
        'MARRIED_WOMEN_RATE_B'          => .01,
        'FISCAL_WEEKS'                  => 52,
    },
    '2011-12' => 
    {
        'UPPER_EARNINGS_LIMIT_PW'       => 817,
        'PRIMARY_THRESHOLD_PW'          => 139,
        'CLASS_1_RATE_A'                => .12,
        'CLASS_1_RATE_B'                => .02,
        'CLASS_2_FLAT_PW'               => 2.5,
        'CLASS_3_FLAT_PW'               => 12.60,
        'CLASS_4_LOWER_PROFIT_LIMIT_PA' => 7225,
        'CLASS_4_UPPER_PROFIT_LIMIT_PA' => 42475,
        'CLASS_4_RATE_A'                => .09,
        'CLASS_4_RATE_B'                => .02,
        'MARRIED_WOMEN_RATE_A'          => .0585,
        'MARRIED_WOMEN_RATE_B'          => .02,
        'FISCAL_WEEKS'                  => 52,
    },
};

=head1 SYNOPSIS

    use Algorithm::NIN;

    my $ni = 'AA123456C';
    my $status = Algorithm::NIN::validate($ni);
    
    or
    
    my $ni = 'AA 12 34 56 C';
    my $status = Algorithm::NIN::validate($ni);

=head1 METHODS

=head2 validate

This method accepts National Insurance number and validate it against the UK format.
For more information please visit http://en.wikipedia.org/wiki/National_Insurance_UK

=cut

sub validate
{
    my $ni = shift;
    return 0 unless defined $ni;
    
    chomp($ni);
    $ni =~ s/\s+//g;
    
    croak(_error($TOO_SHORT))                 if (length($ni) < 8);
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

=head2 calculateNI

Returns NI contributions (approx) according to HMRC website http://www.hmrc.gov.uk/rates/nic.htm
It only covers fiscal year 2009-10, 2010-11 and 2011-2012. I don't claim the number you get back 
is exactly what you see in your pay slip. This is simply my attempt to understand the mathematics 
behind the NI contributions. Any suggestion to improve the functionality is hight appreciated.
This method accepts the following parameter as reference to a hash.


=over 4

=item * fiscal_year

e.g. 2010-11

=item * gross_salary  

e.g. 60000

=item * annual_profit 

e.g. 50000

=item * self_employed 

e.g. 1 or 0

=item * married       

e.g. 1 or 0

=item * sex           

e.g. m or f

=item * class         

e.g. 2 or 4 (only applicable to self-employed); 3 (voluntary contributions).


=back

=head1 TODO

Following NI contributions scenarios are NOT yet covered.

=over 4

=item * Employer's contracted-out rebate, money-purchase schemes

=item * Employer's contracted-out rebate, salary-related schemes

=item * Employee's contracted-out rebate

=item * Special Class 2 rate for share fishermen

=item * Additional primary Class 1 percentage rate on deferred employments

=item * Additional Class 4 percentage rate where deferment has been granted

=back

=cut

sub calculateNI
{
    my $param = shift;
    craok("ERROR: No input provided for NI contribution calculation.\n")
        unless defined $param;

    _validate_param($param);

    if (exists($param->{class}) && ($param->{class} == 3))
    {
        return _format_amount($TABLE->{$param->{fiscal_year}}->{CLASS_3_FLAT_PW});
    }

    my $per_week_gross;
    
    if (defined($param->{gross_salary}))
    {
        $per_week_gross = $param->{gross_salary} / $TABLE->{$param->{fiscal_year}}->{FISCAL_WEEKS};
        print "Gross per week [$per_week_gross]\n" if $DEBUG;
    }

    if (exists($param->{self_employed}) && ($param->{self_employed} == 0))
    {
        if (exists($param->{sex}) && ($param->{sex} =~ /F|f/))
        {
            if (exists($param->{married}) && ($param->{married}))
            {
                return _calculateNI($per_week_gross, 
                                    $param->{fiscal_year}, 
                                    $TABLE->{$param->{fiscal_year}}->{PRIMARY_THRESHOLD_PW},
                                    $TABLE->{$param->{fiscal_year}}->{UPPER_EARNINGS_LIMIT_PW},
                                    $param->{self_employed},
                                    1);
            }
            else
            {
                return _calculateNI($per_week_gross, 
                                    $param->{fiscal_year}, 
                                    $TABLE->{$param->{fiscal_year}}->{PRIMARY_THRESHOLD_PW},
                                    $TABLE->{$param->{fiscal_year}}->{UPPER_EARNINGS_LIMIT_PW},
                                    $param->{self_employed},
                                    0);
            }
        }
        else
        {
            return _calculateNI($per_week_gross, 
                                $param->{fiscal_year}, 
                                $TABLE->{$param->{fiscal_year}}->{PRIMARY_THRESHOLD_PW},
                                $TABLE->{$param->{fiscal_year}}->{UPPER_EARNINGS_LIMIT_PW},
                                $param->{self_employed},
                                0);
        }
    }
    else
    {
        return _format_amount($TABLE->{$param->{fiscal_year}}->{CLASS_2_FLAT_PW})
            if (exists($param->{class}) && ($param->{class} == 2));

        return _calculateNI($param->{annual_profit},
                            $param->{fiscal_year}, 
                            $TABLE->{$param->{fiscal_year}}->{CLASS_4_LOWER_PROFIT_LIMIT_PA},
                            $TABLE->{$param->{fiscal_year}}->{CLASS_4_UPPER_PROFIT_LIMIT_PA},
                            $param->{self_employed},
                            0);
    }
}

sub _calculateNI
{
    my $gross_amount  = shift;
    my $fiscal_year   = shift;
    my $lower_limit   = shift;
    my $upper_limit   = shift;
    my $self_employed = shift;
    my $married_women = shift;

    if (defined($gross_amount) && defined($lower_limit) && ($gross_amount < $lower_limit))
    {
        return 0;
    }
    else
    {
        my ($rate_a, $rate_b);
        $rate_a = $TABLE->{$fiscal_year}->{CLASS_1_RATE_A};
        $rate_a = $TABLE->{$fiscal_year}->{MARRIED_WOMEN_RATE_A}
            if ($married_women);
        $rate_a = $TABLE->{$fiscal_year}->{CLASS_4_RATE_A}
            if $self_employed;
        print "Applying RATE A [$rate_a]\n" if $DEBUG;
        
        if (defined($gross_amount) && defined($upper_limit) && ($gross_amount < $upper_limit))
        {
            return _format_amount((($gross_amount - $lower_limit) * $rate_a));
        }
        else
        {
            $rate_b  = $TABLE->{$fiscal_year}->{CLASS_1_RATE_B};        
            $rate_b = $TABLE->{$fiscal_year}->{MARRIED_WOMEN_RATE_B}
                if ($married_women);
            $rate_b = $TABLE->{$fiscal_year}->{CLASS_4_RATE_B}
                if $self_employed;
            print "Applying RATE B [$rate_b]\n" if $DEBUG;            

            my $level_1 = $upper_limit - $lower_limit;
            my $level_2 = $gross_amount - $upper_limit;
            return _format_amount(($level_1 * $rate_a) + ($level_2 * ($rate_a + $rate_b)));
        }
    }
}

# Checks the param is a reference to a HASH.
# Compare keys of the hash with the list $VALID_PARAM.
# Check if FISCAL YEAR is provided.
# Check if ANNUAL PROFIT is provided when CLASS is set to 4.
# Check if MARITAL STATUS is provided when SEX is set to F/f.
# Check if CLASS is set to either 2, 3 or 4.
# Check if GROSS SALARY is provide when no CLASS found.
# Check if FISCAL YEAR is in the format YYYY-YY.
# Check if GROSS SALARY/ANNUAL PROFIT is real number.
sub _validate_param
{
    my $param = shift;

    print Dumper($param);
    croak("ERROR: Param has to be reference to a HASH.\n")
        unless ref($param) eq 'HASH';
        
    foreach my $key (keys %{$param})
    {
        croak("ERROR: Invalid key [$key] found in the param.\n")
            unless grep(/^$key$/,@VALID_PARAM);
    }
    
    croak("ERROR: Fiscal year key is missing.\n")
        unless defined($param->{fiscal_year});
    croak("ERROR: Annual profit is missing.\n")
        if (defined($param->{class}) && ($param->{class} == 4) && !defined($param->{annual_profit}));
    croak("ERROR: Gross salary is missing.\n")
        if (defined($param->{class}) && ($param->{class} == 1) && !defined($param->{gross_salary}));
    croak("ERROR: Marital status is missing.\n")
        if (defined($param->{sex}) && ($param->{sex} =~ /F|f/i) && !defined($param->{married}));
    croak("ERROR: Invalid class provided.\n")
        if (defined($param->{self_employed}) && ($param->{self_employed} == 0) && 
            defined($param->{class}) && ($param->{class} =~ /2|3|4/));
    croak("ERROR: Missing gross salary.\n")
        if (!defined($param->{class}) && !defined($param->{gross_salary}));
    croak("ERROR: Invalid fiscal year.\n")
        unless defined($TABLE->{$param->{fiscal_year}});
        
    croak("ERROR: Invalid gross salary.\n")
        if (defined($param->{gross_salary}) && ($param->{gross_salary} !~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/));
    croak("ERROR: Invalid annual profit.\n")
        if (defined($param->{annual_profit}) && ($param->{annual_profit} !~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/));
}

sub _format_amount
{
    my $amount = shift;
    return sprintf("%.02f", $amount);
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

=head1 DISCLAIMER

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of Algorithm::NIN
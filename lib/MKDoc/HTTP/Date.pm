=head1 NAME

MKDoc::HTTP::Date - Converts time() to HTTP dates.


=head1 SUMMARY

This class convert time into a HTTP/1.1 RFC 2616 date.

=cut
package MKDoc::HTTP::Date;
use warnings;
use strict;


=head1 API

=head2 $self->process ( [$time] );

Returns a HTTP/1.1 RFC 2616 date for that $time, as given by time().

If $time is omitted, time() is used instead.

=cut
sub process
{
    my $localtime = shift || time;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime ($localtime);
    my @weekday = qw /Sun Mon Tue Wed Thu Fri Sat/;
    my @month   = qw /Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
    $wday = $weekday[$wday];
    $mon  = $month[$mon];
    $year += 1900;
    $mday = '0' . $mday if (length $mday == 1);
    $hour = '0' . $hour if (length $hour == 1);
    $min  = '0' . $min  if (length $min == 1);
    $sec  = '0' . $sec  if (length $sec == 1);
    
    return "$wday, $mday $mon $year $hour:$min:$sec GMT";
}


1;


__END__


=head1 AUTHOR

Copyright 2003 - MKDoc Holdings Ltd.

Author: Jean-Michel Hiver <jhiver@mkdoc.com>

This module is free software and is distributed under the same license as Perl
itself. Use it at your own risk.


=head1 SEE ALSO

  Petal: http://search.cpan.org/author/JHIVER/Petal/
  MKDoc: http://www.mkdoc.com/

Help us open-source MKDoc. Join the mkdoc-modules mailing list:

  mkdoc-modules@lists.webarch.co.uk

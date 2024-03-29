=head1 NAME

MKDoc::HTTP::Response - MKDoc response object.


=head1 SUMMARY

This object defines the response which is sent back to the client.

It is not mandatory to use it, but it is quite nice and convenient.

=cut
package MKDoc::HTTP::Response;
use strict;
use warnings;
our $AUTOLOAD;



=head1 API

=head2 $class->instance();

Returns the MKDoc::HTTP::Response singleton - or creates it if necessary.

=cut
sub instance
{
    my $class = shift;
    $::MKD_Response ||= $class->new();
    return $::MKD_Response;
}



=head2 $class->new();

Instanciates an MKDoc::HTTP::Response object from either a $string
as returned by $self->get(), or @args which is a hash.

    my $response = new MKDoc::HTTP::Response
        Status       => '200 OK',
        Set-Cookie   => 'EvilCookie',
        Content-Type => 'text/plain',
        BODY         => 'Hello, World!';

    my $clone = new MKDoc::HTTP::Response ($response->get());

=cut
sub new
{
    my $class = shift;
    @_ == 1 and return $class->_new_from_string (@_);
    return $class->_new_from_args (@_);
}


sub _new_from_string
{
    my $class = shift;
    my $lines = shift;
    my @lines = split /\n/, $lines;
    my $self  = bless {}, $class;
    while (my $line = shift (@lines))
    {
	chomp ($line);
	chomp ($line);
	last unless ($line);
	
	my ($key, $value) = $line =~ /^(.*?)\:\s*(.*?)\s*$/;
	defined $key || next;
	$self->$key ($value);
    }
    
    $self->Body (join "\n", @lines);
    return $self;
}


sub _new_from_args
{
    my $class = shift;
    my $args  = shift;
    my $self  = bless {}, $class;
    $self->Body (delete $args->{'Body'});
    while (my ($key, $value) = each %{$args})
    {
	$self->$key ($value);
    }
    return $self;
}



=head2 $self->HEAD();

Returns the head of the HTTP query.

=cut
sub HEAD
{
    my $self = shift;

    my @res  = ();
    my $status = $self->Status() || '200 OK';
    push @res, "Status: $status";
    foreach my $key (sort $self->header_keys())
    {
	my $val = $self->{$key};
	my @val = ref $val ? @{$val} : $val;
	next unless ($val);
	foreach (@val)
	{
	    push @res, "$key: $_";
	}
    }
    
    my $res = join "\n", @res;
    $res .= "\n\n";
}


sub header_keys
{
    my $self = shift;
    return map { ($_ !~ /^(?:Status|Body)$/) ? $_ : () } keys %{$self};
}



=head2 $self->GET();

Returns the head plus the body of the HTTP query.

=cut
sub GET
{
    my $self = shift;
    return $self->HEAD() . $self->Body();
}



=head2 $self->Status();

Setter / Getter for the response status code.

$self->Status ("404 Not Found");

=cut
sub Status
{
    my $self = shift;
    $self->{Status} = shift if (@_);
    return $self->{Status} || '200 OK';
}



=head2 $self->Body();

Setter / Getter for the message body.

=cut
sub Body
{
    my $self = shift;
    $self->{Body} = shift if (@_);
    return $self->{Body} || '';
}


sub clear
{
    my $self = shift;
    for (keys %{$self}) { delete $self->{$_} };
}



=head2 $self->Xxx();

Setter / Getter for any other header.

Any other header can be set through the AUTOLOAD method. e.g.

    $self->X_Foo ("Bar");

Will automagically add the header:

    X-Foo: Bar

=cut
sub AUTOLOAD
{
    my $self = shift;
    my ($pkg, $meth) = $AUTOLOAD =~ /(.*)::(.*)/;
    
    if ($meth =~ /^delete_/)
    {
	$meth =~ s/delete_//g;
	$meth =~ s/_/-/g;
	return delete $self->{$meth};
    }
    elsif ($meth =~ /^[A-Z]/)
    {
	$meth =~ s/_/-/g;
	$self->{$meth} = shift if (@_);
	return $self->{$meth};
    }
    else
    {
	use Carp;
	confess qq |Can't locate object method "$meth" via package "$pkg"|;
    }
}



sub DESTROY
{
}



=head2 $self->out();

Outputs the response to STDOUT.

=cut
sub out
{
    my $self = shift;
    my $meth = $ENV{REQUEST_METHOD} || 'GET';
    $meth =~ /HEAD/ ?
        print $self->HEAD :
	print $self->GET;
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

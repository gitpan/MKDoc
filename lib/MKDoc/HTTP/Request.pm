=head1 NAME

MKDoc::HTTP::Request - MKDoc request object.


=head1 SUMMARY

Just like CGI.pm, with a few additions.

See perldoc CGI for the base CGI OO API.

=cut
package MKDoc::HTTP::Request::CompileCGI;
use CGI qw(-compile :all);

package MKDoc::HTTP::Request;
use strict;
use warnings;
use base qw /CGI/;



=head1 API

=head2 $self->instance();

Returns the MKDoc::HTTP::Request singleton - or creates it if necessary.

=cut
sub instance
{
    my $class = shift;
    $::MKD_Request ||= $class->new();
    return $::MKD_Request;
}



=head2 $self->clone();

Clones the current object and returns the copy.

=cut
sub clone
{
    my $self = shift;
    return $self->new();
}


sub self_url
{
    my $self = shift;
    my %opt  = map { "-" . $_ => 1 } @_;
    $opt{relative}  ||= 0;

    # remove the blah:80 like URIs
    my $url  = $self->url (%opt);
    $url =~ s/(.*?\:\/\/(?:.*?\@)?)(.*):80(?!\d)(.*)/$1$2$3/
        if ($url =~ /(.*?\:\/\/(?:.*?\@)?)(.*):80(?!\d)(.*)/);
    
    return $url;
}



=head2 $self->param_eq ($param_name, $param_value);

Returns TRUE if the parameter named $param_name returns
a value of $param_value.

=cut
sub param_eq
{
    my $self  = shift;
    my $param = $self->param (shift());
    my $value = shift;
    return unless (defined $param);
    return unless (defined $value);
    return $param eq $value;
}



=head2 $self->param_equals ($param_name, $param_value);

Alias for param_eq().

=cut
sub param_equals
{
    my $self = shift;
    return $self->param_eq (@_);
}



=head2 $self->path_info_eq ($value);

Returns TRUE if $ENV{PATH_INFO} equals $value,
FALSE otherwise.

=cut
sub path_info_eq
{
    my $self  = shift;
    my $param = $self->path_info();
    my $value = shift;
    return unless (defined $param);
    return unless (defined $value);
    return $param eq $value;
}



=head2 $self->path_info_equals ($param_name, $param_value);

Alias for path_info_eq().

=cut
sub path_info_equals
{
    my $self = shift;
    return $self->path_info_eq (@_);
}



=head2 $self->path_info_starts_with ($value);

Returns TRUE if $ENV{PATH_INFO} starts with $value, FALSE otherwise.

=cut
sub path_info_starts_with
{
    my $self  = shift;
    my $param = $self->path_info();
    my $value = quotemeta (shift);
    return $param =~ /^$value/;
}



=head2 $self->method();

Returns the current request method being used, i.e. normally HEAD, GET or POST.

=cut
sub method
{
    my $self = shift;
    return $ENV{REQUEST_METHOD} || 'GET';
}


# those are horrible hacks that actually got things to work
# with some older versions of CGI.pm, I'll leave them in for now.
# JM 2004-03-02
sub delete
{
    my $self = shift;
    while (@_) { $self->SUPER::delete (shift()) };
}


=head2 $self->is_upload ($param_name);

Returns TRUE if $param_name is an upload, FALSE otherwise.

=cut
sub is_upload
{
    my ($self, $param_name) = @_;
    my @param = grep(ref && fileno($_), $self->SUPER::param ($param_name));
    return unless @param; 
    return wantarray ? @param : $param[0];
}


# WARNING! For some reason, the incoming UTF-8 strings
# are not internally marked up as UTF-8 when they should... 
sub param
{
    my $self = shift;
    return $self->SUPER::param (@_) if ($self->is_upload (@_));
    
    if (wantarray)
    {
	my @res = $self->SUPER::param (@_);
	foreach my $element (@res)
	{
	    if (defined $element)
	    {
		my $tmp = Encode::decode ('UTF-8', $element);
		if (defined $tmp)
		{
		    $element = $tmp;
		}
	    }
	}
	return @res;
    }
    else
    {
	my $res = $self->SUPER::param (@_);
	if (ref $res and ref $res eq 'ARRAY')
	{
	    foreach my $element (@{$res})
	    {
		if (defined $_)
		{
		    my $tmp = Encode::decode ('UTF-8', $element);
		    if (defined $tmp)
		    {
			$element = $tmp;
			Encode::_utf8_on ($element);
		    }
		}
	    }
	}
	else
	{
	    my $tmp = Encode::decode ('UTF-8', $res);
	    if (defined $tmp)
	    {
		$res = $tmp;
		Encode::_utf8_on ($res);
	    }
	}
	
	return $res;
    }
}


##
# $self->url;
# -----------
# There is a bug in apache that makes CGI.pm 2.80 behave
# incorrectly when doing malformed HTTP requests
# this is the subroutine from CGI.pm 2.79
##
sub url {
    my($self,@p) = CGI::self_or_default(@_);
    my ($relative,$absolute,$full,$path_info,$query,$base) =
      CGI::rearrange(['RELATIVE','ABSOLUTE','FULL',['PATH','PATH_INFO'],['QUERY','QUERY_STRING'],'BASE'] ,@p);
    my $url;
    $full++ if $base || !($relative || $absolute);
    
    my $path = $self->path_info;
    my $script_name = $self->script_name;
    
    if ($full) {
        my $protocol = $self->protocol();
        $url = "$protocol://";
        my $vh = CGI::http('host');
        if ($vh) {
            $url .= $vh;
        } else {
            $url .= CGI::server_name();
            my $port = $self->server_port;
            $url .= ":" . $port
                unless (lc($protocol) eq 'http' && $port == 80)
                    || (lc($protocol) eq 'https' && $port == 443);
        }
        return $url if $base;
        $url .= $script_name;
    } elsif ($relative) {
        ($url) = $script_name =~ m!([^/]+)$!;
    } elsif ($absolute) {
        $url = $script_name;
    }
    
    $url .= $path if $path_info and defined $path;
    $url .= "?" . $self->query_string if $query and $self->query_string;
    $url = '' unless defined $url;
    $url =~ s/([^a-zA-Z0-9_.%;&?\/\\:+=~-])/uc sprintf("%%%02x",ord($1))/eg;
    return $url;
}


# redirect() doesn't seem to work with CGI.pm 2.89
# this should fix for this particular version.
sub redirect
{
    my $self = shift;
    my $uri  = shift;
    my $res  = '';
    $res .= "Status: 302 Moved\n";
    $res .= "Location: $uri\n\n";
    return $res;
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

package Niftybin;
use strict;
use warnings;
use Dancer ':syntax';
use Digest::SHA qw/sha1_hex/;
use YAML::XS qw/LoadFile DumpFile/;

set confdir => "/etc/niftyb.in";
set serializer => 'JSON';
set appname => "niftyb.in";
set layout => "main";
set charset => "UTF-8";
set template => "simple";

our $VERSION = '0.1.2';

sub bail
{
	my ($api, $msg, $code) = @_;
	$api and send_error $msg => $code;

	status $code;
	halt template 'error', { msg => $msg };
}

sub filepath
{
	my ($sha1, $api, $mkdir) = @_;
	my @p = ($sha1 =~ m/^([0-9a-f]{4})([0-9a-f]{4})([0-9a-f]{0,32})$/)
		or bail $api, 'bad SHA1 checksum' =>, 400;
	my $root = config->{site}{root}
		or bail $api, 'internal server error' => 500;
	if ($mkdir) {
		mkdir "$root/$p[0]";
		mkdir "$root/$p[0]/$p[1]";
		return "$root/$p[0]/$p[1]/$p[2]";
	}
	error "checking glob for $root/$p[0]/$p[1]/$p[2]*";
	(my @files = glob "$root/$p[0]/$p[1]/$p[2]*") == 1
		or bail $api, 'bad SHA1 checksum' => 400;
	return $files[0];
};

get '/' => sub {
	template 'index';
};

# POST /
# { content: "...",
#   key:     "value" ... }
post '/!' => sub {
	my $meta = params;
	exists $meta->{content}
		or bail 1, 'bad request' => 400;
	length $meta->{content} < config->{site}{max}
		or bail 1, 'request too large' => 413;

	my $sha1 = sha1_hex($meta->{content});
	my $path = filepath($sha1, 1, 1)
		or bail 1, 'server failed' => 500;

	$meta->{sha1}      = $sha1;
	$meta->{posted}    = time;
	$meta->{remote_ip} = request->address;
	$meta->{user}      = request->user;
	$meta->{secure}    = request->secure;
	$meta->{referer}   = request->referer;
	$meta->{ua}        = request->agent;
	DumpFile $path, $meta;
	$sha1 = substr($sha1, 0, 10);
	return { ok => request->base."!$sha1" };
};

del '/!:sha1' => sub {
	my $path = filepath(params->{sha1}, 1)
		or send_error "bad request" => 400;
	unlink $path;
	return { ok => 'removed' }
};

get '/!:sha1' => sub {
	my $path = filepath(params->{sha1}, 0);
	error "got path: $path";
	my $data = LoadFile($path)
		or bail 0, "not found" => 404;
	template 'show', { x => $data };
};

true;

=head1 NAME

Niftybin - A Dancer Application

=head1 DESCRIPTION

An exciting new web app from the guys at NiftyLogic, Inc.

=head1 AUTHOR

Written by James Hunt B<< <james@niftylogic.com> >>

=cut

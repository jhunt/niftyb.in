package Paste::Bin;
use Dancer ':syntax';

our $VERSION = '0.1.0';

get '/' => sub {
    template 'index';
};

true;

=head1 NAME

Paste::Bin - A Dancer Application

=head1 DESCRIPTION

An exciting new web app from the guys at NiftyLogic, Inc.

=head1 AUTHOR

Written by James Hunt B<< <james@niftylogic.com> >>

=cut

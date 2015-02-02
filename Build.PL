use 5.006;
use strict;
use warnings;
use Module::Build;
use File::Find;

my %TREE;
sub tree_files { $TREE{$File::Find::name} = $File::Find::name if -f };

%TREE = (); find(\&tree_files, "views");  my %VIEWS  = %TREE;
%TREE = (); find(\&tree_files, "public"); my %PUBLIC = %TREE;
%TREE = (); find(\&tree_files, "bin");    my %BIN    = %TREE;


my $builder = Module::Build->new(
	module_name         => 'niftybin',
	license             => 'bsd',
	dist_author         => q{James Hunt <james@niftylogic.com>},
	dist_version_from   => 'lib/Niftybin.pm',
	configure_requires => { 'Module::Build' => 0.38 },
	build_requires => {
		'Test::More'   => 0,
	},
	requires => {
		'Dancer'            => 1.3113,
	},
	add_to_cleanup => [
		'niftybin-*',
		'cover_db',
		'*.rpm',
		'*.deb',
	],
	test_files => [
		"t/*.t",
		"t/selenium/*.t",
	],

	share_files  => {'niftybin.psgi' => 'niftybin.psgi'},
	views_files  => \%VIEWS,
	public_files => \%PUBLIC,
	bin_files    => \%BIN,
	install_path => {
		share  => "usr/share/niftybin",
		views  => "usr/share/niftybin/views",
		public => "usr/share/niftybin/public",
		bin    => "usr/bin",
	},
);

$builder->add_build_element('share');
$builder->add_build_element('views');
$builder->add_build_element('public');
$builder->create_build_script();

use 5.006;
use strict;
use warnings;
use Module::Build;
use File::Find;

my $BUILDER = Module::Build->subclass(
	class => 'Module::Build::Paste::Bin',
	code  => <<'LIKEABOSS');

		use File::Find;

		sub process_flair_files
		{
			my ($self) = @_;

			my @flair;
			find(sub { push @flair, $File::Find::name if -f && m/\.flair$/ },
				'public/flair');
			print STDERR "Processing *.flair > paste-bin.css\n";
			if (@flair) {
				qx(rm -f public/css/paste-bin.css; mkdir -p public/css);
				for (sort @flair) {
					print STDERR "[FLAIR] $_\n";
					qx(cat $_ | flair >> public/css/paste-bin.css);
				}
			}
		}
LIKEABOSS

my %TREE;
sub tree_files { $TREE{$File::Find::name} = $File::Find::name if -f };

%TREE = (); find(\&tree_files, "views");  my %VIEWS  = %TREE;
%TREE = (); find(\&tree_files, "public"); my %PUBLIC = %TREE;
%TREE = (); find(\&tree_files, "etc");    my %ETC    = %TREE;
%TREE = (); find(\&tree_files, "sbin");   my %SBIN   = %TREE;
%TREE = (); find(\&tree_files, "bin");    my %BIN    = %TREE;


my $builder = $BUILDER->new(
	module_name         => 'Paste::Bin',
	license             => 'bsd',
	dist_author         => q{James Hunt <james@niftylogic.com>},
	dist_version_from   => 'lib/Paste/Bin.pm',
	configure_requires => { 'Module::Build' => 0.38 },
	build_requires => {
		'Test::More'   => 0,
	},
	requires => {
		'Dancer'            => 1.3113,
	},
	add_to_cleanup => [
		'Paste-Bin-*',
		'cover_db',
		'*.rpm',
		'*.deb',
	],
	test_files => [
		"t/*.t",
		"t/selenium/*.t",
	],

	share_files  => {'paste-bin.psgi' => 'paste-bin.psgi'},
	views_files  => \%VIEWS,
	public_files => \%PUBLIC,
	etc_files    => \%ETC,
	sbin_files   => \%SBIN,
	bin_files    => \%BIN,
	install_path => {
		share  => "usr/share/paste-bin",
		views  => "usr/share/paste-bin/views",
		public => "usr/share/paste-bin/public",
		etc    => "etc",
		sbin   => "usr/sbin",
		bin    => "usr/bin",
	},
);

$builder->add_build_element('share');
$builder->add_build_element('views');
$builder->add_build_element('public');
$builder->add_build_element('etc');
$builder->add_build_element('sbin');
$builder->add_build_element('flair');
$builder->create_build_script();

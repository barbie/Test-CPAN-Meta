use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'			=> 'Test::CPAN::Meta',
    'VERSION_FROM'	=> 'lib/Test/CPAN/Meta.pm',
    'PREREQ_PM'		=> {
		Parse::CPAN::Meta	=> 0.02,
		Test::Builder       => 0,
		Test::More	        => 0.70,	# for testing
	},
	NO_META			=> 1,

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT	=> 'CPAN META.yml testing module',
       AUTHOR	=> 'Barbie <barbie@cpan.org>') : ()),
);

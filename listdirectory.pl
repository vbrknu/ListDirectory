use strict;
use warnings;
use feature 'say';
use autodie;
use JSON::XS;
use Data::Dump;

my %dir_cmd = (
	bare			=> "dir /B",
	infodir 		=> "dir",
	alldirname 		=> "dir /b",
	allfiles 		=> "dir /s /B",
	freadonly	 	=> "dir /A:R",
	hfiles			=> "dir /A:H",
	afiles			=> "dir /A:A",
	sysfiles		=> "dir /A:S",
	onlyfiles		=> "dir /A:-D /B /S",
	noreadonly		=> "dir /A:-R",
	nohidden		=> "dir /A:-H",
	noarchive		=> "dir /A:-A",
	nosys			=> "dir /A:-S",
	infodirown		=> "dir /Q",
	createdinfodir	=> "dir /TC",
	lastaccinfodir	=> "dir /TA",
	lastmodinfodir	=> "dir /TW",
);

my %dispatch_cmd = (
	bare			=> \&bare,
	infodir 		=> \&infodir ,
	alldirname		=> \&alldirname ,
	allfiles		=> \&allfiles,
	freadonly		=> \&freadonly,
	hfiles			=> \&hfiles,
	afiles 			=> \&afiles,
	sysfiles		=> \&sysfiles,
	onlyfiles		=> \&onlyfiles,
	noreadonly		=> \&noreadonly,
	nohidden		=> \&nohidden,
	noarchive		=> \&noarchive,
	nosys 			=> \&nosys,
	infodirown		=> \&infodirown,
	createdinfodir  => \&createdinfodir,
	lastaccinfodir  => \&lastaccinfodir,
	lastmodinfodir  => \&lastmodinfodir,
	DEFAULT => sub { say "The command you entered is not valid";}
	);


sub bare {
	my $path = shift;
	my @output = `$dir_cmd{bare} $path`;
	return \@output;
}

sub infodir {
	my $path = shift;
	my @output = `$dir_cmd{infodir} $path`;
	return \@output;
}

sub alldirname {
	my $path = shift;
	my @output = `$dir_cmd{alldirname} $path`;
	return \@output;
}

sub allfiles {
	my $path = shift;
	my @output = `$dir_cmd{allfiles} $path`;
	return \@output;
}

sub freadonly {
	my $path = shift;
	my @output = `$dir_cmd{freadonly} $path`;
	return \@output;
}

sub hfiles {
	my $path = shift;
	my @output = `$dir_cmd{hfiles} $path`;
	return \@output;
}

sub afiles {
	my $path = shift;
	my @output = `$dir_cmd{afiles} $path`;
	return \@output;
}

sub sysfiles {
	my $path = shift;
	my @output = `$dir_cmd{sysfiles} $path`;
	return \@output;
}

sub onlyfiles{
	my $path = shift;
	my @output = `$dir_cmd{onlyfiles} $path`;
	return \@output;
}

sub noreadonly {
	my $path = shift;
	my @output = `$dir_cmd{noreadonly} $path`;
	return \@output;
}

sub nohidden {
	my $path = shift;
	my @output = `$dir_cmd{nohidden} $path`;
	return \@output;
}

sub noarchive {
	my $path = shift;
	my @output = `$dir_cmd{noarchive} $path`;
	return \@output;
}

sub nosys {
	my $path = shift;
	my @output = `$dir_cmd{nosys} $path`;
	return \@output;
}

sub infodirown {
	my $path = shift;
	my @output = `$dir_cmd{infodirown} $path`;
	return \@output;
}

sub createdinfodir {
	my $path = shift;
	my @output = `$dir_cmd{createdinfodir} $path`;
	return \@output;
}

sub lastaccinfodir {
	my $path = shift;
	my @output = `$dir_cmd{lastaccinfodir} $path`;
	return \@output;
}

sub lastmodinfodir {
	my $path = shift;
	my @output = `$dir_cmd{lastmodinfodir} $path`;
	return \@output;
}

sub win_cmd {
	my $dirpath = shift;
	my $cmd 	= shift;
	my $func = $dispatch_cmd{$cmd} || $dispatch_cmd{DEFAULT};
	my $output = $func->($dirpath);

	return $output;	
}

sub dirlist_to_json {
	my $data = shift;
	my $path = shift;
	my $root = dirname_from_path($path);
	
	foreach (@$data){
		$_ =~ s/$root->{excess}//;
	}
	
	my $json = {};
	foreach my $filename (@$data){
		$filename =~ quotemeta $filename;
		my $ref = $json;
		$ref = $ref->{$_} //= {} for split /\\/ => $filename;
	}

	my $tree = {name => $root->{root}, children => [jsonize_tree($json)] };
	my $json_tree = encode_json $tree;
	say $json_tree;
}

sub jsonize_tree {
    my $tree        = shift;
    my @children    = ();
    while (my ($name, $children) = each %$tree) {
        push @children, {
            name => $name,
            children => [ jsonize_tree($children) ],
        }
    }
    return @children;
}


sub dirname_from_path {
	my $path = shift;
	my @names = split m{\\}, $path;
	my %root;
	foreach my $i (0 .. $#names-1){
		$root{excess} .= $names[$i].'\\\\';
	}
	$root{excess} .= $names[$#names].'\\\\';
	$root{root} = $names[$#names]; 
	return \%root;
}

sub command_list {
	my $heredoc = <<END;
	bare			: all files in plain format
	infodir 		: only directories with their information
	alldirname 		: all subfolders, only names
	allfiles 		: all files in the current folder and the ones in the subfolders
	freadonly	 	: only read-only files
	hfiles			: only hidden files
	afiles			: only files that have attribute set
	sysfiles		: only system files
	onlyfiles		: only files in the current directory
	noreadonly		: all but read-only files
	nohidden		: all but hidden files
	noarchive		: all but archive setted files
	nosys			: all but system files
	infodirown		: owner of dir
	createdinfodir		: when was created
	lastaccinfodir		: when was it last accessed
	lastmodinfodir		: when was it last modified

END
	say $heredoc;
}

my $num_args = $#ARGV + 1;
if ($num_args == 2){
	my $path = $ARGV[0];
	my $cmd = $ARGV[1];
	my $data = win_cmd($path, $cmd);
	dirlist_to_json($data, $path);	
} elsif ($ARGV[0] eq '?') { 
	command_list(); 
} else {
	say "Incorrect nr of arguments. Run with ? for a list of the commands. Usage is: path command";
	exit();
}


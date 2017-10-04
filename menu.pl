#!/usr/bin/perl

# Program:		Menu
# Author: 		Adrian Caymo
# Description:	A menu-driven interface that offers the user list of various functions.

#use strict;
#use warnings;
#use diagnostics;
use HTML::TreeBuilder;
use Win32::Console;
use feature 'say';

# clear screen and display menu
my $out = Win32::Console->new(STD_OUTPUT_HANDLE);
$out->Cls;
menu();

sub menu {
	while (1) {
		printf "\n%25s\n", "MENU";
		printf "%25s\n\n", "----";
		printf "%35s\n", "E - Extract and process string";
		printf "%41s\n", "P - Perform a mathematical operation";
		printf "%28s\n", "S - Sort a list of data";
		printf "%60s\n", "D - Given a sample of HTML file, find the innermost DIV";
		printf "%79s\n", "R - Read a directory of files and display the files in the given directory";
		printf "%74s\n", "F - Find a subpattern among all lines of files in a directory entered";
		printf "%54s\n", "L - Determine if the input string is a palindrome";
		printf "%13s\n", "Q - Quit";
		print "\nOption: ";

		chomp(my $option = uc <STDIN>);

		if ($option eq "E") {
			extract_process_string();
		}
		elsif ($option eq "P") {
			perform_math();
		}
		elsif ($option eq "S") {
			sort_data();
		}
		elsif ($option eq "D") {
			find_innermost_div();
		}
		elsif ($option eq "R") {
			read_directory();
		}
		elsif ($option eq "F") {
			find_subpattern();
		}
		elsif ($option eq "L") {
			palindrome();
		}
		elsif ($option eq "Q") {
			$out->Cls;
			exit 0;
		}
		else {
			# stub
		}
	} # end while
}

sub extract_process_string {
	my $string = "";
	print "\nEnter a string (Type -1 to return to main menu): ";
	chomp($string = uc <STDIN>);
	
	while (1) {
		if ($string eq "-1") {
			$out->Cls;
			menu();
		} # end if
		else {
			$string = trim($string); # removes white space before and after string
			my $string_length = length($string); 
			print "\nThe length of the string is $string_length.\n";
			
			print "\nEnter a string (Type -1 to return to main menu): ";
			chomp($string = uc <STDIN>);
		} # end else
	} # end while
}

sub perform_math {	
	my $exp;
	print "\nEnter a mathematical expression (Type QUIT to return to main menu): ";	
	chomp($exp = <>);

	while (1) {
		if (uc $exp eq "QUIT") {
			$out->Cls;
			menu();
		} # end if

		if (defined($exp)) {
			my $result = eval $exp;

			if ($@) {
				print "\nInvalid mathematical expression: $exp\n"; 
			} # end if
			else {
				print "\n$exp = $result\n";
			} # end else

			print "\nEnter a mathematical expression (Type QUIT to return to main menu): ";	
			chomp($exp = <>);
		} # end if
	} # end while
}

sub sort_data {
	print "\nEnter data to be sorted (Type QUIT to return to main menu): ";
	my @array = split(/\s+/, <>);

	while (1) {
		if (uc $array[0] eq "QUIT") {
			$out->Cls;
			menu();			
		} # end if
		else {
			@array = sort {$a cmp $b} @array;
			print "\nSorted data: @array\n";

			print "\nEnter data to be sorted (Type QUIT to return to main menu): ";
			@array = split(/\s+/, <>);
		} # end else
	} # end while
}

sub find_innermost_div {
	print "\nEnter path to an HTML file to find its innermost DIV (Type QUIT to return to main menu): ";
	chomp(my $html_file = <STDIN>);

	while (1) {
		if (uc $html_file eq "QUIT") {
			$out->Cls;
			menu();
		} # end if
		else {
			my $tree = HTML::TreeBuilder->new;
			$tree->parse_file($html_file);
			my @array = ();

			foreach my $e ($tree->look_down(_tag => 'div')) {
				 push @array, $e;
			} # end foreach
			
			if (!defined($array[$#array])) {
				print "\nInvalid path.\n";				
				find_innermost_div();
			} # end if
			else {
				print "\nInnermost DIV: " . $array[$#array]->as_HTML . "\n";
			}
			$tree->delete;

			print "\nEnter path to an HTML file to find its innermost DIV (Type QUIT to return to main menu): ";
			chomp($html_file = <STDIN>);
		} # end else
	} # end while
}

sub read_directory {
	my $directory = "";
	print "\nEnter a directory to display its files (Type QUIT to return to main menu): ";
	chomp ($directory = <STDIN>);

	while (1) {
		if (uc $directory eq "QUIT") {
			$out->Cls;
			menu();
		} # end if
		else {
			print "\n";

			# read directories into an array
			if (opendir my $DH, $directory) {
				my @files = readdir $DH;

				foreach my $file (@files) {
				    if ($file eq '.' or $file eq '..') {
				        next;
				    } # end if
				    say $file;
				} # end foreach
				closedir $DH;

				print "\nEnter a directory to display its files (Type QUIT to return to main menu): ";
				chomp ($directory = <STDIN>);
			} # end if
			else {
				print "Invalid path.\n";
				read_directory();
			} # end else
		} # end else
	} # end while
}

sub find_subpattern {
	my $directory = "";
	print "\nEnter a path to a directory to read (Type QUIT to return to main menu): ";
	chomp ($directory = <STDIN>);

	while (1) {
		if (uc $directory eq "QUIT") {
			$out->Cls;
			menu();			
		} # end if
		else {
			# read directories into an array
			if (opendir(my $DH, $directory)) {
				my @files = readdir $DH;

				print "\nAll files in $directory has been loaded into an array...\n\n";
				my $file = "";
				#my @file_array = ();
				foreach $file (@files) {
				    if ($file eq '.' or $file eq '..') {
				        next;
				    } # endif
				    say $file;
				} # end foreach

				closedir $DH;
				print "\n";

				print "Please enter a pattern to search for in all files: ";
				chomp(my $pattern = <STDIN>);

				foreach my $ind_file (@files) {
					my $counter = 0;

				    if ($ind_file eq '.' or $ind_file eq '..') {
				        next;
				    } # end  if

				    $ind_file = $directory . '\\' . $ind_file;
					open my $fh, '<', $ind_file or die "Could not open $ind_file $!\n";
						
					while (my $line = <$fh>) {
						chomp $line;
						$line = trim($line);

						$counter++;

						if ($line =~ /$pattern/) {
							say $ind_file . " " . $counter . ": " . $line;
						} # end if
					} # end while
				} # end foreach

				print "\nEnter a path to a directory to read (Type QUIT to return to main menu): ";
				chomp ($directory = <STDIN>);
			} # end if
			else {
				print "\nInvalid path.\n";
				find_subpattern();
			} # end else
		} # end else
	} # end while
}

sub palindrome {
	my $word = "";
	print "\nEnter a string (Type -1 to return to main menu): ";
	chomp($word = <STDIN>);

	while (1) {
		if ($word eq "-1") {
			$out->Cls;
			menu();			
		} # end if
		else {
			my $maybe_palindrome = undef;
			my $word_length = length($word);

			for (my $i = $word_length; $i >= 0; $i--) {
				$maybe_palindrome = $maybe_palindrome.substr($word, $i, 1);
			} # end for
			
			if ($word eq $maybe_palindrome) {
				print "\n$word is a palindrome.\n";
			} # end if
			else {
				print "\n$word is not a palindrome.\n";
			}

			print "\nEnter a string (Type -1 to return to main menu): ";
			chomp( $word = <STDIN> );
		} # end else
	} # end while
}

# helper sub for extract_process_string sub
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

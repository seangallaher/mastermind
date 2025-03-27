#!/usr/bin/perl
#
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

# This is a PERL verion of the board game
# mastermind.
# author: Sean Gallaher
# version: v1.0
# date: 14-MAR-2016
# file: mastermind.pl
#

# generate code

my @colorTable = ("r","b","g","y","p","w");
my @code;

for (my $i = 0; $i < 4; $i++) {
	my $num = int(rand(5));
	my $col = $colorTable[$num];
	push (@code , $col);
}

my $answer = join ('',@code);

# Introduction

print "\nWelcome to Mastermind.\n\nI have chosen four pegs of\nthe following colors:\n";
print RED "   r = red\n", RESET;
print BLUE "   b = blue\n",RESET;
print GREEN "   g = green \n",RESET;
print YELLOW "   y = yellow\n",RESET;
print MAGENTA "   p = purple\n", RESET;
print WHITE "   w = white\n", RESET;
print "\nEnter your first guess and press return.\n";

# for debugging

#print "Shhhh...the answer is $answer\n";

my $help = "\n\nMastermind is a game of logic.\n\nYour opponent (the computer) has placed\nfour colored pegs in a certain order,\nand you have 10 guesses to figure out the colors\nof the pegs and the order in which they are arranged.\n\nWith each guess, your opponent will\ntell you how many are exactly right (both color and position)\nand how many colors are right, but in the wrong position.\n\nYou can read more about the game here:\nhttps://en.wikipedia.org/wiki/Mastermind_(board_game)\n\nStill confused? Try entering four letters from \nthe following set [rbgypw]...\n\n";


my @ordinals = ("spacer","first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth and final");

# the player gets 10 guesses
my $guessHeader = "Guess\tGuess\tRight Color\tRight Color\nNumber\t\t +Position\t   Only\n____________________________________________";
my %allGuesses;
$allGuesses{0} =  $guessHeader;

for (my $j = 1 ; $j <= 10 ; $j++) {
	my $remaining = 10 - $j;
	my $guess = <STDIN>;
	chomp $guess;
	if ($guess eq "quit") {
		print "The answer was ";
		&colorize($answer);
		die "\nThanks for playing!\n";
	}
	elsif ( $guess eq "help" ) {
		print STDOUT "$help";
		$j--;
		next;
	}	
	elsif ( $guess !~ m/^[rbgypwRBGYPW]{4}$/ ) {
		&badInput;
		$j--;
		next;
	}
	else {
		$guess =~ tr/RBGYPW/rbgypw/;
		my $results = &checkGuess( $answer , $guess );
		my @resultArray = @{$results};
		$allGuesses{$j}{'guess'} = $guess;
		$allGuesses{$j}{'col+pos'} = shift @resultArray;
		$allGuesses{$j}{'col'} = shift @resultArray;
	#	my $currentGuess = "  $j\t $guess\t     $correct\t\t     $rightColor";
	#	push (@allGuesses, $currentGuess);
	#	my $board = join ("\n",@allGuesses);
		if ($guess eq $answer) {
			if ($j == 1) {
				print STDOUT "\n";
				&printBoard;
				die "\nYou got it on the first try!\nDid you cheat?\n\n";
			}
			else {
				print STDOUT "\n";
				&printBoard;
				die "\n\nYou win!!!\nYou got it in $j tries\n\n";
			}
		}
		elsif ($j == 9) {
			print "\nYour $ordinals[$j] guess is ";
			&colorize($guess);
			print STDOUT "\n\n";
			&printBoard;
			print STDOUT "\n\nThis is your last chance...\n";	
		}
		elsif ($j == 10) {
			print STDOUT "\n";
			&printBoard;
			print STDOUT "\n\nSorry, the answer was ";
			&colorize($answer);
			die "\nBetter luck next time.\n\n";
		}
		else {
			print STDOUT "\nYour $ordinals[$j] guess is ";
			&colorize($guess);
			print STDOUT "\n\n";
			&printBoard;
			print STDOUT "\n\nYou have $remaining tries left\nPlease try again...\n\n";
		}
	}
}

###################
### subroutines ###
###################

sub checkGuess {
	# this takes the answer and guess as inputs
	# and returns the number of correct and
	# correct colors as output
	my $answer = shift @_;
	my $guess = shift @_;
	my $correct = 0;
	my $rightColor = 0;
	my @answerArray = split (//,$answer);
	my @guessArray = split (//, $guess);
	my %missedColors;
	my @wrongPosition;
	for (my $k = 0 ; $k < 4 ; $k++) {
		if ($answerArray[$k] eq $guessArray[$k]) {
			$correct++;
		}
		else {
			$missedColors{$answerArray[$k]}++;
			push (@wrongPosition, $guessArray[$k]);
		}
	}
	foreach my $wrong (@wrongPosition) {
		if (defined $missedColors{$wrong}) {
			if ($missedColors{$wrong} > 0) {
				$missedColors{$wrong}--;
				$rightColor++;
			}
		}
	}
	my @result = ($correct , $rightColor);
	return \@result;
}

sub badInput {
	print  "That is not a valid guess. \nPlease enter your guess in the \nform of four letters as follows:\n", RED, "   r = red\n", BLUE, "   b = blue \n" , GREEN, "   g = green \n" , YELLOW,"   y = yellow\n", MAGENTA,"   p = purple\n",WHITE,"   w = white\n",RESET," and press <return>\nType \"quit\" to exit\nType \"help\" for more help\n\nTry again\n\n";
}

sub colorize {
	my $code = shift @_;
	my @pegs = split (//,$code);
	foreach my $peg (@pegs) {
		if ($peg eq 'r') {
			print RED, "r", RESET;
		}
		elsif ($peg eq 'b') {
			print BLUE, "b", RESET;
		}
		elsif ($peg eq 'g') {
			print GREEN, "g", RESET;
		}
		elsif ($peg eq 'y') {
			print YELLOW, "y", RESET;
		}
		elsif ($peg eq 'p') {
			print MAGENTA, "p", RESET;
		}
		elsif ($peg eq 'w') {
			print WHITE, "w", RESET;
		}
	}

}

sub printBoard {
	foreach my $num (sort keys %allGuesses) {
		if ($num == 0) {
			print STDOUT "$allGuesses{$num}\n";
		}
		else {
			print STDOUT "  $num\t ";
			my $guess = $allGuesses{$num}{'guess'};
			&colorize($guess);
			print STDOUT "\t     $allGuesses{$num}{'col+pos'}\t\t     $allGuesses{$num}{'col'}\n";
		}
	}
}

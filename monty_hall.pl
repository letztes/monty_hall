#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

=pod

Parameters

=cut

# How many doors
# must be at least 3
my $TUPLET_SIZE = 3;

# How many rounds to play
my $ITERATIONS = 1000;

# constant vs. changing
my $USER_CHOICE = 'changing';




# What is being measured. The whole point of the script
# DO NOT CHANGE THIS VALUE
my $AMOUNT_OF_CORRECT_GUESSES = 0;

=pod

Compile a set of void doors and place the prize behind a random one

=cut

sub get_randomized_tuplet {
	my $tuplet_size = shift;
	
	# hash with each field having the value 0
	# e.g. door1 => 0
	my %randomized_tuplet = map { 'door'.$_ => 0 } 1..$tuplet_size;
	
	# +1 because rand spans from 0 to slightly below upper limit
	# but desired is a range from 1 to actual upper limit
	my $index_of_prize = int(rand($tuplet_size))+1;
	
	$randomized_tuplet{'door'.$index_of_prize} = 1;
	
	return({
		'randomized_tuplet_href' => \%randomized_tuplet,
		});
}

=pod
unselected is important for monty hall problem
must not be random or else the argument of probability increase fails
=cut

sub eliminate_an_unselected_void {
	my $arguments = shift;
	my $selected_door = $arguments->{'selected_door'};
	my $randomized_tuplet_href = $arguments->{'randomized_tuplet_href'};
	
	# get a list of doors that have not a prize behind them, e.g. 0
	my @void_doors = grep {$randomized_tuplet_href->{$_} == 0} keys %{$randomized_tuplet_href};
	
	# in case one of the voids was selected by user
	my @unselected_void_doors = grep {$_ ne $selected_door} @void_doors;
	
	# now the actual eliminating of the one unselected void door
	delete $randomized_tuplet_href->{$unselected_void_doors[0]};
	
	return $randomized_tuplet_href;
}



sub main {
	for (1..$ITERATIONS) {
		print "\nnext iteration\n\n";
		my $randomized_tuplet_result_href = get_randomized_tuplet($TUPLET_SIZE);
		my $randomized_tuplet_href = $randomized_tuplet_result_href->{'randomized_tuplet_href'};
		print Dumper($randomized_tuplet_href);
	
	
	
		# User always starts with guessing door1
		my $selected_door = 'door1';
		
		# must abort if only one element remains
		# either because all voids were opened
		# or worse
		while (scalar keys %{$randomized_tuplet_href} > 2) {
			$randomized_tuplet_href = eliminate_an_unselected_void({
				'selected_door' => $selected_door,
				'randomized_tuplet_href' => $randomized_tuplet_href,	
			});
			
			print Dumper($randomized_tuplet_href);
			
			# User selects one random remaining door if configured so
			# otherwise sticks with door1
			if ($USER_CHOICE eq 'changing') {
				# grep ne $selected_door is important because
				# the user choice is a changing one
				my @remaining_doors = grep {$_ ne $selected_door} keys %{$randomized_tuplet_href};
				my $random_index_of_remaining_list = int(rand(scalar @remaining_doors));
				$selected_door = $remaining_doors[$random_index_of_remaining_list];
			}
			print "User selected $selected_door\n";
		}
		
		# Only two doors remain, check if user selected the correct one
		if ($randomized_tuplet_href->{$selected_door} == 1) {
			$AMOUNT_OF_CORRECT_GUESSES++;
		}	
	}
	
	return;
}

&main();

print "ITERATIONS: $ITERATIONS\n";
print "AMOUNT_OF_CORRECT_GUESSES: $AMOUNT_OF_CORRECT_GUESSES\n";

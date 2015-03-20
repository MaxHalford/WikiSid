#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;

# On récupère les données du formulaire de la page HTML
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}

print keys %formulaire;

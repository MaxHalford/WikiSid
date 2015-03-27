#!/opt/lampp/bin/perl -w

use strict;
use JSON;
use Encode;

# On récupère les paramètres fournis par l'utilisateur
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
# On met des valeurs par défaut si l'utilisateur ne les a pas précisé
if ($formulaire{'documents'} eq '') {
	$formulaire{'documents'} = 30;
}
if ($formulaire{'lemmes'} eq '') {
	$formulaire{'lemmes'} = 50;
}
if ($formulaire{'methode'} eq '') {
	$formulaire{'methode'} = 'TFIDF';
}
# On va stocker les données sous format JSON
my $json = encode_json \%formulaire;
open my $parametres, '>', 'parametres.json' or die $!;
print {$parametres} Encode::decode('utf8', $json);
print "content-type : text/html\n\n <!DOCTYPE html>
<html>
<form name='myform' action='./parametres.pl' method='post'></form>
<script type='text/javascript'>document.myform.submit();</script>
</html>";

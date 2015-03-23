#!/opt/lampp/bin/perl -w

use strict;

# On récupère les paramètres fournis par l'utilisateur
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
my $documents = $formulaire{'documents'};
if ($documents eq '') {
	$documents = 30;
}
my $lemmes = $formulaire{'lemmes'};
if ($documents eq '') {
	$documents = 100;
}
my $methode = $formulaire{'methode'};
if ($documents eq '') {
	$documents = 'TFIDF';
}
# On ouvre le fichier qui contient les paramètres du site web
open my $parametres, '>', 'parametres' or die $!;
# On y met les nouveaux paramètres
print {$parametres} "documents : $documents \n";
print {$parametres} "lemmes : $lemmes \n";
print {$parametres} "methode : $methode";

print "content-type : text/html\n\n <!DOCTYPE html>
<html>
<form name='myform' action='./parametres.pl' method='post'></form>
<script type='text/javascript'>document.myform.submit();</script>
</html>";

#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;

# On se connecte à la base de données
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On récupère les indexs
my $direct = $db -> get_collection('Index direct');

# On récupère les paramètres fournis par l'utilisateur
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
my $document = $formulaire['document'};
my $requete = $formulaire{'requete'};
my $note = $formulaire{'rating'};
if ($note eq '') {
	$direct -> update({'_id' => $document}, {'_id.$.notes' => $note});
}

print "content-type : text/html\n\n <!DOCTYPE html>
<html>
<form name='myform' action='./requete.pl?requete=$requete' method='post'></form>
<script type='text/javascript'>document.myform.submit();</script>
</html>";

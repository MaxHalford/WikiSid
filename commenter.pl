#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;
use Encode;

# On se connecte à la base de données
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On récupère l'index direct
my $direct = $db -> get_collection('Index direct');

# On récupère les paramètres fournis par l'utilisateur
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
my $document = $formulaire{'document'};
my $requete = $formulaire{'requete'};
my $commentaire = $formulaire{'commentaire'};

# On note si l'utilisateur en choisit une
if ($commentaire=~ /.+/) {
	my $idDoc = decode('UTF-8', $document);
	$direct -> update({'_id' => qr/$idDoc/}, {'$push' => {'commentaires' => $commentaire}});
}

print"
content-type : text/html\n\n <!DOCTYPE html>
<html>
<form name='myform' action='./requete.pl?requete=$requete' method='post'></form>
<script type='text/javascript'>
	document.myform.submit();
</script>
</html>";

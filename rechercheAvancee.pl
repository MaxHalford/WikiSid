#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;

# On se connecte à la base de données 
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On se connecte à l'index direct
my $direct = $db -> get_collection('Index direct');
# On fait en sorte que MongoDB renvoit des caractères UTF-8 décodés
$MongoDB::BSON::utf8_flag_on = 0;

# Header
open(HEADER, '<', 'html/header');
# Onglets de navigation
open(NAVIGATION, '<', 'html/navigation');
# Barre de recherche
open(RECHERCHE, '<', 'html/recherche');
# Affichage
print "content-type : text/html\n\n <!DOCTYPE html>";
print <HEADER>;
print"Recherche avancée";
print <NAVIGATION>;
# On récupère toutes les catégories qui existent
my @categories = ();
# On fait une requête sur tous les documents
my $curseur = $db -> run_command(['distinct' => 'Index direct', 'key' => 'categories']);
my %categories = %$curseur;
foreach my $categorie (@{$categories{'values'}}) {
	push(@categories, "'$categorie'");
}

# Jours
my @jours = (1..31);
print "<datalist id='jours'>";
foreach my $jour (@jours) {
	print "<option value=$jour>";
}
print "</datalist>";
# Mois
my @mois = ('janvier', 'février', 'mars', 'avril', 'mai', 'juin',
'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre');
print "<datalist id='mois'>";
foreach my $mois (@mois) {
	print "<option value=$mois>";
}
print "</datalist>";
# Années
my @annees = ('2015');
print "<datalist id='annees'>";
foreach my $annee (@annees) {
	print "<option value=$annee>";
}
print "</datalist>";
# Catégories
print "<datalist id='categories'>";
foreach my $categorie (@categories) {
	print "<option value=$categorie>";
}
print"
</datalist>
<form align='center' class='form-inline well well-lg' action='./requeteAvancee.pl' method='get'>
	<div class='form-group'>
		<label class='sr-only' for='text'>Saisie</label>
		<input list='jours' size='8' name=jour id='text' type='text' class='form-control' placeholder='Jour'>
		<input list='mois' size='8' name=mois id='text' type='text' class='form-control' placeholder='Mois'>
		<input list='annees' size='8' name=annee id='text' type='text' class='form-control' placeholder='Année'>
		<input list='categories' size='15' name=categorie id='text' type='text' class='form-control' placeholder='Catégorie'>
		<button class='btn btn-info' type='submit'><span class='glyphicon glyphicon-search'></span> Rechercher</button>
	</div>
</form>";

print "</body>
</html>";

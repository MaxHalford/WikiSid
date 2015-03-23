#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;
use Time::HiRes qw(time);
#use open qw/:std :utf8/;

# On va mesurer le temps que prend la requête
my $t0 = time;

#########################
### Connexion MongoDB ###
#########################

# On se connecte à la base de données 
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On se connecte à l'index direct
my $direct = $db -> get_collection('Index direct');
# On fait en sorte que MongoDB renvoit des caractères UTF-8 décodés
$MongoDB::BSON::utf8_flag_on = 0;

###############
### Requête ###
###############

# On récupère la requête de l'utilisateur
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
# Si une donnée n'est pas précisée elle devient une expression régulière
my $jour = $formulaire{'jour'};
if ($jour eq '') {
	$jour = '.+';
}
my $mois = $formulaire{'mois'};

if ($mois eq '') {
	$mois = '.+';
}
my $annee = $formulaire{'annee'};
if ($annee eq '') {
	$annee = '.+';
}
my $categorie = $formulaire{'categorie'};
if ($categorie eq '') {
	$categorie = '.+';
}

# On la rentre dans MongoDB (expression régulière pour la ressemblance)
my $curseur = $direct -> find({'dateEcriture' => qr/$jour $mois $annee/, 'categories' => qr/$categorie/});
my @documents = ();

while (my $pointeur = $curseur -> next) {
	my %document = %$pointeur;
	push (@documents, $document{'_id'});
}

#################
### Affichage ###
#################

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

$categorie = "'$categorie'";
print"
</datalist>
<form align='center' class='form-inline well well-lg' action='./requeteAvancee.pl' method='get'>
	<div class='form-group'>
		<label class='sr-only' for='text'>Saisie</label>
		<input value=$jour list='jours' name=jour id='text' type='text' class='form-control'>
		<input value=$mois list='mois' name=mois id='text' type='text' class='form-control'>
		<input value=$annee list='annees' name=annee id='text' type='text' class='form-control'>
		<input value=$categorie list='categories' name=categorie id='text' type='text' placeholder=$categorie class='form-control'>
		<button class='btn btn-info' type='submit'><span class='glyphicon glyphicon-search'></span> Rechercher</button>
	</div>
</form>";

print"
<div align='center' class='container'>
	<div id='accordeon' class='panel-group col-lg-12'>";
my $itemCounter = 1;
foreach my $document (@documents) {
	open FILE, '<', 'stockage/bodies/'.$document.'.txt' or die $!;
	my @contenu = <FILE>;
	my $body = $contenu[0];
	my $item = 'item'.$itemCounter;
	$document = decode('UTF-8', decode('UTF-8', encode('UTF-8', $document)));
	print"
	<div class='panel panel-info'>
		<div align='left' class='panel-heading'> 
		<h4>
			<a href='#$item' data-parent='#accordeon' data-toggle='collapse'>$document</a> 
      	</h4>
      	</div>
      	<div id='$item' class='panel-collapse collapse'>
        	<div align='left' class='panel-body'>$body</div>
      	</div>
    </div>";
$itemCounter += 1;
}

print "</div>
</div>
</br>";

my $elapsed = time - $t0;
print "<center><h1><small>Temps: $elapsed ms.</small></h1></center>";

print"</body>
</html>";

